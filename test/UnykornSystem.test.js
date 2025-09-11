const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("Unykorn System Integration", function () {
  let token, assetVault, revVault, pocBeacons, salesForce, governance;
  let owner, user1, user2, merchant, hustler, admin;
  let mockUSDC;

  beforeEach(async function () {
    [owner, user1, user2, merchant, hustler, admin] = await ethers.getSigners();

    // Deploy mock USDC
    const MockERC20 = await ethers.getContractFactory("contracts/VTV.sol:VTV");
    mockUSDC = await MockERC20.deploy();
    await mockUSDC.waitForDeployment();
    
    // Transfer some tokens to test users
    await mockUSDC.transfer(user1.address, ethers.parseEther("1000"));
    await mockUSDC.transfer(user2.address, ethers.parseEther("1000"));
    await mockUSDC.transfer(merchant.address, ethers.parseEther("1000"));

    // Deploy main token
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Unykorn", "UNY");

    // Deploy AssetVault
    const AssetVault = await ethers.getContractFactory("AssetVault");
    assetVault = await AssetVault.deploy(token.target, admin.address);
    await assetVault.waitForDeployment();

    // Deploy RevVault
    const RevVault = await ethers.getContractFactory("RevVault");
    revVault = await RevVault.deploy(token.target, mockUSDC.target, admin.address);
    await revVault.waitForDeployment();

    // Deploy POCBeacons
    const POCBeacons = await ethers.getContractFactory("POCBeacons");
    pocBeacons = await POCBeacons.deploy(token.target, admin.address);
    await pocBeacons.waitForDeployment();

    // Deploy SalesForceManager
    const SalesForce = await ethers.getContractFactory("SalesForceManager");
    salesForce = await SalesForce.deploy(token.target, mockUSDC.target, admin.address);
    await salesForce.waitForDeployment();

    // Deploy Governance
    const Governance = await ethers.getContractFactory("UnykornGovernance");
    governance = await Governance.deploy(token.target, admin.address);
    await governance.waitForDeployment();

    // Set up permissions
    await token.grantRole(await token.UTILITY_ROLE(), pocBeacons.target);
    await token.grantRole(await token.UTILITY_ROLE(), revVault.target);
    await token.grantRole(await token.UTILITY_ROLE(), salesForce.target);
    await token.grantRole(await token.MINTER_ROLE(), salesForce.target);
    
    // Setup some initial USDC for testing - already done above
  });

  describe("Enhanced Token Functionality", function () {
    it("should allow POC checkins", async function () {
      await time.increase(7 * 24 * 60 * 60 + 1); // Past launch lock
      
      await token.connect(user1).pocCheckin();
      expect(await token.pocStreaks(user1.address)).to.equal(1);
      
      // Should fail if trying to checkin same day
      await expect(token.connect(user1).pocCheckin()).to.be.revertedWith("Already checked in today");
    });

    it("should record POI with proper validation", async function () {
      await token.grantRole(await token.UTILITY_ROLE(), owner.address);
      
      const nonce = ethers.randomBytes(32);
      await token.recordPoi(user1.address, user2.address, nonce);
      
      // Use encodePacked like in contract
      const poiId = ethers.keccak256(
        ethers.solidityPacked(
          ["address", "address", "address", "bytes32"],
          [owner.address, user1.address, user2.address, nonce]
        )
      );
      
      expect(await token.poiRecords(poiId)).to.be.true;
    });

    it("should handle utility usage with burn mechanism", async function () {
      await time.increase(7 * 24 * 60 * 60 + 1); // Past launch lock
      
      const initialSupply = await token.totalSupply();
      const userBalance = await token.balanceOf(owner.address);
      const amount = ethers.parseEther("1000");
      
      await token.useForUtility(amount, "Test utility");
      
      const finalSupply = await token.totalSupply();
      const burnAmount = (amount * 300n) / 10000n; // 3% burn rate
      
      expect(finalSupply).to.equal(initialSupply - burnAmount);
    });
  });

  describe("Asset Vault Operations", function () {
    it("should accept deposits and issue shares", async function () {
      const depositAmount = ethers.parseEther("10");
      
      await assetVault.connect(user1).deposit(60, { value: depositAmount });
      
      expect(await assetVault.depositorShares(user1.address)).to.equal(depositAmount);
      expect(await assetVault.totalShares()).to.equal(depositAmount);
      expect(await assetVault.totalVaultValue()).to.equal(depositAmount);
    });

    it("should enforce lock periods", async function () {
      const depositAmount = ethers.parseEther("5");
      
      await assetVault.connect(user1).deposit(60, { value: depositAmount });
      
      // Should fail to withdraw before lock period
      await expect(
        assetVault.connect(user1).withdraw(depositAmount)
      ).to.be.revertedWith("Still locked");
    });
  });

  describe("RevVault Commerce Layer", function () {
    beforeEach(async function () {
      await revVault.connect(admin).addMerchant(merchant.address);
    });

    it("should create and purchase offers", async function () {
      const price = ethers.parseEther("100");
      
      // Create offer
      await revVault.connect(merchant).createOffer(price, "Test Product");
      
      // Setup buyer
      await mockUSDC.connect(user1).approve(revVault.target, price);
      
      // Purchase
      await revVault.connect(user1).purchase(1, hustler.address);
      
      const offer = await revVault.getOffer(1);
      expect(offer.totalSales).to.equal(1);
      expect(await revVault.directReferrer(user1.address)).to.equal(hustler.address);
    });
  });

  describe("POC Beacon System", function () {
    let beaconId;

    beforeEach(async function () {
      beaconId = await pocBeacons.connect(admin).createBeacon.staticCall(
        "Test Location",
        40742000, // NYC latitude * 1000000
        -73989000, // NYC longitude * 1000000  
        100, // 100m radius
        owner.address
      );
      
      await pocBeacons.connect(admin).createBeacon(
        "Test Location",
        40742000,
        -73989000,
        100,
        owner.address
      );
    });

    it("should record valid checkins", async function () {
      await time.increase(7 * 24 * 60 * 60 + 1); // Past token launch lock
      
      // Checkin within radius
      await pocBeacons.connect(user1).recordCheckin(
        beaconId,
        "QR",
        40742000, // Same coordinates
        -73989000
      );
      
      const checkins = await pocBeacons.getUserCheckins(user1.address);
      expect(checkins.length).to.equal(1);
    });

    it("should reject checkins outside radius", async function () {
      await expect(
        pocBeacons.connect(user1).recordCheckin(
          beaconId,
          "QR", 
          50000000, // Far away coordinates
          50000000
        )
      ).to.be.revertedWith("Outside beacon radius");
    });
  });

  describe("Sales Force Management", function () {
    beforeEach(async function () {
      await salesForce.connect(admin).addFoundingBroker(hustler.address);
    });

    it("should handle early pack purchases", async function () {
      const packPrice = ethers.parseEther("25");
      
      await mockUSDC.connect(user1).approve(salesForce.target, packPrice);
      
      await salesForce.connect(user1).purchaseEarlyPack(1, hustler.address);
      
      expect(await salesForce.upline(user1.address)).to.equal(hustler.address);
      
      const stats = await salesForce.getStats(hustler.address);
      expect(stats.totalSales).to.equal(packPrice);
      expect(stats.directRecruits).to.equal(1);
    });

    it("should enforce token lock periods", async function () {
      const packPrice = ethers.parseEther("25");
      
      await mockUSDC.connect(user1).approve(salesForce.target, packPrice);
      await salesForce.connect(user1).purchaseEarlyPack(1, hustler.address);
      
      // Should fail to unlock before lock period
      await expect(
        salesForce.connect(user1).unlockTokens()
      ).to.be.revertedWith("Still locked");
    });
  });

  describe("Governance System", function () {
    it("should create and execute burn rate proposals", async function () {
      // Transfer enough tokens to admin for proposal threshold
      await token.transfer(admin.address, ethers.parseEther("2000000")); // 2M tokens
      
      // Create proposal
      const newBurnRate = 400; // 4%
      const callData = ethers.AbiCoder.defaultAbiCoder().encode(["uint256"], [newBurnRate]);
      
      const proposalId = await governance.connect(admin).propose.staticCall(
        0, // BurnRate type
        "Increase burn rate to 4%",
        callData
      );
      
      await governance.connect(admin).propose(0, "Increase burn rate to 4%", callData);
      
      // Vote on proposal
      await governance.connect(admin).vote(proposalId, true);
      
      // Fast forward past voting period
      await time.increase(8 * 24 * 60 * 60); // 8 days
      
      // Sign execution
      await governance.connect(admin).signExecution(proposalId);
      
      // Fast forward past execution delay
      await time.increase(3 * 24 * 60 * 60); // 3 days
      
      // Set governance contract as admin on token
      await token.grantRole(await token.DEFAULT_ADMIN_ROLE(), governance.target);
      
      // Execute
      await governance.connect(admin).executeProposal(proposalId);
      
      expect(await token.burnRate()).to.equal(newBurnRate);
    });
  });

  describe("System Integration", function () {
    it("should demonstrate full user journey", async function () {
      await time.increase(7 * 24 * 60 * 60 + 1); // Past launch lock
      
      // 1. User purchases early pack
      await salesForce.connect(admin).addFoundingBroker(hustler.address);
      await mockUSDC.connect(user1).approve(salesForce.target, ethers.parseEther("25"));
      await salesForce.connect(user1).purchaseEarlyPack(1, hustler.address);
      
      // 2. User deposits to vault
      await assetVault.connect(user1).deposit(0, { value: ethers.parseEther("1") });
      
      // 3. User does POC checkin
      const beaconId = await pocBeacons.connect(admin).createBeacon.staticCall(
        "Gas Station", 40742000, -73989000, 100, owner.address
      );
      await pocBeacons.connect(admin).createBeacon(
        "Gas Station", 40742000, -73989000, 100, owner.address
      );
      
      await pocBeacons.connect(user1).recordCheckin(beaconId, "QR", 40742000, -73989000);
      
      // 4. Merchant creates offer and user purchases
      await revVault.connect(admin).addMerchant(merchant.address);
      await revVault.connect(merchant).createOffer(ethers.parseEther("50"), "Coffee Voucher");
      await mockUSDC.connect(user1).approve(revVault.target, ethers.parseEther("50"));
      await revVault.connect(user1).purchase(1, hustler.address);
      
      // Verify all systems working together
      expect(await token.pocStreaks(user1.address)).to.equal(1);
      expect(await assetVault.depositorShares(user1.address)).to.be.gt(0);
      expect(await salesForce.upline(user1.address)).to.equal(hustler.address);
      
      const offer = await revVault.getOffer(1);
      expect(offer.totalSales).to.equal(1);
    });
  });
});