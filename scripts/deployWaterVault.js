const hre = require("hardhat");

async function main() {
  const WaterVault = await hre.ethers.getContractFactory("WaterVault");
  const vault = await WaterVault.deploy("River Nile", 1000000, "0xYourOwnerAddress");

  await vault.deployed();
  console.log(`WaterVault deployed to: ${vault.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
