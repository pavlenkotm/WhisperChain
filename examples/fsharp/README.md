# F# Blockchain Data Analytics

Advanced blockchain data analytics platform demonstrating F#'s powerful functional programming capabilities for Web3 intelligence.

## Why F# for Blockchain Analytics?

F# is exceptional for data analysis and blockchain intelligence:

- **Functional-First**: Immutable data structures perfect for blockchain analysis
- **Type Safety**: Strong static typing prevents errors at compile time
- **Pattern Matching**: Elegant handling of complex blockchain data structures
- **LINQ Integration**: Powerful query capabilities for blockchain data
- **Async/Parallel**: Built-in support for concurrent data processing
- **Interop**: Seamless integration with .NET and C# libraries
- **REPL**: Interactive F# for exploratory data analysis

## Features

- **Transaction Analytics**: Volume, frequency, success rate analysis
- **Time Series Analysis**: Hourly/daily trends, moving averages
- **Address Analysis**: Top senders/receivers, balance tracking
- **Whale Detection**: Identify large value transfers
- **Network Statistics**: Block times, gas prices, utilization
- **Pattern Detection**: Trading pairs, circular transactions
- **Advanced Analytics**: Anomaly detection, correlation analysis, Gini coefficient

## Prerequisites

Install .NET 8 SDK:

```bash
# Windows (winget)
winget install Microsoft.DotNet.SDK.8

# macOS
brew install --cask dotnet-sdk

# Linux (Ubuntu/Debian)
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0

# Verify
dotnet --version  # Should show 8.0.x
```

## Installation

```bash
cd examples/fsharp

# Restore dependencies
dotnet restore

# Build
dotnet build

# Run
dotnet run
```

## Usage

### Command Line

```bash
# Run with sample data
dotnet run

# Build release binary
dotnet build -c Release

# Run release binary
./bin/Release/net8.0/BlockchainAnalyzer
```

### Interactive F# (FSI)

```bash
# Start F# REPL
dotnet fsi

# Load modules
#load "src/Types.fs"
#load "src/Analytics.fs"

open BlockchainAnalyzer.Types
open BlockchainAnalyzer.Analytics

// Analyze transactions
let sampleTx = {
    Hash = TxHash "0x123..."
    From = Address "0xabc..."
    To = Some (Address "0xdef...")
    Value = Wei (bigint 1_000_000_000_000_000_000L)
    GasPrice = Wei (bigint 20_000_000_000L)
    GasUsed = 21000UL
    BlockNumber = BlockNumber 1000UL
    Timestamp = System.DateTime.UtcNow
    Success = true
}

let metrics = analyzeTransactions [sampleTx]
printfn "%A" metrics
```

### As Library

```fsharp
open BlockchainAnalyzer.Types
open BlockchainAnalyzer.Analytics

// Analyze real blockchain data
let analyzeEthereumData (transactions: Transaction list) =
    // Calculate metrics
    let metrics = analyzeTransactions transactions

    // Time series analysis
    let hourlyVolume = volumeTimeSeries (TimeSpan.FromHours(1.0)) transactions

    // Detect whales
    let whales = detectWhaleTransactions (etherToWei 100.0) transactions

    // Top addresses
    let topSenders = topSenders 10 transactions
    let topReceivers = topReceivers 10 transactions

    // Pattern detection
    let tradingPairs = identifyTradingPairs 5 transactions

    {| Metrics = metrics
       HourlyVolume = hourlyVolume
       Whales = whales
       TopSenders = topSenders
       TopReceivers = topReceivers
       TradingPairs = tradingPairs |}
```

## Project Structure

```
examples/fsharp/
├── BlockchainAnalyzer.fsproj  # Project configuration
├── src/
│   ├── Types.fs               # Domain types
│   ├── Analytics.fs           # Analysis functions
│   └── Program.fs             # Main program
└── README.md
```

## Key Concepts

### Discriminated Unions

Type-safe representation of blockchain data:

```fsharp
type Address = Address of string
type Wei = Wei of bigint

// Compiler ensures type safety
let addr: Address = Address "0x123..."
let amount: Wei = Wei 1000n

// Can't accidentally mix types!
// addr + amount  // Compile error!
```

### Pattern Matching

Elegant data handling:

```fsharp
let processTransaction tx =
    match tx.To with
    | Some recipient ->
        printfn "Transfer to %A" recipient
    | None ->
        printfn "Contract creation"

    match tx.Value with
    | Wei v when v > 1000000000000000000n ->
        printfn "Large transaction!"
    | Wei v when v = 0n ->
        printfn "No value transfer"
    | _ ->
        printfn "Regular transaction"
```

### Pipeline Operator

Composable data transformations:

```fsharp
let analysis =
    transactions
    |> List.filter (fun tx -> tx.Success)
    |> List.groupBy (fun tx -> tx.BlockNumber)
    |> List.map (fun (block, txs) ->
        (block, txs |> List.sumBy (fun tx -> weiToEther tx.Value)))
    |> List.sortByDescending snd
    |> List.take 10
```

### Type Inference

Concise code without sacrificing safety:

```fsharp
// Compiler infers all types!
let avgGasPrice transactions =
    transactions
    |> List.averageBy (fun tx -> weiToEther tx.GasPrice)

// Fully type-safe without type annotations
```

## Advanced Usage

### Custom Analytics

```fsharp
// Define custom metric
let customMetric transactions =
    transactions
    |> List.filter (fun tx ->
        let (Wei value) = tx.Value
        value > 1000000000000000000n)
    |> List.groupBy (fun tx -> tx.Timestamp.Date)
    |> List.map (fun (date, txs) ->
        (date, txs.Length, txs |> List.sumBy (fun tx -> weiToEther tx.Value)))

// Use with pipeline
let results =
    loadTransactions()
    |> customMetric
    |> List.sortByDescending (fun (_, _, volume) -> volume)
```

### Parallel Processing

```fsharp
open System.Threading.Tasks

// Process blocks in parallel
let analyzeBlocksParallel blocks =
    blocks
    |> Array.ofList
    |> Array.Parallel.map (fun block ->
        let metrics = analyzeTransactions block.Transactions
        (block.Number, metrics))
    |> Array.toList
```

### Async Data Fetching

```fsharp
open System.Net.Http

let fetchBlockData blockNumber = async {
    use client = new HttpClient()
    let! response =
        client.GetStringAsync($"https://api.etherscan.io/api?module=block&action=getblockreward&blockno={blockNumber}")
        |> Async.AwaitTask
    return response
}

// Use async workflow
let processMultipleBlocks blocks = async {
    let! results =
        blocks
        |> List.map fetchBlockData
        |> Async.Parallel

    return results |> Array.toList
}
```

## Performance Optimization

### Lazy Evaluation

```fsharp
// Process only what's needed
let lazyAnalysis =
    transactions
    |> Seq.ofList
    |> Seq.filter (fun tx -> tx.Success)
    |> Seq.map analyzeTransaction
    |> Seq.take 100  // Only process first 100

// Evaluation happens on demand
let results = lazyAnalysis |> Seq.toList
```

### Memoization

```fsharp
// Cache expensive computations
let memoize f =
    let cache = System.Collections.Generic.Dictionary<_, _>()
    fun x ->
        match cache.TryGetValue(x) with
        | true, v -> v
        | false, _ ->
            let v = f x
            cache.[x] <- v
            v

let expensiveAnalysis = memoize (fun addr ->
    calculateBalance addr allTransactions)
```

## Integration Examples

### Export to CSV

```fsharp
open System.IO

let exportToCsv filename (data: (Address * bigint) list) =
    use writer = new StreamWriter(filename)
    writer.WriteLine("Address,Volume")

    data |> List.iter (fun (Address addr, volume) ->
        writer.WriteLine($"{addr},{volume}"))
```

### REST API

```fsharp
// Using Giraffe web framework
open Giraffe

let analyticsApi =
    choose [
        GET >=> route "/api/metrics" >=> fun next ctx ->
            let metrics = analyzeTransactions loadedTransactions
            json metrics next ctx

        GET >=> routef "/api/address/%s/balance" (fun addr next ctx ->
            let address = Address addr
            let balance = calculateBalance address loadedTransactions
            json balance next ctx)
    ]
```

## Testing

```fsharp
// Create test file: tests/AnalyticsTests.fs
module AnalyticsTests

open Xunit
open BlockchainAnalyzer.Types
open BlockchainAnalyzer.Analytics

[<Fact>]
let ``analyzeTransactions calculates correct count`` () =
    let txs = [
        { Hash = TxHash "0x1"; (* ... *) }
        { Hash = TxHash "0x2"; (* ... *) }
    ]

    let metrics = analyzeTransactions txs

    Assert.Equal(2, metrics.TotalCount)

// Run tests
// dotnet test
```

## Real-World Use Cases

1. **DeFi Analytics**: Analyze DEX trading patterns
2. **Fraud Detection**: Identify suspicious transaction patterns
3. **Token Analysis**: Track token transfer patterns
4. **MEV Research**: Detect MEV strategies
5. **Network Health**: Monitor blockchain performance
6. **Whale Tracking**: Track large holders' activities

## Comparison with Other Languages

### vs Python
- **Performance**: 10-50x faster
- **Type Safety**: Compile-time vs runtime errors
- **Conciseness**: Similar readability
- **Tooling**: Visual Studio, Rider vs Jupyter

### vs R
- **General Purpose**: Full application development vs statistics-focused
- **Performance**: Much faster
- **Integration**: Better web/API integration
- **Learning Curve**: Gentler for programmers

### vs JavaScript
- **Type Safety**: Strong static typing vs dynamic
- **Performance**: 5-20x faster
- **Immutability**: Built-in vs libraries
- **Math Operations**: Better bigint support

## Resources

- [F# Official Docs](https://fsharp.org/)
- [F# for Fun and Profit](https://fsharpforfunandprofit.com/)
- [FSharp.Data](https://fsprojects.github.io/FSharp.Data/)
- [Plotly.NET](https://plotly.net/)
- [F# Software Foundation](https://fsharp.org/)

## Production Deployment

### Docker

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY . .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:8.0
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "BlockchainAnalyzer.dll"]
```

### Azure Functions

```fsharp
open Microsoft.Azure.Functions.Worker

[<Function("AnalyzeBlock")>]
let run ([<QueueTrigger("blocks")>] blockData: string) =
    // Process blockchain data
    let block = parseBlock blockData
    let metrics = analyzeTransactions block.Transactions
    metrics
```

## License

MIT License - see root LICENSE file

## Related Examples

- `examples/python/` - Similar analytics, different paradigm
- `examples/haskell/` - Pure functional approach
- `examples/typescript/` - JavaScript ecosystem

---

Built with 📊 for the WhisperChain Multi-Language Web3 Platform
