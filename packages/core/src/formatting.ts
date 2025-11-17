/**
 * Formatting utilities for blockchain data
 */

/**
 * Formats wei to ether
 */
export function formatWeiToEther(wei: string | bigint): string {
  const weiValue = typeof wei === 'string' ? BigInt(wei) : wei;
  const ether = Number(weiValue) / 1e18;
  return ether.toFixed(4);
}

/**
 * Formats ether to wei
 */
export function formatEtherToWei(ether: string | number): bigint {
  const etherValue = typeof ether === 'string' ? parseFloat(ether) : ether;
  return BigInt(Math.floor(etherValue * 1e18));
}

/**
 * Shortens an address for display (0x1234...5678)
 */
export function shortenAddress(
  address: string,
  prefixLength: number = 6,
  suffixLength: number = 4
): string {
  if (address.length < prefixLength + suffixLength) {
    return address;
  }
  return `${address.slice(0, prefixLength)}...${address.slice(-suffixLength)}`;
}

/**
 * Formats a timestamp to readable date
 */
export function formatTimestamp(timestamp: number): string {
  return new Date(timestamp * 1000).toISOString();
}

/**
 * Adds 0x prefix if not present
 */
export function add0xPrefix(value: string): string {
  return value.startsWith('0x') ? value : `0x${value}`;
}

/**
 * Removes 0x prefix if present
 */
export function remove0xPrefix(value: string): string {
  return value.startsWith('0x') ? value.slice(2) : value;
}

/**
 * Converts bytes to hex string
 */
export function bytesToHex(bytes: Uint8Array): string {
  return '0x' + Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Converts hex string to bytes
 */
export function hexToBytes(hex: string): Uint8Array {
  const cleanHex = remove0xPrefix(hex);
  const bytes = new Uint8Array(cleanHex.length / 2);
  for (let i = 0; i < cleanHex.length; i += 2) {
    bytes[i / 2] = parseInt(cleanHex.slice(i, i + 2), 16);
  }
  return bytes;
}
