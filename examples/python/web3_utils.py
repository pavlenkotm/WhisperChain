"""
Web3 Utilities for Ethereum Interaction
Provides helper functions for common Web3 operations
"""

from web3 import Web3
from eth_account import Account
from typing import Optional, Dict, Any
import json


class Web3Utils:
    """Utility class for Web3 operations"""

    def __init__(self, provider_url: str = "http://localhost:8545"):
        """
        Initialize Web3 connection

        Args:
            provider_url: RPC endpoint URL
        """
        self.w3 = Web3(Web3.HTTPProvider(provider_url))
        if not self.w3.is_connected():
            raise ConnectionError(f"Failed to connect to {provider_url}")

    def get_balance(self, address: str) -> float:
        """
        Get ETH balance of an address

        Args:
            address: Ethereum address

        Returns:
            Balance in ETH
        """
        checksum_address = Web3.to_checksum_address(address)
        balance_wei = self.w3.eth.get_balance(checksum_address)
        return self.w3.from_wei(balance_wei, 'ether')

    def send_transaction(
        self,
        from_private_key: str,
        to_address: str,
        value_eth: float,
        gas_price: Optional[int] = None
    ) -> str:
        """
        Send ETH transaction

        Args:
            from_private_key: Sender's private key
            to_address: Recipient address
            value_eth: Amount in ETH
            gas_price: Gas price in wei (optional)

        Returns:
            Transaction hash
        """
        account = Account.from_key(from_private_key)

        transaction = {
            'from': account.address,
            'to': Web3.to_checksum_address(to_address),
            'value': self.w3.to_wei(value_eth, 'ether'),
            'gas': 21000,
            'gasPrice': gas_price or self.w3.eth.gas_price,
            'nonce': self.w3.eth.get_transaction_count(account.address),
            'chainId': self.w3.eth.chain_id
        }

        signed_txn = self.w3.eth.account.sign_transaction(transaction, from_private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)

        return tx_hash.hex()

    def wait_for_transaction(self, tx_hash: str, timeout: int = 120) -> Dict[str, Any]:
        """
        Wait for transaction confirmation

        Args:
            tx_hash: Transaction hash
            timeout: Timeout in seconds

        Returns:
            Transaction receipt
        """
        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=timeout)
        return dict(receipt)

    def deploy_contract(
        self,
        abi: list,
        bytecode: str,
        from_private_key: str,
        constructor_args: tuple = ()
    ) -> tuple[str, Any]:
        """
        Deploy a smart contract

        Args:
            abi: Contract ABI
            bytecode: Contract bytecode
            from_private_key: Deployer's private key
            constructor_args: Constructor arguments

        Returns:
            Tuple of (contract_address, contract_instance)
        """
        account = Account.from_key(from_private_key)

        Contract = self.w3.eth.contract(abi=abi, bytecode=bytecode)

        transaction = Contract.constructor(*constructor_args).build_transaction({
            'from': account.address,
            'nonce': self.w3.eth.get_transaction_count(account.address),
            'gas': 3000000,
            'gasPrice': self.w3.eth.gas_price,
            'chainId': self.w3.eth.chain_id
        })

        signed_txn = self.w3.eth.account.sign_transaction(transaction, from_private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)

        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        contract_address = receipt['contractAddress']

        contract_instance = self.w3.eth.contract(
            address=contract_address,
            abi=abi
        )

        return contract_address, contract_instance

    def call_contract_function(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        *args
    ) -> Any:
        """
        Call a read-only contract function

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function to call
            *args: Function arguments

        Returns:
            Function return value
        """
        contract = self.w3.eth.contract(
            address=Web3.to_checksum_address(contract_address),
            abi=abi
        )

        function = getattr(contract.functions, function_name)
        return function(*args).call()

    def send_contract_transaction(
        self,
        contract_address: str,
        abi: list,
        function_name: str,
        from_private_key: str,
        *args,
        **kwargs
    ) -> str:
        """
        Send a transaction to a contract function

        Args:
            contract_address: Contract address
            abi: Contract ABI
            function_name: Function to call
            from_private_key: Sender's private key
            *args: Function arguments
            **kwargs: Transaction parameters (gas, gasPrice, value)

        Returns:
            Transaction hash
        """
        account = Account.from_key(from_private_key)
        contract = self.w3.eth.contract(
            address=Web3.to_checksum_address(contract_address),
            abi=abi
        )

        function = getattr(contract.functions, function_name)

        transaction = function(*args).build_transaction({
            'from': account.address,
            'nonce': self.w3.eth.get_transaction_count(account.address),
            'gas': kwargs.get('gas', 300000),
            'gasPrice': kwargs.get('gasPrice', self.w3.eth.gas_price),
            'chainId': self.w3.eth.chain_id,
            'value': kwargs.get('value', 0)
        })

        signed_txn = self.w3.eth.account.sign_transaction(transaction, from_private_key)
        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)

        return tx_hash.hex()

    def create_account(self) -> Dict[str, str]:
        """
        Create a new Ethereum account

        Returns:
            Dictionary with address and private_key
        """
        account = Account.create()
        return {
            'address': account.address,
            'private_key': account.key.hex()
        }

    def sign_message(self, message: str, private_key: str) -> str:
        """
        Sign a message with a private key

        Args:
            message: Message to sign
            private_key: Signer's private key

        Returns:
            Signature
        """
        account = Account.from_key(private_key)
        message_hash = self.w3.keccak(text=message)
        signed_message = account.signHash(message_hash)
        return signed_message.signature.hex()

    def verify_signature(
        self,
        message: str,
        signature: str,
        expected_address: str
    ) -> bool:
        """
        Verify a message signature

        Args:
            message: Original message
            signature: Message signature
            expected_address: Expected signer address

        Returns:
            True if signature is valid
        """
        message_hash = self.w3.keccak(text=message)
        recovered_address = Account.recover_message(
            message_hash,
            signature=bytes.fromhex(signature[2:] if signature.startswith('0x') else signature)
        )
        return recovered_address.lower() == expected_address.lower()


def main():
    """Example usage"""
    # Initialize
    utils = Web3Utils("http://localhost:8545")

    # Create new account
    account = utils.create_account()
    print(f"New account created: {account['address']}")

    # Check balance
    balance = utils.get_balance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
    print(f"Balance: {balance} ETH")


if __name__ == "__main__":
    main()
