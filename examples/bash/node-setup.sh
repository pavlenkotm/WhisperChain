#!/usr/bin/env bash

##############################################################################
# Ethereum Node Setup Script
# Sets up and manages local Ethereum development nodes
##############################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
NODE_TYPE="${NODE_TYPE:-geth}"
NETWORK="${NETWORK:-devnet}"
DATA_DIR="${DATA_DIR:-./data}"
HTTP_PORT="${HTTP_PORT:-8545}"
WS_PORT="${WS_PORT:-8546}"
CHAIN_ID="${CHAIN_ID:-1337}"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_geth() {
    if ! command -v geth &> /dev/null; then
        log_error "Geth not found. Install from https://geth.ethereum.org/"
        exit 1
    fi
    log_info "Geth version: $(geth version | head -n 1)"
}

check_hardhat() {
    if ! command -v npx &> /dev/null; then
        log_error "Node.js/npm not found"
        exit 1
    fi
    log_info "Node.js ready"
}

setup_geth_devnet() {
    log_info "Setting up Geth devnet..."

    mkdir -p "$DATA_DIR"

    # Create genesis.json
    cat > "$DATA_DIR/genesis.json" <<EOF
{
  "config": {
    "chainId": $CHAIN_ID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0
  },
  "difficulty": "1",
  "gasLimit": "8000000",
  "alloc": {
    "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb": {
      "balance": "100000000000000000000"
    }
  }
}
EOF

    log_info "Initializing Geth with genesis..."
    geth --datadir "$DATA_DIR" init "$DATA_DIR/genesis.json"

    log_info "Geth devnet setup complete"
}

start_geth() {
    log_info "Starting Geth node..."

    geth \
        --datadir "$DATA_DIR" \
        --http \
        --http.addr "0.0.0.0" \
        --http.port "$HTTP_PORT" \
        --http.api "eth,net,web3,personal,admin,debug" \
        --ws \
        --ws.addr "0.0.0.0" \
        --ws.port "$WS_PORT" \
        --ws.api "eth,net,web3" \
        --allow-insecure-unlock \
        --dev \
        --dev.period 1 \
        --verbosity 3 \
        &

    local pid=$!
    echo $pid > "$DATA_DIR/geth.pid"

    log_info "Geth started (PID: $pid)"
    log_info "HTTP RPC: http://localhost:$HTTP_PORT"
    log_info "WebSocket: ws://localhost:$WS_PORT"
}

start_hardhat() {
    log_info "Starting Hardhat node..."

    npx hardhat node --port "$HTTP_PORT" &

    local pid=$!
    echo $pid > "hardhat.pid"

    log_info "Hardhat node started (PID: $pid)"
    log_info "HTTP RPC: http://localhost:$HTTP_PORT"
}

start_anvil() {
    if ! command -v anvil &> /dev/null; then
        log_error "Anvil not found. Install Foundry first"
        exit 1
    fi

    log_info "Starting Anvil node..."

    anvil \
        --port "$HTTP_PORT" \
        --chain-id "$CHAIN_ID" \
        --accounts 10 \
        --balance 10000 \
        &

    local pid=$!
    echo $pid > "anvil.pid"

    log_info "Anvil started (PID: $pid)"
    log_info "HTTP RPC: http://localhost:$HTTP_PORT"
}

stop_node() {
    log_info "Stopping node..."

    if [ -f "$DATA_DIR/geth.pid" ]; then
        kill $(cat "$DATA_DIR/geth.pid") 2>/dev/null || true
        rm "$DATA_DIR/geth.pid"
    fi

    if [ -f "hardhat.pid" ]; then
        kill $(cat "hardhat.pid") 2>/dev/null || true
        rm "hardhat.pid"
    fi

    if [ -f "anvil.pid" ]; then
        kill $(cat "anvil.pid") 2>/dev/null || true
        rm "anvil.pid"
    fi

    log_info "Node stopped"
}

check_node_status() {
    log_info "Checking node status..."

    if curl -s -X POST \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        "http://localhost:$HTTP_PORT" > /dev/null; then
        log_info "Node is running ✓"
        return 0
    else
        log_error "Node is not responding"
        return 1
    fi
}

show_accounts() {
    log_info "Fetching accounts..."

    curl -s -X POST \
        -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' \
        "http://localhost:$HTTP_PORT" | jq
}

main() {
    local command=${1:-start}

    case "$command" in
        setup)
            case "$NODE_TYPE" in
                geth)
                    check_geth
                    setup_geth_devnet
                    ;;
                *)
                    log_error "Unknown node type: $NODE_TYPE"
                    exit 1
                    ;;
            esac
            ;;
        start)
            case "$NODE_TYPE" in
                geth)
                    check_geth
                    start_geth
                    ;;
                hardhat)
                    check_hardhat
                    start_hardhat
                    ;;
                anvil)
                    start_anvil
                    ;;
                *)
                    log_error "Unknown node type: $NODE_TYPE"
                    exit 1
                    ;;
            esac
            ;;
        stop)
            stop_node
            ;;
        status)
            check_node_status
            ;;
        accounts)
            show_accounts
            ;;
        *)
            echo "Usage: $0 {setup|start|stop|status|accounts}"
            exit 1
            ;;
    esac
}

main "$@"
