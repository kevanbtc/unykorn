const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const OverdogToken = await ethers.getContractFactory("OverdogToken");
  const token = await OverdogToken.deploy(ethers.parseUnits("1000000", 18));
  await token.waitForDeployment();

  const OverVault = await ethers.getContractFactory("OverVault");
  const vault = await OverVault.deploy(token);
  await vault.waitForDeployment();

  const SmartExecutor = await ethers.getContractFactory("SmartExecutor");
  const exec = await SmartExecutor.deploy();
  await exec.waitForDeployment();

  console.log("Token", await token.getAddress());
  console.log("Vault", await vault.getAddress());
  console.log("Executor", await exec.getAddress());

  // renounce ownership
  await token.setVault(await vault.getAddress());
  await token.renounceOwnership();
  await vault.transferOwnership(ethers.ZeroAddress);
  await exec.transferOwnership(ethers.ZeroAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
