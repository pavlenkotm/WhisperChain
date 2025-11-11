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
 * Derive encryption key from password using PBKDF2
 */
function deriveKeyFromPassword(password: string, salt: string): CryptoJS.lib.WordArray {
  return CryptoJS.PBKDF2(password, salt, {
    keySize: 256 / 32,
    iterations: 100000,
    hasher: CryptoJS.algo.SHA256
  });
}

/**
 * Encrypt data with password-derived key
 */
function encryptWithPassword(data: string, password: string): { encrypted: string; salt: string; iv: string } {
  const salt = CryptoJS.lib.WordArray.random(128 / 8).toString();
  const iv = CryptoJS.lib.WordArray.random(128 / 8);
  const key = deriveKeyFromPassword(password, salt);

  const encrypted = CryptoJS.AES.encrypt(data, key, {
    iv: iv,
    mode: CryptoJS.mode.CBC,
    padding: CryptoJS.pad.Pkcs7
  });

  return {
    encrypted: encrypted.toString(),
    salt: salt,
    iv: iv.toString(CryptoJS.enc.Hex)
  };
}

/**
 * Decrypt data with password-derived key
 */
function decryptWithPassword(encrypted: string, password: string, salt: string, iv: string): string {
  const key = deriveKeyFromPassword(password, salt);
  const ivWordArray = CryptoJS.enc.Hex.parse(iv);

  const decrypted = CryptoJS.AES.decrypt(encrypted, key, {
    iv: ivWordArray,
    mode: CryptoJS.mode.CBC,
    padding: CryptoJS.pad.Pkcs7
  });

  return decrypted.toString(CryptoJS.enc.Utf8);
}

/**
 * Store key pair in local storage (encrypted with password)
 * @param chatId - Chat identifier
 * @param keyPair - Key pair to store
 * @param password - Password for encryption (optional for backwards compatibility)
 */
export function storeKeyPair(chatId: string, keyPair: KeyPair, password?: string): void {
  const data = JSON.stringify({
    privateKey: keyPair.privateKey,
    publicKey: bytesToHex(keyPair.publicKey)
  });

  if (password) {
    // Store encrypted with password
    const { encrypted, salt, iv } = encryptWithPassword(data, password);
    localStorage.setItem(`whisperchain_key_${chatId}`, JSON.stringify({
      version: 2,
      encrypted: true,
      data: encrypted,
      salt: salt,
      iv: iv
    }));
  } else {
    // Fallback: store unencrypted (for backwards compatibility)
    localStorage.setItem(`whisperchain_key_${chatId}`, JSON.stringify({
      version: 1,
      encrypted: false,
      ...JSON.parse(data)
    }));
  }
}

/**
 * Retrieve key pair from local storage
 * @param chatId - Chat identifier
 * @param password - Password for decryption (required for encrypted keys)
 */
export function getKeyPair(chatId: string, password?: string): KeyPair | null {
  const stored = localStorage.getItem(`whisperchain_key_${chatId}`);
  if (!stored) return null;

  try {
    const parsed = JSON.parse(stored);

    // Handle encrypted storage (v2)
    if (parsed.version === 2 && parsed.encrypted) {
      if (!password) {
        throw new Error('Password required to decrypt key pair');
      }

      const decrypted = decryptWithPassword(parsed.data, password, parsed.salt, parsed.iv);
      const data = JSON.parse(decrypted);
      return {
        privateKey: data.privateKey,
        publicKey: hexToBytes(data.publicKey)
      };
    }

    // Handle unencrypted storage (v1 or legacy)
    return {
      privateKey: parsed.privateKey,
      publicKey: hexToBytes(parsed.publicKey)
    };
  } catch (error) {
    console.error('Failed to retrieve key pair:', error);
    return null;
  }
}

/**
 * Check if a key pair is encrypted
 */
export function isKeyPairEncrypted(chatId: string): boolean {
  const stored = localStorage.getItem(`whisperchain_key_${chatId}`);
  if (!stored) return false;

  try {
    const parsed = JSON.parse(stored);
    return parsed.version === 2 && parsed.encrypted === true;
  } catch {
    return false;
  }
}

/**
 * Migrate unencrypted key pair to encrypted storage
 */
export function migrateKeyPairToEncrypted(chatId: string, password: string): boolean {
  try {
    const keyPair = getKeyPair(chatId);
    if (!keyPair) return false;

    // Re-store with encryption
    storeKeyPair(chatId, keyPair, password);
    return true;
  } catch {
    return false;
  }
}

/**
 * Delete key pair from local storage (for self-destructing chats)
 */
export function deleteKeyPair(chatId: string): void {
  localStorage.removeItem(`whisperchain_key_${chatId}`);
}
