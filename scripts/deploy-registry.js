const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying ComplianceRegistry with:", deployer.address);

  const Registry = await hre.ethers.getContractFactory("ComplianceRegistry");
  const registry = await Registry.deploy();
  await registry.deployed();

  console.log("ComplianceRegistry deployed at:", registry.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
