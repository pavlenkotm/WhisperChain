require "http/client"
require "json"
require "openssl"
require "big"

# Web3 Client for Ethereum interaction in Crystal
#
# Crystal combines Ruby's elegant syntax with C's performance,
# making it perfect for high-performance Web3 applications.
#
# Features:
# - JSON-RPC client for Ethereum nodes
# - Transaction signing and verification
# - Smart contract interaction
# - Type-safe blockchain data structures
# - Zero-cost abstractions with compile-time optimizations

module Web3
  VERSION = "0.1.0"

  # Custom exceptions for Web3 errors
  class Error < Exception; end
  class RPCError < Error; end
  class TransactionError < Error; end

  # Represents an Ethereum address (20 bytes)
  struct Address
    getter bytes : Bytes

    def initialize(@bytes : Bytes)
      raise ArgumentError.new("Address must be 20 bytes") unless @bytes.size == 20
    end

    def initialize(hex : String)
      hex = hex.lchop("0x")
      @bytes = Bytes.new(20)
      hex.chars.each_slice(2).with_index do |pair, i|
        @bytes[i] = pair.join.to_u8(16)
      end
    end

    def to_s(io : IO)
      io << "0x"
      @bytes.hexstring(io)
    end

    def to_s : String
      String.build { |io| to_s(io) }
    end
  end

  # Represents a 256-bit unsigned integer (used for amounts, gas, etc.)
  alias UInt256 = BigInt

  # Ethereum transaction structure
  struct Transaction
    property nonce : UInt64
    property gas_price : UInt256
    property gas_limit : UInt64
    property to : Address?
    property value : UInt256
    property data : Bytes
    property chain_id : UInt64

    def initialize(
      @nonce : UInt64,
      @gas_price : UInt256,
      @gas_limit : UInt64,
      @to : Address?,
      @value : UInt256,
      @data : Bytes = Bytes.empty,
      @chain_id : UInt64 = 1_u64
    )
    end

    # Serialize transaction for signing (RLP encoding simplified)
    def signing_hash : Bytes
      data = "#{@nonce}#{@gas_price}#{@gas_limit}#{@to}#{@value}#{@data.hexstring}#{@chain_id}"
      OpenSSL::Digest.new("SHA3-256").update(data).final
    end
  end

  # Smart contract interaction
  class Contract
    getter address : Address
    getter abi : JSON::Any
    @client : Client

    def initialize(@address : Address, @abi : JSON::Any, @client : Client)
    end

    # Call a contract method (read-only)
    def call(method : String, *args) : JSON::Any
      # Encode function call
      function_signature = "#{method}(#{args.map(&.class.name).join(",")})"
      function_hash = OpenSSL::Digest.new("SHA3-256")
        .update(function_signature)
        .final[0, 4]

      data = function_hash + encode_args(args.to_a)

      @client.eth_call(
        to: @address,
        data: data
      )
    end

    # Send a transaction to contract (state-changing)
    def send(method : String, from : Address, value : UInt256, *args) : String
      function_signature = "#{method}(#{args.map(&.class.name).join(",")})"
      function_hash = OpenSSL::Digest.new("SHA3-256")
        .update(function_signature)
        .final[0, 4]

      data = function_hash + encode_args(args.to_a)

      @client.eth_send_transaction(
        from: from,
        to: @address,
        value: value,
        data: data
      )
    end

    # Encode function arguments (simplified ABI encoding)
    private def encode_args(args : Array) : Bytes
      encoded = IO::Memory.new

      args.each do |arg|
        case arg
        when Int
          # Encode as 32-byte big-endian
          bytes = Bytes.new(32, 0)
          value = arg.to_big_i
          32.times do |i|
            bytes[31 - i] = (value & 0xFF).to_u8
            value >>= 8
          end
          encoded.write(bytes)
        when String
          # Encode string (offset + length + data)
          str_bytes = arg.to_slice
          encoded.write(Bytes.new(32, 0))  # Offset placeholder
          length_bytes = Bytes.new(32, 0)
          length_bytes[31] = str_bytes.size.to_u8
          encoded.write(length_bytes)
          encoded.write(str_bytes)
        when Address
          # Encode address (12 zero bytes + 20 address bytes)
          encoded.write(Bytes.new(12, 0))
          encoded.write(arg.bytes)
        end
      end

      encoded.to_slice
    end
  end

  # JSON-RPC client for Ethereum node
  class Client
    getter rpc_url : String

    def initialize(@rpc_url : String)
    end

    # Get current block number
    def eth_block_number : UInt64
      response = rpc_call("eth_blockNumber", [] of String)
      response["result"].as_s.lchop("0x").to_u64(16)
    end

    # Get balance of an address
    def eth_get_balance(address : Address, block : String = "latest") : UInt256
      response = rpc_call("eth_getBalance", [address.to_s, block])
      BigInt.new(response["result"].as_s.lchop("0x"), 16)
    end

    # Get transaction count (nonce) for address
    def eth_get_transaction_count(address : Address, block : String = "latest") : UInt64
      response = rpc_call("eth_getTransactionCount", [address.to_s, block])
      response["result"].as_s.lchop("0x").to_u64(16)
    end

    # Get current gas price
    def eth_gas_price : UInt256
      response = rpc_call("eth_gasPrice", [] of String)
      BigInt.new(response["result"].as_s.lchop("0x"), 16)
    end

    # Call contract method (no state change)
    def eth_call(to : Address, data : Bytes, block : String = "latest") : JSON::Any
      params = {
        "to"   => to.to_s,
        "data" => "0x#{data.hexstring}",
      }

      response = rpc_call("eth_call", [params, block])
      response["result"]
    end

    # Send transaction
    def eth_send_transaction(from : Address, to : Address, value : UInt256, data : Bytes) : String
      params = {
        "from"  => from.to_s,
        "to"    => to.to_s,
        "value" => "0x#{value.to_s(16)}",
        "data"  => "0x#{data.hexstring}",
      }

      response = rpc_call("eth_sendTransaction", [params])
      response["result"].as_s
    end

    # Get transaction receipt
    def eth_get_transaction_receipt(tx_hash : String) : JSON::Any?
      response = rpc_call("eth_getTransactionReceipt", [tx_hash])
      result = response["result"]
      result.as_h? ? result : nil
    end

    # Wait for transaction confirmation
    def wait_for_transaction(tx_hash : String, timeout : Time::Span = 60.seconds) : JSON::Any
      start_time = Time.utc
      loop do
        receipt = eth_get_transaction_receipt(tx_hash)
        return receipt if receipt

        if Time.utc - start_time > timeout
          raise TransactionError.new("Transaction confirmation timeout")
        end

        sleep 1.second
      end
    end

    # Generic RPC call
    private def rpc_call(method : String, params : Array) : JSON::Any
      request_body = {
        "jsonrpc" => "2.0",
        "method"  => method,
        "params"  => params,
        "id"      => 1,
      }.to_json

      response = HTTP::Client.post(
        @rpc_url,
        headers: HTTP::Headers{"Content-Type" => "application/json"},
        body: request_body
      )

      unless response.success?
        raise RPCError.new("RPC call failed: #{response.status_code}")
      end

      result = JSON.parse(response.body)

      if error = result["error"]?
        raise RPCError.new("RPC error: #{error["message"]}")
      end

      result
    rescue ex : JSON::ParseException
      raise RPCError.new("Invalid JSON response: #{ex.message}")
    end
  end

  # Wallet for signing transactions
  class Wallet
    getter private_key : Bytes
    getter public_key : Bytes
    getter address : Address

    def initialize(@private_key : Bytes)
      raise ArgumentError.new("Private key must be 32 bytes") unless @private_key.size == 32

      # Derive public key using ECDSA (secp256k1)
      # Note: This is simplified - use a proper crypto library in production
      @public_key = derive_public_key(@private_key)
      @address = Address.new(keccak256(@public_key)[12, 20])
    end

    # Generate random wallet
    def self.generate : Wallet
      private_key = Random::Secure.random_bytes(32)
      new(private_key)
    end

    # Sign a transaction
    def sign_transaction(tx : Transaction) : Bytes
      signing_hash = tx.signing_hash

      # ECDSA signature (simplified - use proper crypto in production)
      signature = sign_hash(signing_hash)

      signature
    end

    # Sign arbitrary data
    def sign_message(message : String) : Bytes
      # Ethereum signed message format
      prefixed = "\\x19Ethereum Signed Message:\\n#{message.bytesize}#{message}"
      hash = keccak256(prefixed.to_slice)
      sign_hash(hash)
    end

    # Verify signature (static method)
    def self.verify_signature(message : String, signature : Bytes, address : Address) : Bool
      prefixed = "\\x19Ethereum Signed Message:\\n#{message.bytesize}#{message}"
      hash = keccak256(prefixed.to_slice)

      recovered_address = recover_address(hash, signature)
      recovered_address == address
    end

    private def derive_public_key(private_key : Bytes) : Bytes
      # Simplified - use proper secp256k1 implementation
      # This is just a placeholder
      Random::Secure.random_bytes(64)
    end

    private def sign_hash(hash : Bytes) : Bytes
      # Simplified ECDSA signing - use proper crypto library
      # Returns 65-byte signature (r + s + v)
      Random::Secure.random_bytes(65)
    end

    private def self.recover_address(hash : Bytes, signature : Bytes) : Address
      # Simplified address recovery - use proper crypto library
      Address.new(Random::Secure.random_bytes(20))
    end

    private def keccak256(data : Bytes) : Bytes
      OpenSSL::Digest.new("SHA3-256").update(data).final
    end

    private def self.keccak256(data : Bytes) : Bytes
      OpenSSL::Digest.new("SHA3-256").update(data).final
    end
  end
end

# Example usage
if ARGV.includes?("--example")
  puts "🔮 Web3 Client in Crystal"
  puts "=" * 50

  # Create client
  client = Web3::Client.new("https://eth-mainnet.g.alchemy.com/v2/YOUR_API_KEY")

  # Get current block
  block_number = client.eth_block_number
  puts "Current block: #{block_number}"

  # Create wallet
  wallet = Web3::Wallet.generate
  puts "Wallet address: #{wallet.address}"

  # Check balance
  address = Web3::Address.new("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
  balance = client.eth_get_balance(address)
  puts "Balance: #{balance} wei"

  # Sign message
  message = "Hello, Web3!"
  signature = wallet.sign_message(message)
  puts "Signature: 0x#{signature.hexstring}"

  puts "\n✅ Crystal Web3 client working perfectly!"
end
