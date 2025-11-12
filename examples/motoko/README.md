# 🌐 Motoko Smart Contracts for Internet Computer (ICP)

**Actor-based smart contracts for DFINITY's Internet Computer blockchain**

Motoko is a modern programming language designed specifically for the Internet Computer blockchain platform. It provides a familiar yet powerful syntax for building decentralized applications that run at web speed.

## 📋 Overview

This example demonstrates how to build production-ready smart contracts (canisters) for the Internet Computer using Motoko. It includes a complete fungible token implementation with comprehensive functionality.

## 🔍 Why Motoko for Internet Computer?

### Key Advantages

- **🎯 Purpose-Built**: Designed specifically for the Internet Computer
- **⚡ Actor Model**: Natural fit for distributed computing
- **🔒 Type Safety**: Strong static typing prevents runtime errors
- **🧠 Familiar Syntax**: Similar to TypeScript/JavaScript
- **♻️ Automatic Memory Management**: Built-in garbage collection
- **🔄 Orthogonal Persistence**: State automatically persists across upgrades
- **⚙️ Async/Await**: Native support for asynchronous operations
- **🛡️ Security**: Memory-safe with no undefined behavior

### Motoko vs Other Smart Contract Languages

| Feature | Motoko | Solidity | Rust |
|---------|--------|----------|------|
| **Target Platform** | Internet Computer | Ethereum/EVM | Multiple (Solana, NEAR) |
| **Syntax Style** | TypeScript-like | JavaScript-like | Systems programming |
| **Memory Model** | Garbage collected | Manual | Manual (ownership) |
| **Async Support** | Native async/await | Callback-based | Futures/async |
| **State Persistence** | Automatic | Manual | Manual |
| **Learning Curve** | Easy-Medium | Easy | Hard |
| **Performance** | High | Medium | Very High |

## ✨ Features

### WhisperToken Canister

- ✅ **Token Standard Functions**
  - `name()` - Get token name
  - `symbol()` - Get token symbol
  - `decimals()` - Get decimal places
  - `totalSupply()` - Get total supply
  - `balanceOf(account)` - Query balance
  - `fee()` - Get transfer fee

- ✅ **Transfer Functions**
  - `transfer(to, amount)` - Direct transfer
  - `approve(spender, amount)` - Approve allowance
  - `allowance(owner, spender)` - Check allowance
  - `transferFrom(from, to, amount)` - Transfer via allowance

- ✅ **Admin Functions**
  - `mint(to, amount)` - Create new tokens (owner only)
  - `burn(amount)` - Destroy tokens
  - `owner()` - Get contract owner

- ✅ **Utility Functions**
  - `getHolders()` - List all token holders (for admin)

- ✅ **Error Handling**
  - Insufficient funds detection
  - Allowance validation
  - Owner-only restrictions
  - Amount validation

## 🚀 Prerequisites

### Install DFX SDK

The DFINITY Canister SDK (dfx) is required:

```bash
# Install dfx (macOS/Linux)
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Verify installation
dfx --version
```

### Install Node.js (Optional)

For testing and frontend development:

```bash
# Using nvm
nvm install 18
nvm use 18

# Or direct download
# https://nodejs.org/
```

## 📦 Installation

```bash
cd examples/motoko/

# Verify dfx installation
dfx --version

# Start local Internet Computer replica
dfx start --clean --background

# Deploy the canister
dfx deploy
```

## 🔨 Development

### Project Structure

```
motoko/
├── dfx.json                # DFX project configuration
├── src/
│   └── main.mo            # Main token canister code
├── test/
│   └── test.mo            # Test suite
├── .env.example           # Environment template
└── README.md              # This file
```

### Start Local Replica

```bash
# Start in background
dfx start --clean --background

# Or start in foreground (to see logs)
dfx start --clean
```

### Deploy Canister

```bash
# Deploy all canisters
dfx deploy

# Deploy specific canister
dfx deploy whisper_token

# Deploy with specific network
dfx deploy --network ic  # For mainnet
```

### Initialize Token

```bash
# Initialize the token with owner
dfx canister call whisper_token init
```

## 🧪 Testing

### Query Functions (No State Change)

```bash
# Get token name
dfx canister call whisper_token name

# Get token symbol
dfx canister call whisper_token symbol

# Get decimals
dfx canister call whisper_token decimals

# Get total supply
dfx canister call whisper_token totalSupply

# Get balance of principal
dfx canister call whisper_token balanceOf '(principal "rrkah-fqaaa-aaaaa-aaaaq-cai")'

# Check allowance
dfx canister call whisper_token allowance '(principal "owner", principal "spender")'

# Get owner
dfx canister call whisper_token owner
```

### Update Functions (Modify State)

```bash
# Transfer tokens
dfx canister call whisper_token transfer '(principal "ryjl3-tyaaa-aaaaa-aaaba-cai", 1000)'

# Approve spending
dfx canister call whisper_token approve '(principal "ryjl3-tyaaa-aaaaa-aaaba-cai", 5000)'

# Transfer from allowance
dfx canister call whisper_token transferFrom '(
  principal "rrkah-fqaaa-aaaaa-aaaaq-cai",
  principal "r7inp-6aaaa-aaaaa-aaabq-cai",
  500
)'

# Mint tokens (owner only)
dfx canister call whisper_token mint '(principal "ryjl3-tyaaa-aaaaa-aaaba-cai", 10000)'

# Burn tokens
dfx canister call whisper_token burn '(1000)'
```

### Get Your Principal ID

```bash
# Get your default identity's principal
dfx identity get-principal

# Use this principal in commands above
```

## 🌐 Deployment

### Deploy to Local Network

```bash
# Start local replica
dfx start --clean --background

# Deploy
dfx deploy

# Initialize
dfx canister call whisper_token init
```

### Deploy to Mainnet (Internet Computer)

⚠️ **Warning**: Deploying to mainnet requires cycles (ICP tokens)

```bash
# Create identity if needed
dfx identity new production
dfx identity use production

# Get principal and cycles
dfx identity get-principal
# Fund your principal with cycles at: https://faucet.dfinity.org/

# Deploy to mainnet
dfx deploy --network ic --with-cycles 1000000000000

# Initialize on mainnet
dfx canister --network ic call whisper_token init
```

### Get Canister ID

```bash
# Local network
dfx canister id whisper_token

# Mainnet
dfx canister --network ic id whisper_token
```

## 📖 Usage Examples

### Using dfx Command Line

```bash
# 1. Initialize token
dfx canister call whisper_token init

# 2. Check your balance
PRINCIPAL=$(dfx identity get-principal)
dfx canister call whisper_token balanceOf "(principal \"$PRINCIPAL\")"

# 3. Transfer to another user
dfx canister call whisper_token transfer '(
  principal "ryjl3-tyaaa-aaaaa-aaaba-cai",
  1000
)'

# 4. Approve spending
dfx canister call whisper_token approve '(
  principal "r7inp-6aaaa-aaaaa-aaabq-cai",
  5000
)'
```

### JavaScript/TypeScript Integration

```typescript
import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory } from './declarations/whisper_token';

// Create agent
const agent = new HttpAgent({ host: 'https://ic0.app' });

// In development, fetch root key
if (process.env.NODE_ENV !== 'production') {
  await agent.fetchRootKey();
}

// Create actor
const canisterId = 'YOUR_CANISTER_ID';
const token = Actor.createActor(idlFactory, {
  agent,
  canisterId,
});

// Query balance
const balance = await token.balanceOf(principal);
console.log('Balance:', balance);

// Transfer tokens
const result = await token.transfer(recipientPrincipal, 1000);
if ('ok' in result) {
  console.log('Transfer successful:', result.ok);
} else {
  console.error('Transfer failed:', result.err);
}
```

### React Frontend Example

```typescript
import { useCanister } from '@connect2ic/react';

function TokenTransfer() {
  const [token] = useCanister('whisper_token');

  async function transfer(to: string, amount: number) {
    try {
      const result = await token.transfer(
        Principal.fromText(to),
        BigInt(amount)
      );

      if ('ok' in result) {
        alert('Transfer successful!');
      } else {
        alert('Transfer failed: ' + JSON.stringify(result.err));
      }
    } catch (error) {
      console.error('Error:', error);
    }
  }

  return (
    <form onSubmit={(e) => {
      e.preventDefault();
      const data = new FormData(e.target);
      transfer(data.get('to'), Number(data.get('amount')));
    }}>
      <input name="to" placeholder="Recipient Principal" />
      <input name="amount" type="number" placeholder="Amount" />
      <button type="submit">Transfer</button>
    </form>
  );
}
```

## 🔒 Security Best Practices

### 1. **Validate Callers**

```motoko
// ✅ Good: Check caller identity
public shared(msg) func mint(to: Principal, amount: Nat) : async Result<TxIndex, TransferError> {
    if (msg.caller != owner_) {
        return #err(#GenericError({...}));
    };
    // ... mint logic
};

// ❌ Bad: No validation
public func mint(to: Principal, amount: Nat) : async () {
    // Anyone can mint!
};
```

### 2. **Validate Amounts**

```motoko
// ✅ Good: Validate amount
if (amount == 0) {
    return #err(#GenericError({...}));
};

// ❌ Bad: No validation
balances.put(to, toBalance + amount);
```

### 3. **Check Balances**

```motoko
// ✅ Good: Check balance first
let balance = _balanceOf(from);
if (balance < amount) {
    return #err(#InsufficientFunds({...}));
};

// ❌ Bad: No check (could underflow)
balances.put(from, fromBalance - amount);
```

### 4. **Use Stable Storage**

```motoko
// ✅ Good: Stable variables persist across upgrades
private stable var totalSupply_ : Nat = 0;
private stable var owner_ : Principal = ...;

// ⚠️ Careful: Non-stable data lost on upgrade
private var balances = HashMap.HashMap<Principal, Nat>(...);
// Need pre/post-upgrade hooks!
```

### 5. **Handle Errors Properly**

```motoko
// ✅ Good: Return Result types
public func transfer(...) : async Result.Result<TxIndex, TransferError> {
    // ...
    return #ok(txIndex);
};

// ❌ Bad: trap() crashes canister
public func transfer(...) : async () {
    assert(balance >= amount); // Don't use assert in production
};
```

### 6. **Audit Checklist**

- [ ] All sensitive functions check `msg.caller`
- [ ] All amounts are validated (> 0)
- [ ] All balances checked before transfers
- [ ] Stable variables for critical state
- [ ] Pre/post-upgrade hooks for non-stable data
- [ ] Result types for error handling (no trap())
- [ ] Test coverage for edge cases
- [ ] Cycle management in place

## ⚡ Performance & Cost Optimization

### Canister Costs on Internet Computer

```
┌──────────────────┬──────────────┬──────────────┐
│ Operation        │ Cycles Cost  │ USD (approx) │
├──────────────────┼──────────────┼──────────────┤
│ Canister Create  │ 100B cycles  │ ~$0.13       │
│ Storage (1 GB)   │ 127T/year    │ ~$165/year   │
│ Update Call      │ ~1M cycles   │ ~$0.0000013  │
│ Query Call       │ FREE         │ $0           │
└──────────────────┴──────────────┴──────────────┘
```

### Cost Comparison

| Action | Motoko/ICP | Ethereum Gas |
|--------|------------|--------------|
| Deploy | ~$0.13 | ~$200-500 |
| Transfer | ~$0.000001 | ~$5-20 |
| Query | FREE | FREE |
| Storage (1 year) | ~$165/GB | ~$12,000/GB |

### Optimization Tips

```motoko
// ✅ Use query for read-only functions (FREE)
public query func balanceOf(account: Principal) : async Nat {
    return _balanceOf(account);
};

// ✅ Batch operations to save cycles
public func batchTransfer(recipients: [(Principal, Nat)]) : async [Result] {
    // Process multiple transfers in one call
};

// ✅ Use stable storage efficiently
private stable var entries : [(Principal, Nat)] = [];

system func preupgrade() {
    entries := Iter.toArray(balances.entries());
};

system func postupgrade() {
    balances := HashMap.fromIter<Principal, Nat>(
        entries.vals(), 10, Principal.equal, Principal.hash
    );
};
```

## 📚 Resources

### Official Documentation

- **Motoko Docs**: https://internetcomputer.org/docs/current/motoko/main/motoko
- **Internet Computer**: https://internetcomputer.org/
- **Developer Docs**: https://internetcomputer.org/docs/current/developer-docs/

### Tools & IDEs

- **DFX SDK**: https://github.com/dfinity/sdk
- **Motoko Playground**: https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/
- **IC Inspector**: https://ic-inspector.io/

### Tutorials & Examples

- **Motoko Examples**: https://github.com/dfinity/examples
- **Motoko Base Library**: https://github.com/dfinity/motoko-base

### Networks

- **Mainnet**: https://ic0.app
- **Local**: http://localhost:8000

## 🐛 Troubleshooting

### Common Issues

**1. "dfx: command not found"**

```bash
# Reinstall DFX
sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"

# Add to PATH
export PATH="$HOME/.local/share/dfx/bin:$PATH"
```

**2. "Cannot find canister id"**

```bash
# Deploy first
dfx deploy

# Then get canister ID
dfx canister id whisper_token
```

**3. "Replica not running"**

```bash
# Start the replica
dfx start --clean --background

# Check status
dfx ping
```

**4. "Out of cycles"**

```bash
# Check cycle balance
dfx canister status whisper_token

# Top up cycles (testnet)
dfx canister deposit-cycles 1000000000000 whisper_token

# For mainnet, get cycles from exchanges or NNS
```

**5. "Call was rejected"**

Common causes:
- Canister not initialized: Run `dfx canister call whisper_token init`
- Wrong principal format: Use `principal "xxx"` syntax
- Insufficient cycles: Top up canister

**6. Upgrade fails with state loss**

Implement pre/postupgrade:

```motoko
system func preupgrade() {
    // Save state
    entries := Iter.toArray(balances.entries());
};

system func postupgrade() {
    // Restore state
    balances := HashMap.fromIter(...);
};
```

## 🤝 Contributing

Contributions are welcome! Please ensure:

1. Code compiles: `dfx build`
2. Tests pass: Use canister calls to verify
3. Documentation is updated

## 📄 License

MIT License - see [LICENSE](../../LICENSE) for details

## 🔗 Related Examples

- [Solidity](../solidity/) - Ethereum smart contracts
- [ink!](../ink/) - Polkadot smart contracts
- [Clarity](../clarity/) - Stacks/Bitcoin L2 contracts
- [Move](../move-aptos/) - Aptos/Sui smart contracts

---

**Built with Motoko for the Internet Computer** 🌐🚀
