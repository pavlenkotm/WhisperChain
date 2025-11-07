# 📘 TypeScript Web3 Utilities

Professional TypeScript utilities for building Web3 DApps with type safety.

## 📋 Modules

### 1. WalletConnector
- **File**: `wallet-connector.ts`
- **Features**:
  - ✅ MetaMask integration
  - ✅ Multi-wallet support
  - ✅ Network switching
  - ✅ Message signing
  - ✅ Transaction sending
  - ✅ Contract interactions
  - ✅ Event listeners

### 2. TokenUtils
- **File**: `token-utils.ts`
- **Features**:
  - ✅ ERC-20 token operations
  - ✅ Balance queries
  - ✅ Transfer & approve
  - ✅ Transaction history
  - ✅ Common token addresses
  - ✅ Type-safe API

## 🚀 Quick Start

### Installation
```bash
cd examples/typescript
npm install
```

### Build
```bash
npm run build
```

### Development
```bash
# Watch mode
npx tsc --watch
```

## 📖 Usage Examples

### Connect Wallet
```typescript
import { WalletConnector } from './wallet-connector';

const connector = new WalletConnector();

// Connect to MetaMask
try {
  const wallet = await connector.connectMetaMask();
  console.log('Connected:', wallet.address);
  console.log('Chain ID:', wallet.chainId);
  console.log('Balance:', wallet.balance, 'ETH');
} catch (error) {
  console.error('Failed to connect:', error);
}
```

### Switch Network
```typescript
// Switch to Polygon
await connector.switchNetwork(137);

// Switch to Avalanche
await connector.switchNetwork(43114);

// Switch to Mumbai testnet
await connector.switchNetwork(80001);
```

### Sign Message
```typescript
const message = 'Sign in to WhisperChain';
const signature = await connector.signMessage(message);
console.log('Signature:', signature);
```

### Send Transaction
```typescript
const tx = await connector.sendTransaction(
  '0xRecipientAddress',
  '0.1' // ETH amount
);

console.log('Transaction sent:', tx.hash);

// Wait for confirmation
const receipt = await tx.wait();
console.log('Confirmed in block:', receipt.blockNumber);
```

### Interact with Contracts
```typescript
// Read from contract
const balance = await connector.callContract(
  contractAddress,
  abi,
  'balanceOf',
  userAddress
);

// Write to contract
const tx = await connector.sendContractTransaction(
  contractAddress,
  abi,
  'transfer',
  recipientAddress,
  ethers.utils.parseEther('100')
);

await tx.wait();
console.log('Transfer complete!');
```

### Token Operations
```typescript
import { TokenUtils } from './token-utils';
import { ethers } from 'ethers';

const provider = new ethers.providers.Web3Provider(window.ethereum);
const tokenUtils = new TokenUtils(provider);

// Get token info
const info = await tokenUtils.getTokenInfo(tokenAddress);
console.log(`${info.name} (${info.symbol})`);
console.log(`Decimals: ${info.decimals}`);
console.log(`Total Supply: ${info.totalSupply}`);

// Check balance
const balance = await tokenUtils.getBalance(tokenAddress, userAddress);
console.log(`Balance: ${balance} ${info.symbol}`);

// Transfer tokens
const signer = provider.getSigner();
const tx = await tokenUtils.transfer(
  tokenAddress,
  signer,
  recipientAddress,
  '100' // token amount
);

await tx.wait();
console.log('Tokens transferred!');
```

### Approve & TransferFrom
```typescript
// Approve spender
await tokenUtils.approve(
  tokenAddress,
  signer,
  spenderAddress,
  '1000' // allowance
);

// Transfer on behalf of owner
await tokenUtils.transferFrom(
  tokenAddress,
  signer,
  ownerAddress,
  recipientAddress,
  '500'
);
```

### Get Transfer History
```typescript
const history = await tokenUtils.getTransferHistory(
  tokenAddress,
  userAddress,
  0, // from block
  'latest' // to block
);

history.forEach((event) => {
  console.log(`${event.type}: ${event.value} at block ${event.blockNumber}`);
});
```

### Use Common Tokens
```typescript
import { COMMON_TOKENS } from './token-utils';

// Get USDC on mainnet
const usdcAddress = COMMON_TOKENS.mainnet.USDC;
const balance = await tokenUtils.getBalance(usdcAddress, userAddress);
console.log(`USDC Balance: ${balance}`);

// Get USDC on Polygon
const polygonUSDC = COMMON_TOKENS.polygon.USDC;
```

## 🔧 React Integration

### Custom Hook Example
```typescript
import { useState, useEffect } from 'react';
import { WalletConnector } from './wallet-connector';

export function useWallet() {
  const [connector] = useState(() => new WalletConnector());
  const [address, setAddress] = useState<string | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  const connect = async () => {
    try {
      const wallet = await connector.connectMetaMask();
      setAddress(wallet.address);
      setIsConnected(true);
    } catch (error) {
      console.error('Connection failed:', error);
    }
  };

  const disconnect = () => {
    connector.disconnect();
    setAddress(null);
    setIsConnected(false);
  };

  return {
    connector,
    address,
    isConnected,
    connect,
    disconnect,
  };
}
```

### Component Example
```typescript
import React from 'react';
import { useWallet } from './useWallet';

export function WalletButton() {
  const { address, isConnected, connect, disconnect } = useWallet();

  return (
    <button onClick={isConnected ? disconnect : connect}>
      {isConnected
        ? `${address?.slice(0, 6)}...${address?.slice(-4)}`
        : 'Connect Wallet'}
    </button>
  );
}
```

## 🧪 Testing

```bash
# Run tests
npm test

# With coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

## 🔐 Security Best Practices

1. **Never expose private keys**
   ```typescript
   // ❌ Bad
   const privateKey = '0x...';

   // ✅ Good - use wallet provider
   const signer = provider.getSigner();
   ```

2. **Validate addresses**
   ```typescript
   import { ethers } from 'ethers';

   if (!ethers.utils.isAddress(address)) {
     throw new Error('Invalid address');
   }
   ```

3. **Handle errors gracefully**
   ```typescript
   try {
     const tx = await connector.sendTransaction(to, value);
     await tx.wait();
   } catch (error: any) {
     if (error.code === 4001) {
       console.log('User rejected transaction');
     } else {
       console.error('Transaction failed:', error);
     }
   }
   ```

4. **Use typed contracts**
   ```typescript
   import { Contract } from 'ethers';
   import { MyContract__factory } from './typechain';

   const contract = MyContract__factory.connect(address, signer);
   // Now you have full type safety!
   ```

## 📊 Advanced Features

### Event Listening
```typescript
const contract = new ethers.Contract(address, abi, provider);

// Listen for Transfer events
contract.on('Transfer', (from, to, amount) => {
  console.log(`Transfer: ${from} → ${to}: ${amount}`);
});

// Listen once
contract.once('Transfer', (from, to, amount) => {
  console.log('First transfer detected!');
});

// Remove listener
contract.removeAllListeners('Transfer');
```

### Gas Estimation
```typescript
// Estimate gas
const gasEstimate = await contract.estimateGas.transfer(to, amount);
console.log(`Estimated gas: ${gasEstimate.toString()}`);

// Get gas price
const gasPrice = await provider.getGasPrice();
console.log(`Gas price: ${ethers.utils.formatUnits(gasPrice, 'gwei')} gwei`);

// Send with custom gas
const tx = await contract.transfer(to, amount, {
  gasLimit: gasEstimate.mul(120).div(100), // +20% buffer
  gasPrice: gasPrice
});
```

## 📚 Resources

- [Ethers.js Documentation](https://docs.ethers.org/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [MetaMask Documentation](https://docs.metamask.io/)
- [WalletConnect](https://docs.walletconnect.com/)
- [EIP-1193](https://eips.ethereum.org/EIPS/eip-1193)

## 🤝 Contributing

Contributions welcome! Please ensure:
- TypeScript strict mode enabled
- All functions properly typed
- Tests included
- Code formatted with Prettier

## 📄 License

MIT License - see LICENSE file for details
