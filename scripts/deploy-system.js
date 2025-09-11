const { ethers, upgrades } = require("hardhat");

async function main() {
  console.log("🚀 Deploying Unykorn System...");
  
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  // Deploy mock USDC for testing (or use real USDC address on mainnet)
  console.log("\n📄 Deploying Payment Token...");
  const VTV = await ethers.getContractFactory("VTV");
  const paymentToken = await VTV.deploy();
  await paymentToken.waitForDeployment();
  console.log("Payment Token deployed to:", paymentToken.target);

  // Deploy main token with upgradeable proxy
  console.log("\n🪙 Deploying Main Token...");
  const TokenERC20 = await ethers.getContractFactory("TokenERC20");
  const token = await upgrades.deployProxy(
    TokenERC20,
    ["Unykorn", "UNY"],
    { 
      initializer: "initialize",
      kind: "uups"
    }
  );
  await token.waitForDeployment();
  console.log("Token deployed to:", token.target);

  // Deploy AssetVault
  console.log("\n🏦 Deploying Asset Vault...");
  const AssetVault = await ethers.getContractFactory("AssetVault");
  const assetVault = await AssetVault.deploy(token.target, deployer.address);
  await assetVault.waitForDeployment();
  console.log("Asset Vault deployed to:", assetVault.target);

  // Deploy RevVault
  console.log("\n💰 Deploying Revenue Vault...");
  const RevVault = await ethers.getContractFactory("RevVault");
  const revVault = await RevVault.deploy(token.target, paymentToken.target, deployer.address);
  await revVault.waitForDeployment();
  console.log("Revenue Vault deployed to:", revVault.target);

  // Deploy POCBeacons
  console.log("\n📍 Deploying POC Beacons...");
  const POCBeacons = await ethers.getContractFactory("POCBeacons");
  const pocBeacons = await POCBeacons.deploy(token.target, deployer.address);
  await pocBeacons.waitForDeployment();
  console.log("POC Beacons deployed to:", pocBeacons.target);

  // Deploy SalesForceManager
  console.log("\n👥 Deploying Sales Force Manager...");
  const SalesForceManager = await ethers.getContractFactory("SalesForceManager");
  const salesForce = await SalesForceManager.deploy(token.target, paymentToken.target, deployer.address);
  await salesForce.waitForDeployment();
  console.log("Sales Force Manager deployed to:", salesForce.target);

  // Deploy Governance
  console.log("\n🏛️ Deploying Governance...");
  const UnykornGovernance = await ethers.getContractFactory("UnykornGovernance");
  const governance = await UnykornGovernance.deploy(token.target, deployer.address);
  await governance.waitForDeployment();
  console.log("Governance deployed to:", governance.target);

  // Set up permissions
  console.log("\n🔐 Setting up permissions...");
  
  // Grant UTILITY_ROLE to contracts that need to interact with token
  const UTILITY_ROLE = await token.UTILITY_ROLE();
  await token.grantRole(UTILITY_ROLE, pocBeacons.target);
  await token.grantRole(UTILITY_ROLE, revVault.target);
  await token.grantRole(UTILITY_ROLE, salesForce.target);
  console.log("✅ UTILITY_ROLE granted to POC, RevVault, and SalesForce");

  // Grant MINTER_ROLE to SalesForceManager for early packs
  const MINTER_ROLE = await token.MINTER_ROLE();
  await token.grantRole(MINTER_ROLE, salesForce.target);
  console.log("✅ MINTER_ROLE granted to SalesForce");

  // Grant governance control over burn rate
  const DEFAULT_ADMIN_ROLE = await token.DEFAULT_ADMIN_ROLE();
  await token.grantRole(DEFAULT_ADMIN_ROLE, governance.target);
  console.log("✅ DEFAULT_ADMIN_ROLE granted to Governance");

  // Set up governance contracts
  await governance.setContracts(assetVault.target, revVault.target);
  console.log("✅ Governance contracts configured");

  // Deploy LiquidityHelper if needed
  console.log("\n💧 Deploying Liquidity Helper...");
  const LiquidityHelper = await ethers.getContractFactory("LiquidityHelper");
  const liquidityHelper = await LiquidityHelper.deploy(
    token.target,
    "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", // Uniswap V2 Router on mainnet/testnet
    deployer.address,
    Math.floor(Date.now() / 1000) + (90 * 24 * 60 * 60) // 90 days from now
  );
  await liquidityHelper.waitForDeployment();
  console.log("Liquidity Helper deployed to:", liquidityHelper.target);

  // Initialize some default configurations
  console.log("\n⚙️ Initializing system configurations...");
  
  // Set default asset allocations (example)
  await assetVault.setAssetAllocation(ethers.ZeroAddress, 4000); // 40% ETH
  console.log("✅ Default asset allocation set");

  // Create some sample beacons
  await pocBeacons.createBeacon(
    "Demo Gas Station",
    40742000, // NYC coordinates * 1000000  
    -73989000,
    100, // 100m radius
    deployer.address
  );
  console.log("✅ Demo beacon created");

  // Add deployer as founding broker
  await salesForce.addFoundingBroker(deployer.address);
  console.log("✅ Deployer added as founding broker");

  console.log("\n🎉 Deployment Summary:");
  console.log("======================");
  console.log("Payment Token:", paymentToken.target);
  console.log("Main Token:", token.target);
  console.log("Asset Vault:", assetVault.target);
  console.log("Revenue Vault:", revVault.target);
  console.log("POC Beacons:", pocBeacons.target);
  console.log("Sales Force:", salesForce.target);
  console.log("Governance:", governance.target);
  console.log("Liquidity Helper:", liquidityHelper.target);

  console.log("\n📝 Next Steps:");
  console.log("1. Add founding brokers: salesForce.addFoundingBroker(address)");
  console.log("2. Create merchant offers: revVault.addMerchant(address) -> createOffer()");
  console.log("3. Deploy beacon network: pocBeacons.createBeacon()");
  console.log("4. Set up asset vault allocations: assetVault.setAssetAllocation()");
  console.log("5. Initialize governance proposals for parameter tuning");

  // Save deployment addresses to file
  const deploymentInfo = {
    network: (await ethers.provider.getNetwork()).name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      paymentToken: paymentToken.target,
      token: token.target,
      assetVault: assetVault.target,
      revVault: revVault.target,
      pocBeacons: pocBeacons.target,
      salesForce: salesForce.target,
      governance: governance.target,
      liquidityHelper: liquidityHelper.target
    }
  };

  const fs = require('fs');
  const path = require('path');
  
  const deploymentsDir = path.join(__dirname, '..', 'deployments');
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }
  
  fs.writeFileSync(
    path.join(deploymentsDir, `deployment-${Date.now()}.json`),
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log("\n💾 Deployment info saved to deployments/ directory");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });