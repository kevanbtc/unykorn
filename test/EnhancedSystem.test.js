const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Enhanced Token System", function () {
  let token, owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Unykorn", "UNI");
  });

  describe("Enhanced Token Features", function () {
    it("should have trillion supply for psychology", async function () {
      const supply = await token.totalSupply();
      expect(supply).to.equal(ethers.parseEther("1000000000000")); // 1 trillion
    });

    it("should allow setting up pack tiers", async function () {
      await token.setupPackTier(1, ethers.parseEther("0.1"), ethers.parseEther("1000000"), 60 * 24 * 60 * 60);
      
      const tier = await token.packTiers(1);
      expect(tier.price).to.equal(ethers.parseEther("0.1"));
      expect(tier.tokens).to.equal(ethers.parseEther("1000000"));
      expect(tier.active).to.be.true;
    });

    it("should allow buying packs with lockup", async function () {
      await token.setupPackTier(1, ethers.parseEther("0.1"), ethers.parseEther("1000000"), 60 * 24 * 60 * 60);
      
      await token.connect(user1).buyPack(1, { value: ethers.parseEther("0.1") });
      
      const balance = await token.balanceOf(user1.address);
      expect(balance).to.equal(ethers.parseEther("1000000"));
      
      const isLocked = await token.isLocked(user1.address);
      expect(isLocked).to.be.true;
    });

    it("should apply burn on transfers", async function () {
      // Setup pack 
      await token.setupPackTier(1, ethers.parseEther("0.1"), ethers.parseEther("1000000"), 0);
      
      // Advance time to unlock transfers
      await time.increase(8 * 24 * 60 * 60); // Pass launch lock
      
      await token.connect(user1).buyPack(1, { value: ethers.parseEther("0.1") });
      
      const initialBalance = await token.balanceOf(user1.address);
      await token.connect(user1).transfer(user2.address, ethers.parseEther("100000"));
      
      const finalBalance = await token.balanceOf(user1.address);
      const user2Balance = await token.balanceOf(user2.address);
      
      // 3% burn should be applied
      expect(user2Balance).to.equal(ethers.parseEther("97000")); // 100k - 3% burn
    });
  });
});

describe("Proof of Contact System", function () {
  let poc, token, owner, user1, validator;

  beforeEach(async function () {
    [owner, user1, validator] = await ethers.getSigners();
    
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Reward", "REW");
    
    // Advance time to unlock transfers
    await time.increase(8 * 24 * 60 * 60); // Pass launch lock
    
    const POC = await ethers.getContractFactory("ProofOfContact");
    poc = await POC.deploy(await token.getAddress());
    await poc.waitForDeployment();
    
    // Transfer tokens to POC for rewards
    await token.transfer(await poc.getAddress(), ethers.parseEther("1000000"));
  });

  it("should create beacons", async function () {
    const beaconId = await poc.createBeacon("Gas Station A", ethers.parseEther("100"));
    
    const beacon = await poc.beacons(1);
    expect(beacon.location).to.equal("Gas Station A");
    expect(beacon.active).to.be.true;
    expect(beacon.owner).to.equal(owner.address);
  });

  it("should record check-ins and build streaks", async function () {
    await poc.createBeacon("Gas Station A", ethers.parseEther("100"));
    
    // First check-in
    await poc.recordCheckIn(user1.address, 1, "QR");
    
    let stats = await poc.userStats(user1.address);
    expect(stats.currentStreak).to.equal(1);
    expect(stats.totalCheckIns).to.equal(1);
    
    // Advance a day and check in again
    await time.increase(24 * 60 * 60 + 1);
    await poc.recordCheckIn(user1.address, 1, "NFC");
    
    stats = await poc.userStats(user1.address);
    expect(stats.currentStreak).to.equal(2);
  });

  it("should prevent double check-ins same day", async function () {
    await poc.createBeacon("Gas Station A", ethers.parseEther("100"));
    
    await poc.recordCheckIn(user1.address, 1, "QR");
    
    await expect(poc.recordCheckIn(user1.address, 1, "NFC"))
      .to.be.revertedWith("Already checked in today");
  });
});

describe("Proof of Introduction System", function () {
  let poi, token, owner, user1, user2, connector;

  beforeEach(async function () {
    [owner, user1, user2, connector] = await ethers.getSigners();
    
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Payment", "PAY");
    
    // Advance time to unlock transfers
    await time.increase(8 * 24 * 60 * 60); // Pass launch lock
    
    const POI = await ethers.getContractFactory("ProofOfIntroduction");
    poi = await POI.deploy(await token.getAddress());
    await poi.waitForDeployment();
    
    // Setup tokens
    await token.transfer(await poi.getAddress(), ethers.parseEther("1000000"));
  });

  it("should create introductions", async function () {
    const introId = await poi.connect(connector).createIntroduction(user1.address, user2.address);
    
    const introducer = await poi.getIntroducer(user1.address, user2.address);
    expect(introducer).to.equal(connector.address);
    
    const areConnected = await poi.areConnected(user1.address, user2.address);
    expect(areConnected).to.be.true;
  });

  it("should confirm introductions", async function () {
    await poi.connect(connector).createIntroduction(user1.address, user2.address);
    
    // Get the intro ID from the events or user introductions
    const intros = await poi.getUserIntroductions(connector.address);
    const introId = intros[0];
    
    await poi.connect(user1).confirmIntroduction(introId);
    
    const [, , , , confirmed] = await poi.getIntroductionDetails(introId);
    expect(confirmed).to.be.true;
  });

  it("should pay connectors on transactions", async function () {
    await poi.connect(connector).createIntroduction(user1.address, user2.address);
    
    const intros = await poi.getUserIntroductions(connector.address);
    const introId = intros[0];
    
    await poi.connect(user1).confirmIntroduction(introId);
    
    const initialBalance = await token.balanceOf(connector.address);
    
    // Record transaction between introduced parties
    await poi.recordTransaction(user1.address, user2.address, ethers.parseEther("10000"));
    
    const finalBalance = await token.balanceOf(connector.address);
    const commission = finalBalance - initialBalance;
    
    // Should receive 5% commission, but burn is applied to the transfer
    // So actual commission = 5% of 10000 - 3% burn = 500 - 15 = 485
    expect(commission).to.equal(ethers.parseEther("485"));
  });
});

describe("Multi-Asset Vault", function () {
  let vault, owner, user1;

  beforeEach(async function () {
    [owner, user1] = await ethers.getSigners();
    
    const Vault = await ethers.getContractFactory("MultiAssetVault");
    vault = await Vault.deploy();
    await vault.waitForDeployment();
  });

  it("should add assets with allocations", async function () {
    const tokenAddress = ethers.ZeroAddress; // ETH
    
    await vault.addAsset(tokenAddress, 4000, "ETH"); // 40%
    
    const allocation = await vault.allocations(tokenAddress);
    expect(allocation.targetPercentage).to.equal(4000);
    expect(allocation.assetType).to.equal("ETH");
    expect(allocation.active).to.be.true;
  });

  it("should accept ETH deposits", async function () {
    await vault.addAsset(ethers.ZeroAddress, 4000, "ETH");
    
    await vault.deposit(ethers.ZeroAddress, 0, { value: ethers.parseEther("1") });
    
    const totalValue = await vault.getTotalValue();
    expect(totalValue).to.equal(ethers.parseEther("1"));
  });

  it("should create vault proofs", async function () {
    await vault.createVaultProof("GOLD", ethers.parseEther("100"), "ipfs://proof-hash");
    
    const [assetType, amount, proofURI] = await vault.getVaultProof(1);
    expect(assetType).to.equal("GOLD");
    expect(amount).to.equal(ethers.parseEther("100"));
    expect(proofURI).to.equal("ipfs://proof-hash");
  });

  it("should calculate available collateral", async function () {
    await vault.addAsset(ethers.ZeroAddress, 4000, "ETH");
    await vault.deposit(ethers.ZeroAddress, 0, { value: ethers.parseEther("10") });
    
    const collateral = await vault.getAvailableCollateral();
    // Should be 80% of total value by default
    expect(collateral).to.equal(ethers.parseEther("8"));
  });
});

describe("RevVault Commerce Layer", function () {
  let revVault, token, owner, merchant, buyer, territoryPool, platformTreasury, burnContract;

  beforeEach(async function () {
    [owner, merchant, buyer, territoryPool, platformTreasury, burnContract] = await ethers.getSigners();
    
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Payment", "PAY");
    
    // Advance time to unlock transfers
    await time.increase(8 * 24 * 60 * 60); // Pass launch lock
    
    const RevVault = await ethers.getContractFactory("RevVault");
    revVault = await RevVault.deploy(
      await token.getAddress(),
      burnContract.address,
      territoryPool.address,
      platformTreasury.address
    );
    await revVault.waitForDeployment();
    
    // Setup tokens
    await token.transfer(buyer.address, ethers.parseEther("10000"));
    await token.connect(buyer).approve(await revVault.getAddress(), ethers.parseEther("10000"));
  });

  it("should create offers", async function () {
    const offerId = await revVault.connect(merchant).createOffer(
      "Coffee Voucher",
      "Get 10% off coffee",
      ethers.parseEther("100"),
      "VOUCHER"
    );
    
    const [merchantAddr, title, , price, active] = await revVault.getOffer(1);
    expect(merchantAddr).to.equal(merchant.address);
    expect(title).to.equal("Coffee Voucher");
    expect(price).to.equal(ethers.parseEther("100"));
    expect(active).to.be.true;
  });

  it("should process purchases with revenue splitting", async function () {
    await revVault.connect(merchant).createOffer(
      "Coffee Voucher",
      "Get 10% off coffee",
      ethers.parseEther("100"),
      "VOUCHER"
    );
    
    const initialMerchantBalance = await token.balanceOf(merchant.address);
    
    await revVault.connect(buyer).purchase(1, ethers.ZeroAddress, ethers.ZeroHash);
    
    const finalMerchantBalance = await token.balanceOf(merchant.address);
    const merchantPayout = finalMerchantBalance - initialMerchantBalance;
    
    // Should receive 90% of payment, but burn affects transfer
    // 90% of 100 = 90, but 3% burn applies = 90 - 2.7 = 87.3
    expect(merchantPayout).to.equal(ethers.parseEther("87.3"));
  });
});