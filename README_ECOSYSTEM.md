# 🌐 WhisperChain Ecosystem

> **A comprehensive Web3 development ecosystem with multi-language examples, shared packages, and developer tools**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![npm version](https://img.shields.io/npm/v/@whisperchain/sdk.svg)](https://www.npmjs.com/package/@whisperchain/sdk)
[![CI Status](https://github.com/pavlenkotm/WhisperChain/workflows/Ecosystem%20CI/badge.svg)](https://github.com/pavlenkotm/WhisperChain/actions)

## 🎯 What's New in the Ecosystem?

WhisperChain has evolved into a **full-fledged development ecosystem** with:

✅ **NPM Packages** - Production-ready libraries for Web3 development
✅ **CLI Tools** - Command-line interface for developers
✅ **SDK** - Comprehensive JavaScript/TypeScript SDK
✅ **Monorepo** - Organized workspace with shared configurations
✅ **24+ Languages** - Multi-language blockchain examples
✅ **Type Safety** - Full TypeScript support across packages

## 📦 Core Packages

| Package | Description | Version |
|---------|-------------|---------|
| [@whisperchain/types](packages/types) | TypeScript type definitions | 1.0.0 |
| [@whisperchain/core](packages/core) | Core utilities and helpers | 1.0.0 |
| [@whisperchain/crypto](packages/crypto) | Cryptographic primitives | 1.0.0 |
| [@whisperchain/sdk](packages/sdk) | Main SDK for developers | 1.0.0 |
| [@whisperchain/cli](packages/cli) | Command-line tools | 1.0.0 |

## 🚀 Quick Start

### Install the SDK

```bash
npm install @whisperchain/sdk
```

### Use in Your Project

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
  'Hello, Web3!',
  3600 // expires in 1 hour
);

// Check balance
const balance = await client.blockchain.getBalance('0x...');
console.log(`Balance: ${balance} ETH`);
```

### Install the CLI

```bash
npm install -g @whisperchain/cli
```

### Use CLI Commands

```bash
# Initialize new project
whisperchain init --template dapp --name my-project

# Create wallet
whisperchain wallet create

# Check balance
whisperchain wallet balance 0x123...

# Generate encryption keys
whisperchain message keygen

# List supported networks
whisperchain network list
```

## 🏗️ Monorepo Structure

```
WhisperChain/
├── packages/           # NPM packages
│   ├── types/         # Type definitions
│   ├── core/          # Core utilities
│   ├── crypto/        # Cryptography
│   ├── sdk/           # Main SDK
│   └── cli/           # CLI tools
│
├── examples/          # 24+ language examples
│   ├── solidity/      # Ethereum contracts
│   ├── typescript/    # Web3 DApps
│   ├── python/        # Backend scripts
│   ├── rust/          # Solana programs
│   └── ... (20+ more)
│
└── docs/              # Documentation
    ├── ECOSYSTEM.md   # Architecture guide
    ├── API.md         # API reference
    └── GUIDES.md      # Developer guides
```

## 🎓 Documentation

- **[Ecosystem Architecture](docs/ECOSYSTEM.md)** - Complete ecosystem overview
- **[API Reference](docs/API.md)** - Detailed API documentation
- **[Developer Guides](docs/GUIDES.md)** - Step-by-step tutorials
- **[Original App](README_ORIGINAL_APP.md)** - WhisperChain messaging app

## 🔧 Development

### Setup Monorepo

```bash
# Clone repository
git clone https://github.com/pavlenkotm/WhisperChain.git
cd WhisperChain

# Install all dependencies
npm install

# Build all packages
npm run build

# Run all tests
npm test
```

### Work with Packages

```bash
# Build specific package
cd packages/sdk
npm run build

# Test specific package
npm test

# Link for local development
npm link
```

## 🌐 Supported Blockchains

| Blockchain | Languages | Packages |
|------------|-----------|----------|
| **Ethereum** | Solidity, Vyper, TypeScript | `@whisperchain/sdk` |
| **Solana** | Rust | Examples only |
| **Aptos** | Move | Examples only |
| **StarkNet** | Cairo | Examples only |
| **Polkadot** | Rust (Substrate), ink! | Examples only |
| **Cardano** | Haskell (Plutus) | Examples only |
| **Tezos** | OCaml | Examples only |
| **Stacks** | Clarity | Examples only |
| **ICP** | Motoko | Examples only |

## 📊 Package Features

### @whisperchain/sdk

- ✅ Multi-chain support (Ethereum, Solana, and more)
- ✅ End-to-end encryption for messaging
- ✅ Wallet operations (create, sign, send)
- ✅ Smart contract interactions
- ✅ Transaction management
- ✅ Gas estimation and optimization
- ✅ Event listening and filtering
- ✅ Full TypeScript support

### @whisperchain/crypto

- ✅ Public key encryption (X25519-XSalsa20-Poly1305)
- ✅ Digital signatures (Ed25519)
- ✅ Symmetric encryption (XSalsa20-Poly1305)
- ✅ Key derivation (PBKDF2, HKDF)
- ✅ Secure random generation
- ✅ Hash functions (SHA-512)
- ✅ Zero dependencies (uses TweetNaCl)

### @whisperchain/cli

- ✅ Project scaffolding (DApp, Contract, Backend templates)
- ✅ Wallet management
- ✅ Encrypted messaging
- ✅ Contract compilation and deployment
- ✅ Network status monitoring
- ✅ Interactive prompts
- ✅ Colorful output

## 🛠️ Scripts

```bash
# Monorepo scripts
npm run build          # Build all packages
npm run test           # Test all packages
npm run lint           # Lint all code
npm run clean          # Clean build artifacts
npm run dev            # Run in development mode

# Package-specific
npm run build -w @whisperchain/sdk     # Build SDK only
npm run test -w @whisperchain/crypto   # Test crypto only
```

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for details.

### Areas to Contribute

- 🐛 Bug fixes in packages
- ✨ New features for SDK
- 📚 Documentation improvements
- 🧪 Additional test coverage
- 🌍 New language examples
- 🎨 CLI improvements

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Solana Foundation** - Blockchain platform
- **Ethereum Foundation** - Smart contract pioneer
- **NaCl/TweetNaCl** - Cryptography library
- **Ethers.js** - Ethereum library
- **All Contributors** - Building the Web3 future

## 📞 Connect

- **GitHub**: [pavlenkotm/WhisperChain](https://github.com/pavlenkotm/WhisperChain)
- **Issues**: [Report bugs](https://github.com/pavlenkotm/WhisperChain/issues)
- **Discussions**: [Join conversation](https://github.com/pavlenkotm/WhisperChain/discussions)
- **NPM**: [@whisperchain](https://www.npmjs.com/org/whisperchain)

## ⭐ Star the Project

If you find WhisperChain useful, please give it a ⭐ on GitHub!

---

**Built with ❤️ for the Web3 developer community**

*From a simple chat app to a comprehensive ecosystem - WhisperChain demonstrates the future of blockchain development.*
