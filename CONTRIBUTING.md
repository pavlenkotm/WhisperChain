# Contributing to WhisperChain

First off, thank you for considering contributing to WhisperChain! It's people like you that make WhisperChain such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by a simple principle: **Be respectful, be professional, be constructive.**

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** if applicable
- **Environment**: OS, browser, wallet version
- **Logs**: Console errors, network errors

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful**
- **List potential implementation approaches**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes
4. Make sure your code follows the existing style
5. Write a convincing description of your PR

## Development Setup

### Prerequisites
- Rust 1.70+
- Solana CLI 1.18+
- Node.js 18+
- Git

### Setup
```bash
git clone https://github.com/yourusername/WhisperChain.git
cd WhisperChain

# Build Solana program
cd program
./build.sh

# Setup frontend
cd ../app
npm install
npm start
```

## Project Structure

```
WhisperChain/
├── program/           # Solana smart contract (Rust)
│   ├── src/
│   │   ├── lib.rs
│   │   ├── state.rs
│   │   ├── instruction.rs
│   │   └── processor.rs
│   └── tests/
│
└── app/              # React frontend
    ├── src/
    │   ├── components/
    │   ├── hooks/
    │   ├── utils/
    │   └── contexts/
    └── tests/
```

## Coding Standards

### Rust (Solana Program)

- Follow [Rust Style Guide](https://doc.rust-lang.org/nightly/style-guide/)
- Use `cargo fmt` before committing
- Run `cargo clippy` and fix warnings
- Add unit tests for new functions
- Document public APIs with `///` comments

```rust
/// Initializes a new chat between two participants
///
/// # Arguments
/// * `accounts` - Account slice containing payer, chat PDA, and system program
/// * `public_key` - DH public key for encryption
///
/// # Returns
/// * `ProgramResult` - Ok if successful
pub fn initialize_chat(...) -> ProgramResult {
    // Implementation
}
```

### TypeScript (Frontend)

- Follow TypeScript best practices
- Use functional components and hooks
- Keep components small and focused
- Add JSDoc comments for complex functions
- Use Tailwind CSS for styling

```typescript
/**
 * Encrypts a message using AES-256-GCM
 * @param message - Plain text message
 * @param sharedSecret - Shared secret from ECDH
 * @returns Encrypted message with IV
 */
export function encryptMessage(
  message: string,
  sharedSecret: Uint8Array
): { ciphertext: string; iv: string } {
  // Implementation
}
```

## Testing

### Solana Program Tests

```bash
cd program
cargo test
```

Add tests in `tests/` directory:

```rust
#[test]
fn test_initialize_chat() {
    // Test implementation
}
```

### Frontend Tests

```bash
cd app
npm test
```

Add tests alongside components:

```typescript
describe('ChatInterface', () => {
  it('should render messages', () => {
    // Test implementation
  });
});
```

## Git Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Code style (formatting, semicolons)
- **refactor**: Code refactoring
- **test**: Adding tests
- **chore**: Maintenance

### Examples

```
feat(chat): add group chat support

Implements multi-party encryption for group chats using
a hybrid approach with per-user message encryption.

Closes #123
```

```
fix(crypto): resolve IV reuse vulnerability

Ensures unique IV generation for each message to prevent
security issues with AES-GCM encryption.
```

## Security Contributions

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email: security@whisperchain.xyz
3. Include detailed steps to reproduce
4. Wait for acknowledgment before disclosure
5. Coordinate disclosure timeline (90 days recommended)

## Documentation

- Update README.md for significant changes
- Add inline code documentation
- Update DEPLOYMENT_GUIDE.md if deployment changes
- Create detailed technical docs in `/docs` folder

## Areas We Need Help

### High Priority
- [ ] Security audit of cryptographic implementation
- [ ] Mobile app development (React Native)
- [ ] Group chat implementation
- [ ] Performance optimization
- [ ] Comprehensive test coverage

### Medium Priority
- [ ] Browser extension
- [ ] NFT avatar integration
- [ ] File attachment support (IPFS)
- [ ] Voice/video calls
- [ ] Localization (i18n)

### Low Priority
- [ ] Theme customization
- [ ] Emoji reactions
- [ ] Read receipts
- [ ] Typing indicators
- [ ] Message search

## Questions?

Feel free to:
- Open an issue with the "question" label
- Join our Discord (coming soon)
- Email: hello@whisperchain.xyz

## Recognition

Contributors will be:
- Added to CONTRIBUTORS.md
- Mentioned in release notes
- Eligible for community rewards (TBD)

Thank you for contributing! 🙏
