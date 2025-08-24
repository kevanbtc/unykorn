const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const registry = await (await hre.ethers.getContractFactory("ComplianceRegistry")).deploy();
  await registry.deployed();

  const Stablecoin = await hre.ethers.getContractFactory("Stablecoin");
  const stablecoin = await Stablecoin.deploy();
  await stablecoin.deployed();

  const Proof = await hre.ethers.getContractFactory("ProofOfReserves");
  const proof = await Proof.deploy(deployer.address);
  await proof.deployed();

  const Governance = await hre.ethers.getContractFactory("Governance");
  const governance = await Governance.deploy();
  await governance.deployed();

  console.log(`Stablecoin deployed to ${stablecoin.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
