# Elixir Blockchain Node

A production-quality blockchain node implementation demonstrating Elixir's strengths in building distributed, fault-tolerant systems.

## Why Elixir for Blockchain?

Elixir is an excellent choice for blockchain development:

- **Fault Tolerance**: Built on the Erlang VM (BEAM), designed for 99.9999999% uptime
- **Concurrency**: Lightweight processes enable millions of concurrent operations
- **Distribution**: Native support for distributed computing across nodes
- **Hot Code Reloading**: Update code without stopping the system
- **Pattern Matching**: Elegant syntax for complex blockchain logic
- **OTP Framework**: Battle-tested abstractions for building robust applications

## Features

- **Proof of Work Consensus**: Configurable difficulty mining
- **Transaction Management**: Add, validate, and process transactions
- **Block Validation**: Cryptographic hash verification
- **Balance Tracking**: Calculate account balances across the chain
- **GenServer Architecture**: Fault-tolerant state management
- **Mining Rewards**: Automatic reward distribution to miners

## Architecture

```
BlockchainNode (GenServer)
├── State Management
│   ├── Chain (list of blocks)
│   ├── Pending Transactions
│   └── Mining Configuration
├── Block Module
│   ├── Index, Timestamp, Hash
│   ├── Transactions
│   └── Proof of Work
└── Transaction Module
    ├── From/To addresses
    ├── Amount
    └── Signature
```

## Prerequisites

- Elixir 1.14 or higher
- Erlang/OTP 25 or higher

Install Elixir:
```bash
# macOS
brew install elixir

# Ubuntu/Debian
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update
sudo apt-get install elixir

# Using asdf (recommended)
asdf plugin add elixir
asdf install elixir 1.15.7
```

## Installation

```bash
cd examples/elixir

# Install dependencies
mix deps.get

# Compile
mix compile
```

## Usage

### Interactive Shell (IEx)

```bash
iex -S mix
```

```elixir
# The blockchain node starts automatically

# View the genesis block
BlockchainNode.get_chain()

# Add transactions
BlockchainNode.add_transaction("Alice", "Bob", 100.0)
BlockchainNode.add_transaction("Bob", "Charlie", 50.0)

# View pending transactions
BlockchainNode.get_pending_transactions()

# Mine a block (includes mining reward)
{:ok, block} = BlockchainNode.mine_block("Miner1")

# Check balances
BlockchainNode.get_balance("Miner1")  # Should have mining reward
BlockchainNode.get_balance("Alice")   # Should be negative (sent funds)
BlockchainNode.get_balance("Bob")     # Should have received funds

# Validate the blockchain
BlockchainNode.validate_chain()  # Should return true

# View the full chain
BlockchainNode.get_chain() |> Enum.reverse()
```

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test
mix test test/blockchain_node_test.exs
```

### Example Session

```elixir
# Start IEx
iex -S mix

# Simulate mining scenario
iex(1)> BlockchainNode.add_transaction("Alice", "Bob", 25.0)
{:ok, %BlockchainNode.Transaction{...}}

iex(2)> BlockchainNode.add_transaction("Bob", "Charlie", 10.0)
{:ok, %BlockchainNode.Transaction{...}}

iex(3)> {:ok, block} = BlockchainNode.mine_block("Miner1")
{:ok, %BlockchainNode.Block{index: 1, ...}}

iex(4)> BlockchainNode.get_balance("Miner1")
50.0  # Mining reward

iex(5)> BlockchainNode.get_balance("Alice")
-25.0  # Sent 25 to Bob

iex(6)> BlockchainNode.get_balance("Bob")
15.0  # Received 25, sent 10
```

## Configuration

Adjust mining difficulty in `lib/blockchain_node.ex`:

```elixir
@difficulty 4  # Number of leading zeros required in block hash
@mining_reward 50  # Reward for mining a block
```

Higher difficulty = longer mining times, more secure network.

## Key Concepts

### GenServer

The blockchain node uses GenServer for:
- **State Management**: Maintains chain and pending transactions
- **Synchronous Operations**: Call-based API for consistent operations
- **Fault Tolerance**: Automatic restart on crashes (via Supervisor)

### Proof of Work

Mining finds a `proof` (nonce) such that the block hash starts with N zeros:

```elixir
# Example valid hash for difficulty 4:
"0000a3f8c9d2e1b4..."
```

The mining function uses Elixir's Stream for lazy evaluation:

```elixir
Stream.iterate(0, &(&1 + 1))
|> Enum.reduce_while(block, fn nonce, acc ->
  # Try nonce until valid hash found
end)
```

### Pattern Matching

Elixir's pattern matching simplifies blockchain validation:

```elixir
defp validate_blockchain([_genesis]), do: true

defp validate_blockchain([current | [previous | _] = tail]) do
  cond do
    current.previous_hash != previous.hash -> false
    calculate_hash(current) != current.hash -> false
    true -> validate_blockchain(tail)
  end
end
```

## Production Considerations

To use in production:

1. **Implement Proper Cryptography**:
   - Use ECDSA for transaction signatures
   - Integrate with `:crypto` or external libraries like `ex_crypto`

2. **Add P2P Networking**:
   - Use `libp2p` or Erlang distribution
   - Implement gossip protocol for block propagation

3. **Persistent Storage**:
   - Add Mnesia or PostgreSQL backend
   - Implement checkpoint system for large chains

4. **Consensus Improvements**:
   - Consider Proof of Stake alternatives
   - Add difficulty adjustment algorithm

5. **Monitoring**:
   - Integrate Telemetry for metrics
   - Add health check endpoints

## Performance

Elixir's concurrency model enables:

- **~1M processes** per node with minimal memory
- **Microsecond latency** for process communication
- **Horizontal scaling** via distributed Erlang
- **Soft real-time** guarantees for critical operations

Typical mining performance (difficulty 4):
- Average time: ~100ms (varies by CPU)
- Throughput: ~10 blocks/second

## Advanced Features

### Distributed Nodes

Connect multiple blockchain nodes:

```elixir
# Node 1
iex --sname node1 -S mix

# Node 2
iex --sname node2 -S mix
Node.connect(:"node1@hostname")

# Access node1's blockchain from node2
:rpc.call(:"node1@hostname", BlockchainNode, :get_chain, [])
```

### Hot Code Reloading

Update code without stopping the node:

```bash
# In IEx
recompile()
```

## Web3 Integration

Integrate with Ethereum/Solana:

```elixir
# Add to mix.exs
{:ethereumex, "~> 0.10.0"}  # Ethereum
{:solana, "~> 0.1.0"}       # Solana
```

## Resources

- [Elixir Official Guide](https://elixir-lang.org/getting-started/introduction.html)
- [Erlang VM (BEAM)](https://www.erlang.org/)
- [GenServer Documentation](https://hexdocs.pm/elixir/GenServer.html)
- [OTP Design Principles](https://www.erlang.org/doc/design_principles/des_princ.html)
- [Blockchain in Elixir Book](https://pragprog.com/titles/nlblockchain/)

## License

MIT License - see root LICENSE file

## Related Examples

- `examples/erlang/` - Distributed messaging with pure Erlang
- `examples/rust/` - High-performance blockchain consensus
- `examples/haskell/` - Functional smart contracts

---

Built with ❤️ for the WhisperChain Multi-Language Web3 Platform
