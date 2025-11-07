#!/usr/bin/env bash

##############################################################################
# Smart Contract Deployment Script
# Deploys Solidity contracts to Ethereum networks
##############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK="${NETWORK:-localhost}"
PRIVATE_KEY="${PRIVATE_KEY:-}"
RPC_URL="${RPC_URL:-http://localhost:8545}"
CONTRACT_PATH="${CONTRACT_PATH:-contracts/}"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."

    if ! command -v forge &> /dev/null && ! command -v hardhat &> /dev/null; then
        log_error "Neither Foundry (forge) nor Hardhat found"
        log_error "Install one of them to continue"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        log_warn "jq not found. Install for better output parsing"
    fi

    log_info "Dependencies OK"
}

load_env() {
    if [ -f ".env" ]; then
        log_info "Loading .env file..."
        export $(cat .env | grep -v '^#' | xargs)
    else
        log_warn "No .env file found"
    fi
}

compile_contracts() {
    log_info "Compiling contracts..."

    if command -v forge &> /dev/null; then
        forge build
    elif command -v hardhat &> /dev/null; then
        npx hardhat compile
    fi

    log_info "Compilation complete"
}

deploy_with_forge() {
    local contract_name=$1
    local constructor_args=${2:-}

    log_info "Deploying $contract_name with Foundry..."

    local deploy_cmd="forge create $CONTRACT_PATH$contract_name.sol:$contract_name \
        --rpc-url $RPC_URL \
        --private-key $PRIVATE_KEY"

    if [ -n "$constructor_args" ]; then
        deploy_cmd="$deploy_cmd --constructor-args $constructor_args"
    fi

    eval $deploy_cmd
}

deploy_with_hardhat() {
    local contract_name=$1

    log_info "Deploying $contract_name with Hardhat..."

    npx hardhat run scripts/deploy.js --network $NETWORK
}

verify_contract() {
    local address=$1
    local contract_name=$2
    local constructor_args=${3:-}

    log_info "Verifying contract on Etherscan..."

    if command -v forge &> /dev/null; then
        forge verify-contract \
            --chain-id $(cast chain-id --rpc-url $RPC_URL) \
            --constructor-args $constructor_args \
            $address \
            $CONTRACT_PATH$contract_name.sol:$contract_name
    fi
}

save_deployment() {
    local contract_name=$1
    local address=$2
    local network=$3

    local deployments_file="deployments.json"

    if [ ! -f "$deployments_file" ]; then
        echo "{}" > $deployments_file
    fi

    log_info "Saving deployment to $deployments_file..."

    if command -v jq &> /dev/null; then
        jq \
            --arg network "$network" \
            --arg contract "$contract_name" \
            --arg address "$address" \
            --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '.[$network] += {($contract): {address: $address, timestamp: $timestamp}}' \
            $deployments_file > temp.json && mv temp.json $deployments_file
    fi

    log_info "Deployment saved"
}

# Main deployment function
main() {
    log_info "Starting deployment process..."
    log_info "Network: $NETWORK"
    log_info "RPC URL: $RPC_URL"

    check_dependencies
    load_env
    compile_contracts

    if [ -z "$PRIVATE_KEY" ]; then
        log_error "PRIVATE_KEY not set"
        exit 1
    fi

    # Deploy contracts
    log_info "Deploying contracts..."

    # Example: Deploy ERC-20 token
    local token_address=$(deploy_with_forge "ERC20Token" '"WhisperToken" "WHSP" 18 1000000000')

    if [ -n "$token_address" ]; then
        save_deployment "ERC20Token" "$token_address" "$NETWORK"
        log_info "ERC-20 Token deployed at: $token_address"
    fi

    log_info "Deployment complete! 🎉"
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
