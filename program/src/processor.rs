use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint::ProgramResult,
    msg,
    program::{invoke, invoke_signed},
    program_error::ProgramError,
    pubkey::Pubkey,
    rent::Rent,
    system_instruction,
    sysvar::Sysvar,
    clock::Clock,
};
use borsh::{BorshDeserialize, BorshSerialize};

use crate::error::WhisperChainError;
use crate::state::{Chat, Message, MAX_MESSAGE_SIZE};

pub struct Processor;

impl Processor {
    pub fn process_initialize_chat(
        program_id: &Pubkey,
        accounts: &[AccountInfo],
        public_key: [u8; 32],
    ) -> ProgramResult {
        let accounts_iter = &mut accounts.iter();

        let initializer = next_account_info(accounts_iter)?;
        let chat_account = next_account_info(accounts_iter)?;
        let system_program = next_account_info(accounts_iter)?;

        if !initializer.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        // Verify the chat account is a PDA
        let (chat_pda, chat_bump) = Pubkey::find_program_address(
            &[
                b"chat",
                initializer.key.as_ref(),
            ],
            program_id,
        );

        if chat_pda != *chat_account.key {
            msg!("Error: Chat account is not the correct PDA");
            return Err(ProgramError::InvalidAccountData);
        }

        // Create the chat account
        let rent = Rent::get()?;
        let space = Chat::LEN;
        let lamports = rent.minimum_balance(space);

        invoke_signed(
            &system_instruction::create_account(
                initializer.key,
                chat_account.key,
                lamports,
                space as u64,
                program_id,
            ),
            &[
                initializer.clone(),
                chat_account.clone(),
                system_program.clone(),
            ],
            &[&[
                b"chat",
                initializer.key.as_ref(),
                &[chat_bump],
            ]],
        )?;

        // Initialize the chat data
        let clock = Clock::get()?;
        let mut chat = Chat {
            is_initialized: true,
            participant1: *initializer.key,
            participant2: Pubkey::default(), // Will be set when someone sends first message
            participant1_public_key: public_key,
            participant2_public_key: [0u8; 32],
            created_at: clock.unix_timestamp,
            message_count: 0,
            last_message_at: 0,
        };

        chat.serialize(&mut &mut chat_account.data.borrow_mut()[..])?;

        msg!("Chat initialized successfully");
        Ok(())
    }

    pub fn process_send_message(
        program_id: &Pubkey,
        accounts: &[AccountInfo],
        encrypted_data: Vec<u8>,
        ephemeral_public_key: [u8; 32],
        timestamp: i64,
        expires_at: i64,
    ) -> ProgramResult {
        let accounts_iter = &mut accounts.iter();

        let sender = next_account_info(accounts_iter)?;
        let chat_account = next_account_info(accounts_iter)?;
        let message_account = next_account_info(accounts_iter)?;
        let system_program = next_account_info(accounts_iter)?;

        if !sender.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        // Validate encrypted data size
        if encrypted_data.len() > MAX_MESSAGE_SIZE {
            return Err(WhisperChainError::DataTooLarge.into());
        }

        // Deserialize and validate chat account
        if chat_account.owner != program_id {
            return Err(WhisperChainError::InvalidAccountOwner.into());
        }

        let mut chat = Chat::try_from_slice(&chat_account.data.borrow())?;

        if !chat.is_initialized {
            return Err(WhisperChainError::NotInitialized.into());
        }

        // If this is the first message from participant2, set them up
        if chat.participant2 == Pubkey::default() && chat.participant1 != *sender.key {
            chat.participant2 = *sender.key;
            chat.participant2_public_key = ephemeral_public_key;
        } else if !chat.is_participant(sender.key) {
            return Err(WhisperChainError::NotAuthorized.into());
        }

        let message_index = chat.message_count;

        // Create PDA for message
        let (message_pda, message_bump) = Pubkey::find_program_address(
            &[
                b"message",
                chat_account.key.as_ref(),
                &message_index.to_le_bytes(),
            ],
            program_id,
        );

        if message_pda != *message_account.key {
            msg!("Error: Message account is not the correct PDA");
            return Err(ProgramError::InvalidAccountData);
        }

        // Create the message account
        let rent = Rent::get()?;
        let space = Message::space(encrypted_data.len());
        let lamports = rent.minimum_balance(space);

        invoke_signed(
            &system_instruction::create_account(
                sender.key,
                message_account.key,
                lamports,
                space as u64,
                program_id,
            ),
            &[
                sender.clone(),
                message_account.clone(),
                system_program.clone(),
            ],
            &[&[
                b"message",
                chat_account.key.as_ref(),
                &message_index.to_le_bytes(),
                &[message_bump],
            ]],
        )?;

        // Initialize message data
        let message = Message {
            is_initialized: true,
            chat: *chat_account.key,
            sender: *sender.key,
            index: message_index,
            timestamp,
            expires_at,
            ephemeral_public_key,
            encrypted_data,
        };

        message.serialize(&mut &mut message_account.data.borrow_mut()[..])?;

        // Update chat metadata
        chat.message_count += 1;
        chat.last_message_at = timestamp;
        chat.serialize(&mut &mut chat_account.data.borrow_mut()[..])?;

        msg!("Message sent successfully. Index: {}", message_index);
        Ok(())
    }

    pub fn process_delete_chat(
        program_id: &Pubkey,
        accounts: &[AccountInfo],
    ) -> ProgramResult {
        let accounts_iter = &mut accounts.iter();

        let participant = next_account_info(accounts_iter)?;
        let chat_account = next_account_info(accounts_iter)?;

        if !participant.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        if chat_account.owner != program_id {
            return Err(WhisperChainError::InvalidAccountOwner.into());
        }

        let chat = Chat::try_from_slice(&chat_account.data.borrow())?;

        if !chat.is_initialized {
            return Err(WhisperChainError::NotInitialized.into());
        }

        if !chat.is_participant(participant.key) {
            return Err(WhisperChainError::NotAuthorized.into());
        }

        // Close the account and transfer lamports back to participant
        let dest_starting_lamports = participant.lamports();
        **participant.lamports.borrow_mut() = dest_starting_lamports
            .checked_add(chat_account.lamports())
            .ok_or(ProgramError::ArithmeticOverflow)?;
        **chat_account.lamports.borrow_mut() = 0;

        // Zero out the data
        let mut chat_data = chat_account.data.borrow_mut();
        chat_data.fill(0);

        msg!("Chat deleted successfully");
        Ok(())
    }

    pub fn process_delete_message(
        program_id: &Pubkey,
        accounts: &[AccountInfo],
    ) -> ProgramResult {
        let accounts_iter = &mut accounts.iter();

        let sender = next_account_info(accounts_iter)?;
        let message_account = next_account_info(accounts_iter)?;
        let chat_account = next_account_info(accounts_iter)?;
        let clock_account = next_account_info(accounts_iter)?;

        if !sender.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        if message_account.owner != program_id {
            return Err(WhisperChainError::InvalidAccountOwner.into());
        }

        let message = Message::try_from_slice(&message_account.data.borrow())?;

        if !message.is_initialized {
            return Err(WhisperChainError::NotInitialized.into());
        }

        // Verify the message belongs to this chat
        if message.chat != *chat_account.key {
            return Err(ProgramError::InvalidAccountData);
        }

        // Only the sender can delete their message
        if message.sender != *sender.key {
            return Err(WhisperChainError::NotAuthorized.into());
        }

        // Check if message has expired (auto-delete)
        let clock = Clock::from_account_info(clock_account)?;
        if message.is_expired(clock.unix_timestamp) {
            msg!("Message expired, auto-deleting");
        }

        // Close the account and transfer lamports back to sender
        let dest_starting_lamports = sender.lamports();
        **sender.lamports.borrow_mut() = dest_starting_lamports
            .checked_add(message_account.lamports())
            .ok_or(ProgramError::ArithmeticOverflow)?;
        **message_account.lamports.borrow_mut() = 0;

        // Zero out the data
        let mut message_data = message_account.data.borrow_mut();
        message_data.fill(0);

        msg!("Message deleted successfully");
        Ok(())
    }
}
