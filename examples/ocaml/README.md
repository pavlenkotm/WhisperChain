# OCaml Tezos Smart Contract

Production-quality smart contract implementation demonstrating OCaml's strengths for blockchain development. OCaml is the implementation language of Tezos!

## Why OCaml for Blockchain?

OCaml is the language of choice for Tezos and formal verification:

- **Type Safety**: Prevent bugs at compile time
- **Formal Methods**: Mathematical proof of correctness
- **Performance**: Native compilation, fast execution
- **Pattern Matching**: Elegant smart contract logic
- **Functional**: Immutable data structures
- **Industry Proven**: Used in finance (Jane Street) and blockchain (Tezos)

## Features

- **FA2 Token Standard**: NFT and fungible tokens
- **Access Control**: Admin and operator patterns
- **Pausable**: Emergency stop mechanism
- **Minting/Burning**: Token lifecycle management
- **Type-Safe**: Compile-time guarantees

## Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get install opam

# macOS
brew install opam

# Initialize opam
opam init
eval $(opam env)

# Install OCaml
opam switch create 4.14.0
eval $(opam env)

# Install dune (build system)
opam install dune
```

## Installation

```bash
cd examples/ocaml

# Build
dune build

# Run
dune exec tezos_contract
```

## Usage

### Compile

```bash
dune build
# Binary at: _build/default/src/tezos_contract.exe
```

### Interactive REPL (utop)

```bash
opam install utop
utop

# Load module
#use "src/tezos_contract.ml";;

# Create contract
let admin = Address "tz1Admin";;
let storage = create_storage admin;;
```

## Smart Contract Operations

### Transfer

```ocaml
let transfer = {
  from_ = Address "tz1User1";
  txs = [{
    to_ = Address "tz1User2";
    token_id = TokenId 1;
    amount = 100L
  }]
}

let (ops, new_storage) = main (Transfer [transfer]) storage sender
```

### Mint

```ocaml
let metadata = {
  token_id = TokenId 1;
  name = "My Token";
  symbol = "MTK";
  decimals = 18
}

let (ops, new_storage) = main
  (Mint (Address "tz1User", TokenId 1, 1000L, metadata))
  storage
  admin
```

### Balance Query

```ocaml
let (ops, new_storage) = main
  (Balance_of ([(Address "tz1User", TokenId 1)], callback))
  storage
  sender
```

## Type System

### Algebraic Data Types

```ocaml
type parameter =
  | Transfer of transfer list
  | Mint of address * token_id * int64 * metadata
  | Burn of address * token_id * int64
  (* Compiler ensures exhaustive pattern matching! *)
```

### Pattern Matching

```ocaml
match parameter with
| Transfer transfers -> handle_transfer storage transfers
| Mint (to_, token_id, amount, metadata) ->
    if sender <> storage.admin then
      failwith "Not authorized"
    else
      mint_tokens storage to_ token_id amount metadata
```

## Testing

```bash
# Run tests
dune runtest

# With coverage
bisect-ppx-report html
```

## Deployment to Tezos

### Compile to Michelson

```ocaml
(* Use LIGO or SmartPy to generate Michelson *)

(* Or use Tezos OCaml libraries *)
open Tezos_protocol

let contract_code =
  compile_contract tezos_contract
```

### Deploy

```bash
# Using Tezos client
tezos-client originate contract MyToken \
  transferring 0 from alice \
  running contract.tz \
  --init '(Pair "tz1Admin" (Pair {} (Pair {} (Pair {} (Pair {} False)))))' \
  --burn-cap 1.0
```

## OCaml in Tezos Ecosystem

- **Tezos Protocol**: Written in OCaml
- **Formal Verification**: Coq (OCaml-based)
- **LIGO**: Transpiles to Michelson
- **Archetype**: High-level smart contract language

## Resources

- [OCaml Official Site](https://ocaml.org/)
- [Real World OCaml](https://dev.realworldocaml.org/)
- [Tezos Documentation](https://tezos.com/developers/)
- [LIGO Language](https://ligolang.org/)

## License

MIT License

---

Built with 🐫 for the WhisperChain Multi-Language Web3 Platform
