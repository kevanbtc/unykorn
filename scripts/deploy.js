const hre = require('hardhat');

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying with', deployer.address);

  const VTV = await hre.ethers.getContractFactory('VTVToken');
  const vtv = await VTV.deploy(hre.ethers.parseEther('1000000'));
  await vtv.waitForDeployment();
  console.log('VTV deployed at', await vtv.getAddress());

  const VCHAN = await hre.ethers.getContractFactory('VCHANToken');
  const vchan = await VCHAN.deploy(hre.ethers.parseEther('1000000'));
  await vchan.waitForDeployment();
  console.log('VCHAN deployed at', await vchan.getAddress());

  const VPOINT = await hre.ethers.getContractFactory('VPOINTToken');
  const vpoint = await VPOINT.deploy();
  await vpoint.waitForDeployment();
  console.log('VPOINT deployed at', await vpoint.getAddress());

  const Domain = await hre.ethers.getContractFactory('VChannelDomain');
  const domain = await Domain.deploy();
  await domain.waitForDeployment();
  console.log('Domain contract deployed at', await domain.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
