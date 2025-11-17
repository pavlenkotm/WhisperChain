/**
 * Network commands
 */

import chalk from 'chalk';
import ora from 'ora';
import { DEFAULT_NETWORKS } from '@whisperchain/core';
import { WhisperChainClient } from '@whisperchain/sdk';
import type { SupportedBlockchain } from '@whisperchain/types';

async function list() {
  console.log(chalk.blue('\n=== Supported Networks ===\n'));

  for (const [blockchain, network] of Object.entries(DEFAULT_NETWORKS)) {
    console.log(chalk.yellow(`${blockchain.toUpperCase()}`));
    console.log(chalk.white('  Name:'), network.name);
    console.log(chalk.white('  Chain ID:'), network.chainId);
    console.log(chalk.white('  RPC:'), chalk.gray(network.rpcUrl));
    if (network.explorerUrl) {
      console.log(chalk.white('  Explorer:'), chalk.gray(network.explorerUrl));
    }
    console.log();
  }
}

async function status(blockchain: string) {
  const spinner = ora(`Checking ${blockchain} network status...`).start();

  try {
    const client = new WhisperChainClient({
      blockchain: blockchain as SupportedBlockchain,
    });

    // For EVM chains
    if (blockchain === 'ethereum' || blockchain === 'starknet') {
      const blockNumber = await client.blockchain.getBlockNumber();
      const gasPrice = await client.blockchain.getGasPrice();

      spinner.succeed(chalk.green(`${blockchain} network is online!`));
      console.log(chalk.white('Block Number:'), chalk.yellow(blockNumber));
      console.log(chalk.white('Gas Price:'), chalk.yellow(`${gasPrice} gwei`));
    } else {
      spinner.info(chalk.yellow(`Status check not implemented for ${blockchain} yet`));
    }
  } catch (error: any) {
    spinner.fail(`Failed to check ${blockchain} network status`);
    console.error(chalk.red(error.message));
  }
}

export const networkCommand = {
  list,
  status,
};
