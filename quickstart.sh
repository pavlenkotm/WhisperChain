#!/bin/bash

set -e

echo "🔐 WhisperChain Quick Start Script"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v cargo &> /dev/null; then
    echo -e "${RED}❌ Rust/Cargo not found. Install from https://rustup.rs/${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Rust/Cargo found${NC}"

if ! command -v solana &> /dev/null; then
    echo -e "${RED}❌ Solana CLI not found. Install from https://docs.solana.com/cli/install-solana-cli-tools${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Solana CLI found${NC}"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js not found. Install from https://nodejs.org/${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js found${NC}"

echo ""
echo "Building Solana program..."
cd program

if command -v cargo-build-sbf &> /dev/null; then
    cargo-build-sbf
elif command -v cargo-build-bpf &> /dev/null; then
    cargo-build-bpf
else
    echo -e "${YELLOW}⚠ cargo-build-sbf/bpf not found. Install with: cargo install cargo-build-sbf${NC}"
    echo "Attempting to use regular cargo build (may not work for deployment)..."
    cargo build --release
fi

echo -e "${GREEN}✓ Program built successfully${NC}"
echo ""

# Setup Solana
echo "Configuring Solana for Devnet..."
solana config set --url https://api.devnet.solana.com

echo ""
echo -e "${YELLOW}📝 IMPORTANT: Before deploying, you need devnet SOL${NC}"
echo "Run: solana airdrop 2"
echo ""

read -p "Do you want to deploy to devnet now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deploying to devnet..."
    PROGRAM_ID=$(solana program deploy target/deploy/whisperchain.so | grep "Program Id:" | awk '{print $3}')

    echo -e "${GREEN}✓ Program deployed successfully!${NC}"
    echo -e "${YELLOW}Program ID: $PROGRAM_ID${NC}"
    echo ""
    echo "⚠️  IMPORTANT: Update the Program ID in app/src/utils/program.ts"
    echo "   Change PROGRAM_ID to: $PROGRAM_ID"
    echo ""
fi

# Setup frontend
echo "Setting up frontend..."
cd ../app

if [ ! -d "node_modules" ]; then
    echo "Installing npm dependencies..."
    npm install
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Update app/src/utils/program.ts with your Program ID"
echo "2. Start the frontend: cd app && npm start"
echo "3. Connect your Phantom wallet (set to Devnet)"
echo "4. Initialize a chat and start messaging!"
echo ""
echo "For more info, see README.md and DEPLOYMENT_GUIDE.md"
echo ""
echo "Happy encrypted chatting! 🔐"
