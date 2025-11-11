namespace BlockchainAnalyzer

open System

/// Domain types for blockchain data analysis
module Types =

    /// Represents a blockchain address
    type Address = Address of string

    /// Represents a transaction hash
    type TxHash = TxHash of string

    /// Represents a block number
    type BlockNumber = BlockNumber of uint64

    /// Represents an amount in wei (smallest unit)
    type Wei = Wei of bigint

    /// Transaction record
    type Transaction = {
        Hash: TxHash
        From: Address
        To: Address option
        Value: Wei
        GasPrice: Wei
        GasUsed: uint64
        BlockNumber: BlockNumber
        Timestamp: DateTime
        Success: bool
    }

    /// Block record
    type Block = {
        Number: BlockNumber
        Hash: string
        ParentHash: string
        Timestamp: DateTime
        Transactions: Transaction list
        Miner: Address
        Difficulty: bigint
        GasLimit: uint64
        GasUsed: uint64
    }

    /// Account balance snapshot
    type AccountSnapshot = {
        Address: Address
        Balance: Wei
        Timestamp: DateTime
        BlockNumber: BlockNumber
    }

    /// Token transfer event
    type TokenTransfer = {
        Token: Address
        From: Address
        To: Address
        Amount: bigint
        Timestamp: DateTime
        TxHash: TxHash
    }

    /// Statistical metrics for analysis
    type TransactionMetrics = {
        TotalCount: int
        TotalVolume: bigint
        AverageValue: float
        MedianValue: float
        MaxValue: bigint
        MinValue: bigint
        UniqueAddresses: int
        SuccessRate: float
    }

    /// Time series data point
    type TimeSeriesPoint = {
        Timestamp: DateTime
        Value: float
    }

    /// Network statistics
    type NetworkStats = {
        BlockHeight: BlockNumber
        TotalTransactions: uint64
        AverageBlockTime: float
        AverageGasPrice: Wei
        NetworkHashrate: float
        ActiveAddresses: int
    }

    /// Query filters
    type TransactionFilter = {
        FromBlock: BlockNumber option
        ToBlock: BlockNumber option
        Address: Address option
        MinValue: Wei option
        MaxValue: Wei option
    }
