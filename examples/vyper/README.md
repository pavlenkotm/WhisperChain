# 🐍 Vyper Smart Contracts

Alternative EVM smart contract language with Python-like syntax and enhanced security.

## 🎯 What is Vyper?

Vyper is a pythonic smart contract language for the Ethereum Virtual Machine (EVM) designed with:
- **Security**: Eliminates many Solidity pitfalls
- **Simplicity**: Easy to read and audit
- **Auditability**: Clear, explicit code

## 📋 Contracts

### 1. SimpleToken (ERC-20)
- **File**: `SimpleToken.vy`
- **Features**:
  - ✅ Full ERC-20 implementation
  - ✅ Transfer, approve, transferFrom
  - ✅ Safe math (built-in overflow protection)
  - ✅ Event logging
  - ✅ Pythonic syntax

### 2. Vault
- **File**: `Vault.vy`
- **Features**:
  - ✅ Deposit ETH
  - ✅ Withdraw ETH
  - ✅ Balance tracking per user
  - ✅ Event emission
  - ✅ Owner management

## 🚀 Quick Start

### Prerequisites
```bash
python --version  # Python 3.8+
pip --version
```

### Installation
```bash
cd examples/vyper
pip install vyper eth-ape
# or using virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install vyper eth-ape pytest
```

### Compile Contracts
```bash
# Compile SimpleToken
vyper SimpleToken.vy

# Compile with ABI
vyper -f abi SimpleToken.vy

# Compile with bytecode
vyper -f bytecode SimpleToken.vy

# Compile to combined JSON
vyper -f combined_json SimpleToken.vy > SimpleToken.json
```

### Run Tests
```bash
# Using pytest with eth-ape
pytest tests/ -v

# With coverage
pytest tests/ --cov=. --cov-report=html
```

## 📦 Deployment

### Using Ape Framework
```python
from ape import accounts, project

# Load account
account = accounts.load("my_account")

# Deploy SimpleToken
token = project.SimpleToken.deploy(
    "MyToken",
    "MTK",
    18,
    1000000 * 10**18,
    sender=account
)

print(f"Token deployed at: {token.address}")

# Deploy Vault
vault = project.Vault.deploy(sender=account)
print(f"Vault deployed at: {vault.address}")
```

### Using Web3.py
```python
from web3 import Web3
from vyper import compile_code

# Connect to network
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Read and compile contract
with open('SimpleToken.vy', 'r') as f:
    source_code = f.read()

compiled = compile_code(source_code, ['abi', 'bytecode'])

# Create contract instance
SimpleToken = w3.eth.contract(
    abi=compiled['abi'],
    bytecode=compiled['bytecode']
)

# Deploy
tx_hash = SimpleToken.constructor(
    "MyToken", "MTK", 18, 1000000 * 10**18
).transact({'from': w3.eth.accounts[0]})

tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
token_address = tx_receipt.contractAddress
print(f"Token deployed at: {token_address}")
```

## 🧪 Testing

### Running Tests
```bash
# All tests
pytest tests/

# Specific test file
pytest tests/test_simple_token.py -v

# With gas profiling
pytest tests/ --gas-profile

# Generate coverage report
pytest tests/ --cov --cov-report=html
```

### Example Test Output
```
tests/test_simple_token.py::test_deployment PASSED
tests/test_simple_token.py::test_transfer PASSED
tests/test_simple_token.py::test_approve_and_transfer_from PASSED
tests/test_vault.py::test_deposit PASSED
tests/test_vault.py::test_withdraw PASSED

==================== 10 passed in 2.45s ====================
```

## 📖 Usage Examples

### Interacting with SimpleToken
```python
from ape import accounts, project

# Get deployed contract
token = project.SimpleToken.at("CONTRACT_ADDRESS")

# Check balance
balance = token.balanceOf(accounts[0])
print(f"Balance: {balance / 10**18} tokens")

# Transfer tokens
token.transfer(accounts[1], 100 * 10**18, sender=accounts[0])

# Approve and transferFrom
token.approve(accounts[1], 50 * 10**18, sender=accounts[0])
token.transferFrom(
    accounts[0],
    accounts[2],
    50 * 10**18,
    sender=accounts[1]
)
```

### Interacting with Vault
```python
from ape import accounts, project
from eth_utils import to_wei

# Get deployed contract
vault = project.Vault.at("CONTRACT_ADDRESS")

# Deposit ETH
vault.deposit(sender=accounts[0], value=to_wei(1, 'ether'))

# Check balance
balance = vault.getBalance(accounts[0])
print(f"Vault balance: {balance / 10**18} ETH")

# Withdraw
vault.withdraw(to_wei(0.5, 'ether'), sender=accounts[0])
```

## 🔐 Security Features

Vyper provides built-in security advantages:

- ✅ **No overflow/underflow**: Safe math by default
- ✅ **No modifiers**: Explicit function logic
- ✅ **No inline assembly**: Prevents low-level exploits
- ✅ **No recursive calls**: Prevents reentrancy
- ✅ **Bounds checking**: Array access always checked
- ✅ **Clear visibility**: Explicit public/private

### Comparison with Solidity

| Feature | Vyper | Solidity |
|---------|-------|----------|
| Overflow protection | Built-in | Requires Solidity 0.8+ |
| Modifiers | ❌ No | ✅ Yes |
| Inheritance | ❌ No | ✅ Yes |
| Operator overloading | ❌ No | ✅ Yes |
| Recursive calls | ❌ No | ✅ Yes |
| Inline assembly | ❌ No | ✅ Yes |

## 📚 Resources

- [Vyper Documentation](https://docs.vyperlang.org/)
- [Vyper by Example](https://vyper-by-example.org/)
- [Eth-Ape Framework](https://docs.apeworx.io/)
- [Vyper GitHub](https://github.com/vyperlang/vyper)

## 🔍 Code Quality

All contracts follow best practices:
- ✅ Clear, explicit code
- ✅ Comprehensive docstrings
- ✅ Event emission for state changes
- ✅ Input validation
- ✅ Gas-efficient patterns

## 🤝 Contributing

Contributions welcome! Ensure:
- All tests pass
- Code follows Vyper style guide
- Functions have docstrings
- Security best practices followed

## 📄 License

MIT License - see LICENSE file for details
