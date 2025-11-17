/**
 * Encryption utilities using NaCl (TweetNaCl)
 */

import * as nacl from 'tweetnacl';
import * as naclUtil from 'tweetnacl-util';
import type { EncryptedMessage, KeyPair } from '@whisperchain/types';

/**
 * Encrypts a message using public key encryption (X25519-XSalsa20-Poly1305)
 */
export function encryptMessage(
  message: string,
  recipientPublicKey: Uint8Array,
  senderPrivateKey: Uint8Array
): Omit<EncryptedMessage, 'timestamp' | 'expiresAt'> {
  const nonce = nacl.randomBytes(nacl.box.nonceLength);
  const messageBytes = naclUtil.decodeUTF8(message);

  const encrypted = nacl.box(
    messageBytes,
    nonce,
    recipientPublicKey,
    senderPrivateKey
  );

  const senderPublicKey = nacl.box.keyPair.fromSecretKey(senderPrivateKey).publicKey;

  return {
    ciphertext: naclUtil.encodeBase64(encrypted),
    nonce: naclUtil.encodeBase64(nonce),
    recipientPublicKey: naclUtil.encodeBase64(recipientPublicKey),
    senderPublicKey: naclUtil.encodeBase64(senderPublicKey),
  };
}

/**
 * Decrypts a message using private key
 */
export function decryptMessage(
  encryptedMessage: Omit<EncryptedMessage, 'timestamp' | 'expiresAt'>,
  recipientPrivateKey: Uint8Array
): string {
  const ciphertext = naclUtil.decodeBase64(encryptedMessage.ciphertext);
  const nonce = naclUtil.decodeBase64(encryptedMessage.nonce);
  const senderPublicKey = naclUtil.decodeBase64(encryptedMessage.senderPublicKey);

  const decrypted = nacl.box.open(
    ciphertext,
    nonce,
    senderPublicKey,
    recipientPrivateKey
  );

  if (!decrypted) {
    throw new Error('Failed to decrypt message');
  }

  return naclUtil.encodeUTF8(decrypted);
}

/**
 * Symmetric encryption (for self-encrypting data)
 */
export function encryptSymmetric(
  message: string,
  key: Uint8Array
): { ciphertext: string; nonce: string } {
  const nonce = nacl.randomBytes(nacl.secretbox.nonceLength);
  const messageBytes = naclUtil.decodeUTF8(message);

  const encrypted = nacl.secretbox(messageBytes, nonce, key);

  return {
    ciphertext: naclUtil.encodeBase64(encrypted),
    nonce: naclUtil.encodeBase64(nonce),
  };
}

/**
 * Symmetric decryption
 */
export function decryptSymmetric(
  ciphertext: string,
  nonce: string,
  key: Uint8Array
): string {
  const ciphertextBytes = naclUtil.decodeBase64(ciphertext);
  const nonceBytes = naclUtil.decodeBase64(nonce);

  const decrypted = nacl.secretbox.open(ciphertextBytes, nonceBytes, key);

  if (!decrypted) {
    throw new Error('Failed to decrypt message');
  }

  return naclUtil.encodeUTF8(decrypted);
}
