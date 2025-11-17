/**
 * Constants used across WhisperChain ecosystem
 */

import type { BlockchainNetwork, SupportedBlockchain } from '@whisperchain/types';

/**
 * Default blockchain networks configuration
 */
export const DEFAULT_NETWORKS: Record<SupportedBlockchain, BlockchainNetwork> = {
  ethereum: {
    name: 'Ethereum Mainnet',
    chainId: 1,
    rpcUrl: 'https://eth.llamarpc.com',
    explorerUrl: 'https://etherscan.io',
  },
  solana: {
    name: 'Solana Mainnet',
    chainId: 0,
    rpcUrl: 'https://api.mainnet-beta.solana.com',
    explorerUrl: 'https://explorer.solana.com',
  },
  aptos: {
    name: 'Aptos Mainnet',
    chainId: 1,
    rpcUrl: 'https://fullnode.mainnet.aptoslabs.com',
    explorerUrl: 'https://explorer.aptoslabs.com',
  },
  starknet: {
    name: 'StarkNet Mainnet',
    chainId: 0,
    rpcUrl: 'https://starknet-mainnet.public.blastapi.io',
    explorerUrl: 'https://voyager.online',
  },
  polkadot: {
    name: 'Polkadot',
    chainId: 0,
    rpcUrl: 'https://rpc.polkadot.io',
    explorerUrl: 'https://polkadot.subscan.io',
  },
  cardano: {
    name: 'Cardano Mainnet',
    chainId: 1,
    rpcUrl: 'https://cardano-mainnet.blockfrost.io/api/v0',
    explorerUrl: 'https://cardanoscan.io',
  },
  tezos: {
    name: 'Tezos Mainnet',
    chainId: 0,
    rpcUrl: 'https://mainnet.api.tez.ie',
    explorerUrl: 'https://tzstats.com',
  },
  stacks: {
    name: 'Stacks Mainnet',
    chainId: 1,
    rpcUrl: 'https://stacks-node-api.mainnet.stacks.co',
    explorerUrl: 'https://explorer.stacks.co',
  },
  icp: {
    name: 'Internet Computer',
    chainId: 0,
    rpcUrl: 'https://ic0.app',
    explorerUrl: 'https://dashboard.internetcomputer.org',
  },
};

/**
 * Gas limits for common operations
 */
export const GAS_LIMITS = {
  SIMPLE_TRANSFER: 21000,
  ERC20_TRANSFER: 65000,
  ERC721_MINT: 150000,
  SWAP: 200000,
  CONTRACT_DEPLOY: 1500000,
};

/**
 * Common blockchain decimals
 */
export const DECIMALS = {
  ETH: 18,
  BTC: 8,
  SOL: 9,
  APT: 8,
};

/**
 * Zero address
 */
export const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

/**
 * Default message expiration (24 hours)
 */
export const DEFAULT_MESSAGE_EXPIRATION = 24 * 60 * 60; // seconds
