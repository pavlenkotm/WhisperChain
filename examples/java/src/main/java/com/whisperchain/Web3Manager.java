package com.whisperchain;

import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.gas.DefaultGasProvider;
import org.web3j.utils.Convert;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.concurrent.CompletableFuture;

/**
 * Web3 Manager for Ethereum Blockchain Interaction
 * Provides utilities for wallet operations and contract interactions
 */
public class Web3Manager {

    private final Web3j web3j;
    private final Credentials credentials;

    public Web3Manager(String rpcUrl, String privateKey) {
        this.web3j = Web3j.build(new HttpService(rpcUrl));
        this.credentials = Credentials.create(privateKey);
    }

    /**
     * Get ETH balance for an address
     */
    public CompletableFuture<BigDecimal> getBalance(String address) {
        return web3j.ethGetBalance(address, org.web3j.protocol.core.DefaultBlockParameterName.LATEST)
                .sendAsync()
                .thenApply(EthGetBalance::getBalance)
                .thenApply(balance -> Convert.fromWei(new BigDecimal(balance), Convert.Unit.ETHER));
    }

    /**
     * Get current gas price
     */
    public CompletableFuture<BigInteger> getGasPrice() {
        return web3j.ethGasPrice()
                .sendAsync()
                .thenApply(EthGasPrice::getGasPrice);
    }

    /**
     * Get block number
     */
    public CompletableFuture<BigInteger> getBlockNumber() {
        return web3j.ethBlockNumber()
                .sendAsync()
                .thenApply(EthBlockNumber::getBlockNumber);
    }

    /**
     * Get transaction receipt
     */
    public CompletableFuture<TransactionReceipt> getTransactionReceipt(String txHash) {
        return web3j.ethGetTransactionReceipt(txHash)
                .sendAsync()
                .thenApply(EthGetTransactionReceipt::getTransactionReceipt)
                .thenApply(optional -> optional.orElseThrow(() ->
                        new RuntimeException("Transaction not found: " + txHash)));
    }

    /**
     * Send ETH transaction
     */
    public CompletableFuture<String> sendTransaction(
            String toAddress,
            BigDecimal ethAmount
    ) throws Exception {

        BigInteger gasPrice = getGasPrice().get();
        BigInteger gasLimit = BigInteger.valueOf(21000);

        EthGetTransactionCount ethGetTransactionCount = web3j.ethGetTransactionCount(
                credentials.getAddress(),
                org.web3j.protocol.core.DefaultBlockParameterName.LATEST
        ).send();

        BigInteger nonce = ethGetTransactionCount.getTransactionCount();

        org.web3j.protocol.core.methods.request.Transaction transaction =
                org.web3j.protocol.core.methods.request.Transaction.createEtherTransaction(
                        credentials.getAddress(),
                        nonce,
                        gasPrice,
                        gasLimit,
                        toAddress,
                        Convert.toWei(ethAmount, Convert.Unit.ETHER).toBigInteger()
                );

        EthSendTransaction response = web3j.ethSendTransaction(transaction).send();

        if (response.hasError()) {
            throw new RuntimeException("Error sending transaction: " + response.getError().getMessage());
        }

        return CompletableFuture.completedFuture(response.getTransactionHash());
    }

    /**
     * Get wallet address
     */
    public String getAddress() {
        return credentials.getAddress();
    }

    /**
     * Close Web3j connection
     */
    public void shutdown() {
        web3j.shutdown();
    }
}
