# Security Architecture

## Overview

WhisperChain implements end-to-end encryption using industry-standard cryptographic primitives. This document explains the security architecture and guarantees.

## Cryptographic Design

### 1. Key Exchange: Elliptic Curve Diffie-Hellman (ECDH)

**Algorithm**: Curve25519 (via elliptic.js)

**Process**:
1. Each participant generates a keypair (private key, public key)
2. Public keys are exchanged via the blockchain
3. Both parties independently derive the same shared secret
4. Shared secret is used for symmetric encryption

**Security Properties**:
- ✅ Forward secrecy: Ephemeral keys for each message
- ✅ Post-quantum resistant: No (Curve25519 is not PQC)
- ✅ Key size: 256 bits
- ✅ Computationally infeasible to derive private key from public key

### 2. Message Encryption: AES-256-GCM

**Algorithm**: AES-256 in Galois/Counter Mode

**Parameters**:
- Key size: 256 bits (derived from ECDH shared secret)
- IV size: 128 bits (random, unique per message)
- Authentication tag: 128 bits

**Security Properties**:
- ✅ Confidentiality: Messages cannot be read without the key
- ✅ Authenticity: Messages cannot be tampered with
- ✅ Integrity: Any modification will be detected
- ✅ Resistance to known attacks (timing, padding oracle, etc.)

### 3. Ephemeral Keys

**For each message**:
- New ephemeral keypair is generated
- Provides forward secrecy
- Compromise of long-term keys doesn't reveal past messages

**Flow**:
```
Alice → Bob:
1. Alice generates ephemeral keypair (ePriv, ePub)
2. Alice derives shared secret: ePriv × Bob's static public key
3. Alice encrypts message with AES-256-GCM using shared secret
4. Alice sends: {ePub, ciphertext, IV}

Bob receives:
1. Bob derives same shared secret: Bob's private key × ePub
2. Bob decrypts ciphertext using AES-256-GCM
3. Bob verifies authentication tag
```

## Privacy Guarantees

### What is Private

✅ **Message Content**: Encrypted before transmission, decrypted only by recipient

✅ **Private Keys**: Never leave your browser, never transmitted

✅ **Shared Secrets**: Computed locally, never stored on-chain

✅ **Local Storage**: Encryption keys stored in browser (consider additional encryption)

### What is Public (On-Chain)

⚠️ **Public Keys**: Visible on Solana blockchain

⚠️ **Encrypted Payloads**: Ciphertext is publicly visible (but encrypted)

⚠️ **Message Metadata**: Timestamps, message count, participant addresses

⚠️ **Transaction Signatures**: Who sent transactions

⚠️ **Message Timing**: When messages were sent

## Threat Model

### Protected Against

✅ **Passive Eavesdropping**: Attacker can see encrypted traffic but cannot decrypt

✅ **Server Compromise**: No server to compromise (fully decentralized)

✅ **Man-in-the-Middle**: Blockchain ensures public key authenticity

✅ **Message Tampering**: GCM mode provides authentication

✅ **Replay Attacks**: Message indices prevent replays

### Not Protected Against

❌ **Endpoint Compromise**: If your device is hacked, keys can be stolen

❌ **Traffic Analysis**: Metadata (timing, participants) is public

❌ **Quantum Computers**: Curve25519 not quantum-resistant (future risk)

❌ **Browser Vulnerabilities**: Local storage can be accessed by malicious extensions

❌ **Social Engineering**: Users can be tricked into revealing keys

## Security Best Practices

### For Users

1. **Use a Hardware Wallet**: Store your Solana private key securely
2. **Verify Recipient**: Confirm public key out-of-band
3. **Use Self-Destruct**: Enable auto-deletion for sensitive messages
4. **Clear Local Storage**: Delete keys when done chatting
5. **Use Incognito Mode**: For extra-sensitive conversations
6. **Keep Browser Updated**: Latest security patches
7. **Disable Extensions**: Malicious extensions can steal keys
8. **Don't Screenshot**: Avoid leaving traces

### For Developers

1. **Audit Dependencies**: Regular security audits of npm packages
2. **Use CSP Headers**: Content Security Policy in production
3. **Implement SRI**: Subresource Integrity for CDN resources
4. **Rate Limiting**: Prevent spam and DoS
5. **Input Validation**: Sanitize all user inputs
6. **Secure RNG**: Use cryptographically secure random number generator
7. **Memory Wiping**: Clear sensitive data from memory after use
8. **Error Handling**: Don't leak sensitive info in errors

## Known Limitations

### 1. Metadata Leakage

**Issue**: Message timing and participant addresses are public on blockchain

**Mitigation**:
- Use mixing services for addresses
- Add random delays between messages
- Use disposable wallets

### 2. Local Storage Security

**Issue**: Private keys stored in browser localStorage (unencrypted)

**Mitigation**:
- Implement password-based encryption for stored keys
- Use browser's IndexedDB with encryption
- Integrate with hardware security modules

### 3. No Forward Secrecy for Long-Term Keys

**Issue**: Compromise of static keys allows decryption of future messages

**Mitigation**:
- Already implemented: Ephemeral keys per message
- Recommend: Regular key rotation

### 4. Solana Validator Trust

**Issue**: Must trust Solana validators for transaction ordering

**Mitigation**:
- Solana's consensus mechanism (Proof of History + PoS)
- Transaction signatures prevent tampering
- Decentralized validator set

## Cryptographic Audit Checklist

- [ ] Independent security audit of cryptographic implementation
- [ ] Formal verification of key exchange protocol
- [ ] Penetration testing of frontend application
- [ ] Review of random number generation
- [ ] Analysis of side-channel attacks
- [ ] Verification of constant-time operations
- [ ] Review of key storage mechanisms
- [ ] Testing of edge cases and error handling

## Incident Response

### If You Suspect a Security Issue

1. **Do NOT** publicly disclose
2. Email: security@whisperchain.xyz (Coming soon)
3. Include: Detailed description, steps to reproduce, impact
4. Wait for response before disclosure
5. Responsible disclosure: 90-day window

### If Keys Are Compromised

1. **Immediately** delete the chat
2. Generate new keypair
3. Notify your chat partner out-of-band
4. Create new chat with new keys
5. Revoke compromised wallet if possible

## Future Enhancements

### Post-Quantum Cryptography
- Implement hybrid encryption (classical + PQC)
- Use Kyber for key exchange
- Use SPHINCS+ for signatures

### Advanced Privacy Features
- Implement onion routing for metadata privacy
- Use zero-knowledge proofs for sender anonymity
- Add noise traffic to obscure message patterns

### Enhanced Key Management
- Hardware security module integration
- Multi-party computation for key generation
- Threshold encryption for group chats

## References

- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Signal Protocol](https://signal.org/docs/)
- [Double Ratchet Algorithm](https://signal.org/docs/specifications/doubleratchet/)
- [Curve25519](https://cr.yp.to/ecdh.html)
- [AES-GCM](https://csrc.nist.gov/publications/detail/sp/800-38d/final)

## Disclaimer

WhisperChain is experimental software. While we implement industry-standard cryptography, no system is perfectly secure. Use at your own risk and always verify the security properties match your threat model.

**Do not use for:**
- Life-threatening communications
- Financial transactions without additional verification
- Situations where discovery could cause serious harm

**Always:**
- Keep software updated
- Use strong wallet security
- Verify recipient identities
- Consider your threat model

---

Last updated: 2025-11-06
Security version: 1.0
