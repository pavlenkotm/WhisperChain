const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await hre.ethers.provider.getBalance(deployer.address)).toString());

  // Deploy WhisperToken
  console.log("\nDeploying WhisperToken...");
  const WhisperToken = await hre.ethers.getContractFactory("WhisperToken");
  const token = await WhisperToken.deploy(deployer.address);
  await token.waitForDeployment();
  console.log("WhisperToken deployed to:", await token.getAddress());

  // Deploy WhisperNFT
  console.log("\nDeploying WhisperNFT...");
  const WhisperNFT = await hre.ethers.getContractFactory("WhisperNFT");
  const nft = await WhisperNFT.deploy(deployer.address);
  await nft.waitForDeployment();
  console.log("WhisperNFT deployed to:", await nft.getAddress());

  console.log("\nDeployment Summary:");
  console.log("==================");
  console.log("WhisperToken:", await token.getAddress());
  console.log("WhisperNFT:", await nft.getAddress());
  console.log("\nSave these addresses for your frontend configuration!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
