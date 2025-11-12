# 🦑 ink! Smart Contracts for Polkadot/Substrate

**Rust-based smart contracts for the Polkadot and Substrate ecosystem using ink!**

ink! is an eDSL (embedded Domain Specific Language) that allows you to write WebAssembly-based smart contracts in Rust for blockchains built on Substrate, including Polkadot parachains.

## 📋 Overview

This example demonstrates how to build production-ready smart contracts for the Polkadot ecosystem using ink! 4.3. It includes a complete ERC-20 token implementation with comprehensive tests.

## 🔍 Why ink! for Polkadot/Substrate?

### Key Advantages

- **🦀 Rust-Powered**: Leverages Rust's memory safety and performance
- **🔒 Type Safety**: Strong compile-time guarantees prevent common bugs
- **📦 Small Contract Size**: Optimized WebAssembly output (often <10KB)
- **⚡ High Performance**: Near-native execution speed
- **🧪 Testing Framework**: Built-in unit and E2E testing support
- **🛠 Excellent Tooling**: cargo-contract CLI, substrate-contracts-node
- **🌐 Cross-Chain**: Compatible with any Substrate-based blockchain
- **💰 Low Gas Costs**: Efficient Wasm execution reduces transaction fees

### ink! vs Other Smart Contract Languages

| Feature | ink! | Solidity | Vyper |
|---------|------|----------|-------|
| **Language** | Rust | Custom | Python-like |
| **Safety** | Memory-safe by default | Common vulnerabilities | Safer than Solidity |
| **Size** | 5-50KB | 50-500KB | 30-300KB |
| **Tooling** | cargo, rust-analyzer | Hardhat, Remix | Vyper compiler |
| **Learning Curve** | Moderate (Rust knowledge) | Easy | Easy |
| **Blockchain** | Substrate/Polkadot | Ethereum/EVM | Ethereum/EVM |

## ✨ Features

### WhisperToken Contract (ERC-20)

- ✅ **Standard ERC-20 Interface**
  - `total_supply()` - Get total token supply
  - `balance_of(owner)` - Query account balances
  - `transfer(to, value)` - Transfer tokens
  - `approve(spender, value)` - Approve spending allowance
  - `transfer_from(from, to, value)` - Transfer with allowance
  - `allowance(owner, spender)` - Query spending allowance

- ✅ **Events**
  - `Transfer` - Emitted on token transfers
  - `Approval` - Emitted on approvals

- ✅ **Error Handling**
  - `InsufficientBalance` - Not enough tokens
  - `InsufficientAllowance` - Allowance exceeded

- ✅ **Comprehensive Tests**
  - Unit tests for all functions
  - Edge case coverage
  - Balance verification
  - Allowance mechanism tests

## 🚀 Prerequisites

### Install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup component add rust-src
rustup target add wasm32-unknown-unknown
```

### Install cargo-contract

```bash
# Install cargo-contract CLI tool (v4.0.0+)
cargo install --force --locked cargo-contract
```

### Install Substrate Contracts Node (Optional)

For local testing:

```bash
cargo install contracts-node --git https://github.com/paritytech/substrate-contracts-node.git --force --locked
```

## 📦 Installation

```bash
cd examples/ink/

# Check cargo-contract installation
cargo contract --version

# Build the contract
cargo contract build --release

# Output will be in target/ink/
```

## 🔨 Building the Contract

### Standard Build

```bash
cargo contract build
```

### Release Build (Optimized)

```bash
cargo contract build --release
```

This generates three important files in `target/ink/`:

1. **`whisper_token.contract`** - Bundled contract (code + metadata)
2. **`whisper_token.wasm`** - Contract WebAssembly code
3. **`whisper_token.json`** - Contract metadata (ABI)

### Build Output Example

```
Original wasm size: 25.4K, Optimized: 11.2K

Your contract artifacts are ready. You can find them in:
target/ink/whisper_token.contract
```

## 🧪 Testing

### Unit Tests

Run built-in unit tests:

```bash
cargo test
```

Expected output:

```
running 7 tests
test whisper_token::tests::new_works ... ok
test whisper_token::tests::balance_works ... ok
test whisper_token::tests::transfer_works ... ok
test whisper_token::tests::transfer_fails_insufficient_balance ... ok
test whisper_token::tests::approve_works ... ok
test whisper_token::tests::transfer_from_works ... ok
test whisper_token::tests::transfer_from_fails_insufficient_allowance ... ok

test result: ok. 7 passed; 0 failed
```

### E2E Tests (Optional)

For end-to-end testing with a running node:

```bash
cargo test --features e2e-tests
```

## 🌐 Deployment

### 1. Start Local Node (Development)

```bash
substrate-contracts-node --dev --tmp
```

### 2. Deploy Using cargo-contract

```bash
# Upload and instantiate
cargo contract instantiate \
  --constructor new \
  --args 1000000 \
  --suri //Alice \
  --execute

# Alternative: Upload code first
cargo contract upload --suri //Alice
# Then instantiate separately
cargo contract instantiate --suri //Alice --constructor new --args 1000000
```

### 3. Deploy to Testnet (Rococo Contracts)

```bash
# Upload to Rococo Contracts parachain
cargo contract instantiate \
  --constructor new \
  --args 1000000 \
  --url wss://rococo-contracts-rpc.polkadot.io \
  --suri "YOUR_SEED_PHRASE" \
  --execute
```

### 4. Interact with Deployed Contract

```bash
# Call read-only method
cargo contract call \
  --contract 5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY \
  --message balance_of \
  --args 5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY \
  --suri //Alice \
  --dry-run

# Execute transaction
cargo contract call \
  --contract 5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY \
  --message transfer \
  --args 5FHneW46xGXgs5mUiveU4sbTyGBzmstUspZC92UhjJM694ty 1000 \
  --suri //Alice \
  --execute
```

## 📖 Usage Examples

### Deploy and Use Token

```rust
// In your application code (using subxt or polkadot-js)

use ink::env::DefaultEnvironment;

// 1. Deploy contract
let total_supply = 1_000_000;
let contract = WhisperToken::new(total_supply);

// 2. Check balance
let balance = contract.balance_of(alice_account);
println!("Alice balance: {}", balance);

// 3. Transfer tokens
contract.transfer(bob_account, 1000)?;

// 4. Approve spending
contract.approve(charlie_account, 500)?;

// 5. Transfer from allowance
contract.transfer_from(alice_account, dave_account, 250)?;
```

### TypeScript Integration (polkadot.js)

```typescript
import { ApiPromise, WsProvider, Keyring } from '@polkadot/api';
import { ContractPromise } from '@polkadot/api-contract';
import metadata from './target/ink/whisper_token.json';

// Connect to node
const provider = new WsProvider('ws://127.0.0.1:9944');
const api = await ApiPromise.create({ provider });

// Load contract
const contract = new ContractPromise(
  api,
  metadata,
  'CONTRACT_ADDRESS_HERE'
);

// Query balance (read-only)
const { result, output } = await contract.query.balanceOf(
  deployer.address,
  { gasLimit: -1 },
  alice.address
);
console.log('Balance:', output.toHuman());

// Transfer tokens (transaction)
await contract.tx.transfer(
  { gasLimit: -1 },
  bob.address,
  1000
).signAndSend(alice);
```

## 🔒 Security Best Practices

### 1. **Reentrancy Protection**

ink! contracts are less vulnerable to reentrancy than Solidity, but still be cautious:

```rust
// ✅ Good: State changes before external calls
self.balances.insert(from, &(from_balance - value));
self.env().emit_event(Transfer { ... });

// ❌ Bad: External calls before state changes
self.env().emit_event(Transfer { ... });
self.balances.insert(from, &(from_balance - value));
```

### 2. **Integer Overflow/Underflow**

Rust prevents overflows in debug mode:

```rust
// ✅ Checked arithmetic
let new_balance = old_balance.checked_add(value).ok_or(Error::Overflow)?;

// ⚠️ Unchecked (panics in debug)
let new_balance = old_balance + value;
```

### 3. **Access Control**

Always verify callers:

```rust
let caller = self.env().caller();
if caller != self.owner {
    return Err(Error::Unauthorized);
}
```

### 4. **Gas Optimization**

- Use `Mapping` instead of `Vec` for key-value storage
- Minimize storage reads/writes
- Use events for data that doesn't need on-chain storage
- Pack small values together in structs

### 5. **Audit Checklist**

- [ ] All external functions have proper access control
- [ ] No unchecked arithmetic operations
- [ ] State changes happen before external calls
- [ ] Events are emitted for important state changes
- [ ] Comprehensive test coverage (>90%)
- [ ] Gas limits are reasonable
- [ ] No unused dependencies

## ⚡ Performance & Gas Optimization

### Contract Size Comparison

```
┌─────────────────┬──────────┬────────────┐
│ Build Type      │ Size     │ Gas Cost   │
├─────────────────┼──────────┼────────────┤
│ Debug           │ 45.2 KB  │ ~500M gas  │
│ Release         │ 11.2 KB  │ ~150M gas  │
│ Optimized       │ 8.7 KB   │ ~120M gas  │
└─────────────────┴──────────┴────────────┘
```

### Gas Usage (Approximate)

```
┌──────────────────┬──────────────┐
│ Operation        │ Gas Cost     │
├──────────────────┼──────────────┤
│ Deploy           │ ~150M gas    │
│ transfer()       │ ~45K gas     │
│ approve()        │ ~38K gas     │
│ balance_of()     │ ~5K gas      │
│ transfer_from()  │ ~62K gas     │
└──────────────────┴──────────────┘
```

### Optimization Tips

```rust
// ✅ Use Mapping for O(1) lookups
balances: Mapping<AccountId, Balance>

// ❌ Avoid Vec for large datasets (O(n) scans)
balances: Vec<(AccountId, Balance)>

// ✅ Pack related storage together
#[ink(storage)]
pub struct Packed {
    owner: AccountId,      // 32 bytes
    total_supply: u128,    // 16 bytes
    paused: bool,          // 1 byte
}

// ✅ Use lazy storage for large data
use ink::storage::Lazy;
large_data: Lazy<Vec<u8>>
```

## 📚 Resources

### Official Documentation

- **ink! Docs**: https://use.ink/
- **Substrate Docs**: https://docs.substrate.io/
- **Polkadot Wiki**: https://wiki.polkadot.network/

### Tools & IDEs

- **cargo-contract**: https://github.com/paritytech/cargo-contract
- **Contracts UI**: https://contracts-ui.substrate.io/
- **Polkadot.js Apps**: https://polkadot.js.org/apps/

### Tutorials & Examples

- **ink! Examples**: https://github.com/paritytech/ink-examples
- **Awesome ink!**: https://github.com/use-ink/awesome-ink

### Networks

- **Rococo Contracts** (Testnet): wss://rococo-contracts-rpc.polkadot.io
- **Astar Network** (Mainnet): https://astar.network/
- **Aleph Zero** (Mainnet): https://alephzero.org/

## 🏗 Project Structure

```
ink/
├── Cargo.toml              # Project manifest
├── lib/
│   └── lib.rs             # Main contract code
├── tests/
│   └── integration.rs     # E2E tests (optional)
├── .env.example           # Environment variables template
└── README.md              # This file
```

## 🐛 Troubleshooting

### Common Issues

**1. Build fails with "wasm32-unknown-unknown not found"**

```bash
rustup target add wasm32-unknown-unknown
```

**2. "cargo-contract not found"**

```bash
cargo install --force --locked cargo-contract
```

**3. Contract size too large**

```bash
# Use release mode
cargo contract build --release

# Further optimization
cargo install wasm-opt
wasm-opt target/ink/whisper_token.wasm -o optimized.wasm -Os
```

**4. Gas limit exceeded**

Increase gas limit in calls:

```bash
cargo contract call --gas 200000000000 ...
```

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. All tests pass: `cargo test`
2. Code is formatted: `cargo fmt`
3. No clippy warnings: `cargo clippy`
4. Documentation is updated

## 📄 License

MIT License - see [LICENSE](../../LICENSE) for details

## 🔗 Related Examples

- [Rust Substrate Pallet](../rust-substrate/) - Substrate runtime pallets
- [Solidity](../solidity/) - Ethereum smart contracts
- [Move](../move-aptos/) - Aptos/Sui smart contracts
- [Cairo](../cairo/) - StarkNet L2 contracts

---

**Built with ink! 4.3 for the Polkadot Ecosystem** 🦑🔗
