import { useState, useEffect, useCallback } from 'react';
import { useConnection, useWallet } from '@solana/wallet-adapter-react';
import { PublicKey, Transaction } from '@solana/web3.js';
import {
  Chat,
  Message,
  getChatPDA,
  getMessagePDA,
  createInitializeChatInstruction,
  createSendMessageInstruction,
  createDeleteChatInstruction,
  createDeleteMessageInstruction,
  fetchChatAccount,
  fetchChatMessages,
  PROGRAM_ID,
} from '../utils/program';
import {
  generateKeyPair,
  deriveSharedSecret,
  encryptMessage,
  decryptMessage,
  packEncryptedData,
  unpackEncryptedData,
  storeKeyPair,
  getKeyPair,
  deleteKeyPair,
  KeyPair,
} from '../utils/crypto';

export interface DecryptedMessage {
  index: number;
  sender: string;
  content: string;
  timestamp: number;
  expiresAt: number;
  isExpired: boolean;
}

export function useChat(recipientAddress?: string) {
  const { connection } = useConnection();
  const { publicKey, sendTransaction } = useWallet();

  const [chat, setChat] = useState<Chat | null>(null);
  const [messages, setMessages] = useState<DecryptedMessage[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [chatKeyPair, setChatKeyPair] = useState<KeyPair | null>(null);

  /**
   * Initialize a new chat
   */
  const initializeChat = useCallback(async () => {
    if (!publicKey) {
      setError('Wallet not connected');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Generate key pair for this chat
      const keyPair = generateKeyPair();

      // Get chat PDA
      const [chatPDA] = await getChatPDA(publicKey);

      // Create instruction
      const instruction = createInitializeChatInstruction(
        publicKey,
        chatPDA,
        keyPair.publicKey
      );

      // Create and send transaction
      const transaction = new Transaction().add(instruction);
      const signature = await sendTransaction(transaction, connection);

      // Wait for confirmation
      await connection.confirmTransaction(signature, 'confirmed');

      // Store key pair
      storeKeyPair(chatPDA.toBase58(), keyPair);
      setChatKeyPair(keyPair);

      // Fetch the created chat
      const chatAccount = await fetchChatAccount(connection, chatPDA);
      setChat(chatAccount);

      console.log('Chat initialized:', chatPDA.toBase58());
      return chatPDA.toBase58();
    } catch (err) {
      console.error('Error initializing chat:', err);
      setError(err instanceof Error ? err.message : 'Failed to initialize chat');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [publicKey, connection, sendTransaction]);

  /**
   * Load an existing chat
   */
  const loadChat = useCallback(async () => {
    if (!publicKey) {
      setError('Wallet not connected');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const [chatPDA] = await getChatPDA(publicKey);
      const chatAccount = await fetchChatAccount(connection, chatPDA);

      if (!chatAccount) {
        setError('Chat not found');
        return;
      }

      setChat(chatAccount);

      // Load key pair from storage
      const keyPair = getKeyPair(chatPDA.toBase58());
      if (keyPair) {
        setChatKeyPair(keyPair);
      }

      // Fetch messages
      await loadMessages(chatPDA, chatAccount);
    } catch (err) {
      console.error('Error loading chat:', err);
      setError(err instanceof Error ? err.message : 'Failed to load chat');
    } finally {
      setLoading(false);
    }
  }, [publicKey, connection]);

  /**
   * Load messages for a chat
   */
  const loadMessages = useCallback(async (chatPDA: PublicKey, chatAccount: Chat) => {
    if (!chatKeyPair) return;

    try {
      const messageCount = Number(chatAccount.messageCount);
      const rawMessages = await fetchChatMessages(connection, chatPDA, messageCount);

      // Decrypt messages
      const decryptedMessages: DecryptedMessage[] = [];
      const now = Math.floor(Date.now() / 1000);

      for (const msg of rawMessages) {
        try {
          // Determine shared secret
          const isOurMessage = Buffer.from(msg.sender).equals(publicKey!.toBuffer());
          const theirPublicKey = isOurMessage
            ? chatAccount.participant2PublicKey
            : msg.ephemeralPublicKey;

          const sharedSecret = deriveSharedSecret(chatKeyPair.privateKey, theirPublicKey);

          // Decrypt
          const { ciphertext, iv } = unpackEncryptedData(msg.encryptedData);
          const content = decryptMessage(ciphertext, iv, sharedSecret);

          const timestamp = Number(msg.timestamp);
          const expiresAt = Number(msg.expiresAt);
          const isExpired = expiresAt > 0 && now >= expiresAt;

          decryptedMessages.push({
            index: Number(msg.index),
            sender: new PublicKey(msg.sender).toBase58(),
            content,
            timestamp,
            expiresAt,
            isExpired,
          });
        } catch (err) {
          console.error('Error decrypting message:', err);
        }
      }

      setMessages(decryptedMessages);
    } catch (err) {
      console.error('Error loading messages:', err);
    }
  }, [connection, publicKey, chatKeyPair]);

  /**
   * Send a message
   */
  const sendMessage = useCallback(async (
    content: string,
    expiresInSeconds: number = 0
  ) => {
    if (!publicKey || !chat || !chatKeyPair) {
      setError('Not ready to send message');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Get chat PDA
      const [chatPDA] = await getChatPDA(publicKey);

      // Generate ephemeral key pair for this message
      const ephemeralKeyPair = generateKeyPair();

      // Determine recipient's public key
      const isParticipant1 = Buffer.from(chat.participant1).equals(publicKey.toBuffer());
      const recipientPublicKey = isParticipant1
        ? chat.participant2PublicKey
        : chat.participant1PublicKey;

      // Derive shared secret
      const sharedSecret = deriveSharedSecret(
        ephemeralKeyPair.privateKey,
        recipientPublicKey
      );

      // Encrypt message
      const encrypted = encryptMessage(content, sharedSecret);
      const encryptedData = packEncryptedData(encrypted.ciphertext, encrypted.iv);

      // Calculate timestamps
      const timestamp = BigInt(Math.floor(Date.now() / 1000));
      const expiresAt = expiresInSeconds > 0
        ? timestamp + BigInt(expiresInSeconds)
        : BigInt(0);

      // Get message PDA
      const [messagePDA] = await getMessagePDA(chatPDA, chat.messageCount);

      // Create instruction
      const instruction = createSendMessageInstruction(
        publicKey,
        chatPDA,
        messagePDA,
        encryptedData,
        ephemeralKeyPair.publicKey,
        timestamp,
        expiresAt
      );

      // Create and send transaction
      const transaction = new Transaction().add(instruction);
      const signature = await sendTransaction(transaction, connection);

      // Wait for confirmation
      await connection.confirmTransaction(signature, 'confirmed');

      console.log('Message sent:', signature);

      // Reload chat and messages
      await loadChat();
    } catch (err) {
      console.error('Error sending message:', err);
      setError(err instanceof Error ? err.message : 'Failed to send message');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [publicKey, chat, chatKeyPair, connection, sendTransaction, loadChat]);

  /**
   * Delete the chat
   */
  const deleteChat = useCallback(async () => {
    if (!publicKey || !chat) {
      setError('No chat to delete');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const [chatPDA] = await getChatPDA(publicKey);

      // Create instruction
      const instruction = createDeleteChatInstruction(publicKey, chatPDA);

      // Create and send transaction
      const transaction = new Transaction().add(instruction);
      const signature = await sendTransaction(transaction, connection);

      // Wait for confirmation
      await connection.confirmTransaction(signature, 'confirmed');

      // Delete key pair from storage
      deleteKeyPair(chatPDA.toBase58());

      // Clear state
      setChat(null);
      setMessages([]);
      setChatKeyPair(null);

      console.log('Chat deleted:', signature);
    } catch (err) {
      console.error('Error deleting chat:', err);
      setError(err instanceof Error ? err.message : 'Failed to delete chat');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [publicKey, chat, connection, sendTransaction]);

  /**
   * Delete a specific message
   */
  const deleteMessage = useCallback(async (messageIndex: number) => {
    if (!publicKey || !chat) {
      setError('No message to delete');
      return;
    }

    try {
      setLoading(true);
      setError(null);

      const [chatPDA] = await getChatPDA(publicKey);
      const [messagePDA] = await getMessagePDA(chatPDA, BigInt(messageIndex));

      // Create instruction
      const instruction = createDeleteMessageInstruction(publicKey, messagePDA, chatPDA);

      // Create and send transaction
      const transaction = new Transaction().add(instruction);
      const signature = await sendTransaction(transaction, connection);

      // Wait for confirmation
      await connection.confirmTransaction(signature, 'confirmed');

      console.log('Message deleted:', signature);

      // Reload messages
      await loadChat();
    } catch (err) {
      console.error('Error deleting message:', err);
      setError(err instanceof Error ? err.message : 'Failed to delete message');
      throw err;
    } finally {
      setLoading(false);
    }
  }, [publicKey, chat, connection, sendTransaction, loadChat]);

  return {
    chat,
    messages,
    loading,
    error,
    initializeChat,
    loadChat,
    sendMessage,
    deleteChat,
    deleteMessage,
  };
}
