#![cfg_attr(not(feature = "std"), no_std)]

/// Substrate Pallet for WhisperChain
/// Decentralized messaging on Substrate-based chains
pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
    use frame_support::{dispatch::DispatchResult, pallet_prelude::*};
    use frame_system::pallet_prelude::*;
    use sp_std::vec::Vec;

    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
    }

    #[pallet::storage]
    #[pallet::getter(fn messages)]
    pub type Messages<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        T::AccountId,
        Vec<MessageData<T::AccountId>>,
        ValueQuery,
    >;

    #[derive(Encode, Decode, Clone, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    #[scale_info(skip_type_params(T))]
    pub struct MessageData<AccountId> {
        pub sender: AccountId,
        pub content: BoundedVec<u8, ConstU32<256>>,
        pub timestamp: u64,
    }

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        MessageSent {
            from: T::AccountId,
            to: T::AccountId,
            content: Vec<u8>,
        },
        MessageDeleted {
            account: T::AccountId,
            index: u32,
        },
    }

    #[pallet::error]
    pub enum Error<T> {
        MessageTooLong,
        MessageNotFound,
        Unauthorized,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Send an encrypted message
        #[pallet::weight(10_000)]
        #[pallet::call_index(0)]
        pub fn send_message(
            origin: OriginFor<T>,
            to: T::AccountId,
            content: Vec<u8>,
        ) -> DispatchResult {
            let sender = ensure_signed(origin)?;

            ensure!(content.len() <= 256, Error::<T>::MessageTooLong);

            let bounded_content = BoundedVec::<u8, ConstU32<256>>::try_from(content.clone())
                .map_err(|_| Error::<T>::MessageTooLong)?;

            let message = MessageData {
                sender: sender.clone(),
                content: bounded_content,
                timestamp: <frame_system::Pallet<T>>::block_number().saturated_into(),
            };

            Messages::<T>::mutate(&to, |messages| {
                messages.push(message);
            });

            Self::deposit_event(Event::MessageSent {
                from: sender,
                to,
                content,
            });

            Ok(())
        }

        /// Delete a message
        #[pallet::weight(10_000)]
        #[pallet::call_index(1)]
        pub fn delete_message(
            origin: OriginFor<T>,
            index: u32,
        ) -> DispatchResult {
            let account = ensure_signed(origin)?;

            Messages::<T>::try_mutate(&account, |messages| -> DispatchResult {
                ensure!(
                    (index as usize) < messages.len(),
                    Error::<T>::MessageNotFound
                );

                messages.remove(index as usize);

                Self::deposit_event(Event::MessageDeleted { account: account.clone(), index });

                Ok(())
            })
        }
    }
}
