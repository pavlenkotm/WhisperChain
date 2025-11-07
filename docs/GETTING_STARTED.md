# 🚀 Getting Started with WhisperChain

Complete guide for exploring the WhisperChain multi-language repository.

## Prerequisites

### General Requirements
- **Git**: Version control
- **Code editor**: VS Code, IntelliJ, or your favorite IDE
- **Terminal**: Bash, Zsh, or PowerShell

### Language-Specific Tools

#### Solidity & Vyper (EVM)
```bash
# Foundry (recommended)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Or Hardhat
npm install -g hardhat

# Vyper
pip install vyper
```

#### TypeScript & JavaScript
```bash
node --version  # v18+
npm install -g typescript ts-node
```

#### Python
```bash
python --version  # 3.8+
pip install web3 eth-account pytest
```

#### Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable
```

#### Go
```bash
# Download from https://golang.org/dl/
go version  # 1.21+
```

## Quick Start by Language

### 1. Solidity (Ethereum)
```bash
cd examples/solidity
npm install
npm test
npm run deploy:local
```

### 2. Python (Web3 Utilities)
```bash
cd examples/python
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python web3_utils.py
```

### 3. TypeScript (DApp Development)
```bash
cd examples/typescript
npm install
npm run build
```

### 4. Go (Backend Services)
```bash
cd examples/go
go mod download
go test ./...
go build
```

## Repository Navigation

```
WhisperChain/
├── examples/          ← START HERE for language examples
│   ├── solidity/     ← Smart contracts
│   ├── python/       ← Backend scripts
│   ├── typescript/   ← DApp frontend
│   └── ...
├── program/          ← Original Solana program
├── app/              ← Original React app
└── docs/             ← Additional documentation
```

## Learning Paths

### Path 1: Smart Contract Developer
1. **Solidity** (`examples/solidity`) - ERC-20 & ERC-721
2. **Vyper** (`examples/vyper`) - Alternative syntax
3. **Move** (`examples/move-aptos`) - Resource-oriented
4. **Cairo** (`examples/cairo`) - Zero-knowledge proofs

### Path 2: Backend Developer
1. **Python** (`examples/python`) - Web3.py basics
2. **TypeScript** (`examples/typescript`) - Ethers.js
3. **Go** (`examples/go`) - High-performance services
4. **Java** (`examples/java`) - Enterprise backend

### Path 3: Full-Stack Web3 Developer
1. **TypeScript** - Frontend + Backend
2. **Solidity** - Smart contracts
3. **Python** - Scripts & automation
4. **Bash** - Deployment

## Common Tasks

### Deploy a Smart Contract
```bash
# Using Foundry
cd examples/solidity
forge create src/ERC20Token.sol:WhisperToken \
  --rpc-url http://localhost:8545 \
  --private-key 0x...

# Using Hardhat
npx hardhat run scripts/deploy.js --network localhost
```

### Run Tests
```bash
# Solidity
cd examples/solidity && npm test

# Python
cd examples/python && pytest

# Go
cd examples/go && go test ./...

# TypeScript
cd examples/typescript && npm test
```

### Start Local Blockchain
```bash
# Hardhat
npx hardhat node

# Anvil (Foundry)
anvil

# Geth devnet
cd examples/bash && ./node-setup.sh start
```

## Troubleshooting

### Common Issues

**Issue**: `command not found`
- **Solution**: Install the required language/tool

**Issue**: `Module not found`
- **Solution**: Run `npm install`, `pip install -r requirements.txt`, or `go mod download`

**Issue**: `Connection refused`
- **Solution**: Start a local blockchain node first

**Issue**: `Gas estimation failed`
- **Solution**: Check your contract logic or increase gas limit

## Next Steps

1. ✅ Clone the repository
2. ✅ Install prerequisites
3. ✅ Pick a language example
4. ✅ Read the specific README
5. ✅ Run the example
6. ✅ Modify and experiment
7. ✅ Contribute back!

## Resources

- [Main README](../README.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [Code of Conduct](../CODE_OF_CONDUCT.md)
- [Security Policy](../SECURITY.md)

## Support

- 🐛 **Bugs**: [Open an issue](https://github.com/pavlenkotm/WhisperChain/issues)
- 💬 **Questions**: [Discussions](https://github.com/pavlenkotm/WhisperChain/discussions)
- 📧 **Contact**: See README for contact info

Happy coding! 🚀
