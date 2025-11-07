/**
 * ERC-20 Token Utilities
 * Helper functions for token operations
 */

import { ethers } from 'ethers';

// Standard ERC-20 ABI
const ERC20_ABI = [
  'function name() view returns (string)',
  'function symbol() view returns (string)',
  'function decimals() view returns (uint8)',
  'function totalSupply() view returns (uint256)',
  'function balanceOf(address) view returns (uint256)',
  'function allowance(address owner, address spender) view returns (uint256)',
  'function transfer(address to, uint256 amount) returns (bool)',
  'function approve(address spender, uint256 amount) returns (bool)',
  'function transferFrom(address from, address to, uint256 amount) returns (bool)',
  'event Transfer(address indexed from, address indexed to, uint256 value)',
  'event Approval(address indexed owner, address indexed spender, uint256 value)',
];

export interface TokenInfo {
  address: string;
  name: string;
  symbol: string;
  decimals: number;
  totalSupply: string;
}

export class TokenUtils {
  private provider: ethers.providers.Provider;

  constructor(provider: ethers.providers.Provider) {
    this.provider = provider;
  }

  /**
   * Get token information
   */
  async getTokenInfo(tokenAddress: string): Promise<TokenInfo> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, this.provider);

    const [name, symbol, decimals, totalSupply] = await Promise.all([
      contract.name(),
      contract.symbol(),
      contract.decimals(),
      contract.totalSupply(),
    ]);

    return {
      address: tokenAddress,
      name,
      symbol,
      decimals,
      totalSupply: ethers.utils.formatUnits(totalSupply, decimals),
    };
  }

  /**
   * Get token balance for an address
   */
  async getBalance(tokenAddress: string, holderAddress: string): Promise<string> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, this.provider);
    const balance = await contract.balanceOf(holderAddress);
    const decimals = await contract.decimals();

    return ethers.utils.formatUnits(balance, decimals);
  }

  /**
   * Get token allowance
   */
  async getAllowance(
    tokenAddress: string,
    owner: string,
    spender: string
  ): Promise<string> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, this.provider);
    const allowance = await contract.allowance(owner, spender);
    const decimals = await contract.decimals();

    return ethers.utils.formatUnits(allowance, decimals);
  }

  /**
   * Transfer tokens
   */
  async transfer(
    tokenAddress: string,
    signer: ethers.Signer,
    to: string,
    amount: string
  ): Promise<ethers.providers.TransactionResponse> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, signer);
    const decimals = await contract.decimals();
    const amountBN = ethers.utils.parseUnits(amount, decimals);

    return await contract.transfer(to, amountBN);
  }

  /**
   * Approve token spending
   */
  async approve(
    tokenAddress: string,
    signer: ethers.Signer,
    spender: string,
    amount: string
  ): Promise<ethers.providers.TransactionResponse> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, signer);
    const decimals = await contract.decimals();
    const amountBN = ethers.utils.parseUnits(amount, decimals);

    return await contract.approve(spender, amountBN);
  }

  /**
   * Transfer tokens from another address (requires approval)
   */
  async transferFrom(
    tokenAddress: string,
    signer: ethers.Signer,
    from: string,
    to: string,
    amount: string
  ): Promise<ethers.providers.TransactionResponse> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, signer);
    const decimals = await contract.decimals();
    const amountBN = ethers.utils.parseUnits(amount, decimals);

    return await contract.transferFrom(from, to, amountBN);
  }

  /**
   * Get transfer events for an address
   */
  async getTransferHistory(
    tokenAddress: string,
    address: string,
    fromBlock: number = 0,
    toBlock: number | string = 'latest'
  ): Promise<any[]> {
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, this.provider);

    const sentFilter = contract.filters.Transfer(address, null);
    const receivedFilter = contract.filters.Transfer(null, address);

    const [sentEvents, receivedEvents] = await Promise.all([
      contract.queryFilter(sentFilter, fromBlock, toBlock),
      contract.queryFilter(receivedFilter, fromBlock, toBlock),
    ]);

    // Combine and sort by block number
    const allEvents = [...sentEvents, ...receivedEvents].sort(
      (a, b) => a.blockNumber - b.blockNumber
    );

    return allEvents.map((event) => ({
      blockNumber: event.blockNumber,
      transactionHash: event.transactionHash,
      from: event.args?.from,
      to: event.args?.to,
      value: ethers.utils.formatUnits(event.args?.value, 18),
      type: event.args?.from === address ? 'sent' : 'received',
    }));
  }

  /**
   * Check if an address has enough token balance
   */
  async hasEnoughBalance(
    tokenAddress: string,
    holderAddress: string,
    requiredAmount: string
  ): Promise<boolean> {
    const balance = await this.getBalance(tokenAddress, holderAddress);
    return parseFloat(balance) >= parseFloat(requiredAmount);
  }

  /**
   * Format token amount with symbol
   */
  async formatAmount(tokenAddress: string, amount: string): Promise<string> {
    const info = await this.getTokenInfo(tokenAddress);
    return `${amount} ${info.symbol}`;
  }
}

/**
 * Common token addresses
 */
export const COMMON_TOKENS = {
  mainnet: {
    USDC: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
    USDT: '0xdAC17F958D2ee523a2206206994597C13D831ec7',
    DAI: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
    WETH: '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2',
    WBTC: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
  },
  sepolia: {
    USDC: '0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238',
  },
  polygon: {
    USDC: '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
    USDT: '0xc2132D05D31c914a87C6611C10748AEb04B58e8F',
    DAI: '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063',
    WETH: '0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619',
  },
};

export { ERC20_ABI };
