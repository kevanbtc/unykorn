const hre = require("hardhat");

async function main() {
  const SafeToken = await hre.ethers.getContractFactory("SafeToken");
  const safeToken = await SafeToken.deploy();
  await safeToken.deployed();
  console.log("SafeToken deployed to:", safeToken.address);

  const SafeReport = await hre.ethers.getContractFactory("SafeReport");
  const safeReport = await SafeReport.deploy();
  await safeReport.deployed();
  console.log("SafeReport deployed to:", safeReport.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
