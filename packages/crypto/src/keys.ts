/**
 * Key generation and management utilities
 */

import * as nacl from 'tweetnacl';
import * as naclUtil from 'tweetnacl-util';
import type { KeyPair } from '@whisperchain/types';

/**
 * Generates a new key pair for encryption
 */
export function generateKeyPair(): KeyPair {
  const keyPair = nacl.box.keyPair();
  return {
    publicKey: keyPair.publicKey,
    privateKey: keyPair.secretKey,
  };
}

/**
 * Generates a key pair from a seed
 */
export function generateKeyPairFromSeed(seed: Uint8Array): KeyPair {
  const keyPair = nacl.box.keyPair.fromSecretKey(seed);
  return {
    publicKey: keyPair.publicKey,
    privateKey: keyPair.secretKey,
  };
}

/**
 * Generates a signing key pair (Ed25519)
 */
export function generateSigningKeyPair(): KeyPair {
  const keyPair = nacl.sign.keyPair();
  return {
    publicKey: keyPair.publicKey,
    privateKey: keyPair.secretKey,
  };
}

/**
 * Derives a shared secret from public and private keys
 */
export function deriveSharedSecret(
  theirPublicKey: Uint8Array,
  myPrivateKey: Uint8Array
): Uint8Array {
  return nacl.box.before(theirPublicKey, myPrivateKey);
}

/**
 * Encodes a key to base64
 */
export function encodeKey(key: Uint8Array): string {
  return naclUtil.encodeBase64(key);
}

/**
 * Decodes a key from base64
 */
export function decodeKey(encodedKey: string): Uint8Array {
  return naclUtil.decodeBase64(encodedKey);
}

/**
 * Generates a random symmetric key (32 bytes)
 */
export function generateSymmetricKey(): Uint8Array {
  return nacl.randomBytes(nacl.secretbox.keyLength);
}
