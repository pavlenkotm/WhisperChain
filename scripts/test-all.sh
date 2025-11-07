#!/usr/bin/env bash

##############################################################################
# Run tests for all languages
##############################################################################

set -euo pipefail

echo "🧪 Running all tests..."

FAILED=0

# Solidity
echo "Testing Solidity..."
if cd examples/solidity && npm test 2>/dev/null; then
    echo "✅ Solidity tests passed"
else
    echo "❌ Solidity tests failed"
    FAILED=$((FAILED + 1))
fi
cd ../..

# Python
echo "Testing Python..."
if cd examples/python && pytest tests/ 2>/dev/null; then
    echo "✅ Python tests passed"
else
    echo "❌ Python tests failed"
    FAILED=$((FAILED + 1))
fi
cd ../..

# TypeScript
echo "Testing TypeScript..."
if cd examples/typescript && npm test 2>/dev/null; then
    echo "✅ TypeScript tests passed"
else
    echo "❌ TypeScript tests failed"
    FAILED=$((FAILED + 1))
fi
cd ../..

# Go
echo "Testing Go..."
if cd examples/go && go test ./... 2>/dev/null; then
    echo "✅ Go tests passed"
else
    echo "❌ Go tests failed"
    FAILED=$((FAILED + 1))
fi
cd ../..

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "✅ All tests passed!"
    exit 0
else
    echo ""
    echo "❌ $FAILED test suite(s) failed"
    exit 1
fi
