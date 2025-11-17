# WhisperChain API Reference

## @whisperchain/sdk

### WhisperChainClient

Main client for interacting with the WhisperChain ecosystem.

#### Constructor

```typescript
constructor(options?: WhisperChainClientOptions)
```

**Parameters**:
- `options.blockchain?` - Default blockchain to use (default: `'ethereum'`)
- `options.config?` - Partial configuration object
- `options.privateKey?` - Encryption private key (Uint8Array)

**Example**:
```typescript
import { WhisperChainClient } from '@whisperchain/sdk';

const client = new WhisperChainClient({
  blockchain: 'ethereum',
  config: {
    encryptionEnabled: true,
    messageExpirationSeconds: 3600,
  },
});
```

#### Methods

##### `initialize()`

Initializes the client with encryption keys.

```typescript
async initialize(): Promise<void>
```

**Example**:
```typescript
await client.initialize();
```

##### `getPublicKey()`

Gets the client's encryption public key.

```typescript
getPublicKey(): Uint8Array
```

##### `getPrivateKey()`

Gets the client's encryption private key.

```typescript
getPrivateKey(): Uint8Array
```

##### `getCurrentNetwork()`

Gets the current blockchain network configuration.

```typescript
getCurrentNetwork(): BlockchainNetwork
```

##### `switchBlockchain(blockchain)`

Switches to a different blockchain.

```typescript
switchBlockchain(blockchain: SupportedBlockchain): void
```

---

### MessagingClient

Handles encrypted messaging operations.

#### Methods

##### `sendMessage(recipientPublicKey, message, expiresInSeconds?)`

Sends an encrypted message.

```typescript
async sendMessage(
  recipientPublicKey: Uint8Array,
  message: string,
  expiresInSeconds?: number
): Promise<EncryptedMessage>
```

**Parameters**:
- `recipientPublicKey` - Recipient's public encryption key
- `message` - Plaintext message to encrypt
- `expiresInSeconds?` - Optional expiration time (default: 24 hours)

**Returns**: `EncryptedMessage` object

**Example**:
```typescript
const encrypted = await client.messaging.sendMessage(
  bobPublicKey,
  'Hello Bob!',
  3600 // expires in 1 hour
);
```

##### `receiveMessage(encryptedMessage)`

Receives and decrypts a message.

```typescript
async receiveMessage(encryptedMessage: EncryptedMessage): Promise<string>
```

**Throws**: Error if message has expired

**Example**:
```typescript
const plaintext = await client.messaging.receiveMessage(encrypted);
console.log(plaintext); // "Hello Bob!"
```

---

### BlockchainClient

Handles blockchain interactions.

#### Methods

##### `getProvider(blockchain?)`

Gets an RPC provider for the specified blockchain.

```typescript
getProvider(blockchain?: SupportedBlockchain): ethers.JsonRpcProvider
```

##### `getBalance(address, blockchain?)`

Gets the balance of an address.

```typescript
async getBalance(
  address: string,
  blockchain?: SupportedBlockchain
): Promise<string>
```

**Returns**: Balance in ETH (as string)

**Example**:
```typescript
const balance = await client.blockchain.getBalance('0x123...');
console.log(`Balance: ${balance} ETH`);
```

##### `sendTransaction(to, value, privateKey, blockchain?)`

Sends a transaction.

```typescript
async sendTransaction(
  to: string,
  value: string,
  privateKey: string,
  blockchain?: SupportedBlockchain
): Promise<Transaction>
```

**Parameters**:
- `to` - Recipient address
- `value` - Amount in ETH (as string)
- `privateKey` - Sender's private key
- `blockchain?` - Target blockchain (optional)

**Example**:
```typescript
const tx = await client.blockchain.sendTransaction(
  '0xRecipient...',
  '0.1',
  '0xYourPrivateKey...'
);
console.log(`Transaction hash: ${tx.hash}`);
```

##### `getTransaction(hash, blockchain?)`

Gets transaction details.

```typescript
async getTransaction(
  hash: string,
  blockchain?: SupportedBlockchain
): Promise<Transaction | null>
```

##### `getBlockNumber(blockchain?)`

Gets the current block number.

```typescript
async getBlockNumber(blockchain?: SupportedBlockchain): Promise<number>
```

##### `getGasPrice(blockchain?)`

Gets the current gas price in gwei.

```typescript
async getGasPrice(blockchain?: SupportedBlockchain): Promise<string>
```

---

## @whisperchain/crypto

### Encryption Functions

#### `encryptMessage(message, recipientPublicKey, senderPrivateKey)`

Encrypts a message using public key encryption.

```typescript
function encryptMessage(
  message: string,
  recipientPublicKey: Uint8Array,
  senderPrivateKey: Uint8Array
): Omit<EncryptedMessage, 'timestamp' | 'expiresAt'>
```

#### `decryptMessage(encryptedMessage, recipientPrivateKey)`

Decrypts an encrypted message.

```typescript
function decryptMessage(
  encryptedMessage: Omit<EncryptedMessage, 'timestamp' | 'expiresAt'>,
  recipientPrivateKey: Uint8Array
): string
```

#### `encryptSymmetric(message, key)`

Encrypts data with symmetric encryption.

```typescript
function encryptSymmetric(
  message: string,
  key: Uint8Array
): { ciphertext: string; nonce: string }
```

#### `decryptSymmetric(ciphertext, nonce, key)`

Decrypts symmetrically encrypted data.

```typescript
function decryptSymmetric(
  ciphertext: string,
  nonce: string,
  key: Uint8Array
): string
```

### Key Management

#### `generateKeyPair()`

Generates a new encryption key pair.

```typescript
function generateKeyPair(): KeyPair
```

#### `generateSigningKeyPair()`

Generates a new signing key pair (Ed25519).

```typescript
function generateSigningKeyPair(): KeyPair
```

#### `generateSymmetricKey()`

Generates a random symmetric key.

```typescript
function generateSymmetricKey(): Uint8Array
```

#### `encodeKey(key)` / `decodeKey(encodedKey)`

Encodes/decodes keys to/from base64.

```typescript
function encodeKey(key: Uint8Array): string
function decodeKey(encodedKey: string): Uint8Array
```

### Hashing

#### `sha512(data)`

Hashes data using SHA-512.

```typescript
function sha512(data: string | Uint8Array): Uint8Array
```

#### `sha512Hex(data)`

Hashes data to hex string.

```typescript
function sha512Hex(data: string | Uint8Array): string
```

---

## @whisperchain/core

### Validation

#### `isValidEthereumAddress(address)`

Validates an Ethereum address.

```typescript
function isValidEthereumAddress(address: string): boolean
```

#### `isValidSolanaAddress(address)`

Validates a Solana address.

```typescript
function isValidSolanaAddress(address: string): boolean
```

#### `isValidTransactionHash(hash)`

Validates a transaction hash.

```typescript
function isValidTransactionHash(hash: string): boolean
```

### Formatting

#### `formatWeiToEther(wei)`

Converts wei to ether.

```typescript
function formatWeiToEther(wei: string | bigint): string
```

#### `formatEtherToWei(ether)`

Converts ether to wei.

```typescript
function formatEtherToWei(ether: string | number): bigint
```

#### `shortenAddress(address, prefixLength?, suffixLength?)`

Shortens an address for display.

```typescript
function shortenAddress(
  address: string,
  prefixLength?: number,
  suffixLength?: number
): string
```

**Example**:
```typescript
shortenAddress('0x1234567890123456789012345678901234567890')
// Returns: "0x1234...7890"
```

#### `bytesToHex(bytes)` / `hexToBytes(hex)`

Converts between bytes and hex.

```typescript
function bytesToHex(bytes: Uint8Array): string
function hexToBytes(hex: string): Uint8Array
```

### Constants

#### `DEFAULT_NETWORKS`

Default network configurations for all supported blockchains.

```typescript
const DEFAULT_NETWORKS: Record<SupportedBlockchain, BlockchainNetwork>
```

#### `GAS_LIMITS`

Common gas limits for operations.

```typescript
const GAS_LIMITS: {
  SIMPLE_TRANSFER: 21000,
  ERC20_TRANSFER: 65000,
  ERC721_MINT: 150000,
  SWAP: 200000,
  CONTRACT_DEPLOY: 1500000,
}
```

---

## @whisperchain/types

### Core Types

```typescript
type SupportedBlockchain =
  | 'ethereum'
  | 'solana'
  | 'aptos'
  | 'starknet'
  | 'polkadot'
  | 'cardano'
  | 'tezos'
  | 'stacks'
  | 'icp';

interface BlockchainNetwork {
  name: string;
  chainId: number;
  rpcUrl: string;
  explorerUrl?: string;
}

interface Wallet {
  address: string;
  publicKey: string;
  blockchain: SupportedBlockchain;
}

interface Transaction {
  hash: string;
  from: string;
  to: string;
  value: string;
  data?: string;
  timestamp: number;
  blockNumber?: number;
  status: 'pending' | 'confirmed' | 'failed';
}

interface EncryptedMessage {
  ciphertext: string;
  nonce: string;
  recipientPublicKey: string;
  senderPublicKey: string;
  timestamp: number;
  expiresAt?: number;
}

interface KeyPair {
  publicKey: Uint8Array;
  privateKey: Uint8Array;
}
```

---

For more examples, see the [examples directory](../examples/) or visit the [GitHub repository](https://github.com/pavlenkotm/WhisperChain).
