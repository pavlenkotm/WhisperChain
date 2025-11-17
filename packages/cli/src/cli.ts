#!/usr/bin/env node

/**
 * WhisperChain CLI - Command-line interface for the ecosystem
 */

import { Command } from 'commander';
import chalk from 'chalk';
import { initCommand } from './commands/init';
import { walletCommand } from './commands/wallet';
import { messageCommand } from './commands/message';
import { contractCommand } from './commands/contract';
import { networkCommand } from './commands/network';

const program = new Command();

program
  .name('whisperchain')
  .description('CLI tool for WhisperChain Web3 ecosystem')
  .version('1.0.0');

// Initialize a new project
program
  .command('init')
  .description('Initialize a new WhisperChain project')
  .option('-t, --template <type>', 'Project template (dapp, contract, backend)', 'dapp')
  .option('-n, --name <name>', 'Project name')
  .action(initCommand);

// Wallet management
const wallet = program
  .command('wallet')
  .description('Wallet management commands');

wallet
  .command('create')
  .description('Create a new wallet')
  .option('-b, --blockchain <chain>', 'Blockchain (ethereum, solana, etc.)')
  .action(walletCommand.create);

wallet
  .command('balance <address>')
  .description('Check wallet balance')
  .option('-b, --blockchain <chain>', 'Blockchain', 'ethereum')
  .action(walletCommand.balance);

// Messaging commands
const message = program
  .command('message')
  .description('Encrypted messaging commands');

message
  .command('send <recipient> <message>')
  .description('Send an encrypted message')
  .option('-e, --expires <seconds>', 'Message expiration time')
  .action(messageCommand.send);

message
  .command('keygen')
  .description('Generate encryption keys')
  .action(messageCommand.keygen);

// Smart contract commands
const contract = program
  .command('contract')
  .description('Smart contract commands');

contract
  .command('compile <path>')
  .description('Compile a smart contract')
  .option('-l, --language <lang>', 'Contract language (solidity, vyper, etc.)')
  .action(contractCommand.compile);

contract
  .command('deploy <path>')
  .description('Deploy a smart contract')
  .option('-n, --network <network>', 'Network name')
  .action(contractCommand.deploy);

contract
  .command('interact <address>')
  .description('Interact with a deployed contract')
  .action(contractCommand.interact);

// Network commands
const network = program
  .command('network')
  .description('Network management commands');

network
  .command('list')
  .description('List supported networks')
  .action(networkCommand.list);

network
  .command('status <blockchain>')
  .description('Check network status')
  .action(networkCommand.status);

// Error handling
program.exitOverride();

try {
  program.parse(process.argv);
} catch (error: any) {
  if (error.code !== 'commander.help') {
    console.error(chalk.red('Error:'), error.message);
    process.exit(1);
  }
}

// Show help if no command provided
if (!process.argv.slice(2).length) {
  program.outputHelp();
}
