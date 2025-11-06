use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
    rent::Rent,
    sysvar::Sysvar,
    program::invoke,
    system_instruction,
    clock::Clock,
};
use borsh::{BorshDeserialize, BorshSerialize};

pub mod error;
pub mod instruction;
pub mod state;
pub mod processor;

use instruction::WhisperChainInstruction;
use processor::Processor;

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    let instruction = WhisperChainInstruction::try_from_slice(instruction_data)
        .map_err(|_| ProgramError::InvalidInstructionData)?;

    match instruction {
        WhisperChainInstruction::InitializeChat { public_key } => {
            msg!("Instruction: InitializeChat");
            Processor::process_initialize_chat(program_id, accounts, public_key)
        }
        WhisperChainInstruction::SendMessage { encrypted_data, ephemeral_public_key, timestamp, expires_at } => {
            msg!("Instruction: SendMessage");
            Processor::process_send_message(
                program_id,
                accounts,
                encrypted_data,
                ephemeral_public_key,
                timestamp,
                expires_at,
            )
        }
        WhisperChainInstruction::DeleteChat => {
            msg!("Instruction: DeleteChat");
            Processor::process_delete_chat(program_id, accounts)
        }
        WhisperChainInstruction::DeleteMessage => {
            msg!("Instruction: DeleteMessage");
            Processor::process_delete_message(program_id, accounts)
        }
    }
}
