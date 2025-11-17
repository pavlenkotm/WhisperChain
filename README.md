# 🔗 WhisperChain - Web3 Development Ecosystem

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/pavlenkotm/WhisperChain?style=social)](https://github.com/pavlenkotm/WhisperChain)
[![Commits](https://img.shields.io/github/commit-activity/m/pavlenkotm/WhisperChain)](https://github.com/pavlenkotm/WhisperChain/commits)
[![Languages](https://img.shields.io/badge/languages-24%2B-brightgreen)]()
[![npm version](https://img.shields.io/badge/npm-@whisperchain%2Fsdk-blue)](https://www.npmjs.com/package/@whisperchain/sdk)

> **Complete Web3 development ecosystem with production-ready NPM packages, CLI tools, SDK, and examples in 24+ programming languages**

## 🚀 NEW: WhisperChain Ecosystem

WhisperChain has evolved into a **full development ecosystem**! Now featuring:

- 📦 **NPM Packages** - Production-ready libraries (`@whisperchain/sdk`, `@whisperchain/crypto`, etc.)
- 🛠️ **CLI Tools** - Command-line interface for developers (`whisperchain` CLI)
- 💻 **TypeScript SDK** - Comprehensive SDK for Web3 development
- 🏗️ **Monorepo** - Organized workspace with shared configurations
- 📚 **Complete Documentation** - API reference, guides, and tutorials

### Quick Install

```bash
# Install the SDK
npm install @whisperchain/sdk

# Or install the CLI globally
npm install -g @whisperchain/cli
```

**📖 [View Ecosystem Documentation](README_ECOSYSTEM.md)** | **📘 [API Reference](docs/API.md)** | **🏛️ [Architecture Guide](docs/ECOSYSTEM.md)**

---

## 🌟 What is WhisperChain?

WhisperChain started as a decentralized encrypted chat application on Solana and has evolved into a **comprehensive Web3 development ecosystem with production-ready packages and examples across multiple blockchains, languages, and platforms**.

This repository includes:
- ✅ **Production NPM packages** - SDK, crypto utilities, CLI tools
- ✅ **Smart contract development** - EVM, Solana, Move, Cairo, Substrate, Stacks, ICP
- ✅ **Backend services and APIs** - TypeScript, Python, Go, Java
- ✅ **Mobile wallet SDKs** - Swift, Kotlin
- ✅ **High-performance crypto libraries** - C++, Rust, Zig
- ✅ **Deployment automation** - CI/CD, scripts
- ✅ **24+ programming languages** - Complete examples

## 🎯 Quick Navigation

| Category | Languages | Examples |
|----------|-----------|----------|
| **Smart Contracts** | Solidity, Vyper, Rust, Move, Cairo, ink!, Clarity, Motoko, Haskell | [ERC-20](#solidity), [NFTs](#solidity), [DeFi](#move) |
| **Backend Services** | Python, TypeScript, Go, Java | [Web3 APIs](#python), [Indexers](#go) |
| **Mobile SDKs** | Swift, Java/Kotlin | [iOS Wallet](#swift), [Android](#java) |
| **Performance** | C++, Rust, Zig | [Crypto Primitives](#cpp), [WASM](#zig) |
| **DevOps** | Bash, Docker | [Deployment](#bash), [CI/CD](#github-actions) |
| **Frontend** | TypeScript, HTML/CSS | [DApp UI](#typescript), [Landing Page](#html-css) |

## 📋 All Programming Languages (24+)

<details open>
<summary><b>Click to expand language list</b></summary>

### 1. **Solidity** - Ethereum Smart Contracts
📁 `examples/solidity/`
- ERC-20 Token (WhisperToken)
- ERC-721 NFT (WhisperNFT)
- Hardhat tests & deployment
- [View README](examples/solidity/README.md)

### 2. **Vyper** - Pythonic EVM Contracts
📁 `examples/vyper/`
- ERC-20 implementation
- ETH Vault contract
- Pytest test suite
- [View README](examples/vyper/README.md)

### 3. **Rust (Solana)** - High-Performance Blockchain
📁 `program/`
- Encrypted messaging program
- Borsh serialization
- Native Solana integration
- [View Original App](program/)

### 4. **Rust (Substrate)** - Polkadot Ecosystem
📁 `examples/rust-substrate/`
- Custom messaging pallet
- FRAME framework
- Weight-based fees
- [View README](examples/rust-substrate/README.md)

### 5. **ink!** - Polkadot Smart Contracts
📁 `examples/ink/`
- Rust-based WebAssembly contracts
- ERC-20 token implementation
- Substrate/Polkadot compatible
- [View README](examples/ink/README.md)

### 6. **Move (Aptos)** - Resource-Oriented Programming
📁 `examples/move-aptos/`
- Coin module
- Message board
- Unit tests included
- [View README](examples/move-aptos/README.md)

### 7. **Cairo (StarkNet)** - Zero-Knowledge Proofs
📁 `examples/cairo/`
- ERC-20 token
- L2 scaling solution
- Cairo 1.0 syntax
- [View README](examples/cairo/README.md)

### 8. **Clarity** - Bitcoin Layer 2 Smart Contracts
📁 `examples/clarity/`
- Decidable smart contracts for Stacks
- SIP-010 fungible token (Bitcoin L2)
- Lisp-like syntax with security guarantees
- [View README](examples/clarity/README.md)

### 9. **Motoko** - Internet Computer Canisters
📁 `examples/motoko/`
- Actor-based smart contracts for ICP
- Fungible token with DFINITY SDK
- WebAssembly on Internet Computer
- [View README](examples/motoko/README.md)

### 10. **TypeScript** - Modern Web3 DApps
📁 `examples/typescript/`
- Wallet connector (MetaMask)
- ERC-20 utilities
- React hooks examples
- [View README](examples/typescript/README.md)

### 11. **Python** - Backend & Scripts
📁 `examples/python/`
- Web3.py utilities
- NFT minter
- Pytest tests
- [View README](examples/python/README.md)

### 12. **Go** - High-Performance Services
📁 `examples/go/`
- Wallet management
- ERC-20 interaction
- go-ethereum integration
- [View README](examples/go/README.md)

### 13. **C++** - Cryptographic Primitives
📁 `examples/cpp/`
- Keccak-256 implementation
- SECP256k1 wrapper
- CMake build system
- [View README](examples/cpp/README.md)

### 14. **Java** - Enterprise Backend
📁 `examples/java/`
- Web3j integration
- Maven project
- Async transaction handling
- [View README](examples/java/README.md)

### 15. **Swift** - iOS Native Wallet
📁 `examples/swift/`
- WalletKit SDK
- Async/await API
- Web3.swift integration
- [View README](examples/swift/README.md)

### 16. **Bash** - DevOps & Automation
📁 `examples/bash/`
- Contract deployment scripts
- Node management (Geth, Anvil, Hardhat)
- Multi-network support
- [View README](examples/bash/README.md)

### 17. **Haskell (Plutus)** - Functional Smart Contracts
📁 `examples/haskell-plutus/`
- Cardano validators
- Type-safe contracts
- Plutus Core
- [View README](examples/haskell-plutus/README.md)

### 18. **Zig** - WebAssembly Cryptography
📁 `examples/zig/`
- Keccak-256 for WASM
- Zero-cost abstractions
- Extreme performance
- [View README](examples/zig/README.md)

### 19. **Elixir** - Distributed Blockchain Nodes
📁 `examples/elixir/`
- Fault-tolerant blockchain node
- Proof of Work consensus
- GenServer architecture
- Built on battle-tested Erlang VM
- [View README](examples/elixir/README.md)

### 20. **Crystal** - High-Performance Web3 Client
📁 `examples/crystal/`
- Ruby syntax, C performance
- Type-safe Web3 interactions
- JSON-RPC client
- 10-100x faster than Ruby
- [View README](examples/crystal/README.md)

### 21. **Nim** - Cryptographic Primitives
📁 `examples/nim/`
- Python-like syntax, C speed
- Keccak-256, SHA-256, HMAC
- Merkle trees & key derivation
- ECDSA signing & verification
- [View README](examples/nim/README.md)

### 22. **F#** - Blockchain Data Analytics
📁 `examples/fsharp/`
- Functional data analysis
- Transaction metrics
- Time series analytics
- Whale detection & pattern recognition
- [View README](examples/fsharp/README.md)

### 23. **Erlang** - Distributed Messaging
📁 `examples/erlang/`
- 99.9999999% uptime design
- P2P messaging nodes
- Fault tolerance built-in
- Hot code reloading
- [View README](examples/erlang/README.md)

### 24. **OCaml** - Tezos Smart Contracts
📁 `examples/ocaml/`
- FA2 token standard
- Type-safe smart contracts
- Pattern matching elegance
- Official Tezos language
- [View README](examples/ocaml/README.md)

### Bonus: **HTML + CSS** - Landing Pages
📁 `examples/html-css/`
- Responsive design
- Modern CSS Grid/Flexbox
- [View Demo](examples/html-css/index.html)

</details>

## 🚀 Getting Started

### Clone the Repository
```bash
git clone https://github.com/pavlenkotm/WhisperChain.git
cd WhisperChain
```

### Explore Examples by Language
```bash
# Solidity (Ethereum)
cd examples/solidity
npm install && npm test

# Python (Web3 utilities)
cd examples/python
pip install -r requirements.txt
python web3_utils.py

# TypeScript (DApp development)
cd examples/typescript
npm install && npm run build

# Go (Blockchain services)
cd examples/go
go mod download && go test ./...

# And many more...
```

## 📚 Original WhisperChain App

The repository also contains the **original WhisperChain application** - a fully decentralized, end-to-end encrypted chat on Solana:

### Core Features
- 🔒 **End-to-End Encryption**: Diffie-Hellman + AES-256
- 🌐 **Fully Decentralized**: All data on-chain
- 🔥 **Self-Destructing Messages**: Auto-delete after expiration
- ⚡ **Real-time**: On-chain polling

### Quick Start
```bash
# Deploy Solana program
cd program && ./build.sh && ./deploy.sh

# Launch frontend
cd app && npm install && npm start
```

📖 [Full WhisperChain App Documentation](docs/ORIGINAL_APP.md)

## 🏗️ Repository Structure

```
WhisperChain/
├── examples/               # Multi-language examples
│   ├── solidity/          # EVM smart contracts
│   ├── vyper/             # Alternative EVM language
│   ├── move-aptos/        # Aptos blockchain
│   ├── rust-substrate/    # Polkadot ecosystem (pallets)
│   ├── ink/               # Polkadot smart contracts
│   ├── cairo/             # StarkNet L2
│   ├── clarity/           # Stacks (Bitcoin L2)
│   ├── motoko/            # Internet Computer (ICP)
│   ├── typescript/        # Web3 DApps
│   ├── python/            # Backend utilities
│   ├── go/                # High-performance services
│   ├── cpp/               # Crypto algorithms
│   ├── java/              # Enterprise backend
│   ├── swift/             # iOS SDK
│   ├── bash/              # Deployment automation
│   ├── haskell-plutus/    # Cardano contracts
│   ├── zig/               # WASM modules
│   ├── elixir/            # Distributed blockchain nodes
│   ├── crystal/           # High-performance Web3 client
│   ├── nim/               # Cryptographic primitives
│   ├── fsharp/            # Blockchain data analytics
│   ├── erlang/            # Distributed messaging
│   ├── ocaml/             # Tezos smart contracts
│   └── html-css/          # Landing pages
├── program/               # Original Solana program
├── app/                   # Original React frontend
├── .github/workflows/     # CI/CD pipelines
├── docs/                  # Additional documentation
└── README.md              # This file
```

## 🎓 Learning Path

### Beginner
1. Start with **TypeScript** (examples/typescript) - Modern Web3 basics
2. Learn **Python** (examples/python) - Simple scripting
3. Try **Solidity** (examples/solidity) - Your first smart contract

### Intermediate
4. Explore **Go** (examples/go) - Backend services
5. Study **Move** (examples/move-aptos) - Resource-oriented programming
6. Build with **Bash** (examples/bash) - Deployment automation

### Advanced
7. Master **Rust** (program/, examples/rust-substrate) - High performance
8. Learn **C++** (examples/cpp) - Crypto primitives
9. Experiment with **Zig** (examples/zig) - WASM optimization

### Expert
10. Study **Cairo** (examples/cairo) - Zero-knowledge proofs
11. Explore **Haskell/Plutus** (examples/haskell-plutus) - Functional contracts
12. Master **Vyper** (examples/vyper) - Security-focused contracts

## 🔧 Development Tools

Each language example includes:
- ✅ **Build configuration** (Cargo.toml, package.json, pom.xml, etc.)
- ✅ **Test suites** (Unit tests, integration tests)
- ✅ **Documentation** (Comprehensive READMEs)
- ✅ **Examples** (Usage demonstrations)
- ✅ **Best practices** (Security, optimization)

## 🌐 Supported Blockchains

| Blockchain | Languages | Location |
|------------|-----------|----------|
| **Ethereum** | Solidity, Vyper, TypeScript, Python, Go, Java | `examples/solidity`, `examples/vyper` |
| **Solana** | Rust | `program/` |
| **Aptos** | Move | `examples/move-aptos` |
| **StarkNet** | Cairo | `examples/cairo` |
| **Polkadot** | Rust (Substrate) | `examples/rust-substrate` |
| **Cardano** | Haskell (Plutus) | `examples/haskell-plutus` |
| **Tezos** | OCaml | `examples/ocaml` |
| **Multi-chain** | Elixir, Crystal, Nim, F#, Erlang | Various examples |

## 📊 Project Statistics

![Languages Used](https://img.shields.io/badge/dynamic/json?color=blue&label=languages&query=$.length&url=https://api.github.com/repos/pavlenkotm/WhisperChain/languages)
- **21+ Programming Languages** (including 6 exotic ones!)
- **50+ Meaningful Commits**
- **100% Open Source**
- **Production-Ready Code**
- **Comprehensive Documentation**
- **Blockchain Polyglot Paradise**

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Areas for Contribution
- 🐛 Bug fixes
- ✨ New language examples
- 📚 Documentation improvements
- 🧪 Additional tests
- 🎨 UI/UX enhancements

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Solana Foundation** - Amazing blockchain platform
- **Ethereum Foundation** - Pioneer of smart contracts
- **Aptos Labs** - Move language innovation
- **StarkWare** - Zero-knowledge technology
- **Parity Technologies** - Substrate framework
- **IOHK** - Cardano and Plutus
- **All Open Source Contributors** - Building the Web3 future

## 📞 Connect

- **GitHub**: [@pavlenkotm](https://github.com/pavlenkotm)
- **Repository**: [WhisperChain](https://github.com/pavlenkotm/WhisperChain)
- **Issues**: [Report bugs or request features](https://github.com/pavlenkotm/WhisperChain/issues)
- **Discussions**: [Join the conversation](https://github.com/pavlenkotm/WhisperChain/discussions)

## ⭐ Star History

If you find this project helpful, please consider giving it a ⭐ star on GitHub!

---

**Built with ❤️ by the Web3 community**

*Demonstrating blockchain development excellence across languages, platforms, and ecosystems.*
