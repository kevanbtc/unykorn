const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const registryAddr = process.env.COMPLIANCE_REGISTRY;
  if (!registryAddr) throw new Error("COMPLIANCE_REGISTRY env var required");

  console.log("Deploying tokens with registry:", registryAddr);

  const VTV = await hre.ethers.getContractFactory("VTV");
  const vtv = await VTV.deploy(registryAddr);
  await vtv.deployed();
  console.log("VTV deployed:", vtv.address);

  const VPOINT = await hre.ethers.getContractFactory("VPOINT");
  const vpoint = await VPOINT.deploy(registryAddr);
  await vpoint.deployed();
  console.log("VPOINT deployed:", vpoint.address);

  const VCHAN = await hre.ethers.getContractFactory("VCHAN");
  const vchan = await VCHAN.deploy(registryAddr);
  await vchan.deployed();
  console.log("VCHAN deployed:", vchan.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
