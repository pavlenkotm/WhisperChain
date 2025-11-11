package wallet

import (
	"context"
	"crypto/ecdsa"
	"errors"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

// Wallet represents an Ethereum wallet
type Wallet struct {
	PrivateKey *ecdsa.PrivateKey
	PublicKey  *ecdsa.PublicKey
	Address    common.Address
	Client     *ethclient.Client
}

// NewWallet creates a new random wallet
func NewWallet(rpcURL string) (*Wallet, error) {
	privateKey, err := crypto.GenerateKey()
	if err != nil {
		return nil, err
	}

	return NewWalletFromPrivateKey(privateKey, rpcURL)
}

// NewWalletFromPrivateKey creates a wallet from existing private key
func NewWalletFromPrivateKey(privateKey *ecdsa.PrivateKey, rpcURL string) (*Wallet, error) {
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return nil, errors.New("error casting public key to ECDSA")
	}

	address := crypto.PubkeyToAddress(*publicKeyECDSA)

	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, err
	}

	return &Wallet{
		PrivateKey: privateKey,
		PublicKey:  publicKeyECDSA,
		Address:    address,
		Client:     client,
	}, nil
}

// GetBalance returns the ETH balance of the wallet
func (w *Wallet) GetBalance(ctx context.Context) (*big.Int, error) {
	return w.Client.BalanceAt(ctx, w.Address, nil)
}

// GetNonce returns the current nonce for the wallet
func (w *Wallet) GetNonce(ctx context.Context) (uint64, error) {
	return w.Client.PendingNonceAt(ctx, w.Address)
}

// Transfer sends ETH to another address
func (w *Wallet) Transfer(ctx context.Context, to common.Address, amount *big.Int) (*types.Transaction, error) {
	nonce, err := w.GetNonce(ctx)
	if err != nil {
		return nil, err
	}

	gasLimit := uint64(21000) // Standard ETH transfer
	gasPrice, err := w.Client.SuggestGasPrice(ctx)
	if err != nil {
		return nil, err
	}

	chainID, err := w.Client.NetworkID(ctx)
	if err != nil {
		return nil, err
	}

	tx := types.NewTransaction(nonce, to, amount, gasLimit, gasPrice, nil)

	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), w.PrivateKey)
	if err != nil {
		return nil, err
	}

	err = w.Client.SendTransaction(ctx, signedTx)
	if err != nil {
		return nil, err
	}

	return signedTx, nil
}

// SignMessage signs a message with the wallet's private key
func (w *Wallet) SignMessage(message []byte) ([]byte, error) {
	hash := crypto.Keccak256Hash(message)
	signature, err := crypto.Sign(hash.Bytes(), w.PrivateKey)
	if err != nil {
		return nil, err
	}
	return signature, nil
}

// VerifySignature verifies a message signature
func VerifySignature(message []byte, signature []byte, address common.Address) bool {
	hash := crypto.Keccak256Hash(message)

	// Ensure signature has correct length (65 bytes including recovery ID)
	if len(signature) != 65 {
		return false
	}

	// Recover public key from signature (requires full 65-byte signature)
	publicKey, err := crypto.SigToPub(hash.Bytes(), signature)
	if err != nil {
		return false
	}

	recoveredAddr := crypto.PubkeyToAddress(*publicKey)
	return recoveredAddr == address
}

// GetPrivateKeyHex returns the private key as hex string
func (w *Wallet) GetPrivateKeyHex() string {
	return "0x" + common.Bytes2Hex(crypto.FromECDSA(w.PrivateKey))
}

// WaitForTransaction waits for a transaction to be mined
func (w *Wallet) WaitForTransaction(ctx context.Context, txHash common.Hash) (*types.Receipt, error) {
	return w.Client.TransactionReceipt(ctx, txHash)
}
