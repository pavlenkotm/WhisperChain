module whisper_addr::simple_coin {
    use std::signer;
    use std::string;
    use aptos_framework::coin;

    /// Error codes
    const ENOT_OWNER: u64 = 1;
    const EALREADY_INITIALIZED: u64 = 2;
    const EINSUFFICIENT_BALANCE: u64 = 3;

    /// Coin type for WhisperCoin
    struct WhisperCoin has key {}

    /// Capabilities stored under owner account
    struct Capabilities has key {
        mint_cap: coin::MintCapability<WhisperCoin>,
        freeze_cap: coin::FreezeCapability<WhisperCoin>,
        burn_cap: coin::BurnCapability<WhisperCoin>,
    }

    /// Initialize the WhisperCoin
    /// Can only be called once by the module publisher
    public entry fun initialize(account: &signer) {
        let addr = signer::address_of(account);

        // Ensure not already initialized
        assert!(!exists<Capabilities>(addr), EALREADY_INITIALIZED);

        // Initialize coin with metadata
        let (burn_cap, freeze_cap, mint_cap) = coin::initialize<WhisperCoin>(
            account,
            string::utf8(b"Whisper Coin"),
            string::utf8(b"WHSP"),
            8, // decimals
            true, // monitor_supply
        );

        // Store capabilities
        move_to(account, Capabilities {
            mint_cap,
            freeze_cap,
            burn_cap,
        });
    }

    /// Register account to receive WhisperCoin
    public entry fun register(account: &signer) {
        coin::register<WhisperCoin>(account);
    }

    /// Mint new coins (only owner can mint)
    public entry fun mint(
        owner: &signer,
        recipient: address,
        amount: u64
    ) acquires Capabilities {
        let owner_addr = signer::address_of(owner);
        assert!(exists<Capabilities>(owner_addr), ENOT_OWNER);

        let caps = borrow_global<Capabilities>(owner_addr);
        let coins = coin::mint<WhisperCoin>(amount, &caps.mint_cap);
        coin::deposit(recipient, coins);
    }

    /// Transfer coins from sender to recipient
    public entry fun transfer(
        from: &signer,
        to: address,
        amount: u64
    ) {
        coin::transfer<WhisperCoin>(from, to, amount);
    }

    /// Burn coins from sender's account
    public entry fun burn(
        account: &signer,
        amount: u64
    ) acquires Capabilities {
        let owner_addr = @whisper_addr;
        assert!(exists<Capabilities>(owner_addr), ENOT_OWNER);

        let caps = borrow_global<Capabilities>(owner_addr);
        let coins = coin::withdraw<WhisperCoin>(account, amount);
        coin::burn(coins, &caps.burn_cap);
    }

    /// Get balance of an account
    public fun balance_of(account: address): u64 {
        coin::balance<WhisperCoin>(account)
    }

    #[view]
    /// View function to get balance
    public fun get_balance(account: address): u64 {
        balance_of(account)
    }

    #[test_only]
    use aptos_framework::account;

    #[test(owner = @whisper_addr, user = @0x456)]
    fun test_mint_and_transfer(owner: &signer, user: &signer) acquires Capabilities {
        // Setup accounts
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user));

        // Initialize coin
        initialize(owner);

        // Register user
        register(user);

        // Mint coins to user
        let mint_amount = 1000;
        mint(owner, signer::address_of(user), mint_amount);

        // Verify balance
        assert!(balance_of(signer::address_of(user)) == mint_amount, 1);

        // Transfer some coins back to owner
        register(owner);
        let transfer_amount = 300;
        transfer(user, signer::address_of(owner), transfer_amount);

        // Verify balances
        assert!(balance_of(signer::address_of(user)) == mint_amount - transfer_amount, 2);
        assert!(balance_of(signer::address_of(owner)) == transfer_amount, 3);
    }

    #[test(owner = @whisper_addr, user = @0x456)]
    fun test_burn(owner: &signer, user: &signer) acquires Capabilities {
        // Setup
        account::create_account_for_test(signer::address_of(owner));
        account::create_account_for_test(signer::address_of(user));

        initialize(owner);
        register(user);

        // Mint and burn
        let mint_amount = 1000;
        mint(owner, signer::address_of(user), mint_amount);

        let burn_amount = 400;
        burn(user, burn_amount);

        // Verify balance after burn
        assert!(balance_of(signer::address_of(user)) == mint_amount - burn_amount, 1);
    }
}
