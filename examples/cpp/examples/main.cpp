#include <iostream>
#include <string>
#include <vector>
#include <cstring>
#include "crypto/keccak256.h"
#include "crypto/secp256k1_wrapper.h"

int main() {
    std::cout << "WhisperChain Crypto Examples\n" << std::endl;

    // Keccak256 example
    std::string input = "Hello, WhisperChain!";
    std::cout << "Keccak256 example:\n";
    std::cout << "Input: " << input << std::endl;

    std::string hashHex = whisper::crypto::Keccak256::hash(input);
    std::cout << "Hash: " << hashHex << "\n" << std::endl;

    // SECP256k1 example
    std::cout << "SECP256k1 example:\n";

    whisper::crypto::SECP256k1Wrapper secp;

    // Generate a key pair
    auto keyPair = secp.generateKeyPair();

    std::cout << "Private key: " << whisper::crypto::SECP256k1Wrapper::bytesToHex(keyPair.privateKey, 32) << std::endl;
    std::cout << "Public key: " << whisper::crypto::SECP256k1Wrapper::bytesToHex(keyPair.publicKey, 64) << "\n" << std::endl;

    // Sign a message
    std::string message = "Sign this message";

    // Create Keccak256 instance and hash the message
    whisper::crypto::Keccak256 hasher;
    uint8_t messageHash[32];
    hasher.update(reinterpret_cast<const uint8_t*>(message.data()), message.size());
    hasher.finalize(messageHash);

    uint8_t signature[64];
    uint8_t recoveryId;
    bool signSuccess = secp.sign(keyPair.privateKey, messageHash, signature, &recoveryId);

    std::cout << "Message: " << message << std::endl;
    if (signSuccess) {
        std::cout << "Signature: " << whisper::crypto::SECP256k1Wrapper::bytesToHex(signature, 64) << std::endl;
        std::cout << "Recovery ID: " << static_cast<int>(recoveryId) << std::endl;

        // Verify signature
        bool isValid = secp.verify(keyPair.publicKey, messageHash, signature);
        std::cout << "Signature valid: " << (isValid ? "Yes" : "No") << std::endl;
    } else {
        std::cout << "Failed to sign message" << std::endl;
    }

    return 0;
}
