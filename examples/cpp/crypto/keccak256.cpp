/**
 * Keccak-256 Hash Implementation
 * Used in Ethereum for address generation and signing
 */

#include "keccak256.h"
#include <cstring>
#include <iomanip>
#include <sstream>

namespace whisper {
namespace crypto {

// Keccak round constants
static const uint64_t RC[24] = {
    0x0000000000000001ULL, 0x0000000000008082ULL, 0x800000000000808aULL,
    0x8000000080008000ULL, 0x000000000000808bULL, 0x0000000080000001ULL,
    0x8000000080008081ULL, 0x8000000000008009ULL, 0x000000000000008aULL,
    0x0000000000000088ULL, 0x0000000080008009ULL, 0x000000008000000aULL,
    0x000000008000808bULL, 0x800000000000008bULL, 0x8000000000008089ULL,
    0x8000000000008003ULL, 0x8000000000008002ULL, 0x8000000000000080ULL,
    0x000000000000800aULL, 0x800000008000000aULL, 0x8000000080008081ULL,
    0x8000000000008080ULL, 0x0000000080000001ULL, 0x8000000080008008ULL
};

Keccak256::Keccak256() {
    reset();
}

void Keccak256::reset() {
    std::memset(state, 0, sizeof(state));
    std::memset(buffer, 0, sizeof(buffer));
    bufferSize = 0;
}

void Keccak256::update(const uint8_t* data, size_t length) {
    for (size_t i = 0; i < length; ++i) {
        buffer[bufferSize++] = data[i];

        if (bufferSize == RATE_BYTES) {
            absorb();
            bufferSize = 0;
        }
    }
}

void Keccak256::finalize(uint8_t* hash) {
    // Padding
    buffer[bufferSize++] = 0x01;

    while (bufferSize < RATE_BYTES) {
        buffer[bufferSize++] = 0x00;
    }

    buffer[RATE_BYTES - 1] |= 0x80;

    absorb();

    // Squeeze
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 8; ++j) {
            hash[i * 8 + j] = (state[i] >> (j * 8)) & 0xFF;
        }
    }
}

std::string Keccak256::hash(const std::string& input) {
    Keccak256 hasher;
    hasher.update(reinterpret_cast<const uint8_t*>(input.c_str()), input.length());

    uint8_t hash[32];
    hasher.finalize(hash);

    return bytesToHex(hash, 32);
}

void Keccak256::absorb() {
    // XOR input into state
    for (size_t i = 0; i < RATE_BYTES / 8; ++i) {
        uint64_t value = 0;
        for (int j = 0; j < 8; ++j) {
            value |= static_cast<uint64_t>(buffer[i * 8 + j]) << (j * 8);
        }
        state[i] ^= value;
    }

    keccakF();
}

void Keccak256::keccakF() {
    // Keccak-f[1600] permutation (simplified version for demonstration)
    for (int round = 0; round < 24; ++round) {
        // Theta
        uint64_t C[5], D[5];
        for (int x = 0; x < 5; ++x) {
            C[x] = state[x] ^ state[x + 5] ^ state[x + 10] ^ state[x + 15] ^ state[x + 20];
        }

        for (int x = 0; x < 5; ++x) {
            D[x] = C[(x + 4) % 5] ^ rotateLeft(C[(x + 1) % 5], 1);
        }

        for (int x = 0; x < 5; ++x) {
            for (int y = 0; y < 5; ++y) {
                state[x + 5 * y] ^= D[x];
            }
        }

        // Rho and Pi (simplified)
        uint64_t temp[25];
        std::memcpy(temp, state, sizeof(state));

        for (int x = 0; x < 5; ++x) {
            for (int y = 0; y < 5; ++y) {
                int newX = y;
                int newY = (2 * x + 3 * y) % 5;
                state[newX + 5 * newY] = rotateLeft(temp[x + 5 * y], ((x + 3 * y) * (x + 3 * y + 1) / 2) % 64);
            }
        }

        // Chi
        std::memcpy(temp, state, sizeof(state));
        for (int y = 0; y < 5; ++y) {
            for (int x = 0; x < 5; ++x) {
                state[x + 5 * y] = temp[x + 5 * y] ^ ((~temp[(x + 1) % 5 + 5 * y]) & temp[(x + 2) % 5 + 5 * y]);
            }
        }

        // Iota
        state[0] ^= RC[round];
    }
}

uint64_t Keccak256::rotateLeft(uint64_t value, int shift) {
    return (value << shift) | (value >> (64 - shift));
}

std::string Keccak256::bytesToHex(const uint8_t* bytes, size_t length) {
    std::ostringstream oss;
    oss << std::hex << std::setfill('0');

    for (size_t i = 0; i < length; ++i) {
        oss << std::setw(2) << static_cast<int>(bytes[i]);
    }

    return oss.str();
}

} // namespace crypto
} // namespace whisper
