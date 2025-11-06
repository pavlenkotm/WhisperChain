use borsh::{BorshDeserialize, BorshSerialize};

#[derive(BorshSerialize, BorshDeserialize, Debug, Clone)]
pub enum WhisperChainInstruction {
    /// Initialize a new chat between two participants
    ///
    /// Accounts expected:
    /// 0. `[writable, signer]` Chat initializer (payer)
    /// 1. `[writable]` Chat account (PDA)
    /// 2. `[]` System program
    InitializeChat {
        /// Public key for Diffie-Hellman exchange (32 bytes)
        public_key: [u8; 32],
    },

    /// Send an encrypted message to a chat
    ///
    /// Accounts expected:
    /// 0. `[writable, signer]` Message sender (payer)
    /// 1. `[writable]` Chat account
    /// 2. `[writable]` Message account (PDA)
    /// 3. `[]` System program
    /// 4. `[]` Clock sysvar
    SendMessage {
        /// Encrypted message data (max 512 bytes)
        encrypted_data: Vec<u8>,
        /// Ephemeral public key for this message (32 bytes)
        ephemeral_public_key: [u8; 32],
        /// Message timestamp
        timestamp: i64,
        /// Optional expiration timestamp (0 = never expires)
        expires_at: i64,
    },

    /// Delete a chat and all associated data
    ///
    /// Accounts expected:
    /// 0. `[writable, signer]` Chat participant
    /// 1. `[writable]` Chat account
    DeleteChat,

    /// Delete a specific message (self-destruct)
    ///
    /// Accounts expected:
    /// 0. `[writable, signer]` Message sender
    /// 1. `[writable]` Message account
    /// 2. `[]` Chat account
    /// 3. `[]` Clock sysvar
    DeleteMessage,
}
