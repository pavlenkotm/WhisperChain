# 🍎 Swift iOS Wallet SDK

Native iOS SDK for Ethereum wallet integration with SwiftUI support.

## Features
- Wallet creation and management
- ETH transfers
- Message signing
- Transaction monitoring
- Modern async/await API

## Installation
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/argentlabs/web3.swift", from: "1.0.0")
]
```

## Usage
```swift
let wallet = try WalletKit(
    rpcURL: "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY",
    privateKey: "0x..."
)

let balance = try await wallet.getBalance()
print("Balance: \(balance) ETH")
```

## Resources
- [Web3.swift](https://github.com/argentlabs/web3.swift)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
