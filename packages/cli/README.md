# @whisperchain/cli

Command-line interface for the WhisperChain ecosystem.

## Installation

```bash
npm install -g @whisperchain/cli
```

## Usage

### Initialize New Project

```bash
whisperchain init --template dapp --name my-project
```

### Wallet Commands

```bash
# Create wallet
whisperchain wallet create

# Check balance
whisperchain wallet balance 0x123...
```

### Messaging Commands

```bash
# Generate encryption keys
whisperchain message keygen

# Send encrypted message
whisperchain message send <recipient-public-key> "Hello!"
```

### Smart Contract Commands

```bash
# Compile contract
whisperchain contract compile path/to/contract.sol

# Deploy contract
whisperchain contract deploy path/to/contract.sol --network mainnet

# Interact with contract
whisperchain contract interact 0xContractAddress...
```

### Network Commands

```bash
# List supported networks
whisperchain network list

# Check network status
whisperchain network status ethereum
```

## Project Templates

- `dapp` - DApp with React frontend
- `contract` - Smart contract project
- `backend` - Backend service

## License

MIT
