const hre = require("hardhat");

async function main() {
  const registry = process.env.ERC6551_REGISTRY;
  const accountImpl = process.env.ERC6551_ACCOUNT_IMPL;

  const Contract = await hre.ethers.getContractFactory("SoulboundSafe");
  const contract = await Contract.deploy(registry, accountImpl);

  await contract.deployed();
  console.log("SoulboundSafe deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
