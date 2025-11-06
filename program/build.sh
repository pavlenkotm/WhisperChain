#!/bin/bash

set -e

# Build the Solana program
echo "Building WhisperChain Solana program..."

cd "$(dirname "$0")"

# Build with cargo-build-sbf (recommended) or cargo-build-bpf (older)
if command -v cargo-build-sbf &> /dev/null; then
    cargo-build-sbf
elif command -v cargo-build-bpf &> /dev/null; then
    cargo-build-bpf
else
    echo "Error: Neither cargo-build-sbf nor cargo-build-bpf found."
    echo "Please install Solana CLI tools: https://docs.solana.com/cli/install-solana-cli-tools"
    exit 1
fi

echo "Build complete!"
echo "Program binary is at: target/deploy/whisperchain.so"
