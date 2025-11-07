// SPDX-License-Identifier: MIT
// WhisperToken - ERC-20 Token on StarkNet

#[contract]
mod WhisperToken {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap::<ContractAddress, u256>,
        allowances: LegacyMap::<(ContractAddress, ContractAddress), u256>,
    }

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, value: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, spender: ContractAddress, value: u256) {}

    #[constructor]
    fn constructor(
        name: felt252,
        symbol: felt252,
        decimals: u8,
        initial_supply: u256,
        recipient: ContractAddress
    ) {
        name::write(name);
        symbol::write(symbol);
        decimals::write(decimals);
        total_supply::write(initial_supply);
        balances::write(recipient, initial_supply);

        Transfer(ContractAddress::zero(), recipient, initial_supply);
    }

    #[view]
    fn get_name() -> felt252 {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt252 {
        symbol::read()
    }

    #[view]
    fn get_decimals() -> u8 {
        decimals::read()
    }

    #[view]
    fn get_total_supply() -> u256 {
        total_supply::read()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        balances::read(account)
    }

    #[view]
    fn allowance(owner: ContractAddress, spender: ContractAddress) -> u256 {
        allowances::read((owner, spender))
    }

    #[external]
    fn transfer(recipient: ContractAddress, amount: u256) -> bool {
        let sender = get_caller_address();
        _transfer(sender, recipient, amount);
        true
    }

    #[external]
    fn approve(spender: ContractAddress, amount: u256) -> bool {
        let owner = get_caller_address();
        allowances::write((owner, spender), amount);
        Approval(owner, spender, amount);
        true
    }

    #[external]
    fn transfer_from(
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    ) -> bool {
        let caller = get_caller_address();
        let current_allowance = allowances::read((sender, caller));

        assert(current_allowance >= amount, 'Insufficient allowance');

        allowances::write((sender, caller), current_allowance - amount);
        _transfer(sender, recipient, amount);

        true
    }

    fn _transfer(
        sender: ContractAddress,
        recipient: ContractAddress,
        amount: u256
    ) {
        let sender_balance = balances::read(sender);
        assert(sender_balance >= amount, 'Insufficient balance');

        balances::write(sender, sender_balance - amount);

        let recipient_balance = balances::read(recipient);
        balances::write(recipient, recipient_balance + amount);

        Transfer(sender, recipient, amount);
    }
}
