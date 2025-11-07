# 🔷 Go Blockchain Utilities

Professional Go utilities for Ethereum blockchain interaction and wallet management.

## 📋 Packages

### 1. Wallet Package
- **Path**: `wallet/wallet.go`
- **Features**:
  - ✅ Wallet creation
  - ✅ Balance queries
  - ✅ ETH transfers
  - ✅ Message signing & verification
  - ✅ Transaction monitoring
  - ✅ Nonce management

### 2. Contract Package
- **Path**: `contract/erc20.go`
- **Features**:
  - ✅ ERC-20 token interactions
  - ✅ Balance queries
  - ✅ Transfer operations
  - ✅ Approve & allowance
  - ✅ Token metadata

## 🚀 Quick Start

### Prerequisites
```bash
go version  # Go 1.21+
```

### Installation
```bash
cd examples/go

# Download dependencies
go mod download

# Install go-ethereum
go get github.com/ethereum/go-ethereum
```

### Build
```bash
go build -o bin/wallet ./cmd/wallet
```

## 📖 Usage Examples

### Create a Wallet
```go
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/whisperchain/go-examples/wallet"
)

func main() {
    // Create new wallet
    w, err := wallet.NewWallet("http://localhost:8545")
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Address:", w.Address.Hex())
    fmt.Println("Private Key:", w.GetPrivateKeyHex())

    // Get balance
    ctx := context.Background()
    balance, err := w.GetBalance(ctx)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Balance:", balance.String(), "wei")
}
```

### Transfer ETH
```go
package main

import (
    "context"
    "log"
    "math/big"

    "github.com/ethereum/go-ethereum/common"
    "github.com/whisperchain/go-examples/wallet"
)

func main() {
    w, _ := wallet.NewWallet("http://localhost:8545")

    // Transfer 0.1 ETH
    amount := new(big.Int)
    amount.SetString("100000000000000000", 10) // 0.1 ETH in wei

    to := common.HexToAddress("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")

    ctx := context.Background()
    tx, err := w.Transfer(ctx, to, amount)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Transaction hash:", tx.Hash().Hex())

    // Wait for confirmation
    receipt, err := w.WaitForTransaction(ctx, tx.Hash())
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Confirmed in block:", receipt.BlockNumber)
}
```

### Sign & Verify Messages
```go
package main

import (
    "fmt"
    "log"

    "github.com/whisperchain/go-examples/wallet"
)

func main() {
    w, _ := wallet.NewWallet("http://localhost:8545")

    // Sign message
    message := []byte("Authenticate with WhisperChain")
    signature, err := w.SignMessage(message)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Signature:", common.Bytes2Hex(signature))

    // Verify signature
    valid := wallet.VerifySignature(message, signature, w.Address)
    fmt.Println("Valid signature:", valid)
}
```

### Interact with ERC-20 Tokens
```go
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/ethclient"
    "github.com/whisperchain/go-examples/contract"
)

func main() {
    client, _ := ethclient.Dial("http://localhost:8545")

    tokenAddr := common.HexToAddress("0x...")
    erc20 := contract.NewERC20(tokenAddr, client)

    // Get token info
    ctx := context.Background()
    info, err := erc20.GetTokenInfo(ctx)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Printf("Token: %s (%s)\n", info.Name, info.Symbol)
    fmt.Printf("Decimals: %d\n", info.Decimals)
    fmt.Printf("Total Supply: %s\n", info.TotalSupply.String())

    // Get balance
    userAddr := common.HexToAddress("0x...")
    balance, err := erc20.BalanceOf(ctx, userAddr)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println("Balance:", balance.String())
}
```

## 🧪 Testing

### Run Tests
```bash
# All tests
go test ./...

# Specific package
go test ./wallet

# With coverage
go test -cover ./...

# Verbose output
go test -v ./...
```

### Benchmark
```bash
go test -bench=. ./...
```

## 🔧 CLI Tools

### Wallet CLI
```bash
# Create new wallet
go run cmd/wallet/main.go create

# Check balance
go run cmd/wallet/main.go balance --address 0x...

# Transfer ETH
go run cmd/wallet/main.go transfer \
  --to 0x... \
  --amount 0.1 \
  --private-key 0x...
```

## 🏗️ Project Structure

```
examples/go/
├── wallet/
│   ├── wallet.go          # Wallet implementation
│   └── wallet_test.go     # Tests
├── contract/
│   ├── erc20.go           # ERC-20 utilities
│   └── erc20_test.go      # Tests
├── cmd/
│   └── wallet/
│       └── main.go        # CLI tool
├── go.mod                 # Dependencies
├── go.sum
└── README.md
```

## 🔐 Security Best Practices

1. **Never commit private keys**
   ```go
   // Use environment variables
   privateKey := os.Getenv("PRIVATE_KEY")
   ```

2. **Validate addresses**
   ```go
   if !common.IsHexAddress(addrStr) {
       return errors.New("invalid address")
   }
   addr := common.HexToAddress(addrStr)
   ```

3. **Handle errors properly**
   ```go
   if err != nil {
       return fmt.Errorf("transfer failed: %w", err)
   }
   ```

4. **Set timeouts**
   ```go
   ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
   defer cancel()
   ```

## 📊 Advanced Features

### Gas Price Estimation
```go
gasPrice, err := client.SuggestGasPrice(ctx)
if err != nil {
    log.Fatal(err)
}

// Add 20% buffer
adjustedPrice := new(big.Int).Mul(gasPrice, big.NewInt(120))
adjustedPrice.Div(adjustedPrice, big.NewInt(100))
```

### Event Listening
```go
query := ethereum.FilterQuery{
    Addresses: []common.Address{contractAddr},
}

logs := make(chan types.Log)
sub, err := client.SubscribeFilterLogs(ctx, query, logs)
if err != nil {
    log.Fatal(err)
}

for {
    select {
    case err := <-sub.Err():
        log.Fatal(err)
    case vLog := <-logs:
        fmt.Println("New event:", vLog.TxHash.Hex())
    }
}
```

### Concurrent Transactions
```go
var wg sync.WaitGroup

for i := 0; i < 10; i++ {
    wg.Add(1)
    go func(nonce uint64) {
        defer wg.Done()

        tx, err := sendTransaction(ctx, nonce)
        if err != nil {
            log.Println("Error:", err)
            return
        }

        fmt.Println("TX:", tx.Hash().Hex())
    }(baseNonce + uint64(i))
}

wg.Wait()
```

## 📚 Resources

- [Go-Ethereum Documentation](https://geth.ethereum.org/docs)
- [Ethereum JSON-RPC API](https://ethereum.github.io/execution-apis/api-documentation/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://go.dev/doc/effective_go)

## 🤝 Contributing

Contributions welcome! Please ensure:
- Code passes `go vet` and `golint`
- Tests included
- Documentation updated
- Follow Go style guidelines

## 📄 License

MIT License - see LICENSE file for details
