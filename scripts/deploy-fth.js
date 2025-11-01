const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");
const fs = require("fs");

/**
 * Deploy FTH Sovereign Settlement Infrastructure
 * 
 * Deploys all core contracts for the Future Tech Holdings ecosystem:
 * - Multi-sig Treasury (3-of-5)
 * - USDF Stablecoin
 * - FTHG Gold Token
 * - FTH Governance Token
 * - Private DEX with holder discounts
 * - Vault Proof NFT system
 * - Escrow for redemptions
 */
async function main() {
  console.log("=".repeat(60));
  console.log("FTH Sovereign Settlement Infrastructure Deployment");
  console.log("=".repeat(60));

  const [deployer] = await ethers.getSigners();
  console.log("\n📍 Deploying from:", deployer.address);
  console.log("💰 Account balance:", ethers.formatEther(await ethers.provider.getBalance(deployer.address)), "ETH");

  // For production, replace these with actual multi-sig addresses
  const ROLES = {
    ceo: process.env.CEO_ADDRESS || deployer.address,
    cfo: process.env.CFO_ADDRESS || deployer.address,
    custodian: process.env.CUSTODIAN_ADDRESS || deployer.address,
    auditor: process.env.AUDITOR_ADDRESS || deployer.address,
    compliance: process.env.COMPLIANCE_ADDRESS || deployer.address,
  };

  console.log("\n👥 Role Addresses:");
  console.log("  CEO:        ", ROLES.ceo);
  console.log("  CFO:        ", ROLES.cfo);
  console.log("  Custodian:  ", ROLES.custodian);
  console.log("  Auditor:    ", ROLES.auditor);
  console.log("  Compliance: ", ROLES.compliance);

  // ========================================================================
  // 1. Deploy Multi-Sig Treasury
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("1️⃣  Deploying Multi-Sig Treasury (3-of-5)...");
  console.log("=".repeat(60));

  const Treasury = await ethers.getContractFactory("FTHTreasury");
  const treasury = await Treasury.deploy(
    ROLES.ceo,
    ROLES.cfo,
    ROLES.custodian,
    ROLES.auditor,
    ROLES.compliance
  );
  await treasury.waitForDeployment();

  console.log("✅ FTH Treasury deployed at:", treasury.target);
  console.log("   - Required confirmations: 3 of 5");
  console.log("   - Timelock delay: 48 hours");

  // ========================================================================
  // 2. Deploy USDF Stablecoin
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("2️⃣  Deploying USDF Stablecoin...");
  console.log("=".repeat(60));

  const USDF = await ethers.getContractFactory("USDFToken");
  const usdf = await upgrades.deployProxy(USDF, [treasury.target], {
    kind: "uups",
    initializer: "initialize",
  });
  await usdf.waitForDeployment();

  console.log("✅ USDF Token deployed at:", usdf.target);
  console.log("   - Name: FTH USD");
  console.log("   - Symbol: USDF");
  console.log("   - Whitelist enforced: Yes");

  // ========================================================================
  // 3. Deploy FTHG Gold Token
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("3️⃣  Deploying FTHG Gold Token...");
  console.log("=".repeat(60));

  const FTHG = await ethers.getContractFactory("FTHGToken");
  const fthg = await upgrades.deployProxy(
    FTHG,
    [treasury.target, ROLES.custodian, ROLES.auditor],
    {
      kind: "uups",
      initializer: "initialize",
    }
  );
  await fthg.waitForDeployment();

  console.log("✅ FTHG Token deployed at:", fthg.target);
  console.log("   - Name: FTH Gold");
  console.log("   - Symbol: FTHG");
  console.log("   - 1 FTHG = 1 troy oz physical gold");

  // ========================================================================
  // 4. Deploy FTH Governance Token
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("4️⃣  Deploying FTH Governance Token...");
  console.log("=".repeat(60));

  const FTHGov = await ethers.getContractFactory("FTHGovernanceToken");
  const fthToken = await upgrades.deployProxy(FTHGov, [treasury.target], {
    kind: "uups",
    initializer: "initialize",
  });
  await fthToken.waitForDeployment();

  console.log("✅ FTH Governance Token deployed at:", fthToken.target);
  console.log("   - Name: FTH Governance");
  console.log("   - Symbol: FTH");
  console.log("   - Initial supply: 100,000,000 FTH");

  // ========================================================================
  // 5. Deploy Private DEX
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("5️⃣  Deploying Private DEX...");
  console.log("=".repeat(60));

  const qualificationThreshold = ethers.parseEther("1000"); // 1000 tokens
  const DEX = await ethers.getContractFactory("FTHPrivateDEX");
  const dex = await upgrades.deployProxy(
    DEX,
    [treasury.target, usdf.target, fthg.target, qualificationThreshold],
    {
      kind: "uups",
      initializer: "initialize",
    }
  );
  await dex.waitForDeployment();

  console.log("✅ Private DEX deployed at:", dex.target);
  console.log("   - Trading fee: 0.25%");
  console.log("   - Holder discount: 10%");
  console.log("   - Qualification threshold:", ethers.formatEther(qualificationThreshold), "tokens");

  // ========================================================================
  // 6. Deploy Vault Proof NFT
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("6️⃣  Deploying Vault Proof NFT...");
  console.log("=".repeat(60));

  const VaultProof = await ethers.getContractFactory("VaultProofNFT");
  const vaultProof = await upgrades.deployProxy(
    VaultProof,
    [treasury.target, ROLES.custodian, ROLES.auditor],
    {
      kind: "uups",
      initializer: "initialize",
    }
  );
  await vaultProof.waitForDeployment();

  console.log("✅ Vault Proof NFT deployed at:", vaultProof.target);
  console.log("   - Name: FTH Vault Proof");
  console.log("   - Symbol: FTHVAULT");
  console.log("   - IPFS & Chainlink PoR integrated");

  // ========================================================================
  // 7. Deploy Escrow System
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("7️⃣  Deploying Escrow System...");
  console.log("=".repeat(60));

  const Escrow = await ethers.getContractFactory("FTHEscrow");
  const escrow = await upgrades.deployProxy(Escrow, [treasury.target, ROLES.custodian], {
    kind: "uups",
    initializer: "initialize",
  });
  await escrow.waitForDeployment();

  console.log("✅ FTH Escrow deployed at:", escrow.target);
  console.log("   - Time-locked redemptions");
  console.log("   - Multi-party release conditions");

  // ========================================================================
  // Summary
  // ========================================================================
  console.log("\n" + "=".repeat(60));
  console.log("📋 DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));

  const summary = {
    "FTH Treasury": treasury.target,
    "USDF Token": usdf.target,
    "FTHG Token": fthg.target,
    "FTH Governance": fthToken.target,
    "Private DEX": dex.target,
    "Vault Proof NFT": vaultProof.target,
    "Escrow": escrow.target,
  };

  console.table(summary);

  // Save deployment addresses
  const deploymentData = {
    network: hre.network.name,
    timestamp: new Date().toISOString(),
    deployer: deployer.address,
    roles: ROLES,
    contracts: summary,
  };

  fs.writeFileSync(
    `deployments-${hre.network.name}.json`,
    JSON.stringify(deploymentData, null, 2)
  );

  console.log("\n✅ Deployment complete!");
  console.log(`📄 Addresses saved to: deployments-${hre.network.name}.json`);

  console.log("\n" + "=".repeat(60));
  console.log("🚀 NEXT STEPS");
  console.log("=".repeat(60));
  console.log("1. Verify contracts on block explorer");
  console.log("2. Set up Chainlink PoR integration");
  console.log("3. Configure IPFS custody documentation");
  console.log("4. Integrate KYC provider API");
  console.log("5. Deploy client portal frontend");
  console.log("6. Create initial trading pairs on DEX");
  console.log("7. Set up monitoring and alerts");
  console.log("=".repeat(60));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
