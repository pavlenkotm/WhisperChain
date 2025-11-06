import React from 'react';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';

export const Header: React.FC = () => {
  return (
    <header className="bg-dark-800 border-b border-dark-700 px-6 py-4">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
            <span className="text-2xl">🔐</span>
          </div>
          <div>
            <h1 className="text-xl font-bold text-white">WhisperChain</h1>
            <p className="text-xs text-dark-400">Decentralized Encrypted Chat</p>
          </div>
        </div>

        <WalletMultiButton className="!bg-primary-600 hover:!bg-primary-700" />
      </div>
    </header>
  );
};
