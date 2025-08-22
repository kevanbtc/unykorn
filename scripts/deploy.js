const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const Registry = await hre.ethers.getContractFactory("ComplianceRegistry");
  const registry = await Registry.deploy();
  await registry.deployed();
  console.log("ComplianceRegistry deployed to", registry.address);
  await registry.setKYC(deployer.address, true);

  const VTV = await hre.ethers.getContractFactory("VTV");
  const vtv = await VTV.deploy(registry.address);
  await vtv.deployed();
  console.log("VTV deployed to", vtv.address);

  const VCHAN = await hre.ethers.getContractFactory("VCHAN");
  const vchan = await VCHAN.deploy(registry.address);
  await vchan.deployed();
  console.log("VCHAN deployed to", vchan.address);

  const VPOINT = await hre.ethers.getContractFactory("VPOINT");
  const vpoint = await VPOINT.deploy(registry.address);
  await vpoint.deployed();
  console.log("VPOINT deployed to", vpoint.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
