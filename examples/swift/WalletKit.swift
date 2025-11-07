import Foundation
import Web3

/// WhisperChain Wallet Kit for iOS
/// Provides Ethereum wallet functionality for iOS applications
@available(iOS 13.0, *)
public class WalletKit {

    private let client: EthereumClient
    private let account: EthereumAccount

    public init(rpcURL: String, privateKey: String) throws {
        guard let url = URL(string: rpcURL) else {
            throw WalletError.invalidURL
        }

        self.client = EthereumClient(url: url)

        guard let accountData = Data(hexString: privateKey) else {
            throw WalletError.invalidPrivateKey
        }

        self.account = try EthereumAccount(keyStorage: EthereumKeyLocalStorage(), privateKey: accountData)
    }

    /// Get wallet address
    public var address: String {
        return account.address.asString()
    }

    /// Get ETH balance
    public func getBalance() async throws -> String {
        let balance = try await client.eth_getBalance(address: account.address, block: .Latest)
        let ethBalance = Double(balance) / 1_000_000_000_000_000_000.0
        return String(format: "%.4f", ethBalance)
    }

    /// Transfer ETH
    public func transfer(to: String, amount: String) async throws -> String {
        guard let toAddress = try? EthereumAddress(hex: to, eip55: true) else {
            throw WalletError.invalidAddress
        }

        let wei = Web3.Utils.parseToBigUInt(amount, units: .eth)
        guard let value = wei else {
            throw WalletError.invalidAmount
        }

        let transaction = EthereumTransaction(
            from: account.address,
            to: toAddress,
            value: value,
            data: Data(),
            nonce: try await getNonce(),
            gasPrice: try await getGasPrice(),
            gasLimit: 21000
        )

        let signedTx = try account.sign(transaction: transaction)
        let txHash = try await client.eth_sendRawTransaction(signedTx.raw())

        return txHash
    }

    /// Get transaction receipt
    public func getReceipt(txHash: String) async throws -> EthereumTransactionReceipt? {
        return try await client.eth_getTransactionReceipt(txHash: txHash)
    }

    /// Sign message
    public func signMessage(_ message: String) throws -> String {
        guard let data = message.data(using: .utf8) else {
            throw WalletError.invalidMessage
        }

        let signature = try account.sign(message: data)
        return signature.toHexString()
    }

    // MARK: - Private Methods

    private func getNonce() async throws -> Int {
        return try await client.eth_getTransactionCount(address: account.address, block: .Latest)
    }

    private func getGasPrice() async throws -> BigUInt {
        return try await client.eth_gasPrice()
    }
}

// MARK: - Errors

public enum WalletError: Error {
    case invalidURL
    case invalidPrivateKey
    case invalidAddress
    case invalidAmount
    case invalidMessage
    case transactionFailed

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid RPC URL"
        case .invalidPrivateKey:
            return "Invalid private key format"
        case .invalidAddress:
            return "Invalid Ethereum address"
        case .invalidAmount:
            return "Invalid amount"
        case .invalidMessage:
            return "Invalid message format"
        case .transactionFailed:
            return "Transaction failed"
        }
    }
}

// MARK: - Extensions

extension Data {
    init?(hexString: String) {
        let string = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
        guard string.count.isMultiple(of: 2) else { return nil }

        var data = Data(capacity: string.count / 2)
        var index = string.startIndex

        while index < string.endIndex {
            let nextIndex = string.index(index, offsetBy: 2)
            if let byte = UInt8(string[index..<nextIndex], radix: 16) {
                data.append(byte)
            } else {
                return nil
            }
            index = nextIndex
        }

        self = data
    }

    func toHexString() -> String {
        return "0x" + map { String(format: "%02x", $0) }.joined()
    }
}
