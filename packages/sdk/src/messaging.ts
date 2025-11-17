/**
 * Messaging client for encrypted communications
 */

import type { EncryptedMessage } from '@whisperchain/types';
import { encryptMessage, decryptMessage } from '@whisperchain/crypto';
import type { WhisperChainClient } from './client';

/**
 * Client for handling encrypted messaging
 */
export class MessagingClient {
  constructor(private client: WhisperChainClient) {}

  /**
   * Sends an encrypted message
   */
  public async sendMessage(
    recipientPublicKey: Uint8Array,
    message: string,
    expiresInSeconds?: number
  ): Promise<EncryptedMessage> {
    const encrypted = encryptMessage(
      message,
      recipientPublicKey,
      this.client.getPrivateKey()
    );

    const timestamp = Math.floor(Date.now() / 1000);
    const expiresAt = expiresInSeconds
      ? timestamp + expiresInSeconds
      : timestamp + (this.client.config.messageExpirationSeconds || 86400);

    return {
      ...encrypted,
      timestamp,
      expiresAt,
    };
  }

  /**
   * Receives and decrypts a message
   */
  public async receiveMessage(encryptedMessage: EncryptedMessage): Promise<string> {
    // Check if message has expired
    if (encryptedMessage.expiresAt) {
      const now = Math.floor(Date.now() / 1000);
      if (now > encryptedMessage.expiresAt) {
        throw new Error('Message has expired');
      }
    }

    return decryptMessage(encryptedMessage, this.client.getPrivateKey());
  }

  /**
   * Creates a message that will self-destruct
   */
  public async createSelfDestructingMessage(
    recipientPublicKey: Uint8Array,
    message: string,
    expiresInSeconds: number
  ): Promise<EncryptedMessage> {
    return this.sendMessage(recipientPublicKey, message, expiresInSeconds);
  }
}
