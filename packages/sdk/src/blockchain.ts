/**
 * Blockchain interaction client
 */

import type { Transaction, SupportedBlockchain, BlockchainNetwork } from '@whisperchain/types';
import type { WhisperChainClient } from './client';
import { ethers } from 'ethers';

/**
 * Client for blockchain interactions
 */
export class BlockchainClient {
  private providers: Map<SupportedBlockchain, ethers.JsonRpcProvider> = new Map();

  constructor(private client: WhisperChainClient) {}

  /**
   * Gets a provider for the specified blockchain
   */
  public getProvider(blockchain?: SupportedBlockchain): ethers.JsonRpcProvider {
    const chain = blockchain || this.client.config.defaultBlockchain;

    if (!this.providers.has(chain)) {
      const network = this.client.config.networks[chain];
      const provider = new ethers.JsonRpcProvider(network.rpcUrl);
      this.providers.set(chain, provider);
    }

    return this.providers.get(chain)!;
  }

  /**
   * Gets the balance of an address
   */
  public async getBalance(
    address: string,
    blockchain?: SupportedBlockchain
  ): Promise<string> {
    const provider = this.getProvider(blockchain);
    const balance = await provider.getBalance(address);
    return ethers.formatEther(balance);
  }

  /**
   * Sends a transaction
   */
  public async sendTransaction(
    to: string,
    value: string,
    privateKey: string,
    blockchain?: SupportedBlockchain
  ): Promise<Transaction> {
    const provider = this.getProvider(blockchain);
    const wallet = new ethers.Wallet(privateKey, provider);

    const tx = await wallet.sendTransaction({
      to,
      value: ethers.parseEther(value),
    });

    return {
      hash: tx.hash,
      from: tx.from,
      to: tx.to || '',
      value,
      timestamp: Math.floor(Date.now() / 1000),
      status: 'pending',
    };
  }

  /**
   * Gets transaction details
   */
  public async getTransaction(
    hash: string,
    blockchain?: SupportedBlockchain
  ): Promise<Transaction | null> {
    const provider = this.getProvider(blockchain);
    const tx = await provider.getTransaction(hash);

    if (!tx) {
      return null;
    }

    const receipt = await provider.getTransactionReceipt(hash);

    return {
      hash: tx.hash,
      from: tx.from,
      to: tx.to || '',
      value: ethers.formatEther(tx.value),
      data: tx.data,
      timestamp: Math.floor(Date.now() / 1000),
      blockNumber: tx.blockNumber || undefined,
      status: receipt?.status === 1 ? 'confirmed' : 'failed',
    };
  }

  /**
   * Gets the current block number
   */
  public async getBlockNumber(blockchain?: SupportedBlockchain): Promise<number> {
    const provider = this.getProvider(blockchain);
    return provider.getBlockNumber();
  }

  /**
   * Gets gas price
   */
  public async getGasPrice(blockchain?: SupportedBlockchain): Promise<string> {
    const provider = this.getProvider(blockchain);
    const feeData = await provider.getFeeData();
    return ethers.formatUnits(feeData.gasPrice || 0n, 'gwei');
  }
}
