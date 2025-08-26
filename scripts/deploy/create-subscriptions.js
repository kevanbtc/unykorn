const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const License = await hre.ethers.getContractFactory("UnykornLicenseNFT");
  const license = await License.deploy();
  await license.deployed();

  const duration = 30 * 24 * 60 * 60; // 30 days
  await license.mintLicense(deployer.address, 0, duration); // Basic
  await license.mintLicense(deployer.address, 1, duration); // Pro
  await license.mintLicense(deployer.address, 2, duration); // Enterprise

  console.log("Seeded licenses for", deployer.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
