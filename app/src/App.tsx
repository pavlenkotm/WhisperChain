import React, { useEffect, useState } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { Header } from './components/Header';
import { ChatInterface } from './components/ChatInterface';
import { useChat } from './hooks/useChat';

function App() {
  const { publicKey, connected } = useWallet();
  const {
    chat,
    messages,
    loading,
    error,
    initializeChat,
    loadChat,
    sendMessage,
    deleteChat,
    deleteMessage,
  } = useChat();

  const [pollingInterval, setPollingInterval] = useState<NodeJS.Timer | null>(null);
  const [hasNewMessages, setHasNewMessages] = useState(false);

  // Load chat when wallet connects
  useEffect(() => {
    if (connected && publicKey) {
      loadChat();
    }
  }, [connected, publicKey]);

  // Set up polling for new messages
  useEffect(() => {
    if (chat && connected) {
      // Poll every 5 seconds for new messages
      const interval = setInterval(() => {
        loadChat().then(() => {
          // Flash indicator for new messages
          setHasNewMessages(true);
          setTimeout(() => setHasNewMessages(false), 2000);
        });
      }, 5000);

      setPollingInterval(interval);

      return () => {
        if (interval) clearInterval(interval);
      };
    }
  }, [chat, connected]);

  const handleInitializeChat = async () => {
    try {
      await initializeChat();
    } catch (err) {
      console.error('Failed to initialize chat:', err);
    }
  };

  const handleDeleteChat = async () => {
    if (window.confirm('Are you sure you want to delete this chat? This action cannot be undone.')) {
      try {
        await deleteChat();
      } catch (err) {
        console.error('Failed to delete chat:', err);
      }
    }
  };

  if (!connected) {
    return (
      <div className="min-h-screen bg-dark-900">
        <Header />
        <div className="flex items-center justify-center h-[calc(100vh-80px)]">
          <div className="text-center">
            <div className="w-20 h-20 bg-gradient-to-br from-primary-500 to-primary-700 rounded-2xl flex items-center justify-center mx-auto mb-6">
              <span className="text-5xl">🔐</span>
            </div>
            <h2 className="text-3xl font-bold text-white mb-4">Welcome to WhisperChain</h2>
            <p className="text-dark-300 mb-8 max-w-md mx-auto">
              A decentralized, encrypted chat application built on Solana.
              Connect your wallet to start secure messaging.
            </p>
            <div className="bg-dark-800 rounded-lg p-6 max-w-md mx-auto text-left">
              <h3 className="text-lg font-semibold text-white mb-3">Features:</h3>
              <ul className="space-y-2 text-dark-300">
                <li className="flex items-start">
                  <span className="text-primary-500 mr-2">✓</span>
                  End-to-end encryption using Diffie-Hellman and AES-256
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-2">✓</span>
                  No centralized servers - all data on Solana blockchain
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-2">✓</span>
                  Self-destructing messages
                </li>
                <li className="flex items-start">
                  <span className="text-primary-500 mr-2">✓</span>
                  Complete privacy - only you can decrypt your messages
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!chat) {
    return (
      <div className="min-h-screen bg-dark-900">
        <Header />
        <div className="flex items-center justify-center h-[calc(100vh-80px)]">
          <div className="text-center">
            <div className="w-16 h-16 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl flex items-center justify-center mx-auto mb-6">
              <span className="text-4xl">💬</span>
            </div>
            <h2 className="text-2xl font-bold text-white mb-4">No Active Chat</h2>
            <p className="text-dark-300 mb-6">
              Initialize a new encrypted chat to get started
            </p>
            {error && (
              <div className="bg-red-500/10 border border-red-500 text-red-500 rounded-lg px-4 py-3 mb-4">
                {error}
              </div>
            )}
            <button
              onClick={handleInitializeChat}
              disabled={loading}
              className="bg-primary-600 hover:bg-primary-700 disabled:bg-dark-600 disabled:cursor-not-allowed text-white px-8 py-3 rounded-lg font-medium transition-colors"
            >
              {loading ? 'Initializing...' : 'Initialize New Chat'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-dark-900 flex flex-col">
      <Header />

      {/* Chat info bar */}
      <div className="bg-dark-800 border-b border-dark-700 px-6 py-3">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="relative">
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              {hasNewMessages && (
                <div className="absolute inset-0 w-3 h-3 bg-green-500 rounded-full animate-pulse-glow"></div>
              )}
            </div>
            <div>
              <p className="text-sm text-dark-300">
                Chat ID: <span className="font-mono text-dark-200">{publicKey?.toBase58().slice(0, 8)}...</span>
              </p>
              <p className="text-xs text-dark-400">
                {Number(chat.messageCount)} messages
              </p>
            </div>
          </div>

          <button
            onClick={handleDeleteChat}
            className="text-red-400 hover:text-red-300 text-sm transition-colors"
          >
            Delete Chat
          </button>
        </div>
      </div>

      {/* Main chat area */}
      <div className="flex-1 max-w-7xl w-full mx-auto px-6 py-6">
        {error && (
          <div className="bg-red-500/10 border border-red-500 text-red-500 rounded-lg px-4 py-3 mb-4">
            {error}
          </div>
        )}

        <ChatInterface
          messages={messages}
          onSendMessage={sendMessage}
          onDeleteMessage={deleteMessage}
          loading={loading}
        />
      </div>
    </div>
  );
}

export default App;
