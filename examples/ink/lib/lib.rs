#![cfg_attr(not(feature = "std"), no_std, no_main)]

#[ink::contract]
mod whisper_token {
    use ink::storage::Mapping;

    /// ERC-20 Token for Polkadot/Substrate using ink!
    #[ink(storage)]
    pub struct WhisperToken {
        /// Total token supply
        total_supply: Balance,
        /// Mapping from account to balance
        balances: Mapping<AccountId, Balance>,
        /// Mapping from (owner, spender) to allowance
        allowances: Mapping<(AccountId, AccountId), Balance>,
    }

    /// Event emitted when tokens are transferred
    #[ink(event)]
    pub struct Transfer {
        #[ink(topic)]
        from: Option<AccountId>,
        #[ink(topic)]
        to: Option<AccountId>,
        value: Balance,
    }

    /// Event emitted when an approval occurs
    #[ink(event)]
    pub struct Approval {
        #[ink(topic)]
        owner: AccountId,
        #[ink(topic)]
        spender: AccountId,
        value: Balance,
    }

    /// Errors that can occur upon calling this contract
    #[derive(Debug, PartialEq, Eq, scale::Encode, scale::Decode)]
    #[cfg_attr(feature = "std", derive(scale_info::TypeInfo))]
    pub enum Error {
        /// Insufficient balance for transfer
        InsufficientBalance,
        /// Insufficient allowance for transfer
        InsufficientAllowance,
    }

    /// Type alias for the contract's result type
    pub type Result<T> = core::result::Result<T, Error>;

    impl WhisperToken {
        /// Creates a new ERC-20 contract with the specified initial supply
        #[ink(constructor)]
        pub fn new(total_supply: Balance) -> Self {
            let mut balances = Mapping::default();
            let caller = Self::env().caller();
            balances.insert(caller, &total_supply);

            Self::env().emit_event(Transfer {
                from: None,
                to: Some(caller),
                value: total_supply,
            });

            Self {
                total_supply,
                balances,
                allowances: Default::default(),
            }
        }

        /// Returns the total token supply
        #[ink(message)]
        pub fn total_supply(&self) -> Balance {
            self.total_supply
        }

        /// Returns the account balance for the specified `owner`
        #[ink(message)]
        pub fn balance_of(&self, owner: AccountId) -> Balance {
            self.balances.get(owner).unwrap_or(0)
        }

        /// Returns the allowance for a `spender` approved by an `owner`
        #[ink(message)]
        pub fn allowance(&self, owner: AccountId, spender: AccountId) -> Balance {
            self.allowances.get((owner, spender)).unwrap_or(0)
        }

        /// Transfers `value` amount of tokens from the caller to `to`
        #[ink(message)]
        pub fn transfer(&mut self, to: AccountId, value: Balance) -> Result<()> {
            let from = self.env().caller();
            self.transfer_from_to(&from, &to, value)
        }

        /// Approves `spender` to spend `value` amount of tokens on behalf of caller
        #[ink(message)]
        pub fn approve(&mut self, spender: AccountId, value: Balance) -> Result<()> {
            let owner = self.env().caller();
            self.allowances.insert((owner, spender), &value);

            self.env().emit_event(Approval {
                owner,
                spender,
                value,
            });

            Ok(())
        }

        /// Transfers `value` tokens from `from` to `to` using the allowance mechanism
        #[ink(message)]
        pub fn transfer_from(
            &mut self,
            from: AccountId,
            to: AccountId,
            value: Balance,
        ) -> Result<()> {
            let caller = self.env().caller();
            let allowance = self.allowance(from, caller);

            if allowance < value {
                return Err(Error::InsufficientAllowance);
            }

            self.transfer_from_to(&from, &to, value)?;

            // Decrease allowance
            self.allowances
                .insert((from, caller), &(allowance - value));

            Ok(())
        }

        /// Internal transfer helper
        fn transfer_from_to(
            &mut self,
            from: &AccountId,
            to: &AccountId,
            value: Balance,
        ) -> Result<()> {
            let from_balance = self.balance_of(*from);

            if from_balance < value {
                return Err(Error::InsufficientBalance);
            }

            self.balances.insert(from, &(from_balance - value));

            let to_balance = self.balance_of(*to);
            self.balances.insert(to, &(to_balance + value));

            self.env().emit_event(Transfer {
                from: Some(*from),
                to: Some(*to),
                value,
            });

            Ok(())
        }
    }

    #[cfg(test)]
    mod tests {
        use super::*;

        #[ink::test]
        fn new_works() {
            let contract = WhisperToken::new(1000);
            assert_eq!(contract.total_supply(), 1000);
        }

        #[ink::test]
        fn balance_works() {
            let contract = WhisperToken::new(100);
            assert_eq!(contract.total_supply(), 100);
            assert_eq!(contract.balance_of(AccountId::from([0x1; 32])), 100);
        }

        #[ink::test]
        fn transfer_works() {
            let mut contract = WhisperToken::new(100);
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert_eq!(contract.balance_of(accounts.alice), 100);
            assert!(contract.transfer(accounts.bob, 10).is_ok());
            assert_eq!(contract.balance_of(accounts.bob), 10);
            assert_eq!(contract.balance_of(accounts.alice), 90);
        }

        #[ink::test]
        fn transfer_fails_insufficient_balance() {
            let mut contract = WhisperToken::new(100);
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            let result = contract.transfer(accounts.bob, 101);
            assert_eq!(result, Err(Error::InsufficientBalance));
        }

        #[ink::test]
        fn approve_works() {
            let mut contract = WhisperToken::new(100);
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert!(contract.approve(accounts.bob, 20).is_ok());
            assert_eq!(contract.allowance(accounts.alice, accounts.bob), 20);
        }

        #[ink::test]
        fn transfer_from_works() {
            let mut contract = WhisperToken::new(100);
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert!(contract.approve(accounts.bob, 20).is_ok());

            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);

            assert!(contract.transfer_from(accounts.alice, accounts.charlie, 10).is_ok());
            assert_eq!(contract.balance_of(accounts.charlie), 10);
            assert_eq!(contract.balance_of(accounts.alice), 90);
            assert_eq!(contract.allowance(accounts.alice, accounts.bob), 10);
        }

        #[ink::test]
        fn transfer_from_fails_insufficient_allowance() {
            let mut contract = WhisperToken::new(100);
            let accounts = ink::env::test::default_accounts::<ink::env::DefaultEnvironment>();

            assert!(contract.approve(accounts.bob, 20).is_ok());

            ink::env::test::set_caller::<ink::env::DefaultEnvironment>(accounts.bob);

            let result = contract.transfer_from(accounts.alice, accounts.charlie, 25);
            assert_eq!(result, Err(Error::InsufficientAllowance));
        }
    }
}
