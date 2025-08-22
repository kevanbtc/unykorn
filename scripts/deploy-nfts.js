const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const registryAddr = process.env.COMPLIANCE_REGISTRY;
  if (!registryAddr) throw new Error("COMPLIANCE_REGISTRY env var required");

  const NFT = await hre.ethers.getContractFactory("CompliantNFT");
  const nft = await NFT.deploy(registryAddr);
  await nft.deployed();
  console.log("CompliantNFT deployed:", nft.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
