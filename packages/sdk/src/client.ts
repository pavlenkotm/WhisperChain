/**
 * Main WhisperChain client
 */

import type { WhisperChainConfig, SupportedBlockchain } from '@whisperchain/types';
import { DEFAULT_NETWORKS, DEFAULT_MESSAGE_EXPIRATION } from '@whisperchain/core';
import { generateKeyPair } from '@whisperchain/crypto';
import { MessagingClient } from './messaging';
import { BlockchainClient } from './blockchain';

export interface WhisperChainClientOptions {
  blockchain?: SupportedBlockchain;
  config?: Partial<WhisperChainConfig>;
  privateKey?: Uint8Array;
}

/**
 * Main WhisperChain client for interacting with the ecosystem
 */
export class WhisperChainClient {
  public readonly config: WhisperChainConfig;
  public readonly messaging: MessagingClient;
  public readonly blockchain: BlockchainClient;
  private keyPair?: { publicKey: Uint8Array; privateKey: Uint8Array };

  constructor(options: WhisperChainClientOptions = {}) {
    this.config = {
      defaultBlockchain: options.blockchain || 'ethereum',
      networks: DEFAULT_NETWORKS,
      encryptionEnabled: true,
      messageExpirationSeconds: DEFAULT_MESSAGE_EXPIRATION,
      ...options.config,
    };

    if (options.privateKey) {
      this.keyPair = {
        privateKey: options.privateKey,
        publicKey: generateKeyPair().publicKey, // This should derive from private key
      };
    }

    this.messaging = new MessagingClient(this);
    this.blockchain = new BlockchainClient(this);
  }

  /**
   * Initializes the client with a new key pair
   */
  public async initialize(): Promise<void> {
    if (!this.keyPair) {
      this.keyPair = generateKeyPair();
    }
  }

  /**
   * Gets the client's public key
   */
  public getPublicKey(): Uint8Array {
    if (!this.keyPair) {
      throw new Error('Client not initialized. Call initialize() first.');
    }
    return this.keyPair.publicKey;
  }

  /**
   * Gets the client's private key
   */
  public getPrivateKey(): Uint8Array {
    if (!this.keyPair) {
      throw new Error('Client not initialized. Call initialize() first.');
    }
    return this.keyPair.privateKey;
  }

  /**
   * Gets the current blockchain network
   */
  public getCurrentNetwork() {
    return this.config.networks[this.config.defaultBlockchain];
  }

  /**
   * Switches to a different blockchain
   */
  public switchBlockchain(blockchain: SupportedBlockchain): void {
    this.config.defaultBlockchain = blockchain;
  }
}
