## High-Performance Cryptographic Primitives for Web3
##
## This module demonstrates Nim's strengths in building efficient,
## low-level cryptographic operations with Python-like syntax.
##
## Why Nim for Crypto?
## - C/C++ performance with Python-like readability
## - Compile-time evaluation for zero-cost abstractions
## - Memory safety with optional manual control
## - Metaprogramming for optimized code generation
## - Cross-platform with minimal dependencies

import std/[strutils, strformat, times, random, sequtils]
import nimcrypto
import nimcrypto/[hash, keccak, sha2, hmac, pbkdf2]

type
  KeyPair* = object
    ## ECDSA key pair for signing transactions
    privateKey*: array[32, byte]
    publicKey*: array[64, byte]
    address*: EthAddress

  EthAddress* = array[20, byte]

  Signature* = object
    ## ECDSA signature with recovery byte
    r*: array[32, byte]
    s*: array[32, byte]
    v*: byte

  HashDigest* = array[32, byte]

  CryptoError* = object of CatchableError

# ============================================================================
# Keccak-256 (Ethereum's hash function)
# ============================================================================

proc keccak256*(data: openArray[byte]): HashDigest =
  ## Compute Keccak-256 hash (used in Ethereum)
  var ctx: keccak256
  ctx.init()
  ctx.update(data)
  result = ctx.finish().data

proc keccak256*(data: string): HashDigest =
  ## Compute Keccak-256 hash of a string
  keccak256(data.toOpenArrayByte(0, data.high))

# ============================================================================
# SHA-256 (used in Bitcoin and other chains)
# ============================================================================

proc sha256*(data: openArray[byte]): HashDigest =
  ## Compute SHA-256 hash
  var ctx: sha256
  ctx.init()
  ctx.update(data)
  result = ctx.finish().data

proc sha256*(data: string): HashDigest =
  ## Compute SHA-256 hash of a string
  sha256(data.toOpenArrayByte(0, data.high))

proc doubleSha256*(data: openArray[byte]): HashDigest =
  ## Double SHA-256 (used in Bitcoin)
  sha256(sha256(data))

# ============================================================================
# HMAC (used in key derivation)
# ============================================================================

proc hmacSha256*(key: openArray[byte], data: openArray[byte]): HashDigest =
  ## Compute HMAC-SHA256
  var ctx: HMAC[sha256]
  ctx.init(key)
  ctx.update(data)
  result = ctx.finish().data

proc hmacSha512*(key: openArray[byte], data: openArray[byte]): array[64, byte] =
  ## Compute HMAC-SHA512
  var ctx: HMAC[sha512]
  ctx.init(key)
  ctx.update(data)
  result = ctx.finish().data

# ============================================================================
# PBKDF2 (Password-based key derivation)
# ============================================================================

proc deriveKey*(password: string, salt: string, iterations: int = 100_000): HashDigest =
  ## Derive cryptographic key from password using PBKDF2-SHA256
  var output: array[32, byte]
  discard pbkdf2(sha256, password, salt, iterations, output)
  result = output

# ============================================================================
# Ethereum Address Generation
# ============================================================================

proc publicKeyToAddress*(publicKey: openArray[byte]): EthAddress =
  ## Convert public key to Ethereum address
  ## Address = last 20 bytes of Keccak256(publicKey)
  if publicKey.len != 64:
    raise newException(CryptoError, "Public key must be 64 bytes")

  let hash = keccak256(publicKey)
  for i in 0..<20:
    result[i] = hash[i + 12]

proc generateKeyPair*(): KeyPair =
  ## Generate random ECDSA key pair
  ## Note: This is a simplified version. Use proper secp256k1 in production
  result.privateKey = cast[array[32, byte]](newSeq[byte](32))
  result.publicKey = cast[array[64, byte]](newSeq[byte](64))

  # Generate random private key
  var rng = initRand()
  for i in 0..<32:
    result.privateKey[i] = byte(rng.rand(255))

  # Derive public key (simplified - use proper secp256k1)
  let privHash = sha256(result.privateKey)
  for i in 0..<32:
    result.publicKey[i] = privHash[i]
  for i in 32..<64:
    result.publicKey[i] = privHash[i - 32]

  # Generate address
  result.address = publicKeyToAddress(result.publicKey)

# ============================================================================
# Message Signing (Ethereum style)
# ============================================================================

proc signMessage*(message: string, privateKey: array[32, byte]): Signature =
  ## Sign a message using Ethereum's personal_sign format
  ## Message format: "\x19Ethereum Signed Message:\n" + len(message) + message

  let prefix = "\x19Ethereum Signed Message:\n" & $message.len
  let fullMessage = prefix & message
  let messageHash = keccak256(fullMessage)

  # Simplified signing - use proper ECDSA in production
  let sigData = hmacSha256(privateKey, messageHash)

  result.r = cast[array[32, byte]](sigData)
  result.s = sha256(sigData)
  result.v = 27  # Recovery ID

proc verifySignature*(message: string, signature: Signature, address: EthAddress): bool =
  ## Verify a message signature
  ## Note: Simplified version - use proper ECDSA recovery in production
  let prefix = "\x19Ethereum Signed Message:\n" & $message.len
  let fullMessage = prefix & message
  let messageHash = keccak256(fullMessage)

  # In production, recover public key from signature and check address
  # For now, simplified verification
  return signature.v in [27'u8, 28'u8]

# ============================================================================
# Merkle Tree (for efficient data verification)
# ============================================================================

type
  MerkleTree* = object
    leaves*: seq[HashDigest]
    root*: HashDigest

proc buildMerkleTree*(data: seq[string]): MerkleTree =
  ## Build Merkle tree from data
  result.leaves = newSeq[HashDigest](data.len)

  # Hash all leaves
  for i, item in data:
    result.leaves[i] = keccak256(item)

  # Build tree bottom-up
  var level = result.leaves
  while level.len > 1:
    var nextLevel = newSeq[HashDigest]()

    for i in countup(0, level.len - 1, 2):
      if i + 1 < level.len:
        # Combine two nodes
        var combined: array[64, byte]
        for j in 0..<32:
          combined[j] = level[i][j]
          combined[j + 32] = level[i + 1][j]
        nextLevel.add(keccak256(combined))
      else:
        # Odd node, promote to next level
        nextLevel.add(level[i])

    level = nextLevel

  result.root = if level.len > 0: level[0] else: default(HashDigest)

proc generateMerkleProof*(tree: MerkleTree, index: int): seq[HashDigest] =
  ## Generate Merkle proof for a leaf at given index
  result = @[]

  if index < 0 or index >= tree.leaves.len:
    return

  var level = tree.leaves
  var currentIndex = index

  while level.len > 1:
    # Add sibling to proof
    if currentIndex mod 2 == 0:
      if currentIndex + 1 < level.len:
        result.add(level[currentIndex + 1])
    else:
      result.add(level[currentIndex - 1])

    # Move to parent level
    var nextLevel = newSeq[HashDigest]()
    for i in countup(0, level.len - 1, 2):
      if i + 1 < level.len:
        var combined: array[64, byte]
        for j in 0..<32:
          combined[j] = level[i][j]
          combined[j + 32] = level[i + 1][j]
        nextLevel.add(keccak256(combined))
      else:
        nextLevel.add(level[i])

    level = nextLevel
    currentIndex = currentIndex div 2

proc verifyMerkleProof*(leaf: HashDigest, proof: seq[HashDigest], root: HashDigest): bool =
  ## Verify Merkle proof
  var computedHash = leaf

  for proofElement in proof:
    var combined: array[64, byte]
    # Determine order (simplified - should use proper ordering)
    for i in 0..<32:
      combined[i] = computedHash[i]
      combined[i + 32] = proofElement[i]
    computedHash = keccak256(combined)

  return computedHash == root

# ============================================================================
# Utility Functions
# ============================================================================

proc toHex*(data: openArray[byte]): string =
  ## Convert bytes to hex string
  result = newStringOfCap(data.len * 2 + 2)
  result.add("0x")
  for b in data:
    result.add(toHex(b, 2))

proc fromHex*(hex: string): seq[byte] =
  ## Convert hex string to bytes
  var cleaned = hex
  if cleaned.startsWith("0x"):
    cleaned = cleaned[2..^1]

  result = newSeq[byte](cleaned.len div 2)
  for i in 0..<result.len:
    result[i] = byte(parseHexInt(cleaned[i*2..i*2+1]))

# ============================================================================
# Benchmarking
# ============================================================================

proc benchmark*() =
  ## Run performance benchmarks
  echo "🚀 Nim Cryptographic Primitives Benchmark"
  echo "=" .repeat(60)

  const iterations = 10_000
  let testData = "Hello, Web3! This is a test message for hashing."

  # Keccak-256 benchmark
  let start1 = cpuTime()
  for _ in 0..<iterations:
    discard keccak256(testData)
  let time1 = cpuTime() - start1
  echo &"Keccak-256:     {iterations} iterations in {time1:.3f}s ({iterations.float / time1:.0f} ops/sec)"

  # SHA-256 benchmark
  let start2 = cpuTime()
  for _ in 0..<iterations:
    discard sha256(testData)
  let time2 = cpuTime() - start2
  echo &"SHA-256:        {iterations} iterations in {time2:.3f}s ({iterations.float / time2:.0f} ops/sec)"

  # HMAC-SHA256 benchmark
  let key = "secret_key"
  let start3 = cpuTime()
  for _ in 0..<iterations:
    discard hmacSha256(key.toOpenArrayByte(0, key.high), testData.toOpenArrayByte(0, testData.high))
  let time3 = cpuTime() - start3
  echo &"HMAC-SHA256:    {iterations} iterations in {time3:.3f}s ({iterations.float / time3:.0f} ops/sec)"

  # Key generation benchmark
  let start4 = cpuTime()
  for _ in 0..<100:
    discard generateKeyPair()
  let time4 = cpuTime() - start4
  echo &"Key Generation: 100 iterations in {time4:.3f}s ({100.0 / time4:.0f} ops/sec)"

  # Merkle tree benchmark
  let merkleData = newSeq[string](1000).mapIt(&"data_{it}")
  let start5 = cpuTime()
  let tree = buildMerkleTree(merkleData)
  let time5 = cpuTime() - start5
  echo &"Merkle Tree:    1000 leaves built in {time5:.4f}s"

  echo "\n✅ Benchmarks completed!"

# ============================================================================
# Example Usage
# ============================================================================

when isMainModule:
  echo "💎 Nim Cryptographic Primitives for Web3"
  echo "=" .repeat(60)
  echo ""

  # Generate key pair
  echo "1. Generating key pair..."
  let keyPair = generateKeyPair()
  echo &"   Private Key: {toHex(keyPair.privateKey)}"
  echo &"   Public Key:  {toHex(keyPair.publicKey)}"
  echo &"   Address:     {toHex(keyPair.address)}"
  echo ""

  # Hash data
  echo "2. Hashing data..."
  let message = "Hello, Web3!"
  let hash = keccak256(message)
  echo &"   Message: {message}"
  echo &"   Keccak-256: {toHex(hash)}"
  echo ""

  # Sign message
  echo "3. Signing message..."
  let signature = signMessage(message, keyPair.privateKey)
  echo &"   Signature R: {toHex(signature.r)}"
  echo &"   Signature S: {toHex(signature.s)}"
  echo &"   Recovery V:  {signature.v}"
  echo ""

  # Verify signature
  echo "4. Verifying signature..."
  let isValid = verifySignature(message, signature, keyPair.address)
  echo &"   Valid: {isValid}"
  echo ""

  # Merkle tree
  echo "5. Building Merkle tree..."
  let data = @["tx1", "tx2", "tx3", "tx4"]
  let tree = buildMerkleTree(data)
  echo &"   Data: {data}"
  echo &"   Root: {toHex(tree.root)}"

  let proof = generateMerkleProof(tree, 1)
  echo &"   Proof for index 1: {proof.len} elements"
  let proofValid = verifyMerkleProof(tree.leaves[1], proof, tree.root)
  echo &"   Proof valid: {proofValid}"
  echo ""

  # Derive key from password
  echo "6. Deriving key from password..."
  let password = "my_secure_password"
  let salt = "random_salt_12345"
  let derivedKey = deriveKey(password, salt)
  echo &"   Password: {password}"
  echo &"   Salt: {salt}"
  echo &"   Derived Key: {toHex(derivedKey)}"
  echo ""

  # Run benchmarks
  echo "7. Running performance benchmarks..."
  benchmark()
