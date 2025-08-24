const hre = require("hardhat");

async function main() {
  const ESGStablecoin = await hre.ethers.getContractFactory("ESGStablecoin");
  const stablecoin = await ESGStablecoin.deploy("UnykornUSD", "wUSDx");

  await stablecoin.deployed();
  console.log(`ESGStablecoin deployed to: ${stablecoin.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
