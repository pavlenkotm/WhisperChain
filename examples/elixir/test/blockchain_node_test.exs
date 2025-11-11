defmodule BlockchainNodeTest do
  use ExUnit.Case
  doctest BlockchainNode

  setup do
    # Start fresh blockchain for each test
    {:ok, _pid} = start_supervised(BlockchainNode)
    :ok
  end

  test "genesis block is created on initialization" do
    chain = BlockchainNode.get_chain()
    assert length(chain) == 1

    genesis = List.first(chain)
    assert genesis.index == 0
    assert genesis.previous_hash == "0"
    assert genesis.transactions == []
  end

  test "can add transactions" do
    {:ok, tx} = BlockchainNode.add_transaction("Alice", "Bob", 100.0)

    assert tx.from == "Alice"
    assert tx.to == "Bob"
    assert tx.amount == 100.0

    pending = BlockchainNode.get_pending_transactions()
    assert length(pending) == 1
  end

  test "can mine blocks" do
    BlockchainNode.add_transaction("Alice", "Bob", 50.0)
    BlockchainNode.add_transaction("Bob", "Charlie", 25.0)

    {:ok, block} = BlockchainNode.mine_block("Miner1")

    assert block.index == 1
    assert length(block.transactions) == 3  # 2 transactions + 1 mining reward

    chain = BlockchainNode.get_chain()
    assert length(chain) == 2
  end

  test "validates blockchain correctly" do
    BlockchainNode.add_transaction("Alice", "Bob", 100.0)
    BlockchainNode.mine_block("Miner1")

    assert BlockchainNode.validate_chain() == true
  end

  test "calculates balance correctly" do
    # Mine initial block to give Miner1 some coins
    BlockchainNode.mine_block("Miner1")

    # Miner1 should have mining reward
    balance = BlockchainNode.get_balance("Miner1")
    assert balance == 50.0

    # Add transaction and mine
    BlockchainNode.add_transaction("Miner1", "Alice", 30.0)
    BlockchainNode.mine_block("Miner2")

    # Check balances
    assert BlockchainNode.get_balance("Miner1") == 20.0
    assert BlockchainNode.get_balance("Alice") == 30.0
    assert BlockchainNode.get_balance("Miner2") == 50.0
  end

  test "proof of work produces valid hash" do
    BlockchainNode.add_transaction("Alice", "Bob", 10.0)
    {:ok, block} = BlockchainNode.mine_block("Miner1")

    # Hash should start with difficulty zeros
    assert String.starts_with?(block.hash, "0000")
  end

  test "pending transactions are cleared after mining" do
    BlockchainNode.add_transaction("Alice", "Bob", 10.0)
    BlockchainNode.add_transaction("Bob", "Charlie", 5.0)

    assert length(BlockchainNode.get_pending_transactions()) == 2

    BlockchainNode.mine_block("Miner1")

    assert length(BlockchainNode.get_pending_transactions()) == 0
  end
end
