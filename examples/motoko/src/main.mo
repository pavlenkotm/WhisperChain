import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Hash "mo:base/Hash";

actor WhisperToken {
    // Types
    public type Subaccount = Blob;
    public type Account = {
        owner: Principal;
        subaccount: ?Subaccount;
    };

    public type TxIndex = Nat;

    public type TransferArgs = {
        from_subaccount: ?Subaccount;
        to: Account;
        amount: Nat;
        fee: ?Nat;
        memo: ?Blob;
        created_at_time: ?Nat64;
    };

    public type TransferError = {
        #BadFee: { expected_fee: Nat };
        #BadBurn: { min_burn_amount: Nat };
        #InsufficientFunds: { balance: Nat };
        #TooOld;
        #CreatedInFuture: { ledger_time: Nat64 };
        #Duplicate: { duplicate_of: TxIndex };
        #TemporarilyUnavailable;
        #GenericError: { error_code: Nat; message: Text };
    };

    // Token metadata
    private let name_ : Text = "WhisperToken";
    private let symbol_ : Text = "WSPR";
    private let decimals_ : Nat8 = 8;
    private let fee_ : Nat = 10_000;

    // Storage
    private stable var totalSupply_ : Nat = 0;
    private stable var owner_ : Principal = Principal.fromText("aaaaa-aa");

    private var balances = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);
    private var allowances = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Nat>>(10, Principal.equal, Principal.hash);

    // Initialize owner on deployment
    public shared(msg) func init() : async () {
        owner_ := msg.caller;
        let initialSupply = 1_000_000_000_000_000; // 10M tokens with 8 decimals
        balances.put(owner_, initialSupply);
        totalSupply_ := initialSupply;
    };

    // Token information functions
    public query func name() : async Text {
        return name_;
    };

    public query func symbol() : async Text {
        return symbol_;
    };

    public query func decimals() : async Nat8 {
        return decimals_;
    };

    public query func totalSupply() : async Nat {
        return totalSupply_;
    };

    public query func fee() : async Nat {
        return fee_;
    };

    // Balance queries
    public query func balanceOf(account: Principal) : async Nat {
        return _balanceOf(account);
    };

    private func _balanceOf(account: Principal) : Nat {
        switch (balances.get(account)) {
            case null { 0 };
            case (?balance) { balance };
        };
    };

    // Transfer function
    public shared(msg) func transfer(to: Principal, amount: Nat) : async Result.Result<TxIndex, TransferError> {
        let from = msg.caller;

        if (amount == 0) {
            return #err(#GenericError({ error_code = 1; message = "Amount must be greater than 0" }));
        };

        let fromBalance = _balanceOf(from);

        if (fromBalance < amount) {
            return #err(#InsufficientFunds({ balance = fromBalance }));
        };

        // Update balances
        balances.put(from, fromBalance - amount);

        let toBalance = _balanceOf(to);
        balances.put(to, toBalance + amount);

        return #ok(0); // Return transaction index (simplified)
    };

    // Approve spender
    public shared(msg) func approve(spender: Principal, amount: Nat) : async Bool {
        let owner = msg.caller;

        let ownerAllowances = switch (allowances.get(owner)) {
            case null {
                let newMap = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);
                allowances.put(owner, newMap);
                newMap;
            };
            case (?existing) { existing };
        };

        ownerAllowances.put(spender, amount);
        return true;
    };

    // Get allowance
    public query func allowance(owner: Principal, spender: Principal) : async Nat {
        switch (allowances.get(owner)) {
            case null { 0 };
            case (?ownerAllowances) {
                switch (ownerAllowances.get(spender)) {
                    case null { 0 };
                    case (?amount) { amount };
                };
            };
        };
    };

    // Transfer from (using allowance)
    public shared(msg) func transferFrom(from: Principal, to: Principal, amount: Nat) : async Result.Result<TxIndex, TransferError> {
        let spender = msg.caller;

        if (amount == 0) {
            return #err(#GenericError({ error_code = 1; message = "Amount must be greater than 0" }));
        };

        // Check allowance
        let currentAllowance = await allowance(from, spender);

        if (currentAllowance < amount) {
            return #err(#GenericError({
                error_code = 2;
                message = "Insufficient allowance"
            }));
        };

        // Check balance
        let fromBalance = _balanceOf(from);

        if (fromBalance < amount) {
            return #err(#InsufficientFunds({ balance = fromBalance }));
        };

        // Update balances
        balances.put(from, fromBalance - amount);

        let toBalance = _balanceOf(to);
        balances.put(to, toBalance + amount);

        // Update allowance
        let ownerAllowances = switch (allowances.get(from)) {
            case null {
                return #err(#GenericError({ error_code = 3; message = "Allowance not found" }));
            };
            case (?existing) { existing };
        };

        ownerAllowances.put(spender, currentAllowance - amount);

        return #ok(0);
    };

    // Mint tokens (owner only)
    public shared(msg) func mint(to: Principal, amount: Nat) : async Result.Result<TxIndex, TransferError> {
        if (msg.caller != owner_) {
            return #err(#GenericError({
                error_code = 100;
                message = "Only owner can mint tokens"
            }));
        };

        if (amount == 0) {
            return #err(#GenericError({ error_code = 1; message = "Amount must be greater than 0" }));
        };

        let toBalance = _balanceOf(to);
        balances.put(to, toBalance + amount);
        totalSupply_ += amount;

        return #ok(0);
    };

    // Burn tokens
    public shared(msg) func burn(amount: Nat) : async Result.Result<TxIndex, TransferError> {
        let from = msg.caller;

        if (amount == 0) {
            return #err(#GenericError({ error_code = 1; message = "Amount must be greater than 0" }));
        };

        let fromBalance = _balanceOf(from);

        if (fromBalance < amount) {
            return #err(#InsufficientFunds({ balance = fromBalance }));
        };

        balances.put(from, fromBalance - amount);
        totalSupply_ -= amount;

        return #ok(0);
    };

    // Get owner
    public query func owner() : async Principal {
        return owner_;
    };

    // Get all holders (for testing/admin purposes)
    public query func getHolders() : async [(Principal, Nat)] {
        return Iter.toArray(balances.entries());
    };
}
