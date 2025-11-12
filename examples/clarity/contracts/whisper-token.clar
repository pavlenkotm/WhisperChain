;; WhisperToken - SIP-010 Fungible Token for Stacks (Bitcoin L2)
;; Implements the SIP-010 standard for fungible tokens on Stacks

;; Token Trait Implementation
(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))

;; Token Configuration
(define-constant token-name "WhisperToken")
(define-constant token-symbol "WSPR")
(define-constant token-decimals u6)
(define-constant token-uri u"https://whisperchain.io/token")

;; Storage
(define-fungible-token whisper-token)
(define-data-var token-total-supply uint u0)

;; SIP-010 Functions

;; Transfer tokens from sender to recipient
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-token-owner)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (ft-transfer? whisper-token amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

;; Get token name
(define-read-only (get-name)
  (ok token-name)
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok token-symbol)
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok token-decimals)
)

;; Get balance of an account
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance whisper-token account))
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok (var-get token-total-supply))
)

;; Get token URI
(define-read-only (get-token-uri)
  (ok (some token-uri))
)

;; Custom Functions

;; Mint tokens (only contract owner)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (try! (ft-mint? whisper-token amount recipient))
    (var-set token-total-supply (+ (var-get token-total-supply) amount))
    (ok true)
  )
)

;; Burn tokens from sender
(define-public (burn (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (ft-get-balance whisper-token tx-sender) amount) err-insufficient-balance)
    (try! (ft-burn? whisper-token amount tx-sender))
    (var-set token-total-supply (- (var-get token-total-supply) amount))
    (ok true)
  )
)

;; Transfer from caller to recipient (convenience wrapper)
(define-public (transfer-tokens (amount uint) (recipient principal))
  (transfer amount tx-sender recipient none)
)

;; Get contract owner
(define-read-only (get-owner)
  (ok contract-owner)
)

;; Initialize the contract with an initial mint
(define-private (initialize)
  (begin
    (try! (ft-mint? whisper-token u1000000000000 contract-owner))
    (var-set token-total-supply u1000000000000)
    (ok true)
  )
)

;; Initialize on deployment
(initialize)
