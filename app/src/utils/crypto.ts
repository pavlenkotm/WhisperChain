import { ec as EC } from 'elliptic';
import CryptoJS from 'crypto-js';

// Initialize elliptic curve for Diffie-Hellman
const ec = new EC('curve25519');

export interface KeyPair {
  privateKey: string;
  publicKey: Uint8Array;
}

/**
 * Generate a new Diffie-Hellman key pair
 */
export function generateKeyPair(): KeyPair {
  const keyPair = ec.genKeyPair();
  const privateKey = keyPair.getPrivate('hex');
  const publicKey = new Uint8Array(keyPair.getPublic().encode('array', false));

  return {
    privateKey,
    publicKey: publicKey.slice(1, 33) // Take 32 bytes for Curve25519
  };
}

/**
 * Derive a shared secret from our private key and their public key
 */
export function deriveSharedSecret(
  ourPrivateKey: string,
  theirPublicKey: Uint8Array
): Uint8Array {
  const ourKeyPair = ec.keyFromPrivate(ourPrivateKey, 'hex');

  // Reconstruct the public key point
  const theirKeyPoint = ec.keyFromPublic(
    Array.from(new Uint8Array([0x04, ...theirPublicKey])),
    'array'
  ).getPublic();

  // Compute shared secret
  const sharedSecret = ourKeyPair.derive(theirKeyPoint);
  const sharedSecretHex = sharedSecret.toString(16).padStart(64, '0');

  return hexToBytes(sharedSecretHex);
}

/**
 * Encrypt a message using AES-256-GCM
 */
export function encryptMessage(
  message: string,
  sharedSecret: Uint8Array
): { ciphertext: string; iv: string } {
  // Generate random IV
  const iv = CryptoJS.lib.WordArray.random(16);

  // Convert shared secret to WordArray
  const key = CryptoJS.lib.WordArray.create(Array.from(sharedSecret));

  // Encrypt
  const encrypted = CryptoJS.AES.encrypt(message, key, {
    iv: iv,
    mode: CryptoJS.mode.GCM,
    padding: CryptoJS.pad.Pkcs7
  });

  return {
    ciphertext: encrypted.toString(),
    iv: iv.toString(CryptoJS.enc.Hex)
  };
}

/**
 * Decrypt a message using AES-256-GCM
 */
export function decryptMessage(
  ciphertext: string,
  iv: string,
  sharedSecret: Uint8Array
): string {
  try {
    // Convert shared secret to WordArray
    const key = CryptoJS.lib.WordArray.create(Array.from(sharedSecret));

    // Convert IV from hex
    const ivWordArray = CryptoJS.enc.Hex.parse(iv);

    // Decrypt
    const decrypted = CryptoJS.AES.decrypt(ciphertext, key, {
      iv: ivWordArray,
      mode: CryptoJS.mode.GCM,
      padding: CryptoJS.pad.Pkcs7
    });

    return decrypted.toString(CryptoJS.enc.Utf8);
  } catch (error) {
    console.error('Decryption error:', error);
    throw new Error('Failed to decrypt message');
  }
}

/**
 * Combine encrypted message parts into a single payload
 */
export function packEncryptedData(ciphertext: string, iv: string): Uint8Array {
  const payload = JSON.stringify({ ciphertext, iv });
  return new TextEncoder().encode(payload);
}

/**
 * Extract encrypted message parts from payload
 */
export function unpackEncryptedData(data: Uint8Array): { ciphertext: string; iv: string } {
  const payload = new TextDecoder().decode(data);
  return JSON.parse(payload);
}

/**
 * Utility: Convert hex string to Uint8Array
 */
export function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.substr(i, 2), 16);
  }
  return bytes;
}

/**
 * Utility: Convert Uint8Array to hex string
 */
export function bytesToHex(bytes: Uint8Array): string {
  return Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Store key pair in local storage (encrypted with password in production)
 */
export function storeKeyPair(chatId: string, keyPair: KeyPair): void {
  localStorage.setItem(`whisperchain_key_${chatId}`, JSON.stringify({
    privateKey: keyPair.privateKey,
    publicKey: bytesToHex(keyPair.publicKey)
  }));
}

/**
 * Retrieve key pair from local storage
 */
export function getKeyPair(chatId: string): KeyPair | null {
  const stored = localStorage.getItem(`whisperchain_key_${chatId}`);
  if (!stored) return null;

  try {
    const parsed = JSON.parse(stored);
    return {
      privateKey: parsed.privateKey,
      publicKey: hexToBytes(parsed.publicKey)
    };
  } catch {
    return null;
  }
}

/**
 * Delete key pair from local storage (for self-destructing chats)
 */
export function deleteKeyPair(chatId: string): void {
  localStorage.removeItem(`whisperchain_key_${chatId}`);
}
