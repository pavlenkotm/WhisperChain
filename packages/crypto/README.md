# @whisperchain/crypto

Cryptographic utilities for the WhisperChain ecosystem.

## Installation

```bash
npm install @whisperchain/crypto
```

## Features

- **Public Key Encryption** - X25519-XSalsa20-Poly1305
- **Key Management** - Generate, encode, decode keys
- **Hashing** - SHA-512
- **Symmetric Encryption** - XSalsa20-Poly1305

## Usage

```typescript
import {
  generateKeyPair,
  encryptMessage,
  decryptMessage,
  sha512Hex,
} from '@whisperchain/crypto';

// Generate keys
const aliceKeys = generateKeyPair();
const bobKeys = generateKeyPair();

// Encrypt message
const encrypted = encryptMessage(
  'Hello Bob!',
  bobKeys.publicKey,
  aliceKeys.privateKey
);

// Decrypt message
const plaintext = decryptMessage(encrypted, bobKeys.privateKey);
console.log(plaintext); // "Hello Bob!"

// Hash data
const hash = sha512Hex('some data');
```

## Security

This package uses [TweetNaCl](https://tweetnacl.js.org/), a high-security cryptographic library.

## API

See [API Documentation](../../docs/API.md) for full details.

## License

MIT
