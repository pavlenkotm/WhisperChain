# Package
version       = "0.1.0"
author        = "WhisperChain Team"
description   = "High-performance cryptographic primitives for Web3"
license       = "MIT"
srcDir        = "src"
bin           = @["crypto_primitives"]

# Dependencies
requires "nim >= 2.0.0"
requires "nimcrypto >= 0.6.0"
requires "stew >= 0.1.0"
