const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with", deployer.address);

  const MockStablecoin = await hre.ethers.getContractFactory("MockStablecoin");
  const stable = await MockStablecoin.deploy();
  await stable.deployed();
  await stable.mint(deployer.address, hre.ethers.utils.parseEther("1000000"));

  const ComplianceRegistry = await hre.ethers.getContractFactory("ComplianceRegistry");
  const compliance = await ComplianceRegistry.deploy();
  await compliance.deployed();
  await compliance.add(deployer.address);

  const FTHDebtToken = await hre.ethers.getContractFactory("FTHDebtToken");
  const debt = await FTHDebtToken.deploy(stable.address);
  await debt.deployed();

  const FTHEquityToken = await hre.ethers.getContractFactory("FTHEquityToken");
  const equity = await FTHEquityToken.deploy(stable.address);
  await equity.deployed();

  const RevenueRouter = await hre.ethers.getContractFactory("RevenueRouter");
  const router = await RevenueRouter.deploy(
    stable.address,
    debt.address,
    equity.address,
    deployer.address,
    compliance.address,
    50,
    40,
    10
  );
  await router.deployed();

  await debt.setRevenueRouter(router.address);
  await equity.setRevenueRouter(router.address);
  await debt.mint(deployer.address, hre.ethers.utils.parseEther("1000"));
  await equity.mint(deployer.address, hre.ethers.utils.parseEther("1000"));

  console.log("Stablecoin:", stable.address);
  console.log("Compliance:", compliance.address);
  console.log("Debt token:", debt.address);
  console.log("Equity token:", equity.address);
  console.log("Revenue router:", router.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

