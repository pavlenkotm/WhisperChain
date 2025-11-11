require "spec"
require "../src/web3_client"

describe Web3::Address do
  it "creates address from hex string" do
    hex = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    address = Web3::Address.new(hex)
    address.to_s.should eq(hex)
  end

  it "creates address from bytes" do
    bytes = Bytes.new(20, 0)
    address = Web3::Address.new(bytes)
    address.bytes.should eq(bytes)
  end

  it "raises on invalid length" do
    expect_raises(ArgumentError) do
      Web3::Address.new(Bytes.new(19, 0))
    end
  end
end

describe Web3::Transaction do
  it "creates transaction with required fields" do
    to = Web3::Address.new(Bytes.new(20, 0))
    tx = Web3::Transaction.new(
      nonce: 0_u64,
      gas_price: BigInt.new(20_000_000_000),
      gas_limit: 21000_u64,
      to: to,
      value: BigInt.new(1_000_000_000_000_000_000),
      chain_id: 1_u64
    )

    tx.nonce.should eq(0)
    tx.gas_limit.should eq(21000)
    tx.to.should eq(to)
  end

  it "generates signing hash" do
    to = Web3::Address.new(Bytes.new(20, 0))
    tx = Web3::Transaction.new(
      nonce: 0_u64,
      gas_price: BigInt.new(20_000_000_000),
      gas_limit: 21000_u64,
      to: to,
      value: BigInt.new(1_000_000_000_000_000_000)
    )

    hash = tx.signing_hash
    hash.size.should eq(32)
  end
end

describe Web3::Wallet do
  it "generates random wallet" do
    wallet = Web3::Wallet.generate
    wallet.private_key.size.should eq(32)
    wallet.address.bytes.size.should eq(20)
  end

  it "creates wallet from private key" do
    private_key = Random::Secure.random_bytes(32)
    wallet = Web3::Wallet.new(private_key)
    wallet.private_key.should eq(private_key)
  end

  it "raises on invalid private key length" do
    expect_raises(ArgumentError) do
      Web3::Wallet.new(Bytes.new(31, 0))
    end
  end

  it "signs messages" do
    wallet = Web3::Wallet.generate
    message = "Hello, Web3!"
    signature = wallet.sign_message(message)
    signature.size.should eq(65)
  end

  it "signs transactions" do
    wallet = Web3::Wallet.generate
    to = Web3::Address.new(Bytes.new(20, 0))

    tx = Web3::Transaction.new(
      nonce: 0_u64,
      gas_price: BigInt.new(20_000_000_000),
      gas_limit: 21000_u64,
      to: to,
      value: BigInt.new(1_000_000_000_000_000_000)
    )

    signature = wallet.sign_transaction(tx)
    signature.size.should eq(65)
  end
end

describe Web3::Client do
  it "creates client with RPC URL" do
    client = Web3::Client.new("https://eth-mainnet.g.alchemy.com/v2/test")
    client.rpc_url.should eq("https://eth-mainnet.g.alchemy.com/v2/test")
  end

  # Note: These tests require a mock HTTP server in production
  # For now, they're placeholder tests
end

describe Web3::Contract do
  it "creates contract with address and ABI" do
    address = Web3::Address.new(Bytes.new(20, 0))
    abi = JSON.parse(%([{"name":"test","type":"function"}]))
    client = Web3::Client.new("http://localhost:8545")

    contract = Web3::Contract.new(address, abi, client)
    contract.address.should eq(address)
  end
end
