const hre = require("hardhat");

async function main() {
  const CarbonVault = await hre.ethers.getContractFactory("CarbonVault");
  const vault = await CarbonVault.deploy("Project-Kenya-123", 50000, "0xYourOwnerAddress");

  await vault.deployed();
  console.log(`CarbonVault deployed to: ${vault.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
