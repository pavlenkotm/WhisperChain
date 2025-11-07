# 🐍 Python Web3 Utilities

Professional Python utilities for Ethereum blockchain interaction using Web3.py.

## 📋 Modules

### 1. Web3Utils
- **File**: `web3_utils.py`
- **Features**:
  - ✅ Balance queries
  - ✅ Transaction sending
  - ✅ Smart contract deployment
  - ✅ Contract function calls
  - ✅ Account creation
  - ✅ Message signing & verification
  - ✅ Transaction monitoring

### 2. NFT Minter
- **File**: `nft_minter.py`
- **Features**:
  - ✅ Single & batch NFT minting
  - ✅ Metadata creation (ERC-721 standard)
  - ✅ IPFS integration ready
  - ✅ Token queries
  - ✅ Automatic transaction handling

## 🚀 Quick Start

### Prerequisites
```bash
python --version  # Python 3.8+
pip --version
```

### Installation
```bash
cd examples/python

# Create virtual environment (recommended)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### Environment Setup
```bash
# Create .env file
cat > .env << EOF
RPC_URL=http://localhost:8545
PRIVATE_KEY=0x...
CONTRACT_ADDRESS=0x...
EOF
```

## 📖 Usage Examples

### Basic Web3 Operations
```python
from web3_utils import Web3Utils

# Initialize
utils = Web3Utils("http://localhost:8545")

# Create new account
account = utils.create_account()
print(f"Address: {account['address']}")
print(f"Private Key: {account['private_key']}")

# Check balance
balance = utils.get_balance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
print(f"Balance: {balance} ETH")

# Send ETH
tx_hash = utils.send_transaction(
    from_private_key="0x...",
    to_address="0x...",
    value_eth=0.1
)
print(f"Transaction: {tx_hash}")

# Wait for confirmation
receipt = utils.wait_for_transaction(tx_hash)
print(f"Confirmed in block: {receipt['blockNumber']}")
```

### Smart Contract Deployment
```python
import json
from web3_utils import Web3Utils

# Load contract artifacts
with open("MyContract.json", "r") as f:
    contract_json = json.load(f)
    abi = contract_json["abi"]
    bytecode = contract_json["bytecode"]

# Deploy
utils = Web3Utils("http://localhost:8545")
contract_address, contract = utils.deploy_contract(
    abi=abi,
    bytecode=bytecode,
    from_private_key="0x...",
    constructor_args=("Constructor", "Args")
)

print(f"Contract deployed at: {contract_address}")
```

### Interacting with Contracts
```python
from web3_utils import Web3Utils

utils = Web3Utils("http://localhost:8545")

# Read from contract (no gas)
balance = utils.call_contract_function(
    contract_address="0x...",
    abi=abi,
    function_name="balanceOf",
    "0xUserAddress"
)
print(f"Token balance: {balance}")

# Write to contract (costs gas)
tx_hash = utils.send_contract_transaction(
    contract_address="0x...",
    abi=abi,
    function_name="transfer",
    from_private_key="0x...",
    "0xRecipient",
    1000  # amount
)

receipt = utils.wait_for_transaction(tx_hash)
print(f"Transfer successful! Gas used: {receipt['gasUsed']}")
```

### NFT Minting
```python
from nft_minter import NFTMinter
import json

# Load contract ABI
with open("NFTContract.json", "r") as f:
    abi = json.load(f)["abi"]

# Initialize minter
minter = NFTMinter(
    provider_url="http://localhost:8545",
    contract_address="0x...",
    contract_abi=abi,
    private_key="0x..."
)

# Create metadata
metadata = NFTMinter.create_metadata(
    name="Cool NFT #1",
    description="An amazing NFT from WhisperChain",
    image_url="ipfs://QmImage...",
    attributes=[
        {"trait_type": "Background", "value": "Blue"},
        {"trait_type": "Rarity", "value": "Legendary"}
    ]
)

# Save metadata
metadata_file = NFTMinter.save_metadata(metadata, "metadata/1.json")

# Mint NFT
tx_hash = minter.mint_nft(
    recipient="0x...",
    metadata_uri="ipfs://QmMetadata...",
    mint_price_eth=0.01
)

print(f"NFT minted! Transaction: {tx_hash}")
```

### Batch Minting
```python
# Mint multiple NFTs
recipients = ["0xAddr1", "0xAddr2", "0xAddr3"]
uris = [
    "ipfs://QmMeta1...",
    "ipfs://QmMeta2...",
    "ipfs://QmMeta3..."
]

tx_hashes = minter.batch_mint(
    recipients=recipients,
    metadata_uris=uris,
    mint_price_eth=0.01
)

print(f"Minted {len(tx_hashes)} NFTs!")
```

### Message Signing & Verification
```python
from web3_utils import Web3Utils

utils = Web3Utils("http://localhost:8545")

# Sign message
message = "Authenticate with WhisperChain"
private_key = "0x..."
signature = utils.sign_message(message, private_key)
print(f"Signature: {signature}")

# Verify signature
signer_address = "0x..."
is_valid = utils.verify_signature(message, signature, signer_address)
print(f"Valid signature: {is_valid}")
```

## 🧪 Testing

### Run All Tests
```bash
# Install test dependencies
pip install pytest pytest-cov

# Run tests
pytest tests/ -v

# With coverage
pytest tests/ --cov=. --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Test Output
```
tests/test_web3_utils.py::test_initialization PASSED
tests/test_web3_utils.py::test_get_balance PASSED
tests/test_web3_utils.py::test_create_account PASSED
tests/test_web3_utils.py::test_sign_message PASSED

==================== 8 passed in 1.23s ====================
```

## 🔧 CLI Scripts

### Create Account
```bash
python -c "from web3_utils import Web3Utils; \
    import json; \
    utils = Web3Utils(); \
    print(json.dumps(utils.create_account(), indent=2))"
```

### Check Balance
```bash
python -c "from web3_utils import Web3Utils; \
    utils = Web3Utils('http://localhost:8545'); \
    print(f'Balance: {utils.get_balance(\"0x...\")} ETH')"
```

## 🔐 Security Best Practices

1. **Never commit private keys**
   ```bash
   # Always use environment variables or .env files
   echo ".env" >> .gitignore
   ```

2. **Use hardware wallets for mainnet**
   ```python
   # For production, integrate with Ledger or Trezor
   from ledgereth import get_account
   ```

3. **Validate addresses**
   ```python
   from web3 import Web3
   address = Web3.to_checksum_address(user_input)
   ```

4. **Set gas limits**
   ```python
   # Always specify reasonable gas limits
   tx_hash = utils.send_contract_transaction(
       ...,
       gas=300000,  # Prevent infinite gas usage
       gasPrice=utils.w3.eth.gas_price
   )
   ```

## 📊 Common Use Cases

### Event Monitoring
```python
# Monitor contract events
contract = utils.w3.eth.contract(address=address, abi=abi)

# Get past events
events = contract.events.Transfer.get_logs(fromBlock=0)
for event in events:
    print(f"Transfer: {event['args']}")

# Listen for new events
event_filter = contract.events.Transfer.create_filter(fromBlock='latest')
for event in event_filter.get_new_entries():
    print(f"New transfer: {event['args']}")
```

### Gas Price Estimation
```python
# Get current gas price
gas_price = utils.w3.eth.gas_price
print(f"Gas price: {Web3.from_wei(gas_price, 'gwei')} gwei")

# Estimate gas for transaction
gas_estimate = contract.functions.transfer(to, amount).estimate_gas({
    'from': sender
})
print(f"Estimated gas: {gas_estimate}")
```

## 📚 Resources

- [Web3.py Documentation](https://web3py.readthedocs.io/)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [ERC-20 Standard](https://eips.ethereum.org/EIPS/eip-20)
- [ERC-721 Standard](https://eips.ethereum.org/EIPS/eip-721)
- [IPFS Documentation](https://docs.ipfs.tech/)

## 🤝 Contributing

Contributions welcome! Please ensure:
- All tests pass
- Code follows PEP 8 style guide
- Functions have docstrings
- Type hints included

## 📄 License

MIT License - see LICENSE file for details
