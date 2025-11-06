#!/bin/bash

set -e

# Deploy to Solana devnet
echo "Deploying WhisperChain to Solana devnet..."

cd "$(dirname "$0")"

# Set cluster to devnet
solana config set --url https://api.devnet.solana.com

# Check balance
echo "Checking wallet balance..."
solana balance

# Deploy
echo "Deploying program..."
solana program deploy target/deploy/whisperchain.so

echo "Deployment complete!"
echo "You can verify the program with: solana program show <PROGRAM_ID>"
