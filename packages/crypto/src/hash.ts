/**
 * Hashing utilities
 */

import * as nacl from 'tweetnacl';
import * as naclUtil from 'tweetnacl-util';

/**
 * Hashes data using SHA-512
 */
export function sha512(data: string | Uint8Array): Uint8Array {
  const bytes = typeof data === 'string' ? naclUtil.decodeUTF8(data) : data;
  return nacl.hash(bytes);
}

/**
 * Hashes data to hex string
 */
export function sha512Hex(data: string | Uint8Array): string {
  const hash = sha512(data);
  return Array.from(hash)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Hashes data to base64
 */
export function sha512Base64(data: string | Uint8Array): string {
  const hash = sha512(data);
  return naclUtil.encodeBase64(hash);
}

/**
 * Creates a message digest (first 32 bytes of SHA-512)
 */
export function messageDigest(message: string): Uint8Array {
  const hash = sha512(message);
  return hash.slice(0, 32);
}
