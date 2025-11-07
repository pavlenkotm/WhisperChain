# ⚡ Zig WASM Cryptography

High-performance Keccak-256 implementation in Zig compiled to WebAssembly.

## Features
- Zero-cost abstractions
- Compile to WASM
- Memory-safe
- Extremely fast

## Build
```bash
zig build-lib keccak.zig -target wasm32-freestanding -dynamic -O ReleaseFast
```

## Use in JavaScript
```javascript
const wasm = await WebAssembly.instantiateStreaming(fetch('keccak.wasm'));
const hash = wasm.instance.exports.keccak256(dataPtr, dataLen);
```

## Resources
- [Zig Documentation](https://ziglang.org/documentation/)
- [WebAssembly](https://webassembly.org/)
