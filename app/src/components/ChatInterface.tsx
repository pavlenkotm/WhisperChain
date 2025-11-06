import React, { useState, useEffect, useRef } from 'react';
import { useWallet } from '@solana/wallet-adapter-react';
import { DecryptedMessage } from '../hooks/useChat';

interface ChatInterfaceProps {
  messages: DecryptedMessage[];
  onSendMessage: (content: string, expiresInSeconds?: number) => Promise<void>;
  onDeleteMessage: (index: number) => Promise<void>;
  loading: boolean;
}

export const ChatInterface: React.FC<ChatInterfaceProps> = ({
  messages,
  onSendMessage,
  onDeleteMessage,
  loading,
}) => {
  const { publicKey } = useWallet();
  const [messageContent, setMessageContent] = useState('');
  const [selfDestruct, setSelfDestruct] = useState(false);
  const [destructTime, setDestructTime] = useState(3600); // 1 hour default
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = async () => {
    if (!messageContent.trim() || sending) return;

    try {
      setSending(true);
      const expiresIn = selfDestruct ? destructTime : 0;
      await onSendMessage(messageContent, expiresIn);
      setMessageContent('');
    } catch (err) {
      console.error('Error sending message:', err);
    } finally {
      setSending(false);
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const formatTimestamp = (timestamp: number) => {
    return new Date(timestamp * 1000).toLocaleTimeString();
  };

  const formatExpiration = (expiresAt: number) => {
    if (expiresAt === 0) return null;
    const now = Math.floor(Date.now() / 1000);
    const remaining = expiresAt - now;

    if (remaining <= 0) return 'Expired';

    const hours = Math.floor(remaining / 3600);
    const minutes = Math.floor((remaining % 3600) / 60);

    if (hours > 0) return `${hours}h ${minutes}m`;
    return `${minutes}m`;
  };

  return (
    <div className="flex flex-col h-full bg-dark-800 rounded-lg shadow-xl">
      {/* Messages area */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="flex items-center justify-center h-full text-dark-400">
            <p>No messages yet. Start the conversation!</p>
          </div>
        ) : (
          messages.map((message) => {
            const isOwnMessage = message.sender === publicKey?.toBase58();
            const expirationText = formatExpiration(message.expiresAt);

            return (
              <div
                key={message.index}
                className={`flex ${isOwnMessage ? 'justify-end' : 'justify-start'} message-appear`}
              >
                <div
                  className={`max-w-xs lg:max-w-md xl:max-w-lg px-4 py-2 rounded-lg ${
                    isOwnMessage
                      ? 'bg-primary-600 text-white'
                      : 'bg-dark-700 text-white'
                  } ${message.isExpired ? 'opacity-50' : ''}`}
                >
                  {message.isExpired ? (
                    <p className="italic text-sm">Message expired</p>
                  ) : (
                    <>
                      <p className="break-words">{message.content}</p>
                      <div className="flex items-center justify-between mt-2 text-xs opacity-75">
                        <span>{formatTimestamp(message.timestamp)}</span>
                        {expirationText && (
                          <span className="ml-2 flex items-center">
                            <span className="mr-1">🔥</span>
                            {expirationText}
                          </span>
                        )}
                      </div>
                      {isOwnMessage && !message.isExpired && (
                        <button
                          onClick={() => onDeleteMessage(message.index)}
                          className="text-xs text-red-300 hover:text-red-200 mt-1"
                        >
                          Delete
                        </button>
                      )}
                    </>
                  )}
                </div>
              </div>
            );
          })
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input area */}
      <div className="border-t border-dark-700 p-4">
        {/* Self-destruct options */}
        <div className="mb-3">
          <label className="flex items-center space-x-2 text-sm text-dark-300">
            <input
              type="checkbox"
              checked={selfDestruct}
              onChange={(e) => setSelfDestruct(e.target.checked)}
              className="rounded"
            />
            <span>Self-destruct message</span>
          </label>

          {selfDestruct && (
            <div className="mt-2 flex items-center space-x-2">
              <select
                value={destructTime}
                onChange={(e) => setDestructTime(Number(e.target.value))}
                className="bg-dark-700 text-white rounded px-2 py-1 text-sm"
              >
                <option value={60}>1 minute</option>
                <option value={300}>5 minutes</option>
                <option value={1800}>30 minutes</option>
                <option value={3600}>1 hour</option>
                <option value={86400}>24 hours</option>
              </select>
              <span className="text-xs text-dark-400">after sending</span>
            </div>
          )}
        </div>

        {/* Message input */}
        <div className="flex space-x-2">
          <textarea
            value={messageContent}
            onChange={(e) => setMessageContent(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Type your encrypted message..."
            disabled={loading || sending}
            className="flex-1 bg-dark-700 text-white rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
            rows={2}
          />
          <button
            onClick={handleSendMessage}
            disabled={!messageContent.trim() || loading || sending}
            className="bg-primary-600 hover:bg-primary-700 disabled:bg-dark-600 disabled:cursor-not-allowed text-white px-6 py-2 rounded-lg font-medium transition-colors"
          >
            {sending ? 'Sending...' : 'Send'}
          </button>
        </div>
      </div>
    </div>
  );
};
