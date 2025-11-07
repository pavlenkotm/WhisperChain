# 🚀 Move Smart Contracts (Aptos)

Move language smart contracts for the Aptos blockchain showcasing resource-oriented programming.

## 🎯 What is Move?

Move is a safe and flexible programming language for blockchain applications:
- **Resource-Oriented**: Assets are first-class citizens
- **Memory Safe**: No null/dangling pointers
- **Flexible**: Modules and generics support
- **Originally created by Facebook** for the Diem (Libra) project

## 📋 Modules

### 1. Simple Coin
- **File**: `sources/simple_coin.move`
- **Features**:
  - ✅ Custom coin creation using Aptos Framework
  - ✅ Minting with owner capabilities
  - ✅ Transfer functionality
  - ✅ Burn mechanism
  - ✅ Balance queries
  - ✅ Built-in tests

### 2. Message Board
- **File**: `sources/message_board.move`
- **Features**:
  - ✅ Decentralized message posting
  - ✅ Message storage per account
  - ✅ Delete messages
  - ✅ Event emission
  - ✅ View functions
  - ✅ Timestamp tracking

## 🚀 Quick Start

### Prerequisites
```bash
# Install Aptos CLI
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3

# Verify installation
aptos --version
```

### Initialize Aptos Account
```bash
# Create new account
aptos init --network testnet

# This creates ~/.aptos/config.yaml with your account info
```

### Compile Contracts
```bash
cd examples/move-aptos

# Compile all modules
aptos move compile

# Compile with specific address
aptos move compile --named-addresses whisper_addr=0x123
```

### Run Tests
```bash
# Run all tests
aptos move test

# Run with coverage
aptos move test --coverage

# Run specific test
aptos move test --filter test_mint_and_transfer
```

Expected output:
```
Running Move unit tests
[ PASS    ] 0x123::simple_coin::test_mint_and_transfer
[ PASS    ] 0x123::simple_coin::test_burn
[ PASS    ] 0x123::message_board::test_post_and_read_message
[ PASS    ] 0x123::message_board::test_delete_message

Test result: OK. Total tests: 4; passed: 4; failed: 0
```

## 📦 Deployment

### Deploy to Testnet
```bash
# Fund your account with testnet tokens
aptos account fund-with-faucet --account default

# Compile and publish
aptos move publish --named-addresses whisper_addr=default

# Example output:
# {
#   "Result": {
#     "transaction_hash": "0x...",
#     "gas_used": 1234,
#     "vm_status": "Executed successfully"
#   }
# }
```

### Deploy to Mainnet
```bash
# Switch to mainnet
aptos init --network mainnet

# Publish (costs real APT)
aptos move publish --named-addresses whisper_addr=default
```

## 📖 Usage Examples

### Interacting with SimpleCoin

```bash
# Initialize the coin
aptos move run \
  --function-id 'YOUR_ADDRESS::simple_coin::initialize' \
  --assume-yes

# Register to receive coins
aptos move run \
  --function-id 'YOUR_ADDRESS::simple_coin::register' \
  --assume-yes

# Mint coins
aptos move run \
  --function-id 'YOUR_ADDRESS::simple_coin::mint' \
  --args address:RECIPIENT_ADDRESS u64:1000000 \
  --assume-yes

# Transfer coins
aptos move run \
  --function-id 'YOUR_ADDRESS::simple_coin::transfer' \
  --args address:RECIPIENT_ADDRESS u64:500 \
  --assume-yes

# Check balance
aptos move view \
  --function-id 'YOUR_ADDRESS::simple_coin::get_balance' \
  --args address:ACCOUNT_ADDRESS
```

### Interacting with MessageBoard

```bash
# Initialize message board
aptos move run \
  --function-id 'YOUR_ADDRESS::message_board::initialize' \
  --assume-yes

# Post a message
aptos move run \
  --function-id 'YOUR_ADDRESS::message_board::post_message' \
  --args string:"Hello, Aptos!" \
  --assume-yes

# View messages
aptos move view \
  --function-id 'YOUR_ADDRESS::message_board::get_messages' \
  --args address:YOUR_ADDRESS

# Delete a message (by ID)
aptos move run \
  --function-id 'YOUR_ADDRESS::message_board::delete_message' \
  --args u64:0 \
  --assume-yes
```

## 🧪 Testing

### Unit Tests
All modules include comprehensive tests:

```bash
# Run tests with verbose output
aptos move test -v

# Generate coverage report
aptos move test --coverage
aptos move coverage summary

# View coverage for specific module
aptos move coverage source --module simple_coin
```

### Integration Testing
```bash
# Test on local testnet
aptos node run-local-testnet --with-faucet

# Deploy and test
aptos move publish --named-addresses whisper_addr=default
```

## 🔐 Security Features

Move provides inherent security advantages:

- ✅ **Resource Safety**: Assets can't be copied or dropped accidentally
- ✅ **Type Safety**: Strong static typing
- ✅ **Memory Safety**: No null/dangling pointers
- ✅ **Formal Verification**: Move Prover for mathematical verification
- ✅ **Capability-Based Security**: Explicit permissions
- ✅ **Module Verification**: Bytecode verification on-chain

### Move Prover (Advanced)
```bash
# Install Move Prover
./scripts/dev_setup.sh -yp

# Verify module
aptos move prove
```

## 📊 Gas Optimization

Tips for optimizing gas costs:

1. **Minimize storage**: Use references where possible
2. **Batch operations**: Combine multiple calls
3. **Use view functions**: For read-only operations
4. **Efficient data structures**: Choose appropriate types

## 📚 Resources

- [Aptos Documentation](https://aptos.dev/)
- [Move Book](https://move-language.github.io/move/)
- [Move Tutorial](https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples)
- [Aptos TypeScript SDK](https://github.com/aptos-labs/aptos-ts-sdk)
- [Move Prover Guide](https://github.com/move-language/move/tree/main/language/move-prover)

## 🔍 Key Concepts

### Resources
```move
struct MyCoin has key {
    value: u64
}
// `has key` means it's a resource stored in global storage
```

### Abilities
- `copy`: Can be copied
- `drop`: Can be dropped/destroyed
- `store`: Can be stored in structs
- `key`: Can be used as a key in global storage

### Capabilities Pattern
```move
struct MintCapability has key, store {}
// Capabilities control who can perform privileged operations
```

## 🤝 Contributing

Contributions welcome! Please ensure:
- All tests pass (`aptos move test`)
- Code follows Move style guide
- Functions have proper documentation
- Security best practices followed

## 📄 License

MIT License - see LICENSE file for details
