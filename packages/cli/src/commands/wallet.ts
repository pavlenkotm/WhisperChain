/**
 * Wallet commands
 */

import chalk from 'chalk';
import ora from 'ora';
import { WhisperChainClient } from '@whisperchain/sdk';
import { generateKeyPair, encodeKey } from '@whisperchain/crypto';
import { ethers } from 'ethers';

interface WalletCreateOptions {
  blockchain?: string;
}

interface WalletBalanceOptions {
  blockchain: string;
}

async function create(options: WalletCreateOptions) {
  const spinner = ora('Generating new wallet...').start();

  try {
    // Generate Ethereum wallet
    const wallet = ethers.Wallet.createRandom();

    // Generate encryption keys
    const keyPair = generateKeyPair();

    spinner.succeed(chalk.green('Wallet created successfully!'));

    console.log(chalk.blue('\n=== Wallet Details ==='));
    console.log(chalk.white('Address:'), chalk.yellow(wallet.address));
    console.log(chalk.white('Private Key:'), chalk.red(wallet.privateKey));
    console.log(chalk.white('\n=== Encryption Keys ==='));
    console.log(chalk.white('Public Key:'), chalk.yellow(encodeKey(keyPair.publicKey)));
    console.log(chalk.white('Private Key:'), chalk.red(encodeKey(keyPair.privateKey)));
    console.log(
      chalk.red('\n⚠️  IMPORTANT: Save your private keys securely! Never share them!')
    );
  } catch (error: any) {
    spinner.fail('Failed to create wallet');
    console.error(chalk.red(error.message));
  }
}

async function balance(address: string, options: WalletBalanceOptions) {
  const spinner = ora(`Fetching balance for ${address}...`).start();

  try {
    const client = new WhisperChainClient({
      blockchain: options.blockchain as any,
    });

    const balance = await client.blockchain.getBalance(address);

    spinner.succeed(chalk.green('Balance fetched successfully!'));
    console.log(chalk.white('Address:'), chalk.yellow(address));
    console.log(chalk.white('Balance:'), chalk.green(`${balance} ETH`));
  } catch (error: any) {
    spinner.fail('Failed to fetch balance');
    console.error(chalk.red(error.message));
  }
}

export const walletCommand = {
  create,
  balance,
};
