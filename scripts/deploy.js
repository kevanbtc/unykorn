const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const VTV = await hre.ethers.getContractFactory("VTV");
  const vtv = await VTV.deploy();
  await vtv.waitForDeployment();
  console.log("VTV deployed to", await vtv.getAddress());

  const VCHAN = await hre.ethers.getContractFactory("VCHAN");
  const vchan = await VCHAN.deploy();
  await vchan.waitForDeployment();
  console.log("VCHAN deployed to", await vchan.getAddress());

  const VPOINT = await hre.ethers.getContractFactory("VPOINT");
  const vpoint = await VPOINT.deploy();
  await vpoint.waitForDeployment();
  console.log("VPOINT deployed to", await vpoint.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
