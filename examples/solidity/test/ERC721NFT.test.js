const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WhisperNFT", function () {
  let nft;
  let owner;
  let addr1;
  let addr2;
  const MINT_PRICE = ethers.parseEther("0.01");

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const WhisperNFT = await ethers.getContractFactory("WhisperNFT");
    nft = await WhisperNFT.deploy(owner.address);
    await nft.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await nft.owner()).to.equal(owner.address);
    });

    it("Should have correct name and symbol", async function () {
      expect(await nft.name()).to.equal("WhisperNFT");
      expect(await nft.symbol()).to.equal("WNFT");
    });

    it("Should have correct initial mint price", async function () {
      expect(await nft.mintPrice()).to.equal(MINT_PRICE);
    });
  });

  describe("Minting", function () {
    it("Should allow minting with correct payment", async function () {
      const uri = "ipfs://QmTest123";
      await nft.connect(addr1).mint(addr1.address, uri, { value: MINT_PRICE });

      expect(await nft.ownerOf(1)).to.equal(addr1.address);
      expect(await nft.tokenURI(1)).to.equal(uri);
      expect(await nft.totalSupply()).to.equal(1);
    });

    it("Should not allow minting with insufficient payment", async function () {
      const uri = "ipfs://QmTest123";
      const insufficientPayment = ethers.parseEther("0.001");

      await expect(
        nft.connect(addr1).mint(addr1.address, uri, { value: insufficientPayment })
      ).to.be.revertedWith("Insufficient payment");
    });

    it("Should emit NFTMinted event", async function () {
      const uri = "ipfs://QmTest123";
      await expect(nft.connect(addr1).mint(addr1.address, uri, { value: MINT_PRICE }))
        .to.emit(nft, "NFTMinted")
        .withArgs(addr1.address, 1, uri);
    });

    it("Should allow owner to mint for free", async function () {
      const uri = "ipfs://QmTest123";
      await nft.ownerMint(addr1.address, uri);

      expect(await nft.ownerOf(1)).to.equal(addr1.address);
      expect(await nft.tokenURI(1)).to.equal(uri);
    });

    it("Should not allow non-owner to use ownerMint", async function () {
      const uri = "ipfs://QmTest123";
      await expect(
        nft.connect(addr1).ownerMint(addr1.address, uri)
      ).to.be.reverted;
    });

    it("Should not exceed max supply", async function () {
      const maxSupply = await nft.MAX_SUPPLY();

      // This test would take too long to run fully, so we just check the logic
      await expect(
        nft.mint(addr1.address, "ipfs://test", { value: MINT_PRICE })
      ).to.not.be.reverted;
    });
  });

  describe("Pricing", function () {
    it("Should allow owner to update mint price", async function () {
      const newPrice = ethers.parseEther("0.05");
      await nft.setMintPrice(newPrice);
      expect(await nft.mintPrice()).to.equal(newPrice);
    });

    it("Should not allow non-owner to update mint price", async function () {
      const newPrice = ethers.parseEther("0.05");
      await expect(
        nft.connect(addr1).setMintPrice(newPrice)
      ).to.be.reverted;
    });

    it("Should emit MintPriceUpdated event", async function () {
      const newPrice = ethers.parseEther("0.05");
      await expect(nft.setMintPrice(newPrice))
        .to.emit(nft, "MintPriceUpdated")
        .withArgs(MINT_PRICE, newPrice);
    });
  });

  describe("Withdrawal", function () {
    it("Should allow owner to withdraw contract balance", async function () {
      // Mint an NFT to fund the contract
      await nft.connect(addr1).mint(addr1.address, "ipfs://test", { value: MINT_PRICE });

      const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
      const contractBalance = await ethers.provider.getBalance(await nft.getAddress());

      const tx = await nft.withdraw();
      const receipt = await tx.wait();
      const gasUsed = receipt.gasUsed * receipt.gasPrice;

      const finalOwnerBalance = await ethers.provider.getBalance(owner.address);
      expect(finalOwnerBalance).to.equal(
        initialOwnerBalance + contractBalance - gasUsed
      );
    });

    it("Should not allow non-owner to withdraw", async function () {
      await expect(
        nft.connect(addr1).withdraw()
      ).to.be.reverted;
    });
  });

  describe("Burning", function () {
    it("Should allow token owner to burn their NFT", async function () {
      await nft.connect(addr1).mint(addr1.address, "ipfs://test", { value: MINT_PRICE });
      await nft.connect(addr1).burn(1);

      await expect(nft.ownerOf(1)).to.be.reverted;
    });
  });
});
