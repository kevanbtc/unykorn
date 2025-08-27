const hre = require("hardhat");

async function main() {
  const sge = process.env.SGE_ADDRESS;
  const treasury = process.env.TREASURY_ADDRESS;
  if (!sge || !treasury) {
    throw new Error("SGE_ADDRESS and TREASURY_ADDRESS must be set");
  }

  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying SGEAffiliateSaleV3 with", deployer.address);

  const Sale = await hre.ethers.getContractFactory("SGEAffiliateSaleV3");
  const sale = await Sale.deploy(sge, treasury);
  await sale.deployed();

  console.log("SGEAffiliateSaleV3 deployed to", sale.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
