const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const GovernanceToken = await hre.ethers.getContractFactory("GovernanceToken");
  const governanceToken = await GovernanceToken.deploy(hre.ethers.parseEther("1000"));
  await governanceToken.waitForDeployment();
  console.log("GovernanceToken deployed to:", governanceToken.target);

  const DAO = await hre.ethers.getContractFactory("DAO");
  const dao = await DAO.deploy(governanceToken.target);
  await dao.waitForDeployment();
  console.log("DAO deployed to:", dao.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
