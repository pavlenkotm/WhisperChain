const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WhisperToken", function () {
  let token;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    const WhisperToken = await ethers.getContractFactory("WhisperToken");
    token = await WhisperToken.deploy(owner.address);
    await token.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await token.owner()).to.equal(owner.address);
    });

    it("Should assign initial supply to owner", async function () {
      const ownerBalance = await token.balanceOf(owner.address);
      expect(ownerBalance).to.equal(ethers.parseEther("100000000"));
    });

    it("Should have correct name and symbol", async function () {
      expect(await token.name()).to.equal("WhisperToken");
      expect(await token.symbol()).to.equal("WHSP");
    });
  });

  describe("Minting", function () {
    it("Should allow owner to mint tokens", async function () {
      const mintAmount = ethers.parseEther("1000");
      await token.mint(addr1.address, mintAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(mintAmount);
    });

    it("Should not allow non-owner to mint", async function () {
      const mintAmount = ethers.parseEther("1000");
      await expect(
        token.connect(addr1).mint(addr1.address, mintAmount)
      ).to.be.reverted;
    });

    it("Should not exceed max supply", async function () {
      const maxSupply = await token.MAX_SUPPLY();
      const currentSupply = await token.totalSupply();
      const excessAmount = maxSupply - currentSupply + ethers.parseEther("1");

      await expect(
        token.mint(addr1.address, excessAmount)
      ).to.be.revertedWith("Exceeds max supply");
    });

    it("Should emit TokensMinted event", async function () {
      const mintAmount = ethers.parseEther("1000");
      await expect(token.mint(addr1.address, mintAmount))
        .to.emit(token, "TokensMinted")
        .withArgs(addr1.address, mintAmount);
    });
  });

  describe("Burning", function () {
    it("Should allow token holders to burn their tokens", async function () {
      const burnAmount = ethers.parseEther("1000");
      await token.burn(burnAmount);

      const ownerBalance = await token.balanceOf(owner.address);
      expect(ownerBalance).to.equal(
        ethers.parseEther("100000000") - burnAmount
      );
    });

    it("Should emit TokensBurned event", async function () {
      const burnAmount = ethers.parseEther("1000");
      await expect(token.burn(burnAmount))
        .to.emit(token, "TokensBurned")
        .withArgs(owner.address, burnAmount);
    });
  });

  describe("Transfers", function () {
    it("Should transfer tokens between accounts", async function () {
      const transferAmount = ethers.parseEther("100");
      await token.transfer(addr1.address, transferAmount);
      expect(await token.balanceOf(addr1.address)).to.equal(transferAmount);

      await token.connect(addr1).transfer(addr2.address, transferAmount);
      expect(await token.balanceOf(addr2.address)).to.equal(transferAmount);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const initialOwnerBalance = await token.balanceOf(owner.address);
      await expect(
        token.connect(addr1).transfer(owner.address, 1)
      ).to.be.reverted;

      expect(await token.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    });
  });
});
