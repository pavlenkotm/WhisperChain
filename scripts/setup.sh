#!/usr/bin/env bash

##############################################################################
# WhisperChain Setup Script
# Sets up development environment for all languages
##############################################################################

set -euo pipefail

echo "🔗 Setting up WhisperChain development environment..."

# Check operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "✓ Detected OS: $OS"

# Install Node.js dependencies
if command -v node &> /dev/null; then
    echo "✓ Node.js found: $(node --version)"

    echo "📦 Installing Solidity dependencies..."
    cd examples/solidity && npm install && cd ../..

    echo "📦 Installing TypeScript dependencies..."
    cd examples/typescript && npm install && cd ../..
else
    echo "⚠️  Node.js not found. Install from https://nodejs.org/"
fi

# Install Python dependencies
if command -v python3 &> /dev/null; then
    echo "✓ Python found: $(python3 --version)"

    echo "📦 Installing Python dependencies..."
    cd examples/python
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate
    cd ../..
else
    echo "⚠️  Python not found. Install from https://python.org/"
fi

# Check Rust
if command -v cargo &> /dev/null; then
    echo "✓ Rust found: $(cargo --version)"
else
    echo "⚠️  Rust not found. Install from https://rustup.rs/"
fi

# Check Go
if command -v go &> /dev/null; then
    echo "✓ Go found: $(go version)"

    echo "📦 Installing Go dependencies..."
    cd examples/go && go mod download && cd ../..
else
    echo "⚠️  Go not found. Install from https://golang.org/"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Choose a language example from examples/"
echo "  2. Read the README in that directory"
echo "  3. Start coding!"
echo ""
echo "📖 Documentation: docs/GETTING_STARTED.md"
