# 🔺 Cairo Smart Contracts (StarkNet)

Cairo smart contracts for StarkNet L2 scaling solution with zero-knowledge proofs.

## 📋 Contracts

- **token.cairo**: ERC-20 token implementation
- Supports transfer, approve, transferFrom
- Built with Cairo 1.0+ syntax

## 🚀 Setup

```bash
# Install Cairo
curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash

# Or use scarb
curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | sh
```

## 📖 Compile & Deploy

```bash
# Compile
scarb build

# Test
scarb test

# Deploy to testnet
starkli deploy target/dev/whisper_token.sierra.json
```

## 📚 Resources
- [Cairo Book](https://book.cairo-lang.org/)
- [StarkNet Docs](https://docs.starknet.io/)
