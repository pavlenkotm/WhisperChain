#ifndef WHISPER_CRYPTO_KECCAK256_H
#define WHISPER_CRYPTO_KECCAK256_H

#include <cstdint>
#include <string>

namespace whisper {
namespace crypto {

/**
 * @brief Keccak-256 hash implementation
 *
 * Used in Ethereum for:
 * - Address generation
 * - Transaction hashing
 * - Message signing
 */
class Keccak256 {
public:
    static constexpr size_t HASH_SIZE = 32;
    static constexpr size_t STATE_SIZE = 25;
    static constexpr size_t RATE_BYTES = 136;

    Keccak256();

    /**
     * @brief Reset the hasher state
     */
    void reset();

    /**
     * @brief Update hash with new data
     * @param data Input data
     * @param length Data length
     */
    void update(const uint8_t* data, size_t length);

    /**
     * @brief Finalize and get the hash
     * @param hash Output buffer (32 bytes)
     */
    void finalize(uint8_t* hash);

    /**
     * @brief Compute hash of a string
     * @param input Input string
     * @return Hex-encoded hash
     */
    static std::string hash(const std::string& input);

private:
    uint64_t state[STATE_SIZE];
    uint8_t buffer[RATE_BYTES];
    size_t bufferSize;

    void absorb();
    void keccakF();
    uint64_t rotateLeft(uint64_t value, int shift);
    static std::string bytesToHex(const uint8_t* bytes, size_t length);
};

} // namespace crypto
} // namespace whisper

#endif // WHISPER_CRYPTO_KECCAK256_H
