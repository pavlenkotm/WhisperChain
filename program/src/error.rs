use solana_program::program_error::ProgramError;
use thiserror::Error;

#[derive(Error, Debug, Copy, Clone)]
pub enum WhisperChainError {
    #[error("Invalid instruction")]
    InvalidInstruction,

    #[error("Not authorized")]
    NotAuthorized,

    #[error("Account not initialized")]
    NotInitialized,

    #[error("Account already initialized")]
    AlreadyInitialized,

    #[error("Invalid account owner")]
    InvalidAccountOwner,

    #[error("Message expired")]
    MessageExpired,

    #[error("Invalid public key")]
    InvalidPublicKey,

    #[error("Data too large")]
    DataTooLarge,
}

impl From<WhisperChainError> for ProgramError {
    fn from(e: WhisperChainError) -> Self {
        ProgramError::Custom(e as u32)
    }
}
