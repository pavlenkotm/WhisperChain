open System
open BlockchainAnalyzer.Types
open BlockchainAnalyzer.Analytics

// Sample data generator for demonstration
module SampleData =
    let random = Random()

    let randomAddress() =
        Address (sprintf "0x%040x" (random.Next()))

    let generateTransaction (blockNum: uint64) (timestamp: DateTime) : Transaction =
        {
            Hash = TxHash (sprintf "0x%064x" (random.Next()))
            From = randomAddress()
            To = Some (randomAddress())
            Value = Wei (bigint (random.Next(1, 1000)) * bigint 1_000_000_000_000_000_000L)
            GasPrice = Wei (bigint (random.Next(20, 100)) * bigint 1_000_000_000L)
            GasUsed = uint64 (random.Next(21000, 200000))
            BlockNumber = BlockNumber blockNum
            Timestamp = timestamp
            Success = random.Next(100) > 5
        }

    let generateBlock (number: uint64) (timestamp: DateTime) (txCount: int) : Block =
        {
            Number = BlockNumber number
            Hash = sprintf "0x%064x" (random.Next())
            ParentHash = sprintf "0x%064x" (random.Next())
            Timestamp = timestamp
            Transactions = List.init txCount (fun _ -> generateTransaction number timestamp)
            Miner = randomAddress()
            Difficulty = bigint (random.Next(1000000, 10000000))
            GasLimit = 30_000_000UL
            GasUsed = uint64 (txCount * random.Next(50000, 150000))
        }

    let generateSampleData (blockCount: int) (txPerBlock: int) : Block list =
        let startTime = DateTime.UtcNow.AddDays(-7.0)

        [0 .. blockCount - 1]
        |> List.map (fun i ->
            let timestamp = startTime.AddSeconds(float (i * 12))
            generateBlock (uint64 i) timestamp txPerBlock)

[<EntryPoint>]
let main argv =
    printfn "╔══════════════════════════════════════════════════════════════╗"
    printfn "║  F# Blockchain Data Analytics Platform                      ║"
    printfn "║  Functional Programming for Web3 Intelligence                ║"
    printfn "╚══════════════════════════════════════════════════════════════╝"
    printfn ""

    // Generate sample blockchain data
    printfn "📊 Generating sample blockchain data..."
    let blocks = SampleData.generateSampleData 100 50
    let allTransactions = blocks |> List.collect (fun b -> b.Transactions)

    printfn "   Generated %d blocks with %d transactions" blocks.Length allTransactions.Length
    printfn ""

    // Basic transaction analysis
    printfn "📈 Transaction Analysis"
    printfn "════════════════════════════════════════════════════════════════"
    let metrics = analyzeTransactions allTransactions

    printfn "Total Transactions:  %d" metrics.TotalCount
    printfn "Total Volume:        %.2f ETH" (weiToEther (Wei metrics.TotalVolume))
    printfn "Average Value:       %.4f ETH" metrics.AverageValue
    printfn "Median Value:        %.4f ETH" metrics.MedianValue
    printfn "Max Transaction:     %.4f ETH" (float metrics.MaxValue / 1e18)
    printfn "Min Transaction:     %.4f ETH" (float metrics.MinValue / 1e18)
    printfn "Unique Addresses:    %d" metrics.UniqueAddresses
    printfn "Success Rate:        %.2f%%" metrics.SuccessRate
    printfn ""

    // Time series analysis
    printfn "📉 Time Series Analysis"
    printfn "════════════════════════════════════════════════════════════════"
    let hourlyVolume = volumeTimeSeries (TimeSpan.FromHours(1.0)) allTransactions
    printfn "Generated %d hourly volume data points" hourlyVolume.Length

    if hourlyVolume.Length > 0 then
        let maxVolume = hourlyVolume |> List.maxBy (fun p -> p.Value)
        let minVolume = hourlyVolume |> List.minBy (fun p -> p.Value)
        printfn "Max hourly volume:   %.2f ETH at %s" maxVolume.Value (maxVolume.Timestamp.ToString("yyyy-MM-dd HH:mm"))
        printfn "Min hourly volume:   %.2f ETH at %s" minVolume.Value (minVolume.Timestamp.ToString("yyyy-MM-dd HH:mm"))

    let gasPrices = gasPriceTrends (TimeSpan.FromHours(1.0)) allTransactions
    if gasPrices.Length > 0 then
        let avgGasPrice = gasPrices |> List.averageBy (fun p -> p.Value)
        printfn "Average gas price:   %.2f Gwei" avgGasPrice
    printfn ""

    // Address analysis
    printfn "👥 Address Analysis"
    printfn "════════════════════════════════════════════════════════════════"
    let topSendersList = topSenders 5 allTransactions
    printfn "Top 5 Senders by Volume:"
    topSendersList |> List.iteri (fun i (Address addr, volume) ->
        printfn "  %d. %s... %.2f ETH" (i + 1) (addr.Substring(0, min 10 addr.Length)) (float volume / 1e18))

    let topReceiversList = topReceivers 5 allTransactions
    printfn "\nTop 5 Receivers by Volume:"
    topReceiversList |> List.iteri (fun i (Address addr, volume) ->
        printfn "  %d. %s... %.2f ETH" (i + 1) (addr.Substring(0, min 10 addr.Length)) (float volume / 1e18))
    printfn ""

    // Whale detection
    printfn "🐋 Whale Detection"
    printfn "════════════════════════════════════════════════════════════════"
    let whaleThreshold = etherToWei 100.0
    let whales = detectWhaleTransactions whaleThreshold allTransactions
    printfn "Found %d whale transactions (> 100 ETH)" whales.Length

    if not whales.IsEmpty then
        printfn "Largest whale transactions:"
        whales
        |> List.take (min 3 whales.Length)
        |> List.iteri (fun i tx ->
            let (Address fromAddr) = tx.From
            printfn "  %d. %.2f ETH from %s..." (i + 1) (weiToEther tx.Value) (fromAddr.Substring(0, min 10 fromAddr.Length)))
    printfn ""

    // Network statistics
    printfn "🌐 Network Statistics"
    printfn "════════════════════════════════════════════════════════════════"
    let networkStats = calculateNetworkStats blocks
    let (BlockNumber height) = networkStats.BlockHeight
    printfn "Block Height:        %d" height
    printfn "Total Transactions:  %d" networkStats.TotalTransactions
    printfn "Avg Block Time:      %.2f seconds" networkStats.AverageBlockTime
    printfn "Avg Gas Price:       %.2f Gwei" (weiToEther networkStats.AverageGasPrice * 1e9)
    printfn "Active Addresses:    %d" networkStats.ActiveAddresses
    printfn ""

    // Block utilization
    printfn "⛽ Gas Utilization"
    printfn "════════════════════════════════════════════════════════════════"
    let utilization = blockUtilization blocks
    let avgUtilization = utilization |> List.averageBy (fun p -> p.Value)
    let maxUtilization = utilization |> List.maxBy (fun p -> p.Value)
    printfn "Average block utilization: %.2f%%" avgUtilization
    printfn "Max block utilization:     %.2f%%" maxUtilization.Value
    printfn ""

    // Pattern detection
    printfn "🔍 Pattern Detection"
    printfn "════════════════════════════════════════════════════════════════"
    let tradingPairs = identifyTradingPairs 3 allTransactions
    printfn "Found %d active trading pairs (min 3 transactions)" tradingPairs.Length

    if not tradingPairs.IsEmpty then
        printfn "Most active trading pairs:"
        tradingPairs
        |> List.take (min 3 tradingPairs.Length)
        |> List.iteri (fun i ((Address from, Address to), count) ->
            printfn "  %d. %s... ↔ %s... (%d transactions)"
                (i + 1)
                (from.Substring(0, min 8 from.Length))
                (to.Substring(0, min 8 to.Length))
                count)
    printfn ""

    // Advanced analytics
    printfn "🎯 Advanced Analytics"
    printfn "════════════════════════════════════════════════════════════════"

    // Anomaly detection
    let values = allTransactions |> List.map (fun tx -> weiToEther tx.Value)
    let anomalies = detectAnomalies 2.5 values
    printfn "Detected %d anomalous transactions (z-score > 2.5)" anomalies.Length

    // Moving average
    let volumeValues = hourlyVolume |> List.map (fun p -> p.Value)
    if volumeValues.Length >= 5 then
        let ma = movingAverage 5 volumeValues
        printfn "Calculated %d-period moving average: %d points" 5 ma.Length

    printfn ""
    printfn "✅ Analysis complete!"
    printfn ""
    printfn "💡 F# Features Demonstrated:"
    printfn "   • Immutable data structures"
    printfn "   • Pattern matching"
    printfn "   • Pipeline operators (|>)"
    printfn "   • List comprehensions"
    printfn "   • Type inference"
    printfn "   • Discriminated unions"
    printfn "   • Functional composition"

    0 // return an integer exit code
