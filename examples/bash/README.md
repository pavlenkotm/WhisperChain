# 🔧 Bash Deployment Scripts

Professional Bash scripts for Ethereum node management and smart contract deployment.

## 📋 Scripts

### 1. deploy-contract.sh
- **Purpose**: Deploy smart contracts to Ethereum networks
- **Features**:
  - ✅ Support for Foundry and Hardhat
  - ✅ Multi-network deployment
  - ✅ Automatic compilation
  - ✅ Contract verification
  - ✅ Deployment tracking
  - ✅ Environment variable support

### 2. node-setup.sh
- **Purpose**: Set up and manage Ethereum nodes
- **Features**:
  - ✅ Geth devnet setup
  - ✅ Hardhat node support
  - ✅ Anvil (Foundry) support
  - ✅ Start/stop management
  - ✅ Status checking
  - ✅ Account management

## 🚀 Quick Start

### Prerequisites
```bash
# Make scripts executable
chmod +x examples/bash/*.sh

# Install dependencies (choose one)
# Foundry (recommended)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Or Hardhat
npm install --global hardhat

# Optional: jq for JSON parsing
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS
```

## 📖 Usage Examples

### Deploy Contracts

#### Basic Deployment
```bash
cd examples/bash

# Set environment variables
export PRIVATE_KEY="0x..."
export RPC_URL="http://localhost:8545"
export NETWORK="localhost"

# Deploy
./deploy-contract.sh
```

#### Deploy to Testnet
```bash
# Sepolia testnet
export NETWORK="sepolia"
export RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
export PRIVATE_KEY="0x..."

./deploy-contract.sh
```

#### Using .env File
```bash
# Create .env file
cat > .env <<EOF
NETWORK=localhost
RPC_URL=http://localhost:8545
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
CONTRACT_PATH=contracts/
ETHERSCAN_API_KEY=YOUR_KEY
EOF

# Deploy (will auto-load .env)
./deploy-contract.sh
```

### Node Management

#### Start Hardhat Node
```bash
# Start Hardhat node (fastest for development)
NODE_TYPE=hardhat ./node-setup.sh start

# In another terminal
./node-setup.sh status
./node-setup.sh accounts
```

#### Start Anvil Node
```bash
# Start Anvil (Foundry's local node)
NODE_TYPE=anvil HTTP_PORT=8545 ./node-setup.sh start

# Check status
./node-setup.sh status
```

#### Start Geth Devnet
```bash
# Setup Geth devnet (first time only)
NODE_TYPE=geth ./node-setup.sh setup

# Start node
NODE_TYPE=geth ./node-setup.sh start

# Check status
./node-setup.sh status

# Stop node
./node-setup.sh stop
```

#### Custom Configuration
```bash
# Start on different port
HTTP_PORT=9545 NODE_TYPE=hardhat ./node-setup.sh start

# Custom chain ID
CHAIN_ID=31337 NODE_TYPE=anvil ./node-setup.sh start

# Custom data directory
DATA_DIR=/tmp/eth-node NODE_TYPE=geth ./node-setup.sh setup
```

## 🔧 Advanced Usage

### Custom Deployment Script
```bash
#!/bin/bash
source examples/bash/deploy-contract.sh

# Deploy multiple contracts
deploy_all() {
    log_info "Deploying all contracts..."

    # Deploy Token
    TOKEN_ADDR=$(deploy_with_forge "WhisperToken" \
        '"0xYourAddress"')

    # Deploy NFT
    NFT_ADDR=$(deploy_with_forge "WhisperNFT" \
        '"0xYourAddress"')

    # Save deployments
    save_deployment "WhisperToken" "$TOKEN_ADDR" "$NETWORK"
    save_deployment "WhisperNFT" "$NFT_ADDR" "$NETWORK"

    log_info "All contracts deployed!"
}

deploy_all
```

### Automated Testing Pipeline
```bash
#!/bin/bash

# Start local node
NODE_TYPE=anvil ./node-setup.sh start
sleep 2

# Deploy contracts
./deploy-contract.sh

# Run tests
npm test

# Stop node
./node-setup.sh stop
```

### Multi-Network Deployment
```bash
#!/bin/bash

networks=("localhost" "sepolia" "mainnet")

for network in "${networks[@]}"; do
    echo "Deploying to $network..."

    NETWORK=$network ./deploy-contract.sh

    echo "$network deployment complete"
done
```

## 📊 Script Functions

### deploy-contract.sh Functions

| Function | Description |
|----------|-------------|
| `check_dependencies()` | Verify required tools installed |
| `load_env()` | Load .env file variables |
| `compile_contracts()` | Compile Solidity contracts |
| `deploy_with_forge()` | Deploy using Foundry |
| `deploy_with_hardhat()` | Deploy using Hardhat |
| `verify_contract()` | Verify on Etherscan |
| `save_deployment()` | Save deployment info to JSON |

### node-setup.sh Functions

| Function | Description |
|----------|-------------|
| `setup_geth_devnet()` | Initialize Geth devnet |
| `start_geth()` | Start Geth node |
| `start_hardhat()` | Start Hardhat node |
| `start_anvil()` | Start Anvil node |
| `stop_node()` | Stop running node |
| `check_node_status()` | Check if node is running |
| `show_accounts()` | Display available accounts |

## 🔐 Security Best Practices

### Private Key Management
```bash
# ❌ Bad: Hardcode private key
PRIVATE_KEY="0x..."

# ✅ Good: Use .env (gitignored)
echo "PRIVATE_KEY=0x..." >> .env
echo ".env" >> .gitignore

# ✅ Better: Use environment variable
export PRIVATE_KEY=$(cat ~/.secrets/private-key)

# ✅ Best: Use hardware wallet or keystore
cast send --ledger ...
```

### Network Validation
```bash
# Validate network before deployment
validate_network() {
    case "$NETWORK" in
        localhost|hardhat|anvil)
            log_info "Deploying to local network"
            ;;
        sepolia|goerli)
            log_warn "Deploying to testnet"
            read -p "Continue? (y/n) " -n 1 -r
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
            ;;
        mainnet)
            log_error "Deploying to MAINNET!"
            read -p "Are you SURE? (yes/no) " REPLY
            [[ ! $REPLY == "yes" ]] && exit 1
            ;;
        *)
            log_error "Unknown network: $NETWORK"
            exit 1
            ;;
    esac
}
```

## 📚 Common Patterns

### Wait for Transaction
```bash
wait_for_tx() {
    local tx_hash=$1

    echo "Waiting for transaction: $tx_hash"

    while true; do
        local receipt=$(cast receipt $tx_hash --rpc-url $RPC_URL 2>/dev/null)

        if [ -n "$receipt" ]; then
            echo "Transaction confirmed!"
            echo "$receipt"
            break
        fi

        echo -n "."
        sleep 2
    done
}
```

### Gas Price Estimation
```bash
get_gas_price() {
    cast gas-price --rpc-url $RPC_URL
}

estimate_gas() {
    local to=$1
    local data=$2

    cast estimate \
        --to $to \
        --data $data \
        --rpc-url $RPC_URL
}
```

### Balance Checking
```bash
check_balance() {
    local address=$1

    local balance=$(cast balance $address --rpc-url $RPC_URL)
    local eth=$(cast --to-unit $balance ether)

    echo "Balance: $eth ETH"
}
```

## 📄 Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `NETWORK` | Target network | `localhost`, `sepolia`, `mainnet` |
| `RPC_URL` | RPC endpoint | `http://localhost:8545` |
| `PRIVATE_KEY` | Deployer private key | `0x...` |
| `CONTRACT_PATH` | Contract directory | `contracts/` |
| `ETHERSCAN_API_KEY` | Etherscan API key | For verification |
| `NODE_TYPE` | Node to use | `geth`, `hardhat`, `anvil` |
| `HTTP_PORT` | RPC HTTP port | `8545` |
| `WS_PORT` | WebSocket port | `8546` |
| `CHAIN_ID` | Chain ID | `1337` |
| `DATA_DIR` | Node data directory | `./data` |

## 🤝 Contributing

Contributions welcome! Please ensure:
- Scripts follow bash best practices
- Use `set -euo pipefail`
- Include error handling
- Add logging with colors
- Document all functions

## 📄 License

MIT License - see LICENSE file for details
