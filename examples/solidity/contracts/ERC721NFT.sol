// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WhisperNFT
 * @dev ERC-721 NFT collection for WhisperChain identity and avatars
 * Features: Minting, Burning, URI storage, Ownership
 */
contract WhisperNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.01 ether;

    event NFTMinted(address indexed to, uint256 indexed tokenId, string uri);
    event MintPriceUpdated(uint256 oldPrice, uint256 newPrice);

    constructor(address initialOwner)
        ERC721("WhisperNFT", "WNFT")
        Ownable(initialOwner)
    {
        _tokenIdCounter = 1; // Start from token ID 1
    }

    /**
     * @dev Mint a new NFT
     * @param to Address to receive the NFT
     * @param uri Metadata URI for the NFT
     */
    function mint(address to, string memory uri) public payable {
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit NFTMinted(to, tokenId, uri);
    }

    /**
     * @dev Mint NFT for free (owner only)
     * @param to Address to receive the NFT
     * @param uri Metadata URI for the NFT
     */
    function ownerMint(address to, string memory uri) public onlyOwner {
        require(_tokenIdCounter <= MAX_SUPPLY, "Max supply reached");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit NFTMinted(to, tokenId, uri);
    }

    /**
     * @dev Update mint price (owner only)
     * @param newPrice New mint price in wei
     */
    function setMintPrice(uint256 newPrice) public onlyOwner {
        uint256 oldPrice = mintPrice;
        mintPrice = newPrice;
        emit MintPriceUpdated(oldPrice, newPrice);
    }

    /**
     * @dev Withdraw contract balance (owner only)
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

    /**
     * @dev Get total number of minted NFTs
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter - 1;
    }

    // Required overrides
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
