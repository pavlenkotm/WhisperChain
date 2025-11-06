# WhisperChain Deployment Guide

This guide walks you through deploying WhisperChain to Solana Devnet and Mainnet.

## Prerequisites

1. **Solana CLI installed**
```bash
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
```

2. **Rust and Cargo installed**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

3. **Solana Program Library tools**
```bash
cargo install cargo-build-sbf
# or for older versions
cargo install cargo-build-bpf
```

## Step 1: Build the Program

```bash
cd program
./build.sh
```

This will create `target/deploy/whisperchain.so`

## Step 2: Setup Solana Wallet

### Create a new wallet (if needed)
```bash
solana-keygen new --outfile ~/.config/solana/devnet.json
```

### Set wallet as default
```bash
solana config set --keypair ~/.config/solana/devnet.json
```

## Step 3: Deploy to Devnet

### Switch to Devnet
```bash
solana config set --url https://api.devnet.solana.com
```

### Get devnet SOL (airdrop)
```bash
solana airdrop 2
```

### Deploy the program
```bash
cd program
solana program deploy target/deploy/whisperchain.so
```

**Save the Program ID!** It will look like:
```
Program Id: 7xXXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXxXx
```

### Verify deployment
```bash
solana program show <PROGRAM_ID>
```

## Step 4: Configure Frontend

Edit `/app/src/utils/program.ts`:

```typescript
export const PROGRAM_ID = new PublicKey('YOUR_PROGRAM_ID_HERE');
```

## Step 5: Test Locally

### Install dependencies
```bash
cd app
npm install
```

### Start development server
```bash
npm start
```

Open http://localhost:3000 and test:
1. Connect Phantom wallet (set to Devnet)
2. Initialize a chat
3. Send encrypted messages
4. Test self-destructing messages

## Step 6: Deploy Frontend

### Build for production
```bash
cd app
npm run build
```

### Deploy options:

#### Option A: Vercel
```bash
npm install -g vercel
vercel --prod
```

#### Option B: Netlify
```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build
```

#### Option C: GitHub Pages
```bash
npm install --save-dev gh-pages

# Add to package.json:
"homepage": "https://yourusername.github.io/WhisperChain",
"scripts": {
  "predeploy": "npm run build",
  "deploy": "gh-pages -d build"
}

npm run deploy
```

## Step 7: Mainnet Deployment (Production)

### ⚠️ Important Mainnet Considerations

1. **Audit your code**: Get a professional security audit
2. **Test thoroughly**: Extensive testing on devnet
3. **Have sufficient SOL**: Deployment costs ~5 SOL
4. **Immutable**: Once deployed, you can't change the program easily

### Switch to Mainnet
```bash
solana config set --url https://api.mainnet-beta.solana.com
```

### Get mainnet SOL
You need to purchase SOL from an exchange (Coinbase, Binance, etc.) and transfer to your wallet.

### Deploy to mainnet
```bash
cd program
solana program deploy target/deploy/whisperchain.so
```

### Update frontend for mainnet

1. Edit `/app/src/contexts/WalletConnectionProvider.tsx`:
```typescript
const network = WalletAdapterNetwork.Mainnet; // Changed from Devnet
```

2. Update program ID in `/app/src/utils/program.ts`

3. Build and deploy frontend:
```bash
cd app
npm run build
# Deploy to your hosting provider
```

## Program Upgrade

If you need to upgrade your program:

### Build new version
```bash
cd program
./build.sh
```

### Upgrade
```bash
solana program deploy target/deploy/whisperchain.so --program-id <EXISTING_PROGRAM_ID>
```

Note: You must be the upgrade authority to do this.

## Monitoring & Maintenance

### Check program status
```bash
solana program show <PROGRAM_ID>
```

### View program logs
```bash
solana logs <PROGRAM_ID>
```

### Check account balance
```bash
solana balance
```

## Troubleshooting

### "Insufficient funds"
```bash
# Devnet
solana airdrop 2

# Mainnet
# Purchase SOL from exchange
```

### "Program deployment failed"
- Ensure you have enough SOL (deployment costs vary)
- Check file path: `target/deploy/whisperchain.so`
- Verify Solana CLI is up to date

### "Account already in use"
- Program ID already exists
- Use `--program-id` flag to upgrade existing program

### Frontend not connecting
- Verify Phantom is on correct network (devnet/mainnet)
- Check program ID in code matches deployed program
- Open browser console for errors

## Cost Estimation

### Devnet (Free)
- Deployment: Free (use airdrop)
- Transactions: Free

### Mainnet
- Program deployment: ~5-10 SOL (one-time)
- Transaction fees: ~0.000005 SOL per transaction
- Account rent: ~0.002 SOL per message account

## Security Best Practices

1. **Never commit private keys** to git
2. **Use hardware wallet** for mainnet deployments
3. **Test all features** on devnet first
4. **Enable upgrade authority** cautiously
5. **Monitor program** regularly for issues
6. **Keep dependencies updated**
7. **Consider multi-sig** for program authority

## Resources

- [Solana Documentation](https://docs.solana.com/)
- [Solana Program Library](https://spl.solana.com/)
- [Anchor Framework](https://www.anchor-lang.com/)
- [Solana Explorer](https://explorer.solana.com/)

## Support

Issues? Open a GitHub issue or contact the team.

---

Good luck with your deployment! 🚀
