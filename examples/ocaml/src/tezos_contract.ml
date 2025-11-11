(** Tezos Smart Contract in OCaml (Michelson generator)

    This module demonstrates OCaml's strengths for blockchain development:
    - Type safety with algebraic data types
    - Pattern matching for complex contract logic
    - Functional programming for immutable state
    - Strong type inference

    OCaml is the language of Tezos blockchain!
**)

(** Contract types *)
type address = Address of string

type tez = Tez of int64

type timestamp = Timestamp of int64

(** Token types *)
type token_id = TokenId of int

type token_metadata = {
  token_id : token_id;
  name : string;
  symbol : string;
  decimals : int;
}

(** FA2 (NFT/Token) standard types *)
type transfer_destination = {
  to_ : address;
  token_id : token_id;
  amount : int64;
}

type transfer = {
  from_ : address;
  txs : transfer_destination list;
}

(** Contract storage *)
type storage = {
  admin : address;
  ledger : (address * token_id, int64) Hashtbl.t;
  operators : (address * address * token_id, unit) Hashtbl.t;
  metadata : (token_id, token_metadata) Hashtbl.t;
  total_supply : (token_id, int64) Hashtbl.t;
  paused : bool;
}

(** Contract operations *)
type parameter =
  | Transfer of transfer list
  | Balance_of of (address * token_id) list * ((address * token_id * int64) list -> unit)
  | Update_operators of update_operator list
  | Mint of address * token_id * int64 * token_metadata
  | Burn of address * token_id * int64
  | Pause
  | Unpause
  | Set_admin of address

and update_operator =
  | Add_operator of address * address * token_id
  | Remove_operator of address * address * token_id

(** Operation result *)
type operation =
  | Transaction of address * tez * string
  | Origination of string

type contract_result = operation list * storage

(** Helper functions *)
let get_balance storage owner token_id =
  match Hashtbl.find_opt storage.ledger (owner, token_id) with
  | Some balance -> balance
  | None -> 0L

let set_balance storage owner token_id amount =
  if amount = 0L then
    Hashtbl.remove storage.ledger (owner, token_id)
  else
    Hashtbl.replace storage.ledger (owner, token_id) amount

let is_operator storage owner operator token_id =
  Hashtbl.mem storage.operators (owner, operator, token_id)

let check_admin storage sender =
  if sender <> storage.admin then
    failwith "Not authorized: only admin can perform this action"

(** Contract entrypoints *)
let transfer storage sender (transfers : transfer list) =
  if storage.paused then
    failwith "Contract is paused";

  let process_transfer storage transfer =
    let process_destination storage from_ dest =
      (* Check authorization *)
      if from_ <> sender && not (is_operator storage from_ sender dest.token_id) then
        failwith "Not authorized to transfer";

      (* Check balance *)
      let from_balance = get_balance storage from_ dest.token_id in
      if from_balance < dest.amount then
        failwith "Insufficient balance";

      (* Update balances *)
      set_balance storage from_ dest.token_id (Int64.sub from_balance dest.amount);

      let to_balance = get_balance storage dest.to_ dest.token_id in
      set_balance storage dest.to_ dest.token_id (Int64.add to_balance dest.amount);

      storage
    in

    List.fold_left (fun acc_storage dest ->
      process_destination acc_storage transfer.from_ dest
    ) storage transfer.txs
  in

  let new_storage = List.fold_left process_transfer storage transfers in
  ([], new_storage)

let balance_of storage (queries : (address * token_id) list) callback =
  let responses = List.map (fun (owner, token_id) ->
    let balance = get_balance storage owner token_id in
    (owner, token_id, balance)
  ) queries in

  callback responses;
  ([], storage)

let update_operators storage sender (updates : update_operator list) =
  let process_update storage update =
    match update with
    | Add_operator (owner, operator, token_id) ->
        if owner <> sender then
          failwith "Not authorized: only owner can add operators";
        Hashtbl.replace storage.operators (owner, operator, token_id) ();
        storage
    | Remove_operator (owner, operator, token_id) ->
        if owner <> sender then
          failwith "Not authorized: only owner can remove operators";
        Hashtbl.remove storage.operators (owner, operator, token_id);
        storage
  in

  let new_storage = List.fold_left process_update storage updates in
  ([], new_storage)

let mint storage sender to_ token_id amount metadata =
  check_admin storage sender;

  if storage.paused then
    failwith "Contract is paused";

  (* Add metadata if new token *)
  if not (Hashtbl.mem storage.metadata token_id) then
    Hashtbl.replace storage.metadata token_id metadata;

  (* Update balance *)
  let current_balance = get_balance storage to_ token_id in
  set_balance storage to_ token_id (Int64.add current_balance amount);

  (* Update total supply *)
  let current_supply = match Hashtbl.find_opt storage.total_supply token_id with
    | Some supply -> supply
    | None -> 0L
  in
  Hashtbl.replace storage.total_supply token_id (Int64.add current_supply amount);

  ([], storage)

let burn storage sender from_ token_id amount =
  if storage.paused then
    failwith "Contract is paused";

  (* Check authorization *)
  if from_ <> sender && not (is_operator storage from_ sender token_id) then
    failwith "Not authorized to burn";

  (* Check balance *)
  let current_balance = get_balance storage from_ token_id in
  if current_balance < amount then
    failwith "Insufficient balance to burn";

  (* Update balance *)
  set_balance storage from_ token_id (Int64.sub current_balance amount);

  (* Update total supply *)
  let current_supply = Hashtbl.find storage.total_supply token_id in
  Hashtbl.replace storage.total_supply token_id (Int64.sub current_supply amount);

  ([], storage)

let pause storage sender =
  check_admin storage sender;

  if storage.paused then
    failwith "Already paused";

  ({ storage with paused = true }, [])

let unpause storage sender =
  check_admin storage sender;

  if not storage.paused then
    failwith "Not paused";

  ({ storage with paused = false }, [])

let set_admin storage sender new_admin =
  check_admin storage sender;
  ({ storage with admin = new_admin }, [])

(** Main contract entry point *)
let main (parameter : parameter) (storage : storage) (sender : address) : contract_result =
  match parameter with
  | Transfer transfers -> transfer storage sender transfers
  | Balance_of (queries, callback) -> balance_of storage queries callback
  | Update_operators updates -> update_operators storage sender updates
  | Mint (to_, token_id, amount, metadata) -> mint storage sender to_ token_id amount metadata
  | Burn (from_, token_id, amount) -> burn storage sender from_ token_id amount
  | Pause -> pause storage sender
  | Unpause -> unpause storage sender
  | Set_admin new_admin -> set_admin storage sender new_admin

(** Example usage and testing *)
let () =
  print_endline "🐫 Tezos Smart Contract in OCaml";
  print_endline "════════════════════════════════════════════════════════════";
  print_endline "";

  (* Initialize storage *)
  let admin = Address "tz1Admin123" in
  let storage = {
    admin = admin;
    ledger = Hashtbl.create 10;
    operators = Hashtbl.create 10;
    metadata = Hashtbl.create 10;
    total_supply = Hashtbl.create 10;
    paused = false;
  } in

  print_endline "✅ Contract initialized";
  Printf.printf "   Admin: %s\n" (match admin with Address a -> a);
  print_endline "";

  (* Mint tokens *)
  print_endline "💰 Minting tokens...";
  let user1 = Address "tz1User1" in
  let token_id = TokenId 1 in
  let metadata = {
    token_id = token_id;
    name = "WhisperChain Token";
    symbol = "WCT";
    decimals = 18;
  } in

  let (ops, storage) = mint storage admin user1 token_id 1000L metadata in
  let balance = get_balance storage user1 token_id in
  Printf.printf "   Minted %Ld tokens to %s\n" balance (match user1 with Address a -> a);
  print_endline "";

  (* Transfer tokens *)
  print_endline "🔄 Transferring tokens...";
  let user2 = Address "tz1User2" in
  let transfer = {
    from_ = user1;
    txs = [{ to_ = user2; token_id = token_id; amount = 250L }]
  } in

  let (ops, storage) = transfer storage user1 [transfer] in
  let balance1 = get_balance storage user1 token_id in
  let balance2 = get_balance storage user2 token_id in

  Printf.printf "   User1 balance: %Ld tokens\n" balance1;
  Printf.printf "   User2 balance: %Ld tokens\n" balance2;
  print_endline "";

  (* Check total supply *)
  let total_supply = Hashtbl.find storage.total_supply token_id in
  Printf.printf "📊 Total supply: %Ld tokens\n" total_supply;
  print_endline "";

  print_endline "✅ OCaml smart contract demonstration complete!";
  print_endline "";
  print_endline "💡 OCaml Features Demonstrated:";
  print_endline "   • Type safety with ADTs";
  print_endline "   • Pattern matching";
  print_endline "   • Immutable-first design";
  print_endline "   • First-class functions";
  print_endline "   • Strong type inference"
