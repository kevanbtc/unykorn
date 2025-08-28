const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const multisig = process.env.MULTISIG_SAFE;
  console.log("Deploying with", deployer.address);
  if (multisig) {
    console.log("Initial ownership will be transferred to", multisig);
  }

  const VTV = await hre.ethers.getContractFactory("VTV");
  const vtv = await VTV.deploy();
  await vtv.deployed();
  if (multisig) {
    await vtv.transferOwnership(multisig);
  }
  console.log("VTV deployed to", vtv.address);

  const VCHAN = await hre.ethers.getContractFactory("VCHAN");
  const vchan = await VCHAN.deploy();
  await vchan.deployed();
  if (multisig) {
    await vchan.transferOwnership(multisig);
  }
  console.log("VCHAN deployed to", vchan.address);

  const VPOINT = await hre.ethers.getContractFactory("VPOINT");
  const vpoint = await VPOINT.deploy();
  await vpoint.deployed();
  if (multisig) {
    await vpoint.transferOwnership(multisig);
  }
  console.log("VPOINT deployed to", vpoint.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
