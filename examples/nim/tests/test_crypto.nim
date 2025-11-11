import unittest
import ../src/crypto_primitives

suite "Cryptographic Primitives Tests":
  test "Keccak-256 hashing":
    let data = "test"
    let hash = keccak256(data)
    check hash.len == 32

    # Test determinism
    let hash2 = keccak256(data)
    check hash == hash2

  test "SHA-256 hashing":
    let data = "test"
    let hash = sha256(data)
    check hash.len == 32

    # SHA-256 should be different from Keccak-256
    let keccakHash = keccak256(data)
    check hash != keccakHash

  test "Double SHA-256":
    let data = "test"
    let hash = doubleSha256(data)
    check hash.len == 32

    # Should equal SHA256(SHA256(data))
    let expected = sha256(sha256(data))
    check hash == expected

  test "HMAC-SHA256":
    let key = "secret"
    let data = "message"
    let mac = hmacSha256(
      key.toOpenArrayByte(0, key.high),
      data.toOpenArrayByte(0, data.high)
    )
    check mac.len == 32

  test "Key derivation (PBKDF2)":
    let password = "password123"
    let salt = "salt"
    let key = deriveKey(password, salt, 1000)
    check key.len == 32

    # Same password + salt = same key
    let key2 = deriveKey(password, salt, 1000)
    check key == key2

    # Different salt = different key
    let key3 = deriveKey(password, "different_salt", 1000)
    check key != key3

  test "Key pair generation":
    let keyPair = generateKeyPair()
    check keyPair.privateKey.len == 32
    check keyPair.publicKey.len == 64
    check keyPair.address.len == 20

    # Each generation should be unique
    let keyPair2 = generateKeyPair()
    check keyPair.privateKey != keyPair2.privateKey

  test "Public key to address":
    var publicKey: array[64, byte]
    for i in 0..<64:
      publicKey[i] = byte(i)

    let address = publicKeyToAddress(publicKey)
    check address.len == 20

  test "Message signing":
    let keyPair = generateKeyPair()
    let message = "Hello, Web3!"

    let signature = signMessage(message, keyPair.privateKey)
    check signature.r.len == 32
    check signature.s.len == 32
    check signature.v in [27'u8, 28'u8]

  test "Signature verification":
    let keyPair = generateKeyPair()
    let message = "Test message"

    let signature = signMessage(message, keyPair.privateKey)
    let isValid = verifySignature(message, signature, keyPair.address)

    check isValid == true

  test "Merkle tree construction":
    let data = @["a", "b", "c", "d"]
    let tree = buildMerkleTree(data)

    check tree.leaves.len == 4
    check tree.root.len == 32

  test "Merkle tree with single leaf":
    let data = @["single"]
    let tree = buildMerkleTree(data)

    check tree.leaves.len == 1
    check tree.root == tree.leaves[0]

  test "Merkle proof generation":
    let data = @["a", "b", "c", "d"]
    let tree = buildMerkleTree(data)

    let proof = generateMerkleProof(tree, 1)
    check proof.len > 0

  test "Merkle proof verification":
    let data = @["tx1", "tx2", "tx3", "tx4"]
    let tree = buildMerkleTree(data)

    for i in 0..<data.len:
      let proof = generateMerkleProof(tree, i)
      let isValid = verifyMerkleProof(tree.leaves[i], proof, tree.root)
      check isValid == true

  test "Hex encoding/decoding":
    let original = [byte(0xDE), byte(0xAD), byte(0xBE), byte(0xEF)]
    let hex = toHex(original)
    check hex == "0xdeadbeef"

    let decoded = fromHex(hex)
    check decoded == @original

  test "Hex decoding without 0x prefix":
    let hex = "deadbeef"
    let decoded = fromHex(hex)
    check decoded == @[byte(0xDE), byte(0xAD), byte(0xBE), byte(0xEF)]
