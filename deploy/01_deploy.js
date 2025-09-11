const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with:", deployer.address);

  const Compliance = await ethers.getContractFactory("ComplianceManager");
  const compliance = await Compliance.deploy(deployer.address);
  await compliance.waitForDeployment();
  console.log("ComplianceManager:", await compliance.getAddress());

  const Stable = await ethers.getContractFactory("Stablecoin");
  const stable = await Stable.deploy("RWA Dollar", "rUSD", deployer.address, await compliance.getAddress());
  await stable.waitForDeployment();
  console.log("Stablecoin:", await stable.getAddress());

  const Registry = await ethers.getContractFactory("RWARegistry");
  const registry = await Registry.deploy(deployer.address);
  await registry.waitForDeployment();
  console.log("RWARegistry:", await registry.getAddress());

  const Oracle = await ethers.getContractFactory("OracleConnector");
  const oracle = await Oracle.deploy(deployer.address);
  await oracle.waitForDeployment();
  console.log("OracleConnector:", await oracle.getAddress());

  const Pause = await ethers.getContractFactory("EmergencyPause");
  const pause = await Pause.deploy(deployer.address);
  await pause.waitForDeployment();
  console.log("EmergencyPause:", await pause.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

