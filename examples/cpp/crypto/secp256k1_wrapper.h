#ifndef WHISPER_CRYPTO_SECP256K1_H
#define WHISPER_CRYPTO_SECP256K1_H

#include <cstdint>
#include <string>

namespace whisper {
namespace crypto {

/**
 * @brief Key pair for SECP256k1 elliptic curve
 */
struct KeyPair {
    uint8_t privateKey[32];
    uint8_t publicKey[64];
};

/**
 * @brief Wrapper for SECP256k1 cryptographic operations
 *
 * Used in Ethereum for:
 * - Key generation
 * - Message signing
 * - Signature verification
 * - Public key recovery
 */
class SECP256k1Wrapper {
public:
    SECP256k1Wrapper();
    ~SECP256k1Wrapper();

    /**
     * @brief Generate a new key pair
     * @return KeyPair with private and public keys
     */
    KeyPair generateKeyPair();

    /**
     * @brief Derive public key from private key
     * @param privateKey 32-byte private key
     * @param publicKey Output 64-byte public key
     * @return true on success
     */
    bool derivePublicKey(const uint8_t privateKey[32], uint8_t publicKey[64]);

    /**
     * @brief Sign a message hash
     * @param privateKey Signer's private key
     * @param messageHash 32-byte Keccak-256 hash
     * @param signature Output 64-byte signature
     * @param recoveryId Output recovery ID (0-3)
     * @return true on success
     */
    bool sign(
        const uint8_t privateKey[32],
        const uint8_t messageHash[32],
        uint8_t signature[64],
        uint8_t* recoveryId
    );

    /**
     * @brief Verify a signature
     * @param publicKey Signer's public key
     * @param messageHash Original message hash
     * @param signature 64-byte signature
     * @return true if valid
     */
    bool verify(
        const uint8_t publicKey[64],
        const uint8_t messageHash[32],
        const uint8_t signature[64]
    );

    /**
     * @brief Recover public key from signature
     * @param messageHash Original message hash
     * @param signature 64-byte signature
     * @param recoveryId Recovery ID (0-3)
     * @param publicKey Output 64-byte public key
     * @return true on success
     */
    bool recoverPublicKey(
        const uint8_t messageHash[32],
        const uint8_t signature[64],
        uint8_t recoveryId,
        uint8_t publicKey[64]
    );

    /**
     * @brief Convert bytes to hex string
     */
    static std::string bytesToHex(const uint8_t* bytes, size_t length);
};

} // namespace crypto
} // namespace whisper

#endif // WHISPER_CRYPTO_SECP256K1_H
