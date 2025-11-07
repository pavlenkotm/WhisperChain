# 🚀 Deployment Guide

Comprehensive guide for deploying WhisperChain examples to production.

## Table of Contents

1. [Smart Contracts](#smart-contracts)
2. [Backend Services](#backend-services)
3. [Frontend Applications](#frontend-applications)
4. [Infrastructure](#infrastructure)

## Smart Contracts

### Solidity (Ethereum/L2)

#### Testnet Deployment
```bash
cd examples/solidity

# Set environment
export NETWORK="sepolia"
export RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
export PRIVATE_KEY="0x..."

# Deploy
npm run deploy:sepolia
```

#### Mainnet Deployment
```bash
# ⚠️ CAUTION: Real money involved!
export NETWORK="mainnet"
export RPC_URL="https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY"
export PRIVATE_KEY="0x..."  # Use hardware wallet!

# Deploy with gas optimization
npm run deploy:mainnet
```

#### Verification
```bash
npx hardhat verify --network sepolia CONTRACT_ADDRESS "Constructor" "Args"
```

### Solana

```bash
cd program

# Build
cargo build-bpf

# Deploy to devnet
solana program deploy target/deploy/whisperchain.so --url devnet

# Deploy to mainnet
solana program deploy target/deploy/whisperchain.so --url mainnet-beta
```

## Backend Services

### Python Service

```bash
cd examples/python

# Setup
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure
cp .env.example .env
# Edit .env with production values

# Run
gunicorn app:app --workers 4 --bind 0.0.0.0:8000
```

### TypeScript/Node.js

```bash
cd examples/typescript

# Build
npm install
npm run build

# Production run
NODE_ENV=production node dist/index.js
```

## Frontend Applications

### React/TypeScript DApp

```bash
cd app

# Build for production
npm install
npm run build

# Deploy to hosting
# Option 1: Vercel
vercel deploy

# Option 2: Netlify
netlify deploy --prod

# Option 3: AWS S3 + CloudFront
aws s3 sync build/ s3://your-bucket/
aws cloudfront create-invalidation --distribution-id ID --paths "/*"
```

### Environment Configuration

```bash
# .env.production
REACT_APP_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
REACT_APP_CHAIN_ID=1
REACT_APP_CONTRACT_ADDRESS=0x...
```

## Infrastructure

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

```bash
# Build and run
docker build -t whisperchain .
docker run -p 3000:3000 whisperchain
```

### Kubernetes

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whisperchain
spec:
  replicas: 3
  selector:
    matchLabels:
      app: whisperchain
  template:
    metadata:
      labels:
        app: whisperchain
    spec:
      containers:
      - name: whisperchain
        image: whisperchain:latest
        ports:
        - containerPort: 3000
```

## Monitoring

### Logging
```bash
# Structured logging with Winston
npm install winston

# Configure log levels
LOG_LEVEL=info
```

### Metrics
- Prometheus for metrics
- Grafana for visualization
- Alert Manager for notifications

### Error Tracking
- Sentry for error monitoring
- DataDog for APM

## Security Checklist

- [ ] All secrets in environment variables
- [ ] HTTPS enabled
- [ ] Rate limiting configured
- [ ] CORS properly set
- [ ] Smart contracts audited
- [ ] Dependencies updated
- [ ] Monitoring configured
- [ ] Backup strategy in place

## Cost Optimization

### Gas Optimization
- Use Foundry's gas snapshots
- Optimize contract storage
- Batch transactions where possible

### Infrastructure
- Use CDN for static assets
- Implement caching
- Auto-scaling based on load

## Rollback Procedure

1. Keep previous deployment artifacts
2. Monitor metrics after deployment
3. Have rollback scripts ready
4. Test rollback in staging first

## References

- [Getting Started](GETTING_STARTED.md)
- [Architecture](ARCHITECTURE.md)
- [Security Policy](../SECURITY.md)
