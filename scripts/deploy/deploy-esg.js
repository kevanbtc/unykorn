const hre = require("hardhat");

async function main() {
  const Token = await hre.ethers.getContractFactory("MockERC20");
  const waterToken = await Token.deploy("Water Token", "WAT");
  await waterToken.deployed();

  const WaterVault = await hre.ethers.getContractFactory("WaterVault");
  const waterVault = await WaterVault.deploy(waterToken.address);
  await waterVault.deployed();

  const Stable = await hre.ethers.getContractFactory("ESGStablecoin");
  const stable = await Stable.deploy();
  await stable.deployed();

  await stable.addCollateralVault(waterVault.address, 50);

  console.log("WaterVault deployed to:", waterVault.address);
  console.log("ESGStablecoin deployed to:", stable.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
