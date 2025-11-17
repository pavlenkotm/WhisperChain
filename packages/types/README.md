# @whisperchain/types

TypeScript type definitions for the WhisperChain ecosystem.

## Installation

```bash
npm install @whisperchain/types
```

## Usage

```typescript
import type {
  BlockchainNetwork,
  Transaction,
  EncryptedMessage,
  Wallet,
} from '@whisperchain/types';

const network: BlockchainNetwork = {
  name: 'Ethereum Mainnet',
  chainId: 1,
  rpcUrl: 'https://eth.llamarpc.com',
};
```

## Exported Types

- `SupportedBlockchain` - Union type of supported blockchains
- `BlockchainNetwork` - Network configuration
- `Wallet` - Wallet interface
- `Transaction` - Transaction data
- `EncryptedMessage` - Encrypted message format
- `Token` - ERC-20 token interface
- `NFT` - NFT metadata interface
- And more...

## License

MIT
