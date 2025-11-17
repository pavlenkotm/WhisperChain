# @whisperchain/sdk

Main SDK for the WhisperChain ecosystem.

## Installation

```bash
npm install @whisperchain/sdk
```

## Features

- **Multi-chain Support** - Ethereum, Solana, and more
- **Encrypted Messaging** - End-to-end encryption
- **Blockchain Operations** - Transactions, balances, gas
- **Type Safety** - Full TypeScript support

## Quick Start

```typescript
import { WhisperChainClient } from '@whisperchain/sdk';

// Initialize client
const client = new WhisperChainClient({
  blockchain: 'ethereum',
});

await client.initialize();

// Send encrypted message
const message = await client.messaging.sendMessage(
  recipientPublicKey,
  'Hello, Web3!',
  3600 // expires in 1 hour
);

// Check balance
const balance = await client.blockchain.getBalance('0x...');
console.log(`Balance: ${balance} ETH`);

// Send transaction
const tx = await client.blockchain.sendTransaction(
  '0xRecipient...',
  '0.1',
  privateKey
);
```

## API

See [API Documentation](../../docs/API.md) for full details.

## Examples

Check out the [examples directory](../../examples/) for more use cases.

## License

MIT
