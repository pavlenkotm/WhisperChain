#!/bin/bash

# Quick test script for WhisperChain

echo "======================================"
echo "WhisperChain - Quick Test Suite"
echo "======================================"
echo ""

# Test Python
echo "[1/4] Testing Python..."
cd /home/user/WhisperChain/examples/python && python -m pytest tests/ -q && echo "✓ Python passed" || echo "✗ Python failed"
echo ""

# Test TypeScript
echo "[2/4] Testing TypeScript..."
cd /home/user/WhisperChain/examples/typescript && npm run build --silent && echo "✓ TypeScript passed" || echo "✗ TypeScript failed"
echo ""

# Test C++
echo "[3/4] Testing C++..."
cd /home/user/WhisperChain/examples/cpp && rm -rf build && mkdir build && cd build && cmake .. -DBUILD_TESTS=OFF >/dev/null 2>&1 && make >/dev/null 2>&1 && echo "✓ C++ passed" || echo "✗ C++ failed"
echo ""

# Test Rust
echo "[4/4] Testing Rust..."
cd /home/user/WhisperChain/program && cargo build --release >/dev/null 2>&1 && echo "✓ Rust passed" || echo "✗ Rust failed"
echo ""

echo "======================================"
echo "Tests completed!"
echo "======================================"
