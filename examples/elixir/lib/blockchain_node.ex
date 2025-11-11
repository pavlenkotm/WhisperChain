defmodule BlockchainNode do
  @moduledoc """
  A decentralized blockchain node implementation in Elixir.

  This module demonstrates Elixir's strengths in building distributed,
  fault-tolerant systems - perfect for blockchain applications.

  Features:
  - Block creation and validation
  - Proof of Work consensus
  - Transaction management
  - P2P communication (simulated)
  - State management with GenServer
  """

  use GenServer
  require Logger

  @difficulty 4
  @mining_reward 50

  defmodule Block do
    @moduledoc "Represents a block in the blockchain"

    defstruct [
      :index,
      :timestamp,
      :transactions,
      :proof,
      :previous_hash,
      :hash
    ]

    @type t :: %__MODULE__{
      index: non_neg_integer(),
      timestamp: integer(),
      transactions: list(map()),
      proof: non_neg_integer(),
      previous_hash: String.t(),
      hash: String.t()
    }
  end

  defmodule Transaction do
    @moduledoc "Represents a transaction"

    defstruct [:from, :to, :amount, :timestamp, :signature]

    @type t :: %__MODULE__{
      from: String.t(),
      to: String.t(),
      amount: float(),
      timestamp: integer(),
      signature: String.t() | nil
    }
  end

  # Client API

  @doc "Starts the blockchain node"
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @doc "Gets the current blockchain"
  def get_chain do
    GenServer.call(__MODULE__, :get_chain)
  end

  @doc "Gets pending transactions"
  def get_pending_transactions do
    GenServer.call(__MODULE__, :get_pending_transactions)
  end

  @doc "Adds a new transaction"
  def add_transaction(from, to, amount) do
    GenServer.call(__MODULE__, {:add_transaction, from, to, amount})
  end

  @doc "Mines a new block"
  def mine_block(miner_address) do
    GenServer.call(__MODULE__, {:mine_block, miner_address}, :infinity)
  end

  @doc "Validates the blockchain"
  def validate_chain do
    GenServer.call(__MODULE__, :validate_chain)
  end

  @doc "Gets balance for an address"
  def get_balance(address) do
    GenServer.call(__MODULE__, {:get_balance, address})
  end

  # Server Callbacks

  @impl true
  def init(:ok) do
    genesis_block = create_genesis_block()

    state = %{
      chain: [genesis_block],
      pending_transactions: [],
      mining_reward: @mining_reward
    }

    Logger.info("Blockchain node initialized with genesis block")
    {:ok, state}
  end

  @impl true
  def handle_call(:get_chain, _from, state) do
    {:reply, state.chain, state}
  end

  @impl true
  def handle_call(:get_pending_transactions, _from, state) do
    {:reply, state.pending_transactions, state}
  end

  @impl true
  def handle_call({:add_transaction, from, to, amount}, _from, state) do
    transaction = %Transaction{
      from: from,
      to: to,
      amount: amount,
      timestamp: System.system_time(:second),
      signature: sign_transaction(from, to, amount)
    }

    new_state = %{state | pending_transactions: [transaction | state.pending_transactions]}

    Logger.info("Added transaction: #{from} -> #{to}: #{amount}")
    {:reply, {:ok, transaction}, new_state}
  end

  @impl true
  def handle_call({:mine_block, miner_address}, _from, state) do
    last_block = List.first(state.chain)

    # Add mining reward transaction
    reward_tx = %Transaction{
      from: "NETWORK",
      to: miner_address,
      amount: state.mining_reward,
      timestamp: System.system_time(:second),
      signature: nil
    }

    transactions = [reward_tx | Enum.reverse(state.pending_transactions)]

    Logger.info("Mining block with #{length(transactions)} transactions...")

    new_block = %Block{
      index: last_block.index + 1,
      timestamp: System.system_time(:second),
      transactions: transactions,
      previous_hash: last_block.hash,
      proof: 0,
      hash: nil
    }

    # Proof of Work
    mined_block = mine_block_pow(new_block)

    new_state = %{
      state |
      chain: [mined_block | state.chain],
      pending_transactions: []
    }

    Logger.info("Block ##{mined_block.index} mined successfully! Hash: #{String.slice(mined_block.hash, 0, 16)}...")
    {:reply, {:ok, mined_block}, new_state}
  end

  @impl true
  def handle_call(:validate_chain, _from, state) do
    result = validate_blockchain(Enum.reverse(state.chain))
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_balance, address}, _from, state) do
    balance = calculate_balance(state.chain, address)
    {:reply, balance, state}
  end

  # Private Functions

  defp create_genesis_block do
    genesis = %Block{
      index: 0,
      timestamp: System.system_time(:second),
      transactions: [],
      previous_hash: "0",
      proof: 0,
      hash: nil
    }

    %{genesis | hash: calculate_hash(genesis)}
  end

  defp calculate_hash(block) do
    data = "#{block.index}#{block.timestamp}#{inspect(block.transactions)}#{block.previous_hash}#{block.proof}"

    :crypto.hash(:sha256, data)
    |> Base.encode16()
    |> String.downcase()
  end

  defp mine_block_pow(block) do
    target = String.duplicate("0", @difficulty)

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(block, fn nonce, acc ->
      candidate = %{acc | proof: nonce}
      hash = calculate_hash(candidate)

      if String.starts_with?(hash, target) do
        {:halt, %{candidate | hash: hash}}
      else
        {:cont, candidate}
      end
    end)
  end

  defp validate_blockchain([_genesis]), do: true

  defp validate_blockchain([current | [previous | _rest] = tail]) do
    cond do
      current.previous_hash != previous.hash ->
        Logger.error("Invalid previous hash at block #{current.index}")
        false

      calculate_hash(current) != current.hash ->
        Logger.error("Invalid hash at block #{current.index}")
        false

      not String.starts_with?(current.hash, String.duplicate("0", @difficulty)) ->
        Logger.error("Invalid proof of work at block #{current.index}")
        false

      true ->
        validate_blockchain(tail)
    end
  end

  defp calculate_balance(chain, address) do
    chain
    |> Enum.flat_map(& &1.transactions)
    |> Enum.reduce(0, fn tx, balance ->
      cond do
        tx.to == address -> balance + tx.amount
        tx.from == address -> balance - tx.amount
        true -> balance
      end
    end)
  end

  defp sign_transaction(from, to, amount) do
    # Simplified signing - in production use proper ECDSA
    data = "#{from}#{to}#{amount}"

    :crypto.hash(:sha256, data)
    |> Base.encode16()
    |> String.downcase()
  end
end
