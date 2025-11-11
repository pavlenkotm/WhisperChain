namespace BlockchainAnalyzer

open System
open System.Linq
open Types

/// Advanced blockchain data analytics using F# functional programming
module Analytics =

    // ========================================================================
    // Conversion utilities
    // ========================================================================

    let weiToEther (Wei amount) : float =
        float amount / 1e18

    let etherToWei (ether: float) : Wei =
        Wei (bigint (ether * 1e18))

    // ========================================================================
    // Statistical analysis
    // ========================================================================

    /// Calculate transaction metrics from a list of transactions
    let analyzeTransactions (transactions: Transaction list) : TransactionMetrics =
        let values =
            transactions
            |> List.map (fun tx -> weiToEther tx.Value)
            |> List.filter (fun v -> v > 0.0)

        let sortedValues = values |> List.sort

        {
            TotalCount = transactions.Length
            TotalVolume =
                transactions
                |> List.sumBy (fun tx -> let (Wei v) = tx.Value in v)
            AverageValue =
                if values.IsEmpty then 0.0
                else List.average values
            MedianValue =
                if sortedValues.IsEmpty then 0.0
                else sortedValues.[sortedValues.Length / 2]
            MaxValue =
                if transactions.IsEmpty then bigint 0
                else transactions |> List.maxBy (fun tx -> tx.Value) |> fun tx -> let (Wei v) = tx.Value in v
            MinValue =
                if transactions.IsEmpty then bigint 0
                else transactions |> List.filter (fun tx -> let (Wei v) = tx.Value in v > bigint 0) |> List.minBy (fun tx -> tx.Value) |> fun tx -> let (Wei v) = tx.Value in v
            UniqueAddresses =
                transactions
                |> List.collect (fun tx -> [tx.From; match tx.To with Some addr -> addr | None -> Address ""])
                |> List.distinct
                |> List.length
            SuccessRate =
                let successful = transactions |> List.filter (fun tx -> tx.Success) |> List.length |> float
                if transactions.IsEmpty then 0.0
                else successful / float transactions.Length * 100.0
        }

    /// Group transactions by time period
    let groupByTimePeriod (period: TimeSpan) (transactions: Transaction list) : Map<DateTime, Transaction list> =
        transactions
        |> List.groupBy (fun tx ->
            let ticks = tx.Timestamp.Ticks / period.Ticks
            DateTime(ticks * period.Ticks))
        |> Map.ofList

    /// Calculate moving average
    let movingAverage (windowSize: int) (data: float list) : float list =
        data
        |> List.windowed windowSize
        |> List.map List.average

    /// Calculate transaction volume over time
    let volumeTimeSeries (interval: TimeSpan) (transactions: Transaction list) : TimeSeriesPoint list =
        transactions
        |> groupByTimePeriod interval
        |> Map.toList
        |> List.map (fun (timestamp, txs) ->
            {
                Timestamp = timestamp
                Value = txs |> List.sumBy (fun tx -> weiToEther tx.Value)
            })
        |> List.sortBy (fun point -> point.Timestamp)

    /// Calculate gas price trends
    let gasPriceTrends (interval: TimeSpan) (transactions: Transaction list) : TimeSeriesPoint list =
        transactions
        |> groupByTimePeriod interval
        |> Map.toList
        |> List.map (fun (timestamp, txs) ->
            {
                Timestamp = timestamp
                Value = txs |> List.averageBy (fun tx -> weiToEther tx.GasPrice)
            })
        |> List.sortBy (fun point -> point.Timestamp)

    // ========================================================================
    // Address analysis
    // ========================================================================

    /// Calculate balance for an address from transaction history
    let calculateBalance (address: Address) (transactions: Transaction list) : Wei =
        let received =
            transactions
            |> List.filter (fun tx -> tx.To = Some address)
            |> List.sumBy (fun tx -> let (Wei v) = tx.Value in v)

        let sent =
            transactions
            |> List.filter (fun tx -> tx.From = address)
            |> List.sumBy (fun tx -> let (Wei v) = tx.Value in v)

        Wei (received - sent)

    /// Find top senders by volume
    let topSenders (count: int) (transactions: Transaction list) : (Address * bigint) list =
        transactions
        |> List.groupBy (fun tx -> tx.From)
        |> List.map (fun (addr, txs) ->
            (addr, txs |> List.sumBy (fun tx -> let (Wei v) = tx.Value in v)))
        |> List.sortByDescending snd
        |> List.take (min count (transactions |> List.groupBy (fun tx -> tx.From) |> List.length))

    /// Find top receivers by volume
    let topReceivers (count: int) (transactions: Transaction list) : (Address * bigint) list =
        transactions
        |> List.choose (fun tx -> tx.To |> Option.map (fun addr -> (addr, tx.Value)))
        |> List.groupBy fst
        |> List.map (fun (addr, values) ->
            (addr, values |> List.sumBy (fun (_, Wei v) -> v)))
        |> List.sortByDescending snd
        |> List.take (min count (transactions |> List.choose (fun tx -> tx.To) |> List.distinct |> List.length))

    /// Detect whale transactions (large value transfers)
    let detectWhaleTransactions (threshold: Wei) (transactions: Transaction list) : Transaction list =
        let (Wei thresholdValue) = threshold
        transactions
        |> List.filter (fun tx ->
            let (Wei value) = tx.Value
            value >= thresholdValue)
        |> List.sortByDescending (fun tx -> tx.Value)

    // ========================================================================
    // Pattern detection
    // ========================================================================

    /// Detect potential wash trading (circular transactions)
    let detectCircularTransactions (windowSize: int) (transactions: Transaction list) : (Address * Transaction list) list =
        transactions
        |> List.sortBy (fun tx -> tx.Timestamp)
        |> List.windowed windowSize
        |> List.filter (fun window ->
            let addresses = window |> List.collect (fun tx -> [tx.From; match tx.To with Some a -> a | None -> Address ""])
            let uniqueAddresses = addresses |> List.distinct |> List.length
            uniqueAddresses < addresses.Length / 2)
        |> List.collect id
        |> List.groupBy (fun tx -> tx.From)

    /// Calculate transaction frequency for addresses
    let transactionFrequency (transactions: Transaction list) : Map<Address, int> =
        transactions
        |> List.collect (fun tx -> [tx.From; match tx.To with Some a -> a | None -> Address ""])
        |> List.countBy id
        |> Map.ofList

    /// Identify active trading pairs
    let identifyTradingPairs (minTransactions: int) (transactions: Transaction list) : ((Address * Address) * int) list =
        transactions
        |> List.choose (fun tx ->
            tx.To |> Option.map (fun toAddr -> (tx.From, toAddr)))
        |> List.countBy id
        |> List.filter (fun (_, count) -> count >= minTransactions)
        |> List.sortByDescending snd

    // ========================================================================
    // Network analysis
    // ========================================================================

    /// Calculate network statistics
    let calculateNetworkStats (blocks: Block list) : NetworkStats =
        let allTransactions = blocks |> List.collect (fun b -> b.Transactions)

        let blockTimes =
            blocks
            |> List.sortBy (fun b -> b.Number)
            |> List.pairwise
            |> List.map (fun (b1, b2) -> (b2.Timestamp - b1.Timestamp).TotalSeconds)

        {
            BlockHeight =
                if blocks.IsEmpty then BlockNumber 0UL
                else blocks |> List.maxBy (fun b -> b.Number) |> fun b -> b.Number
            TotalTransactions = uint64 allTransactions.Length
            AverageBlockTime =
                if blockTimes.IsEmpty then 0.0
                else List.average blockTimes
            AverageGasPrice =
                if allTransactions.IsEmpty then Wei (bigint 0)
                else
                    let avgGwei = allTransactions |> List.averageBy (fun tx -> let (Wei gp) = tx.GasPrice in float gp)
                    Wei (bigint avgGwei)
            NetworkHashrate =
                blocks |> List.averageBy (fun b -> float b.Difficulty)
            ActiveAddresses =
                allTransactions
                |> List.collect (fun tx -> [tx.From; match tx.To with Some a -> a | None -> Address ""])
                |> List.distinct
                |> List.length
        }

    /// Calculate block utilization (gas used / gas limit)
    let blockUtilization (blocks: Block list) : TimeSeriesPoint list =
        blocks
        |> List.map (fun block ->
            {
                Timestamp = block.Timestamp
                Value = (float block.GasUsed / float block.GasLimit) * 100.0
            })
        |> List.sortBy (fun point -> point.Timestamp)

    // ========================================================================
    // Advanced analytics
    // ========================================================================

    /// Calculate Gini coefficient (wealth inequality measure)
    let giniCoefficient (balances: bigint list) : float =
        let sortedBalances = balances |> List.sort |> List.map float
        let n = float sortedBalances.Length

        if n = 0.0 then 0.0
        else
            let numerator =
                sortedBalances
                |> List.mapi (fun i balance -> (2.0 * float (i + 1) - n - 1.0) * balance)
                |> List.sum

            let denominator = n * (sortedBalances |> List.sum)

            if denominator = 0.0 then 0.0
            else numerator / denominator

    /// Detect anomalies using z-score
    let detectAnomalies (threshold: float) (values: float list) : (int * float) list =
        let mean = List.average values
        let stdDev =
            values
            |> List.averageBy (fun v -> (v - mean) ** 2.0)
            |> sqrt

        values
        |> List.mapi (fun i v -> (i, v, abs (v - mean) / stdDev))
        |> List.filter (fun (_, _, zscore) -> zscore > threshold)
        |> List.map (fun (i, v, _) -> (i, v))

    /// Calculate correlation between two time series
    let correlation (series1: float list) (series2: float list) : float =
        if series1.Length <> series2.Length || series1.IsEmpty then 0.0
        else
            let mean1 = List.average series1
            let mean2 = List.average series2

            let covariance =
                List.zip series1 series2
                |> List.averageBy (fun (x, y) -> (x - mean1) * (y - mean2))

            let stdDev1 = series1 |> List.averageBy (fun x -> (x - mean1) ** 2.0) |> sqrt
            let stdDev2 = series2 |> List.averageBy (fun y -> (y - mean2) ** 2.0) |> sqrt

            if stdDev1 = 0.0 || stdDev2 = 0.0 then 0.0
            else covariance / (stdDev1 * stdDev2)

    // ========================================================================
    // Reporting
    // ========================================================================

    /// Generate human-readable report
    let generateReport (metrics: TransactionMetrics) : string =
        sprintf """
Blockchain Transaction Analysis Report
========================================

Total Transactions: %d
Total Volume: %s ETH
Average Value: %.4f ETH
Median Value: %.4f ETH
Max Transaction: %s ETH
Min Transaction: %s ETH
Unique Addresses: %d
Success Rate: %.2f%%
        """
            metrics.TotalCount
            (metrics.TotalVolume.ToString())
            metrics.AverageValue
            metrics.MedianValue
            (metrics.MaxValue.ToString())
            (metrics.MinValue.ToString())
            metrics.UniqueAddresses
            metrics.SuccessRate
