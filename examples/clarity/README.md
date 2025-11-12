# 🔗 Clarity Smart Contracts for Stacks (Bitcoin L2)

**Decidable, Lisp-like smart contracts for Bitcoin via Stacks blockchain**

Clarity is a decidable smart contract language for the Stacks blockchain, which brings smart contracts to Bitcoin through the Stacks Layer 2 network. It's designed to be more predictable and secure than Turing-complete languages.

## 📋 Overview

This example demonstrates how to build production-ready smart contracts for Bitcoin via Stacks using Clarity 2.0. It includes a complete SIP-010 fungible token implementation (equivalent to ERC-20) with comprehensive tests.

## 🔍 Why Clarity for Bitcoin/Stacks?

### Key Advantages

- **🔒 Decidable**: No recursion or loops - prevents infinite execution
- **📖 Non-Turing Complete**: More predictable and secure by design
- **🔍 Post-Conditions**: Built-in runtime assertions for security
- **📝 Human-Readable**: Lisp-like syntax is explicit and auditable
- **₿ Bitcoin-Secured**: Inherits Bitcoin's security via Stacks
- **🎯 No Hidden Fees**: Predictable gas costs
- **🛡️ No Reentrancy**: Architecture prevents reentrancy attacks
- **📊 Static Analysis**: Easier to analyze and verify formally

### Clarity vs Other Smart Contract Languages

| Feature | Clarity | Solidity | Vyper |
|---------|---------|----------|-------|
| **Completeness** | Decidable | Turing-complete | Turing-complete |
| **Syntax** | Lisp-like | JavaScript-like | Python-like |
| **Loops** | ❌ No | ✅ Yes | ✅ Limited |
| **Recursion** | ❌ No | ✅ Yes | ❌ No |
| **Reentrancy** | 🛡️ Protected | ⚠️ Vulnerable | ⚠️ Vulnerable |
| **Post-conditions** | ✅ Built-in | ❌ No | ❌ No |
| **Blockchain** | Stacks/Bitcoin | Ethereum/EVM | Ethereum/EVM |
| **Security** | Very High | Medium | High |

## ✨ Features

### WhisperToken Contract (SIP-010)

- ✅ **SIP-010 Standard Interface** (Stacks' ERC-20)
  - `transfer` - Transfer tokens between accounts
  - `get-name` - Get token name
  - `get-symbol` - Get token symbol
  - `get-decimals` - Get decimal places
  - `get-balance` - Query account balance
  - `get-total-supply` - Get total supply
  - `get-token-uri` - Get metadata URI

- ✅ **Extended Functions**
  - `mint` - Create new tokens (owner only)
  - `burn` - Destroy tokens
  - `transfer-tokens` - Convenience transfer wrapper

- ✅ **Security Features**
  - Owner-only minting
  - Balance validation
  - Amount validation
  - Explicit error handling

- ✅ **Comprehensive Tests**
  - Token metadata tests
  - Transfer functionality
  - Mint/burn operations
  - Access control
  - Error handling

## 🚀 Prerequisites

### Install Clarinet

Clarinet is the CLI tool for Clarity development:

```bash
# macOS/Linux
curl -L https://github.com/hirosystems/clarinet/releases/download/v1.7.0/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/

# Or via Homebrew (macOS)
brew install clarinet

# Verify installation
clarinet --version
```

### Install Stacks CLI (Optional)

```bash
npm install -g @stacks/cli
```

### Install Node.js/Deno (for tests)

```bash
# Tests use Deno
curl -fsSL https://deno.land/x/install/install.sh | sh
```

## 📦 Installation

```bash
cd examples/clarity/

# Check Clarinet installation
clarinet --version

# Check contract syntax
clarinet check

# Run tests
clarinet test
```

## 🔨 Development

### Project Structure

```
clarity/
├── Clarinet.toml                    # Project configuration
├── contracts/
│   └── whisper-token.clar          # Main token contract
├── tests/
│   └── whisper-token_test.ts       # TypeScript tests
├── .env.example                     # Environment template
└── README.md                        # This file
```

### Check Contract Syntax

```bash
clarinet check
```

Expected output:
```
✔ 1 contract checked
```

### Launch REPL

```bash
clarinet console
```

Interactive commands:
```clarity
;; Deploy contract
::deploy_contract whisper-token contracts/whisper-token.clar

;; Get token name
(contract-call? .whisper-token get-name)

;; Get balance
(contract-call? .whisper-token get-balance tx-sender)

;; Transfer tokens
(contract-call? .whisper-token transfer u1000 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM none)
```

## 🧪 Testing

### Run All Tests

```bash
clarinet test
```

Expected output:
```
running 8 tests
test ensure_that_token_has_correct_name_and_symbol ... ok
test ensure_deployer_has_initial_balance ... ok
test test_token_transfer ... ok
test test_transfer_with_insufficient_balance_fails ... ok
test test_minting_by_owner ... ok
test test_minting_by_non_owner_fails ... ok
test test_burning_tokens ... ok
test test_burning_more_than_balance_fails ... ok

test result: ok. 8 passed; 0 failed
```

### Run Specific Test

```bash
clarinet test --filter "token_transfer"
```

### Watch Mode

```bash
clarinet test --watch
```

## 🌐 Deployment

### 1. Deploy to Testnet

```bash
# Generate a new testnet account
clarinet integrate

# Deploy to testnet
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### 2. Deploy Using Stacks CLI

```bash
# Deploy contract
stx deploy_contract \
  whisper-token \
  contracts/whisper-token.clar \
  --testnet \
  --fee 10000

# Output will show contract address:
# Contract deployed: ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.whisper-token
```

### 3. Deploy to Mainnet

⚠️ **Warning**: Always test thoroughly on testnet first!

```bash
# Generate mainnet deployment
clarinet deployments generate --mainnet

# Review deployment plan
cat deployments/mainnet.plan.yaml

# Deploy (CAREFULLY!)
clarinet deployments apply --mainnet
```

## 📖 Usage Examples

### Using Stacks CLI

```bash
# Get token name
stx call_read_only_contract_func \
  ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM \
  whisper-token \
  get-name \
  --testnet

# Get balance
stx call_read_only_contract_func \
  ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM \
  whisper-token \
  get-balance \
  --testnet \
  -e "'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"

# Transfer tokens
stx call_contract_func \
  ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM \
  whisper-token \
  transfer \
  --testnet \
  -e "u1000" \
  -e "'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM" \
  -e "'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG" \
  -e "none"
```

### JavaScript/TypeScript Integration

```typescript
import {
  makeContractCall,
  broadcastTransaction,
  AnchorMode,
  PostConditionMode,
} from '@stacks/transactions';
import { StacksTestnet } from '@stacks/network';

const network = new StacksTestnet();

// Transfer tokens
const txOptions = {
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'whisper-token',
  functionName: 'transfer',
  functionArgs: [
    uintCV(1000),
    principalCV('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM'),
    principalCV('ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG'),
    noneCV(),
  ],
  senderKey: 'your-private-key',
  network,
  anchorMode: AnchorMode.Any,
};

const transaction = await makeContractCall(txOptions);
const broadcastResponse = await broadcastTransaction(transaction, network);

console.log('Transaction ID:', broadcastResponse.txid);
```

### Read-Only Calls (No Gas)

```typescript
import { callReadOnlyFunction } from '@stacks/transactions';

// Get balance
const result = await callReadOnlyFunction({
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'whisper-token',
  functionName: 'get-balance',
  functionArgs: [principalCV('ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM')],
  network,
  senderAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
});

console.log('Balance:', result.value);
```

## 🔒 Security Best Practices

### 1. **Post-Conditions**

Always use post-conditions to protect users:

```typescript
import { createSTXPostCondition, FungibleConditionCode } from '@stacks/transactions';

const postConditions = [
  createSTXPostCondition(
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
    FungibleConditionCode.LessEqual,
    1000
  ),
];
```

### 2. **Access Control**

Always validate callers:

```clarity
;; ✅ Good: Check caller
(asserts! (is-eq tx-sender contract-owner) err-owner-only)

;; ❌ Bad: No validation
(ft-mint? token amount recipient)
```

### 3. **Amount Validation**

Always validate amounts:

```clarity
;; ✅ Good: Validate amount
(asserts! (> amount u0) err-invalid-amount)

;; ❌ Bad: No validation
(ft-transfer? token amount sender recipient)
```

### 4. **Balance Checks**

Check balances before operations:

```clarity
;; ✅ Good: Check balance first
(asserts! (>= (ft-get-balance token tx-sender) amount) err-insufficient-balance)
(try! (ft-burn? token amount tx-sender))
```

### 5. **Use try! for Errors**

Propagate errors properly:

```clarity
;; ✅ Good: Propagate errors
(try! (ft-transfer? token amount sender recipient))

;; ❌ Bad: Ignore errors
(ft-transfer? token amount sender recipient)
```

### 6. **Audit Checklist**

- [ ] All public functions have access control
- [ ] All amounts are validated (> 0)
- [ ] All balances are checked before operations
- [ ] Errors are properly propagated with try!
- [ ] Read-only functions don't modify state
- [ ] Post-conditions are documented for users
- [ ] Test coverage is comprehensive (>90%)

## ⚡ Performance & Gas Optimization

### Gas Cost Comparison

```
┌──────────────────┬──────────────┬──────────────┐
│ Operation        │ Clarity Cost │ Solidity Gas │
├──────────────────┼──────────────┼──────────────┤
│ Deploy           │ ~500 µSTX    │ ~150M gas    │
│ transfer()       │ ~0.5 µSTX    │ ~45K gas     │
│ mint()           │ ~0.8 µSTX    │ ~50K gas     │
│ burn()           │ ~0.6 µSTX    │ ~35K gas     │
│ get-balance()    │ FREE         │ FREE         │
└──────────────────┴──────────────┴──────────────┘
```

### Optimization Tips

```clarity
;; ✅ Use built-in functions (optimized)
(ft-transfer? whisper-token amount sender recipient)

;; ❌ Don't implement from scratch
(map-set balances sender (- (get-balance sender) amount))

;; ✅ Fail fast with asserts!
(asserts! (is-eq tx-sender owner) err-unauthorized)
;; ... rest of function

;; ❌ Don't validate at the end
;; ... long function
(asserts! (is-eq tx-sender owner) err-unauthorized)

;; ✅ Use read-only for queries
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance whisper-token account)))
```

## 📚 Resources

### Official Documentation

- **Clarity Docs**: https://docs.stacks.co/clarity
- **Stacks Docs**: https://docs.stacks.co/
- **SIP-010 Standard**: https://github.com/stacksgov/sips/blob/main/sips/sip-010/sip-010-fungible-token-standard.md

### Tools & IDEs

- **Clarinet**: https://github.com/hirosystems/clarinet
- **Stacks Explorer**: https://explorer.stacks.co/
- **Hiro Platform**: https://platform.hiro.so/

### Tutorials & Examples

- **Clarity Examples**: https://github.com/clarity-lang/examples
- **Book of Clarity**: https://book.clarity-lang.org/

### Networks

- **Testnet**: https://stacks-node-api.testnet.stacks.co
- **Mainnet**: https://stacks-node-api.mainnet.stacks.co

## 🐛 Troubleshooting

### Common Issues

**1. "clarinet: command not found"**

```bash
# Reinstall Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/latest/download/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/
```

**2. "Analysis error: contract not found"**

```bash
# Check Clarinet.toml has correct paths
cat Clarinet.toml

# Re-run check
clarinet check
```

**3. "Deno not found" (for tests)**

```bash
# Install Deno
curl -fsSL https://deno.land/x/install/install.sh | sh

# Add to PATH
export PATH="$HOME/.deno/bin:$PATH"
```

**4. Tests fail with "insufficient balance"**

Make sure initialization runs:
```clarity
;; At end of contract
(initialize)
```

**5. Transaction fails on testnet**

Check you have testnet STX:
```bash
# Get testnet STX from faucet
curl -X POST https://stacks-node-api.testnet.stacks.co/extended/v1/faucets/stx?address=YOUR_ADDRESS
```

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. All tests pass: `clarinet test`
2. Syntax is valid: `clarinet check`
3. Documentation is updated

## 📄 License

MIT License - see [LICENSE](../../LICENSE) for details

## 🔗 Related Examples

- [Solidity](../solidity/) - Ethereum smart contracts
- [Vyper](../vyper/) - Python-style EVM contracts
- [ink!](../ink/) - Polkadot smart contracts
- [Motoko](../motoko/) - Internet Computer canisters

---

**Built with Clarity 2.0 for Bitcoin via Stacks** 🔗₿
