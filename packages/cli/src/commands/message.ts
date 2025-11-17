/**
 * Messaging commands
 */

import chalk from 'chalk';
import ora from 'ora';
import { generateKeyPair, encodeKey, decodeKey, encryptMessage } from '@whisperchain/crypto';

interface MessageSendOptions {
  expires?: string;
}

async function send(recipient: string, message: string, options: MessageSendOptions) {
  const spinner = ora('Encrypting and sending message...').start();

  try {
    // For demo purposes, generate sender keys
    const senderKeys = generateKeyPair();
    const recipientPublicKey = decodeKey(recipient);

    const encrypted = encryptMessage(message, recipientPublicKey, senderKeys.privateKey);

    spinner.succeed(chalk.green('Message encrypted successfully!'));

    console.log(chalk.blue('\n=== Encrypted Message ==='));
    console.log(chalk.white('Recipient:'), chalk.yellow(recipient));
    console.log(chalk.white('Ciphertext:'), chalk.gray(encrypted.ciphertext.slice(0, 50) + '...'));
    console.log(chalk.white('Nonce:'), chalk.gray(encrypted.nonce));
    console.log(chalk.white('Sender Public Key:'), chalk.yellow(encrypted.senderPublicKey));

    if (options.expires) {
      console.log(chalk.white('Expires in:'), chalk.yellow(`${options.expires} seconds`));
    }
  } catch (error: any) {
    spinner.fail('Failed to encrypt message');
    console.error(chalk.red(error.message));
  }
}

async function keygen() {
  const spinner = ora('Generating encryption keys...').start();

  try {
    const keyPair = generateKeyPair();

    spinner.succeed(chalk.green('Encryption keys generated!'));

    console.log(chalk.blue('\n=== Encryption Keys ==='));
    console.log(chalk.white('Public Key:'), chalk.yellow(encodeKey(keyPair.publicKey)));
    console.log(chalk.white('Private Key:'), chalk.red(encodeKey(keyPair.privateKey)));
    console.log(
      chalk.red('\n⚠️  Save your private key securely! You need it to decrypt messages.')
    );
  } catch (error: any) {
    spinner.fail('Failed to generate keys');
    console.error(chalk.red(error.message));
  }
}

export const messageCommand = {
  send,
  keygen,
};
