import {
  Connection,
  PublicKey,
  Transaction,
  TransactionInstruction,
  SystemProgram,
  SYSVAR_CLOCK_PUBKEY,
} from '@solana/web3.js';
import { serialize, deserialize } from 'borsh';

// Replace with your deployed program ID
export const PROGRAM_ID = new PublicKey('YourProgramIdHere11111111111111111111111111');

/**
 * Chat account data structure
 */
export class Chat {
  isInitialized: boolean = false;
  participant1: Uint8Array = new Uint8Array(32);
  participant2: Uint8Array = new Uint8Array(32);
  participant1PublicKey: Uint8Array = new Uint8Array(32);
  participant2PublicKey: Uint8Array = new Uint8Array(32);
  createdAt: bigint = BigInt(0);
  messageCount: bigint = BigInt(0);
  lastMessageAt: bigint = BigInt(0);

  constructor(fields?: {
    isInitialized: boolean;
    participant1: Uint8Array;
    participant2: Uint8Array;
    participant1PublicKey: Uint8Array;
    participant2PublicKey: Uint8Array;
    createdAt: bigint;
    messageCount: bigint;
    lastMessageAt: bigint;
  }) {
    if (fields) {
      this.isInitialized = fields.isInitialized;
      this.participant1 = fields.participant1;
      this.participant2 = fields.participant2;
      this.participant1PublicKey = fields.participant1PublicKey;
      this.participant2PublicKey = fields.participant2PublicKey;
      this.createdAt = fields.createdAt;
      this.messageCount = fields.messageCount;
      this.lastMessageAt = fields.lastMessageAt;
    }
  }

  static schema = new Map([
    [
      Chat,
      {
        kind: 'struct',
        fields: [
          ['isInitialized', 'u8'],
          ['participant1', [32]],
          ['participant2', [32]],
          ['participant1PublicKey', [32]],
          ['participant2PublicKey', [32]],
          ['createdAt', 'i64'],
          ['messageCount', 'u64'],
          ['lastMessageAt', 'i64'],
        ],
      },
    ],
  ]);
}

/**
 * Message account data structure
 */
export class Message {
  isInitialized: boolean = false;
  chat: Uint8Array = new Uint8Array(32);
  sender: Uint8Array = new Uint8Array(32);
  index: bigint = BigInt(0);
  timestamp: bigint = BigInt(0);
  expiresAt: bigint = BigInt(0);
  ephemeralPublicKey: Uint8Array = new Uint8Array(32);
  encryptedData: Uint8Array = new Uint8Array(0);

  constructor(fields?: {
    isInitialized: boolean;
    chat: Uint8Array;
    sender: Uint8Array;
    index: bigint;
    timestamp: bigint;
    expiresAt: bigint;
    ephemeralPublicKey: Uint8Array;
    encryptedData: Uint8Array;
  }) {
    if (fields) {
      this.isInitialized = fields.isInitialized;
      this.chat = fields.chat;
      this.sender = fields.sender;
      this.index = fields.index;
      this.timestamp = fields.timestamp;
      this.expiresAt = fields.expiresAt;
      this.ephemeralPublicKey = fields.ephemeralPublicKey;
      this.encryptedData = fields.encryptedData;
    }
  }

  static schema = new Map([
    [
      Message,
      {
        kind: 'struct',
        fields: [
          ['isInitialized', 'u8'],
          ['chat', [32]],
          ['sender', [32]],
          ['index', 'u64'],
          ['timestamp', 'i64'],
          ['expiresAt', 'i64'],
          ['ephemeralPublicKey', [32]],
          ['encryptedData', ['u8']],
        ],
      },
    ],
  ]);
}

/**
 * Get the PDA for a chat account
 */
export async function getChatPDA(
  participant1: PublicKey,
  programId: PublicKey = PROGRAM_ID
): Promise<[PublicKey, number]> {
  return await PublicKey.findProgramAddress(
    [Buffer.from('chat'), participant1.toBuffer()],
    programId
  );
}

/**
 * Get the PDA for a message account
 */
export async function getMessagePDA(
  chatAccount: PublicKey,
  messageIndex: bigint,
  programId: PublicKey = PROGRAM_ID
): Promise<[PublicKey, number]> {
  const indexBuffer = Buffer.alloc(8);
  indexBuffer.writeBigUInt64LE(messageIndex);

  return await PublicKey.findProgramAddress(
    [Buffer.from('message'), chatAccount.toBuffer(), indexBuffer],
    programId
  );
}

/**
 * Create an initialize chat instruction
 */
export function createInitializeChatInstruction(
  payer: PublicKey,
  chatAccount: PublicKey,
  publicKey: Uint8Array,
  programId: PublicKey = PROGRAM_ID
): TransactionInstruction {
  // Instruction discriminator (0 = InitializeChat)
  const instructionData = Buffer.concat([
    Buffer.from([0]),
    Buffer.from(publicKey),
  ]);

  return new TransactionInstruction({
    keys: [
      { pubkey: payer, isSigner: true, isWritable: true },
      { pubkey: chatAccount, isSigner: false, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ],
    programId,
    data: instructionData,
  });
}

/**
 * Create a send message instruction
 */
export function createSendMessageInstruction(
  sender: PublicKey,
  chatAccount: PublicKey,
  messageAccount: PublicKey,
  encryptedData: Uint8Array,
  ephemeralPublicKey: Uint8Array,
  timestamp: bigint,
  expiresAt: bigint,
  programId: PublicKey = PROGRAM_ID
): TransactionInstruction {
  // Instruction discriminator (1 = SendMessage)
  const dataLengthBuffer = Buffer.alloc(4);
  dataLengthBuffer.writeUInt32LE(encryptedData.length, 0);

  const timestampBuffer = Buffer.alloc(8);
  timestampBuffer.writeBigInt64LE(timestamp);

  const expiresAtBuffer = Buffer.alloc(8);
  expiresAtBuffer.writeBigInt64LE(expiresAt);

  const instructionData = Buffer.concat([
    Buffer.from([1]), // Instruction discriminator
    dataLengthBuffer,
    Buffer.from(encryptedData),
    Buffer.from(ephemeralPublicKey),
    timestampBuffer,
    expiresAtBuffer,
  ]);

  return new TransactionInstruction({
    keys: [
      { pubkey: sender, isSigner: true, isWritable: true },
      { pubkey: chatAccount, isSigner: false, isWritable: true },
      { pubkey: messageAccount, isSigner: false, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ],
    programId,
    data: instructionData,
  });
}

/**
 * Create a delete chat instruction
 */
export function createDeleteChatInstruction(
  participant: PublicKey,
  chatAccount: PublicKey,
  programId: PublicKey = PROGRAM_ID
): TransactionInstruction {
  const instructionData = Buffer.from([2]); // Instruction discriminator

  return new TransactionInstruction({
    keys: [
      { pubkey: participant, isSigner: true, isWritable: true },
      { pubkey: chatAccount, isSigner: false, isWritable: true },
    ],
    programId,
    data: instructionData,
  });
}

/**
 * Create a delete message instruction
 */
export function createDeleteMessageInstruction(
  sender: PublicKey,
  messageAccount: PublicKey,
  chatAccount: PublicKey,
  programId: PublicKey = PROGRAM_ID
): TransactionInstruction {
  const instructionData = Buffer.from([3]); // Instruction discriminator

  return new TransactionInstruction({
    keys: [
      { pubkey: sender, isSigner: true, isWritable: true },
      { pubkey: messageAccount, isSigner: false, isWritable: true },
      { pubkey: chatAccount, isSigner: false, isWritable: false },
      { pubkey: SYSVAR_CLOCK_PUBKEY, isSigner: false, isWritable: false },
    ],
    programId,
    data: instructionData,
  });
}

/**
 * Fetch and deserialize a chat account
 */
export async function fetchChatAccount(
  connection: Connection,
  chatAccount: PublicKey
): Promise<Chat | null> {
  const accountInfo = await connection.getAccountInfo(chatAccount);
  if (!accountInfo) return null;

  const chat = deserialize(Chat.schema, Chat, accountInfo.data) as Chat;
  return chat;
}

/**
 * Fetch and deserialize a message account
 */
export async function fetchMessageAccount(
  connection: Connection,
  messageAccount: PublicKey
): Promise<Message | null> {
  const accountInfo = await connection.getAccountInfo(messageAccount);
  if (!accountInfo) return null;

  const message = deserialize(Message.schema, Message, accountInfo.data) as Message;
  return message;
}

/**
 * Fetch all messages for a chat
 */
export async function fetchChatMessages(
  connection: Connection,
  chatAccount: PublicKey,
  messageCount: number,
  programId: PublicKey = PROGRAM_ID
): Promise<Message[]> {
  const messages: Message[] = [];

  for (let i = 0; i < messageCount; i++) {
    const [messageAccount] = await getMessagePDA(chatAccount, BigInt(i), programId);
    const message = await fetchMessageAccount(connection, messageAccount);
    if (message) {
      messages.push(message);
    }
  }

  return messages;
}
