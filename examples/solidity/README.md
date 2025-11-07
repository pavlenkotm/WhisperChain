# 🔷 Solidity Smart Contracts

Professional ERC-20 and ERC-721 smart contract implementations for the WhisperChain ecosystem.

## 📋 Contracts

### 1. WhisperToken (ERC-20)
- **File**: `ERC20Token.sol`
- **Standard**: ERC-20 with extensions
- **Features**:
  - ✅ Minting with max supply cap (1 billion tokens)
  - ✅ Burning mechanism
  - ✅ Ownership control
  - ✅ OpenZeppelin security standards
  - ✅ Event emission for tracking

### 2. WhisperNFT (ERC-721)
- **File**: `ERC721NFT.sol`
- **Standard**: ERC-721 with URI storage
- **Features**:
  - ✅ Public minting with configurable price
  - ✅ Owner minting (free)
  - ✅ Max supply limit (10,000 NFTs)
  - ✅ URI metadata storage
  - ✅ Burnable tokens
  - ✅ Withdrawal mechanism
  - ✅ Price updates

## 🚀 Quick Start

### Prerequisites
```bash
node --version  # v18 or higher
npm --version
```

### Installation
```bash
cd examples/solidity
npm install
```

### Compile Contracts
```bash
npm run compile
```

### Run Tests
```bash
npm run test
```

Expected output:
```
  WhisperToken
    Deployment
      ✓ Should set the right owner
      ✓ Should assign initial supply to owner
      ✓ Should have correct name and symbol
    Minting
      ✓ Should allow owner to mint tokens
      ✓ Should not allow non-owner to mint
      ...

  WhisperNFT
    Deployment
      ✓ Should set the right owner
      ...

  30 passing (2s)
```

## 📦 Deployment

### Local Deployment (Hardhat Network)
```bash
# Terminal 1: Start local node
npx hardhat node

# Terminal 2: Deploy contracts
npm run deploy:local
```

### Testnet Deployment (Sepolia)
```bash
# Set up environment variables
export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
export PRIVATE_KEY="your_private_key"
export ETHERSCAN_API_KEY="your_etherscan_key"

# Deploy
npm run deploy:sepolia
```

### Verify on Etherscan
```bash
npx hardhat verify --network sepolia DEPLOYED_CONTRACT_ADDRESS "CONSTRUCTOR_ARGS"
```

## 🧪 Testing

### Run All Tests
```bash
npm test
```

### Test Coverage
```bash
npx hardhat coverage
```

### Gas Report
```bash
REPORT_GAS=true npm test
```

## 📖 Usage Examples

### Interacting with WhisperToken
```javascript
const { ethers } = require("hardhat");

async function main() {
  const token = await ethers.getContractAt("WhisperToken", "CONTRACT_ADDRESS");

  // Check balance
  const balance = await token.balanceOf("ADDRESS");
  console.log("Balance:", ethers.formatEther(balance));

  // Transfer tokens
  await token.transfer("RECIPIENT_ADDRESS", ethers.parseEther("100"));

  // Mint new tokens (owner only)
  await token.mint("ADDRESS", ethers.parseEther("1000"));

  // Burn tokens
  await token.burn(ethers.parseEther("50"));
}

main();
```

### Interacting with WhisperNFT
```javascript
const { ethers } = require("hardhat");

async function main() {
  const nft = await ethers.getContractAt("WhisperNFT", "CONTRACT_ADDRESS");

  // Mint NFT
  const mintPrice = await nft.mintPrice();
  await nft.mint("RECIPIENT_ADDRESS", "ipfs://QmMetadataURI", {
    value: mintPrice
  });

  // Check ownership
  const owner = await nft.ownerOf(1);
  console.log("Token 1 owner:", owner);

  // Get metadata URI
  const uri = await nft.tokenURI(1);
  console.log("Token URI:", uri);
}

main();
```

## 🔐 Security

- All contracts use OpenZeppelin's audited implementations
- Access control implemented with `Ownable`
- Reentrancy protection built-in
- Integer overflow protection (Solidity 0.8+)

### Audit Checklist
- ✅ No floating pragma
- ✅ Using latest OpenZeppelin contracts
- ✅ Access control on critical functions
- ✅ Events for state changes
- ✅ Input validation
- ✅ Gas optimization

## 📚 Resources

- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [ERC-20 Standard](https://eips.ethereum.org/EIPS/eip-20)
- [ERC-721 Standard](https://eips.ethereum.org/EIPS/eip-721)

## 🤝 Contributing

Contributions welcome! Please ensure:
- All tests pass
- Gas optimization considered
- Security best practices followed
- Code commented and documented

## 📄 License

MIT License - see LICENSE file for details
