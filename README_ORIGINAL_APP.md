# 🔐 WhisperChain

**Decentralized Encrypted Chat on Solana**

WhisperChain is a fully decentralized, end-to-end encrypted chat application built on the Solana blockchain. Every message is an encrypted transaction, with no centralized servers and no metadata storage.

## ✨ Features

- 🔒 **End-to-End Encryption**: Uses Diffie-Hellman key exchange + AES-256 encryption
- 🌐 **Fully Decentralized**: All data stored on Solana blockchain, no servers
- 🔥 **Self-Destructing Messages**: Set expiration times for messages
- 👻 **Anonymous**: No metadata, no tracking, complete privacy
- ⚡ **Real-time Updates**: On-chain polling with visual indicators for new messages
- 💰 **Low Cost**: Leverages Solana's low transaction fees
- 🎨 **Beautiful UI**: Modern interface built with React + Tailwind CSS

## 🏗️ Architecture

### Smart Contract (Rust)
- **Location**: `/program`
- **Tech Stack**: Solana Program (Rust), Borsh serialization
- **Features**:
  - Initialize encrypted chats between two participants
  - Send encrypted messages (stored on-chain)
  - Delete chats and messages (self-destruct)
  - Automatic message expiration

### Frontend (React + TypeScript)
- **Location**: `/app`
- **Tech Stack**: React, TypeScript, Tailwind CSS, Solana Wallet Adapter
- **Features**:
  - Phantom wallet integration
  - Client-side encryption/decryption
  - Real-time message polling
  - Self-destruct message UI
  - Responsive design

### Cryptography
- **Key Exchange**: Elliptic Curve Diffie-Hellman (Curve25519)
- **Encryption**: AES-256-GCM
- **Key Storage**: Local browser storage (encrypted in production)

## 🚀 Getting Started

### Prerequisites

- **Rust** (1.70+): https://rustup.rs/
- **Solana CLI** (1.18+): https://docs.solana.com/cli/install-solana-cli-tools
- **Node.js** (18+): https://nodejs.org/
- **Phantom Wallet**: https://phantom.app/

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/WhisperChain.git
cd WhisperChain
```

2. **Build the Solana Program**
```bash
cd program
chmod +x build.sh
./build.sh
```

3. **Deploy to Solana Devnet**
```bash
# Make sure you have SOL in your devnet wallet
solana airdrop 2

# Deploy the program
chmod +x deploy.sh
./deploy.sh
```

4. **Update Program ID**

After deployment, update the program ID in `/app/src/utils/program.ts`:
```typescript
export const PROGRAM_ID = new PublicKey('YOUR_DEPLOYED_PROGRAM_ID');
```

5. **Install Frontend Dependencies**
```bash
cd ../app
npm install
```

6. **Start the Frontend**
```bash
npm start
```

The app will open at `http://localhost:3000`

## 📖 Usage

### 1. Connect Wallet
Click "Select Wallet" and connect your Phantom wallet.

### 2. Initialize Chat
Click "Initialize New Chat" to create an encrypted chat session. This generates your Diffie-Hellman key pair.

### 3. Send Messages
Type your message and click "Send". The message will be:
- Encrypted locally with AES-256
- Sent as a transaction to Solana
- Decrypted locally by the recipient

### 4. Self-Destructing Messages
- Check "Self-destruct message"
- Select expiration time (1 min to 24 hours)
- Message will auto-delete after expiration

### 5. Delete Chat
Click "Delete Chat" to remove all chat data from the blockchain and clear your local keys.

## 🔐 Security & Privacy

### How Encryption Works

1. **Key Generation**: Each participant generates a Diffie-Hellman key pair
2. **Key Exchange**: Public keys are exchanged via the chat initialization
3. **Shared Secret**: Both parties derive the same shared secret
4. **Message Encryption**:
   - Each message uses an ephemeral key pair
   - Message encrypted with AES-256-GCM
   - Ciphertext stored on-chain
5. **Message Decryption**:
   - Recipient uses their private key + sender's ephemeral public key
   - Derives shared secret
   - Decrypts message locally

### Privacy Guarantees

- ✅ Messages encrypted before leaving your device
- ✅ Only you and your chat partner can decrypt messages
- ✅ No centralized server can read your messages
- ✅ Solana validators only see encrypted data
- ✅ Private keys never leave your browser
- ✅ No metadata collection

## 📁 Project Structure

```
WhisperChain/
├── program/                    # Solana smart contract
│   ├── src/
│   │   ├── lib.rs             # Program entry point
│   │   ├── error.rs           # Custom errors
│   │   ├── instruction.rs     # Instruction definitions
│   │   ├── processor.rs       # Instruction handlers
│   │   └── state.rs           # Account structures
│   ├── Cargo.toml
│   ├── build.sh               # Build script
│   └── deploy.sh              # Deployment script
│
├── app/                        # React frontend
│   ├── public/
│   │   └── index.html
│   ├── src/
│   │   ├── components/
│   │   │   ├── ChatInterface.tsx
│   │   │   └── Header.tsx
│   │   ├── contexts/
│   │   │   └── WalletConnectionProvider.tsx
│   │   ├── hooks/
│   │   │   └── useChat.ts     # Chat logic hook
│   │   ├── utils/
│   │   │   ├── crypto.ts      # Encryption utilities
│   │   │   └── program.ts     # Solana program interface
│   │   ├── App.tsx
│   │   ├── index.tsx
│   │   └── index.css
│   ├── package.json
│   ├── tsconfig.json
│   └── tailwind.config.js
│
└── README.md
```

## 🛠️ Development

### Build the Program
```bash
cd program
cargo build-sbf
# or
cargo build-bpf
```

### Run Tests
```bash
cd program
cargo test
```

### Run Frontend in Development
```bash
cd app
npm start
```

### Build Frontend for Production
```bash
cd app
npm run build
```

## 🌐 Deployment

### Mainnet Deployment

1. Switch to mainnet:
```bash
solana config set --url https://api.mainnet-beta.solana.com
```

2. Deploy program:
```bash
cd program
solana program deploy target/deploy/whisperchain.so
```

3. Update frontend config:
- Change network to mainnet in `WalletConnectionProvider.tsx`
- Update `PROGRAM_ID` in `program.ts`

## 🎯 Roadmap

- [x] Core encrypted chat functionality
- [x] Self-destructing messages
- [x] Visual indicators for new messages
- [ ] Group chats (multi-party encryption)
- [ ] Browser extension
- [ ] NFT avatar integration
- [ ] Mobile app (React Native)
- [ ] File attachments (IPFS integration)
- [ ] Voice messages
- [ ] Video calls (WebRTC + Solana signaling)

## 🐛 Known Limitations

- **Message Size**: Limited to 512 bytes per message (can be increased)
- **Chat Partners**: Currently supports 1-on-1 chats only
- **Storage Costs**: Each message requires rent on Solana (~0.002 SOL)
- **Polling**: Uses 5-second polling (can be optimized with websockets)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Solana Foundation for the amazing blockchain platform
- Phantom wallet team for excellent wallet support
- Elliptic.js and CryptoJS for cryptography libraries

## 📞 Support

If you have questions or need help:
- Open an issue on GitHub
- Join our Discord: [Coming soon]
- Twitter: [@WhisperChain](https://twitter.com/whisperchain)

## ⚠️ Disclaimer

This is experimental software. Use at your own risk. Always verify security before using in production with sensitive data.

---

Built with ❤️ on Solana
