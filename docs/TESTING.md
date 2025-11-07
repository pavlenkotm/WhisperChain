# 🧪 Testing Guide

Comprehensive testing strategies across all programming languages.

## Testing Philosophy

- **Unit Tests**: Test individual functions/modules
- **Integration Tests**: Test component interactions
- **E2E Tests**: Test complete workflows
- **Security Tests**: Test for vulnerabilities

## Testing by Language

### Solidity
```bash
cd examples/solidity

# Run tests with Hardhat
npm test

# Run tests with Foundry
forge test

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

### Python
```bash
cd examples/python

# Run tests
pytest tests/ -v

# With coverage
pytest tests/ --cov=. --cov-report=html

# Specific test
pytest tests/test_web3_utils.py::test_create_account
```

### TypeScript
```bash
cd examples/typescript

# Run tests
npm test

# Watch mode
npm test -- --watch

# Coverage
npm test -- --coverage
```

### Go
```bash
cd examples/go

# Run all tests
go test ./...

# Verbose output
go test -v ./...

# With coverage
go test -cover ./...

# Benchmark
go test -bench=. ./...
```

### Rust
```bash
cd program

# Run tests
cargo test

# Show output
cargo test -- --nocapture

# Specific test
cargo test test_name
```

## Test Structure

### Unit Test Example (TypeScript)
```typescript
describe('WalletConnector', () => {
  it('should connect to MetaMask', async () => {
    const connector = new WalletConnector();
    const wallet = await connector.connectMetaMask();

    expect(wallet.address).toBeDefined();
    expect(wallet.chainId).toBeGreaterThan(0);
  });
});
```

### Integration Test Example (Python)
```python
def test_full_transaction_flow():
    utils = Web3Utils('http://localhost:8545')

    # Create account
    account = utils.create_account()

    # Get balance
    balance = utils.get_balance(account['address'])

    # Send transaction
    tx_hash = utils.send_transaction(...)

    # Wait for confirmation
    receipt = utils.wait_for_transaction(tx_hash)

    assert receipt['status'] == 1
```

## Mocking and Fixtures

### Mock Web3 Provider (TypeScript)
```typescript
jest.mock('ethers', () => ({
  providers: {
    Web3Provider: jest.fn(() => ({
      getSigner: jest.fn(),
      getBalance: jest.fn(() => Promise.resolve(ethers.BigNumber.from('1000000000000000000')))
    }))
  }
}));
```

### Pytest Fixtures (Python)
```python
@pytest.fixture
def web3_utils():
    return Web3Utils('http://localhost:8545')

def test_balance(web3_utils):
    balance = web3_utils.get_balance('0x...')
    assert balance is not None
```

## Continuous Integration

### GitHub Actions
See `.github/workflows/ci.yml` for multi-language CI setup.

### Local CI Simulation
```bash
# Run all tests
./scripts/test-all.sh

# Or manually
cd examples/solidity && npm test
cd examples/python && pytest
cd examples/typescript && npm test
cd examples/go && go test ./...
```

## Test Coverage Goals

| Language | Target Coverage |
|----------|----------------|
| Solidity | 90%+ |
| Python | 85%+ |
| TypeScript | 80%+ |
| Go | 85%+ |
| Rust | 90%+ |

## Best Practices

1. **Write tests first** (TDD)
2. **Test edge cases**
3. **Use descriptive names**
4. **Keep tests isolated**
5. **Mock external dependencies**
6. **Test error conditions**
7. **Maintain test data**
8. **Run tests before commits**

## Security Testing

### Static Analysis
```bash
# Solidity
slither examples/solidity/

# Python
bandit -r examples/python/

# TypeScript
npm audit
```

### Penetration Testing
- Use tools like Mythril for smart contracts
- Run OWASP ZAP for web applications
- Perform manual code review

## Performance Testing

### Load Testing
```bash
# Using Apache Bench
ab -n 1000 -c 10 http://localhost:3000/

# Using k6
k6 run load-test.js
```

### Gas Profiling (Solidity)
```bash
forge test --gas-report
```

## Debugging Tests

### Node.js/TypeScript
```bash
node --inspect-brk node_modules/.bin/jest tests/
```

### Python
```bash
pytest --pdb tests/
```

### Go
```bash
go test -v -run TestName
```

## Resources

- [Jest Documentation](https://jestjs.io/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Foundry Testing](https://book.getfoundry.sh/forge/tests)
- [Go Testing](https://golang.org/pkg/testing/)

## Contributing Tests

When contributing, ensure:
- [ ] New features have tests
- [ ] All tests pass
- [ ] Coverage doesn't decrease
- [ ] Tests are documented
