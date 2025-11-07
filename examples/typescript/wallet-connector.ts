/**
 * Wallet Connection Utilities for Web3 DApps
 * Supports MetaMask, WalletConnect, Coinbase Wallet
 */

import { ethers } from 'ethers';

export interface WalletInfo {
  address: string;
  chainId: number;
  balance: string;
  provider: ethers.providers.Web3Provider;
  signer: ethers.Signer;
}

export class WalletConnector {
  private provider: ethers.providers.Web3Provider | null = null;
  private signer: ethers.Signer | null = null;

  /**
   * Connect to MetaMask wallet
   */
  async connectMetaMask(): Promise<WalletInfo> {
    if (typeof window === 'undefined' || !window.ethereum) {
      throw new Error('MetaMask is not installed');
    }

    // Request account access
    await window.ethereum.request({ method: 'eth_requestAccounts' });

    this.provider = new ethers.providers.Web3Provider(window.ethereum);
    this.signer = this.provider.getSigner();

    const address = await this.signer.getAddress();
    const chainId = (await this.provider.getNetwork()).chainId;
    const balance = await this.provider.getBalance(address);

    // Listen for account changes
    window.ethereum.on('accountsChanged', (accounts: string[]) => {
      console.log('Account changed:', accounts[0]);
      window.location.reload();
    });

    // Listen for chain changes
    window.ethereum.on('chainChanged', (_chainId: string) => {
      console.log('Chain changed:', _chainId);
      window.location.reload();
    });

    return {
      address,
      chainId,
      balance: ethers.utils.formatEther(balance),
      provider: this.provider,
      signer: this.signer,
    };
  }

  /**
   * Switch to a specific network
   */
  async switchNetwork(chainId: number): Promise<void> {
    if (!window.ethereum) {
      throw new Error('No wallet detected');
    }

    const chainIdHex = `0x${chainId.toString(16)}`;

    try {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: chainIdHex }],
      });
    } catch (error: any) {
      // Chain not added, try to add it
      if (error.code === 4902) {
        await this.addNetwork(chainId);
      } else {
        throw error;
      }
    }
  }

  /**
   * Add a new network to wallet
   */
  async addNetwork(chainId: number): Promise<void> {
    const networks: Record<number, any> = {
      137: {
        chainId: '0x89',
        chainName: 'Polygon Mainnet',
        nativeCurrency: { name: 'MATIC', symbol: 'MATIC', decimals: 18 },
        rpcUrls: ['https://polygon-rpc.com/'],
        blockExplorerUrls: ['https://polygonscan.com/'],
      },
      80001: {
        chainId: '0x13881',
        chainName: 'Polygon Mumbai Testnet',
        nativeCurrency: { name: 'MATIC', symbol: 'MATIC', decimals: 18 },
        rpcUrls: ['https://rpc-mumbai.maticvigil.com/'],
        blockExplorerUrls: ['https://mumbai.polygonscan.com/'],
      },
      43114: {
        chainId: '0xa86a',
        chainName: 'Avalanche C-Chain',
        nativeCurrency: { name: 'AVAX', symbol: 'AVAX', decimals: 18 },
        rpcUrls: ['https://api.avax.network/ext/bc/C/rpc'],
        blockExplorerUrls: ['https://snowtrace.io/'],
      },
    };

    if (!networks[chainId]) {
      throw new Error(`Network ${chainId} not configured`);
    }

    await window.ethereum.request({
      method: 'wallet_addEthereumChain',
      params: [networks[chainId]],
    });
  }

  /**
   * Sign a message
   */
  async signMessage(message: string): Promise<string> {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }

    return await this.signer.signMessage(message);
  }

  /**
   * Send a transaction
   */
  async sendTransaction(
    to: string,
    value: string,
    data?: string
  ): Promise<ethers.providers.TransactionResponse> {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }

    const tx = {
      to,
      value: ethers.utils.parseEther(value),
      data: data || '0x',
    };

    return await this.signer.sendTransaction(tx);
  }

  /**
   * Interact with a smart contract
   */
  async callContract(
    contractAddress: string,
    abi: any[],
    method: string,
    ...args: any[]
  ): Promise<any> {
    if (!this.provider) {
      throw new Error('Provider not initialized');
    }

    const contract = new ethers.Contract(contractAddress, abi, this.provider);
    return await contract[method](...args);
  }

  /**
   * Send a transaction to a smart contract
   */
  async sendContractTransaction(
    contractAddress: string,
    abi: any[],
    method: string,
    ...args: any[]
  ): Promise<ethers.providers.TransactionResponse> {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }

    const contract = new ethers.Contract(contractAddress, abi, this.signer);
    return await contract[method](...args);
  }

  /**
   * Get current wallet address
   */
  async getAddress(): Promise<string> {
    if (!this.signer) {
      throw new Error('Wallet not connected');
    }
    return await this.signer.getAddress();
  }

  /**
   * Get wallet balance
   */
  async getBalance(address?: string): Promise<string> {
    if (!this.provider) {
      throw new Error('Provider not initialized');
    }

    const addr = address || (await this.getAddress());
    const balance = await this.provider.getBalance(addr);
    return ethers.utils.formatEther(balance);
  }

  /**
   * Disconnect wallet
   */
  disconnect(): void {
    this.provider = null;
    this.signer = null;
  }
}

// Export singleton instance
export const walletConnector = new WalletConnector();

// Type declarations for window.ethereum
declare global {
  interface Window {
    ethereum?: any;
  }
}
