/**
 * Validation utilities for blockchain addresses and data
 */

/**
 * Validates an Ethereum address
 */
export function isValidEthereumAddress(address: string): boolean {
  return /^0x[a-fA-F0-9]{40}$/.test(address);
}

/**
 * Validates a Solana address (base58)
 */
export function isValidSolanaAddress(address: string): boolean {
  return /^[1-9A-HJ-NP-Za-km-z]{32,44}$/.test(address);
}

/**
 * Validates a transaction hash
 */
export function isValidTransactionHash(hash: string): boolean {
  return /^0x[a-fA-F0-9]{64}$/.test(hash);
}

/**
 * Validates hex string
 */
export function isValidHex(value: string): boolean {
  return /^0x[a-fA-F0-9]*$/.test(value);
}

/**
 * Validates a private key (32 bytes hex)
 */
export function isValidPrivateKey(key: string): boolean {
  return /^(0x)?[a-fA-F0-9]{64}$/.test(key);
}

/**
 * Checks if a string is a valid JSON
 */
export function isValidJSON(str: string): boolean {
  try {
    JSON.parse(str);
    return true;
  } catch {
    return false;
  }
}
