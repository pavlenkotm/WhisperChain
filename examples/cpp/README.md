# ⚡ C++ Cryptographic Utilities

High-performance C++ implementations of cryptographic algorithms used in blockchain applications.

## 📋 Features

### 1. Keccak-256
- **Files**: `crypto/keccak256.{h,cpp}`
- **Features**:
  - ✅ Full Keccak-256 implementation
  - ✅ Used in Ethereum address generation
  - ✅ Transaction hashing
  - ✅ Message signing
  - ✅ Optimized for performance

### 2. SECP256k1 Wrapper
- **Files**: `crypto/secp256k1_wrapper.{h,cpp}`
- **Features**:
  - ✅ Key pair generation
  - ✅ Public key derivation
  - ✅ ECDSA signing
  - ✅ Signature verification
  - ✅ Public key recovery
  - ✅ Compatible with Ethereum

## 🚀 Quick Start

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt-get install build-essential cmake

# macOS
brew install cmake

# Check versions
g++ --version  # or clang++ --version
cmake --version
```

### Build
```bash
cd examples/cpp

# Create build directory
mkdir build && cd build

# Configure
cmake ..

# Build
make

# Or use ninja
cmake -G Ninja ..
ninja
```

### Run Example
```bash
./crypto_example
```

## 📖 Usage Examples

### Keccak-256 Hashing
```cpp
#include "crypto/keccak256.h"
#include <iostream>

int main() {
    using namespace whisper::crypto;

    // Hash a string
    std::string input = "Hello, Ethereum!";
    std::string hash = Keccak256::hash(input);

    std::cout << "Input: " << input << std::endl;
    std::cout << "Keccak-256: 0x" << hash << std::endl;

    // Incremental hashing
    Keccak256 hasher;
    hasher.update(reinterpret_cast<const uint8_t*>(input.c_str()), input.length());

    uint8_t result[32];
    hasher.finalize(result);

    return 0;
}
```

### Key Generation
```cpp
#include "crypto/secp256k1_wrapper.h"
#include <iostream>

int main() {
    using namespace whisper::crypto;

    SECP256k1Wrapper crypto;

    // Generate new key pair
    KeyPair keyPair = crypto.generateKeyPair();

    std::cout << "Private Key: 0x"
              << SECP256k1Wrapper::bytesToHex(keyPair.privateKey, 32)
              << std::endl;

    std::cout << "Public Key: 0x"
              << SECP256k1Wrapper::bytesToHex(keyPair.publicKey, 64)
              << std::endl;

    return 0;
}
```

### Message Signing
```cpp
#include "crypto/keccak256.h"
#include "crypto/secp256k1_wrapper.h"

int main() {
    using namespace whisper::crypto;

    SECP256k1Wrapper crypto;
    KeyPair keyPair = crypto.generateKeyPair();

    // Create message hash
    std::string message = "Sign this message";
    Keccak256 hasher;
    hasher.update(reinterpret_cast<const uint8_t*>(message.c_str()), message.length());

    uint8_t messageHash[32];
    hasher.finalize(messageHash);

    // Sign
    uint8_t signature[64];
    uint8_t recoveryId;

    crypto.sign(keyPair.privateKey, messageHash, signature, &recoveryId);

    std::cout << "Signature: 0x"
              << SECP256k1Wrapper::bytesToHex(signature, 64)
              << std::endl;
    std::cout << "Recovery ID: " << static_cast<int>(recoveryId) << std::endl;

    // Verify
    bool valid = crypto.verify(keyPair.publicKey, messageHash, signature);
    std::cout << "Valid: " << (valid ? "true" : "false") << std::endl;

    return 0;
}
```

### Public Key Recovery
```cpp
#include "crypto/secp256k1_wrapper.h"

int main() {
    using namespace whisper::crypto;

    SECP256k1Wrapper crypto;

    uint8_t messageHash[32] = {/* ... */};
    uint8_t signature[64] = {/* ... */};
    uint8_t recoveryId = 0;

    uint8_t recoveredPublicKey[64];

    bool success = crypto.recoverPublicKey(
        messageHash,
        signature,
        recoveryId,
        recoveredPublicKey
    );

    if (success) {
        std::cout << "Recovered Public Key: 0x"
                  << SECP256k1Wrapper::bytesToHex(recoveredPublicKey, 64)
                  << std::endl;
    }

    return 0;
}
```

## 🧪 Testing

### Build Tests
```bash
cd build
cmake -DBUILD_TESTS=ON ..
make

# Run tests
ctest --verbose

# Or run directly
./tests/crypto_tests
```

### Example Test
```cpp
#include <cassert>
#include "crypto/keccak256.h"

void testKeccak256() {
    using namespace whisper::crypto;

    // Test vector
    std::string input = "hello";
    std::string expected = "1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8";

    std::string result = Keccak256::hash(input);

    assert(result == expected);
}
```

## 🔧 Integration with Production Code

### Using with libsecp256k1
```bash
# Install libsecp256k1
git clone https://github.com/bitcoin-core/secp256k1.git
cd secp256k1
./autogen.sh
./configure
make
sudo make install
```

```cmake
# CMakeLists.txt
find_package(secp256k1 REQUIRED)
target_link_libraries(whisper_crypto PRIVATE secp256k1)
```

## 📊 Performance

### Benchmarks
```cpp
#include <chrono>

void benchmarkKeccak256() {
    using namespace whisper::crypto;
    using namespace std::chrono;

    const int iterations = 100000;
    std::string data = "benchmark data";

    auto start = high_resolution_clock::now();

    for (int i = 0; i < iterations; ++i) {
        Keccak256::hash(data);
    }

    auto end = high_resolution_clock::now();
    auto duration = duration_cast<microseconds>(end - start).count();

    std::cout << "Hashes per second: "
              << (iterations * 1000000.0 / duration)
              << std::endl;
}
```

Expected performance (on modern CPU):
- Keccak-256: ~500,000 hashes/sec
- SECP256k1 signing: ~10,000 ops/sec
- SECP256k1 verification: ~5,000 ops/sec

## 🔐 Security Considerations

1. **Use Production Libraries**: Replace demo implementations with:
   - [libsecp256k1](https://github.com/bitcoin-core/secp256k1)
   - [tiny-keccak](https://github.com/debris/tiny-keccak) (for embedded)

2. **Secure Memory**:
   ```cpp
   // Zero sensitive data
   std::memset(privateKey, 0, sizeof(privateKey));

   // Use secure allocators
   std::vector<uint8_t, SecureAllocator<uint8_t>> key;
   ```

3. **Constant-Time Operations**: Prevent timing attacks
4. **Hardware RNG**: Use OS crypto RNG for key generation

## 📚 Resources

- [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
- [libsecp256k1](https://github.com/bitcoin-core/secp256k1)
- [Keccak Specification](https://keccak.team/keccak.html)
- [SECP256k1](https://en.bitcoin.it/wiki/Secp256k1)

## 🤝 Contributing

Contributions welcome! Please ensure:
- Code follows C++17 standards
- All tests pass
- Performance benchmarks included
- Memory safety verified
- Constant-time operations where applicable

## 📄 License

MIT License - see LICENSE file for details
