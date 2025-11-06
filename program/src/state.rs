use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::pubkey::Pubkey;

/// Maximum size for encrypted message data (512 bytes)
pub const MAX_MESSAGE_SIZE: usize = 512;

/// Chat account state
#[derive(BorshSerialize, BorshDeserialize, Debug, Clone)]
pub struct Chat {
    /// Is this chat initialized
    pub is_initialized: bool,

    /// First participant
    pub participant1: Pubkey,

    /// Second participant
    pub participant2: Pubkey,

    /// Public key of participant 1 for DH exchange
    pub participant1_public_key: [u8; 32],

    /// Public key of participant 2 for DH exchange (set when they join)
    pub participant2_public_key: [u8; 32],

    /// Chat creation timestamp
    pub created_at: i64,

    /// Total messages in this chat
    pub message_count: u64,

    /// Last message timestamp
    pub last_message_at: i64,
}

impl Chat {
    pub const LEN: usize = 1 + // is_initialized
        32 + // participant1
        32 + // participant2
        32 + // participant1_public_key
        32 + // participant2_public_key
        8 +  // created_at
        8 +  // message_count
        8;   // last_message_at

    pub fn is_participant(&self, pubkey: &Pubkey) -> bool {
        self.participant1 == *pubkey || self.participant2 == *pubkey
    }
}

/// Message account state
#[derive(BorshSerialize, BorshDeserialize, Debug, Clone)]
pub struct Message {
    /// Is this message initialized
    pub is_initialized: bool,

    /// Associated chat account
    pub chat: Pubkey,

    /// Message sender
    pub sender: Pubkey,

    /// Message index in the chat
    pub index: u64,

    /// Message timestamp
    pub timestamp: i64,

    /// Expiration timestamp (0 = never expires)
    pub expires_at: i64,

    /// Ephemeral public key for this message
    pub ephemeral_public_key: [u8; 32],

    /// Encrypted message data
    pub encrypted_data: Vec<u8>,
}

impl Message {
    /// Calculate the space needed for a message with given data size
    pub fn space(data_size: usize) -> usize {
        1 +  // is_initialized
        32 + // chat
        32 + // sender
        8 +  // index
        8 +  // timestamp
        8 +  // expires_at
        32 + // ephemeral_public_key
        4 + data_size // encrypted_data (vec has 4 byte length prefix)
    }

    pub fn is_expired(&self, current_timestamp: i64) -> bool {
        self.expires_at > 0 && current_timestamp >= self.expires_at
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_chat_len() {
        let chat = Chat {
            is_initialized: true,
            participant1: Pubkey::default(),
            participant2: Pubkey::default(),
            participant1_public_key: [0u8; 32],
            participant2_public_key: [0u8; 32],
            created_at: 0,
            message_count: 0,
            last_message_at: 0,
        };

        let serialized = chat.try_to_vec().unwrap();
        assert_eq!(serialized.len(), Chat::LEN);
    }

    #[test]
    fn test_message_space() {
        let data_size = 256;
        let space = Message::space(data_size);

        let message = Message {
            is_initialized: true,
            chat: Pubkey::default(),
            sender: Pubkey::default(),
            index: 0,
            timestamp: 0,
            expires_at: 0,
            ephemeral_public_key: [0u8; 32],
            encrypted_data: vec![0u8; data_size],
        };

        let serialized = message.try_to_vec().unwrap();
        assert_eq!(serialized.len(), space);
    }
}
