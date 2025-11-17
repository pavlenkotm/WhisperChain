# WhisperChain Ecosystem Architecture

## Overview

WhisperChain has evolved from a single decentralized chat application into a **comprehensive Web3 development ecosystem**. This document describes the architecture and components of the ecosystem.

## Architecture Diagram

```
WhisperChain Ecosystem
│
├── Packages (Shared Libraries)
│   ├── @whisperchain/types      - TypeScript type definitions
│   ├── @whisperchain/core       - Core utilities (validation, formatting)
│   ├── @whisperchain/crypto     - Cryptographic primitives
│   ├── @whisperchain/sdk        - Main SDK for developers
│   ├── @whisperchain/contracts  - Smart contract interfaces
│   └── @whisperchain/cli        - Command-line tools
│
├── Examples (Multi-Language Demonstrations)
│   ├── Solidity, Vyper          - Ethereum smart contracts
│   ├── Rust (Solana/Substrate)  - Blockchain programs
│   ├── Move, Cairo, ink!        - Alternative blockchain languages
│   ├── TypeScript, Python, Go   - Backend services
│   └── 20+ more languages...
│
└── Apps (Full Applications)
    └── Original WhisperChain App - Encrypted messaging on Solana
```

## Core Packages

### @whisperchain/types

**Purpose**: Shared TypeScript type definitions for the entire ecosystem

**Key Features**:
- Blockchain network types
- Wallet and transaction interfaces
- Smart contract ABIs
- Token and NFT types
- Encryption message formats

**Installation**:
```bash
npm install @whisperchain/types
```

**Usage**:
```typescript
import type { BlockchainNetwork, Transaction } from '@whisperchain/types';
```

---

### @whisperchain/core

**Purpose**: Core utilities used across all packages

**Key Features**:
- **Validation**: Address validation, transaction hash verification
- **Formatting**: Wei/Ether conversion, address shortening, hex encoding
- **Constants**: Network configurations, gas limits, common values

**Installation**:
```bash
npm install @whisperchain/core
```

**Usage**:
```typescript
import { isValidEthereumAddress, formatWeiToEther, DEFAULT_NETWORKS } from '@whisperchain/core';

if (isValidEthereumAddress('0x123...')) {
  const ether = formatWeiToEther('1000000000000000000');
  console.log(ether); // "1.0000"
}
```

---

### @whisperchain/crypto

**Purpose**: Cryptographic operations for encryption and signing

**Key Features**:
- **Encryption**: Public key encryption (X25519-XSalsa20-Poly1305)
- **Key Management**: Key pair generation, key encoding/decoding
- **Hashing**: SHA-512, message digests
- **Symmetric Encryption**: For self-encrypting data

**Installation**:
```bash
npm install @whisperchain/crypto
```

**Usage**:
```typescript
import { generateKeyPair, encryptMessage, decryptMessage } from '@whisperchain/crypto';

// Generate keys
const aliceKeys = generateKeyPair();
const bobKeys = generateKeyPair();

// Alice encrypts message for Bob
const encrypted = encryptMessage(
  'Hello Bob!',
  bobKeys.publicKey,
  aliceKeys.privateKey
);

// Bob decrypts message
const decrypted = decryptMessage(encrypted, bobKeys.privateKey);
console.log(decrypted); // "Hello Bob!"
```

---

### @whisperchain/sdk

**Purpose**: Main SDK that combines all functionality

**Key Features**:
- **WhisperChainClient**: Main client for interacting with the ecosystem
- **MessagingClient**: Encrypted messaging
- **BlockchainClient**: Multi-chain interactions (Ethereum, Solana, etc.)
- **Transaction Management**: Send/receive transactions
- **Wallet Operations**: Balance checking, transaction history

**Installation**:
```bash
npm install @whisperchain/sdk
```

**Usage**:
```typescript
import { WhisperChainClient } from '@whisperchain/sdk';

// Initialize client
const client = new WhisperChainClient({
  blockchain: 'ethereum',
});

await client.initialize();

// Send encrypted message
const message = await client.messaging.sendMessage(
  recipientPublicKey,
  'Secret message',
  3600 // expires in 1 hour
);

// Check balance
const balance = await client.blockchain.getBalance('0x123...');
```

---

### @whisperchain/cli

**Purpose**: Command-line interface for developers

**Key Features**:
- **Project Initialization**: Scaffold new WhisperChain projects
- **Wallet Management**: Create wallets, check balances
- **Messaging**: Send/receive encrypted messages
- **Contract Operations**: Compile, deploy, interact
- **Network Tools**: List networks, check status

**Installation**:
```bash
npm install -g @whisperchain/cli
```

**Usage**:
```bash
# Initialize new project
whisperchain init --template dapp --name my-dapp

# Create wallet
whisperchain wallet create

# Check balance
whisperchain wallet balance 0x123...

# Generate encryption keys
whisperchain message keygen

# List supported networks
whisperchain network list

# Check network status
whisperchain network status ethereum
```

---

## Multi-Language Examples

The ecosystem includes production-quality examples in 24+ languages:

### Smart Contract Languages
- **Solidity** - ERC-20, ERC-721, DeFi contracts
- **Vyper** - Security-focused EVM contracts
- **Move** - Resource-oriented programming (Aptos)
- **Cairo** - Zero-knowledge proofs (StarkNet)
- **Rust** - Solana programs, Substrate pallets
- **ink!** - Polkadot smart contracts
- **Clarity** - Bitcoin Layer 2 (Stacks)
- **Motoko** - Internet Computer canisters
- **Haskell (Plutus)** - Cardano validators
- **OCaml** - Tezos smart contracts

### Backend/Service Languages
- **TypeScript** - Web3 DApps, APIs
- **Python** - Scripts, utilities, indexers
- **Go** - High-performance services
- **Java** - Enterprise backends
- **Elixir** - Distributed nodes
- **Erlang** - Fault-tolerant messaging

### Performance/System Languages
- **C++** - Cryptographic primitives
- **Zig** - WebAssembly modules
- **Nim** - High-performance crypto
- **Crystal** - Fast Web3 clients

### Analytics/Functional Languages
- **F#** - Blockchain data analytics

### Frontend
- **HTML/CSS** - Landing pages
- **TypeScript/React** - DApp UIs

---

## Monorepo Structure

WhisperChain uses **npm workspaces** for monorepo management:

```
WhisperChain/
├── package.json              # Root workspace configuration
├── tsconfig.base.json        # Shared TypeScript config
├── .eslintrc.json            # Shared ESLint rules
├── .prettierrc               # Shared Prettier config
├── jest.config.base.js       # Shared Jest config
│
├── packages/                 # Shared packages
│   ├── types/
│   ├── core/
│   ├── crypto/
│   ├── sdk/
│   └── cli/
│
├── apps/                     # Full applications
│   └── (future apps)
│
├── examples/                 # Language examples
│   ├── solidity/
│   ├── typescript/
│   ├── python/
│   └── ... (20+ more)
│
└── docs/                     # Documentation
    ├── ECOSYSTEM.md
    ├── API.md
    └── GUIDES.md
```

## Development Workflow

### Setting Up the Ecosystem

```bash
# Clone repository
git clone https://github.com/pavlenkotm/WhisperChain.git
cd WhisperChain

# Install all dependencies
npm install

# Build all packages
npm run build

# Run all tests
npm run test
```

### Working with Packages

```bash
# Build a specific package
cd packages/sdk
npm run build

# Test a specific package
npm run test

# Link local packages for development
npm link
```

### Adding New Packages

1. Create directory: `packages/new-package/`
2. Add `package.json` with workspace dependencies
3. Update root `package.json` workspaces array
4. Run `npm install` to link

## Best Practices

### Package Dependencies

- **Internal dependencies**: Always use workspace protocol
  ```json
  {
    "dependencies": {
      "@whisperchain/core": "^1.0.0"
    }
  }
  ```

- **External dependencies**: Pin major versions
  ```json
  {
    "dependencies": {
      "ethers": "^6.9.0"
    }
  }
  ```

### Versioning

- All packages follow **semantic versioning**
- Major version bumps require coordination across packages
- Use `npm version` for version management

### Testing

- Each package has its own test suite
- Shared test utilities in `@whisperchain/test-utils` (future)
- Minimum 70% code coverage

### Documentation

- Every package has a detailed README
- API documentation using TSDoc
- Examples for common use cases

## Continuous Integration

The ecosystem uses GitHub Actions for CI/CD:

- **Build**: Compile all packages
- **Test**: Run all test suites
- **Lint**: Check code style
- **Type Check**: Verify TypeScript types
- **Coverage**: Measure test coverage
- **Publish**: Automated NPM publishing

## Future Roadmap

### Planned Packages

- `@whisperchain/contracts` - Smart contract ABIs and utilities
- `@whisperchain/test-utils` - Testing utilities
- `@whisperchain/react` - React hooks and components
- `@whisperchain/indexer` - Blockchain indexing service
- `@whisperchain/wallet` - Wallet management library

### Planned Features

- **Multi-signature wallets**
- **Gasless transactions**
- **Cross-chain bridges**
- **Decentralized storage integration**
- **NFT marketplace SDK**

## Contributing to the Ecosystem

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### Adding a New Package

1. Fork the repository
2. Create your package in `packages/your-package/`
3. Follow the existing package structure
4. Add comprehensive tests
5. Update this documentation
6. Submit a pull request

### Reporting Issues

Report bugs and feature requests on [GitHub Issues](https://github.com/pavlenkotm/WhisperChain/issues).

## License

All packages are licensed under **MIT License**.

---

**Built with ❤️ by the WhisperChain community**
