# @whisperchain/core

Core utilities for the WhisperChain ecosystem.

## Installation

```bash
npm install @whisperchain/core
```

## Features

- **Validation** - Address and data validation
- **Formatting** - Wei/Ether conversion, address formatting
- **Constants** - Network configs, gas limits

## Usage

```typescript
import {
  isValidEthereumAddress,
  formatWeiToEther,
  shortenAddress,
  DEFAULT_NETWORKS,
} from '@whisperchain/core';

// Validate address
if (isValidEthereumAddress('0x123...')) {
  console.log('Valid address');
}

// Format wei to ether
const ether = formatWeiToEther('1000000000000000000'); // "1.0000"

// Shorten address for display
const short = shortenAddress('0x1234567890123456789012345678901234567890');
// "0x1234...7890"

// Get network configuration
const ethNetwork = DEFAULT_NETWORKS.ethereum;
```

## API

See [API Documentation](../../docs/API.md) for full details.

## License

MIT
