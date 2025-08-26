const hre = require("hardhat");

async function main() {
  const Registry = await hre.ethers.getContractFactory("ComplianceRegistry");
  const registry = await Registry.deploy();
  await registry.deployed();

  const License = await hre.ethers.getContractFactory("UnykornLicenseNFT");
  const license = await License.deploy();
  await license.deployed();

  const Sovereignty = await hre.ethers.getContractFactory(
    "UnykornSovereigntyRegistry"
  );
  const sovereignty = await Sovereignty.deploy();
  await sovereignty.deployed();

  console.log("ComplianceRegistry deployed to:", registry.address);
  console.log("UnykornLicenseNFT deployed to:", license.address);
  console.log("UnykornSovereigntyRegistry deployed to:", sovereignty.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
