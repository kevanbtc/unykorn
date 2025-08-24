const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  const Stablecoin = await ethers.getContractFactory("Stablecoin");
  const stable = await Stablecoin.deploy();
  await stable.deployed();
  console.log("Stablecoin deployed at:", stable.address);

  const Compliance = await ethers.getContractFactory("ComplianceRegistry");
  const compliance = await Compliance.deploy();
  await compliance.deployed();
  console.log("ComplianceRegistry deployed at:", compliance.address);

  const VaultManager = await ethers.getContractFactory("VaultManager");
  const vault = await VaultManager.deploy(stable.address);
  await vault.deployed();
  console.log("VaultManager deployed at:", vault.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
