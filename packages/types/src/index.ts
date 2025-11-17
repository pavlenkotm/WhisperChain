/**
 * @whisperchain/types - Shared TypeScript types for WhisperChain ecosystem
 */

// Blockchain types
export interface BlockchainNetwork {
  name: string;
  chainId: number;
  rpcUrl: string;
  explorerUrl?: string;
}

export type SupportedBlockchain =
  | 'ethereum'
  | 'solana'
  | 'aptos'
  | 'starknet'
  | 'polkadot'
  | 'cardano'
  | 'tezos'
  | 'stacks'
  | 'icp';

// Wallet types
export interface Wallet {
  address: string;
  publicKey: string;
  blockchain: SupportedBlockchain;
}

export interface SignedMessage {
  message: string;
  signature: string;
  publicKey: string;
}

// Transaction types
export interface Transaction {
  hash: string;
  from: string;
  to: string;
  value: string;
  data?: string;
  timestamp: number;
  blockNumber?: number;
  status: 'pending' | 'confirmed' | 'failed';
}

// Smart contract types
export interface ContractABI {
  name: string;
  type: 'function' | 'event' | 'constructor';
  inputs: Array<{
    name: string;
    type: string;
  }>;
  outputs?: Array<{
    name: string;
    type: string;
  }>;
}

export interface DeployedContract {
  address: string;
  blockchain: SupportedBlockchain;
  abi: ContractABI[];
  deploymentTransaction: string;
}

// Token types
export interface Token {
  symbol: string;
  name: string;
  decimals: number;
  totalSupply: string;
  contractAddress: string;
}

export interface NFT {
  tokenId: string;
  contractAddress: string;
  owner: string;
  metadata: {
    name: string;
    description: string;
    image: string;
    attributes?: Array<{
      trait_type: string;
      value: string | number;
    }>;
  };
}

// Encryption types (for WhisperChain messaging)
export interface EncryptedMessage {
  ciphertext: string;
  nonce: string;
  recipientPublicKey: string;
  senderPublicKey: string;
  timestamp: number;
  expiresAt?: number;
}

export interface KeyPair {
  publicKey: Uint8Array;
  privateKey: Uint8Array;
}

// Configuration types
export interface WhisperChainConfig {
  defaultBlockchain: SupportedBlockchain;
  networks: Record<SupportedBlockchain, BlockchainNetwork>;
  encryptionEnabled: boolean;
  messageExpirationSeconds?: number;
}

// Error types
export class WhisperChainError extends Error {
  constructor(
    message: string,
    public code: string,
    public details?: unknown
  ) {
    super(message);
    this.name = 'WhisperChainError';
  }
}

export type ErrorCode =
  | 'NETWORK_ERROR'
  | 'INVALID_ADDRESS'
  | 'TRANSACTION_FAILED'
  | 'ENCRYPTION_ERROR'
  | 'SIGNATURE_INVALID'
  | 'CONTRACT_ERROR';
