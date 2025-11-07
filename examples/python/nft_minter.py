"""
NFT Minter Script
Automated NFT minting with metadata upload to IPFS
"""

import json
import os
from typing import Dict, List, Optional
from web3_utils import Web3Utils
from pathlib import Path


class NFTMinter:
    """NFT minting utility"""

    def __init__(
        self,
        provider_url: str,
        contract_address: str,
        contract_abi: list,
        private_key: str
    ):
        """
        Initialize NFT Minter

        Args:
            provider_url: RPC endpoint
            contract_address: NFT contract address
            contract_abi: Contract ABI
            private_key: Minter's private key
        """
        self.web3_utils = Web3Utils(provider_url)
        self.contract_address = contract_address
        self.contract_abi = contract_abi
        self.private_key = private_key

    def mint_nft(
        self,
        recipient: str,
        metadata_uri: str,
        mint_price_eth: float = 0
    ) -> str:
        """
        Mint a single NFT

        Args:
            recipient: Address to receive NFT
            metadata_uri: IPFS or HTTP URI for metadata
            mint_price_eth: Mint price in ETH

        Returns:
            Transaction hash
        """
        tx_hash = self.web3_utils.send_contract_transaction(
            self.contract_address,
            self.contract_abi,
            "mint",
            self.private_key,
            recipient,
            metadata_uri,
            value=self.web3_utils.w3.to_wei(mint_price_eth, 'ether')
        )

        print(f"NFT minted! Transaction: {tx_hash}")
        return tx_hash

    def batch_mint(
        self,
        recipients: List[str],
        metadata_uris: List[str],
        mint_price_eth: float = 0
    ) -> List[str]:
        """
        Mint multiple NFTs

        Args:
            recipients: List of recipient addresses
            metadata_uris: List of metadata URIs
            mint_price_eth: Mint price per NFT

        Returns:
            List of transaction hashes
        """
        if len(recipients) != len(metadata_uris):
            raise ValueError("Recipients and metadata URIs must have same length")

        tx_hashes = []
        for recipient, uri in zip(recipients, metadata_uris):
            tx_hash = self.mint_nft(recipient, uri, mint_price_eth)
            tx_hashes.append(tx_hash)

            # Wait for confirmation
            self.web3_utils.wait_for_transaction(tx_hash)
            print(f"✓ Minted to {recipient}")

        return tx_hashes

    def get_token_uri(self, token_id: int) -> str:
        """
        Get metadata URI for a token

        Args:
            token_id: Token ID

        Returns:
            Metadata URI
        """
        return self.web3_utils.call_contract_function(
            self.contract_address,
            self.contract_abi,
            "tokenURI",
            token_id
        )

    def get_total_supply(self) -> int:
        """
        Get total number of minted NFTs

        Returns:
            Total supply
        """
        return self.web3_utils.call_contract_function(
            self.contract_address,
            self.contract_abi,
            "totalSupply"
        )

    def get_owner(self, token_id: int) -> str:
        """
        Get owner of a token

        Args:
            token_id: Token ID

        Returns:
            Owner address
        """
        return self.web3_utils.call_contract_function(
            self.contract_address,
            self.contract_abi,
            "ownerOf",
            token_id
        )

    @staticmethod
    def create_metadata(
        name: str,
        description: str,
        image_url: str,
        attributes: Optional[List[Dict[str, str]]] = None
    ) -> Dict:
        """
        Create NFT metadata in standard format

        Args:
            name: NFT name
            description: NFT description
            image_url: Image URL (IPFS or HTTP)
            attributes: List of trait attributes

        Returns:
            Metadata dictionary
        """
        metadata = {
            "name": name,
            "description": description,
            "image": image_url,
        }

        if attributes:
            metadata["attributes"] = attributes

        return metadata

    @staticmethod
    def save_metadata(metadata: Dict, filename: str) -> str:
        """
        Save metadata to JSON file

        Args:
            metadata: Metadata dictionary
            filename: Output filename

        Returns:
            File path
        """
        filepath = Path(filename)
        filepath.parent.mkdir(parents=True, exist_ok=True)

        with open(filepath, 'w') as f:
            json.dump(metadata, f, indent=2)

        return str(filepath)


def example_usage():
    """Example minting workflow"""

    # Configuration
    PROVIDER_URL = "http://localhost:8545"
    CONTRACT_ADDRESS = "0x..."  # Your NFT contract address
    PRIVATE_KEY = "0x..."  # Your private key

    # Load contract ABI
    with open("contract_abi.json", "r") as f:
        CONTRACT_ABI = json.load(f)

    # Initialize minter
    minter = NFTMinter(
        PROVIDER_URL,
        CONTRACT_ADDRESS,
        CONTRACT_ABI,
        PRIVATE_KEY
    )

    # Create metadata
    metadata = NFTMinter.create_metadata(
        name="Whisper Avatar #1",
        description="Unique avatar for WhisperChain",
        image_url="ipfs://QmExample123...",
        attributes=[
            {"trait_type": "Background", "value": "Blue"},
            {"trait_type": "Expression", "value": "Happy"},
            {"trait_type": "Rarity", "value": "Rare"}
        ]
    )

    # Save metadata
    metadata_file = NFTMinter.save_metadata(metadata, "metadata/1.json")
    print(f"Metadata saved to {metadata_file}")

    # Upload to IPFS and get URI
    metadata_uri = "ipfs://QmMetadata..."  # After IPFS upload

    # Mint NFT
    recipient = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
    tx_hash = minter.mint_nft(recipient, metadata_uri, mint_price_eth=0.01)

    # Wait for confirmation
    receipt = minter.web3_utils.wait_for_transaction(tx_hash)
    print(f"NFT minted successfully! Block: {receipt['blockNumber']}")

    # Check total supply
    total_supply = minter.get_total_supply()
    print(f"Total NFTs minted: {total_supply}")


if __name__ == "__main__":
    example_usage()
