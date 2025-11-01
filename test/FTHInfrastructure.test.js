const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("FTH Sovereign Settlement Infrastructure", function () {
  let usdf, fthg, fthToken, dex, treasury, escrow, vaultProof;
  let deployer, ceo, cfo, custodian, auditor, compliance, user1, user2;

  beforeEach(async function () {
    [deployer, ceo, cfo, custodian, auditor, compliance, user1, user2] = await ethers.getSigners();

    // Deploy Treasury
    const Treasury = await ethers.getContractFactory("FTHTreasury");
    treasury = await Treasury.deploy(
      ceo.address,
      cfo.address,
      custodian.address,
      auditor.address,
      compliance.address
    );

    // Deploy USDF Token
    const USDF = await ethers.getContractFactory("USDFToken");
    usdf = await upgrades.deployProxy(USDF, [treasury.target], { kind: "uups" });

    // Deploy FTHG Token
    const FTHG = await ethers.getContractFactory("FTHGToken");
    fthg = await upgrades.deployProxy(
      FTHG,
      [treasury.target, custodian.address, auditor.address],
      { kind: "uups" }
    );

    // Deploy FTH Governance Token
    const FTHGov = await ethers.getContractFactory("FTHGovernanceToken");
    fthToken = await upgrades.deployProxy(FTHGov, [treasury.target], { kind: "uups" });

    // Deploy Private DEX
    const DEX = await ethers.getContractFactory("FTHPrivateDEX");
    dex = await upgrades.deployProxy(
      DEX,
      [treasury.target, usdf.target, fthg.target, ethers.parseEther("1000")],
      { kind: "uups" }
    );

    // Deploy Escrow
    const Escrow = await ethers.getContractFactory("FTHEscrow");
    escrow = await upgrades.deployProxy(Escrow, [treasury.target, custodian.address], {
      kind: "uups",
    });

    // Deploy Vault Proof NFT
    const VaultProof = await ethers.getContractFactory("VaultProofNFT");
    vaultProof = await upgrades.deployProxy(
      VaultProof,
      [treasury.target, custodian.address, auditor.address],
      { kind: "uups" }
    );
  });

  describe("USDF Token", function () {
    it("Should mint USDF to whitelisted addresses", async function () {
      // Deployer needs to grant roles since treasury.target has admin
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);
      await usdf.grantRole(await usdf.COMPLIANCE_ROLE(), deployer.address);
      await usdf.setWhitelisted(user1.address, true);

      // Mint tokens
      await usdf.mint(user1.address, ethers.parseEther("1000"));

      expect(await usdf.balanceOf(user1.address)).to.equal(ethers.parseEther("1000"));
    });

    it("Should prevent minting to non-whitelisted addresses", async function () {
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);

      await expect(
        usdf.mint(user1.address, ethers.parseEther("1000"))
      ).to.be.revertedWith("USDF: recipient not whitelisted");
    });

    it("Should enforce whitelist on transfers", async function () {
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);
      await usdf.grantRole(await usdf.COMPLIANCE_ROLE(), deployer.address);
      await usdf.setWhitelisted(user1.address, true);
      await usdf.setWhitelisted(user2.address, true);
      await usdf.mint(user1.address, ethers.parseEther("1000"));

      // Transfer should work between whitelisted addresses
      await usdf.connect(user1).transfer(user2.address, ethers.parseEther("100"));
      expect(await usdf.balanceOf(user2.address)).to.equal(ethers.parseEther("100"));
    });

    it("Should allow redemption requests", async function () {
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);
      await usdf.grantRole(await usdf.COMPLIANCE_ROLE(), deployer.address);
      await usdf.setWhitelisted(user1.address, true);
      await usdf.mint(user1.address, ethers.parseEther("1000"));

      await usdf.connect(user1).requestRedemption(ethers.parseEther("500"));
      expect(await usdf.redemptionRequests(user1.address)).to.equal(ethers.parseEther("500"));
    });
  });

  describe("FTHG Gold Token", function () {
    it("Should mint gold-backed tokens", async function () {
      await fthg.connect(custodian).grantRole(await fthg.COMPLIANCE_ROLE(), custodian.address);
      await fthg.connect(custodian).setWhitelisted(user1.address, true);
      await fthg.connect(custodian).mint(user1.address, 10); // 10 troy oz

      expect(await fthg.balanceOf(user1.address)).to.equal(ethers.parseEther("10"));
      expect(await fthg.totalPhysicalGold()).to.equal(10);
    });

    it("Should handle physical gold redemption requests", async function () {
      await fthg.connect(custodian).grantRole(await fthg.COMPLIANCE_ROLE(), custodian.address);
      await fthg.connect(custodian).setWhitelisted(user1.address, true);
      await fthg.connect(custodian).mint(user1.address, 10);

      await fthg.connect(user1).requestPhysicalRedemption(5);
      expect(await fthg.physicalRedemptions(user1.address)).to.equal(5);
    });

    it("Should allow auditor to update vault proof", async function () {
      const ipfsHash = "QmTest123...";
      await fthg.connect(auditor).updateVaultProof(ipfsHash);

      expect(await fthg.vaultProofURI()).to.equal(ipfsHash);
      expect(await fthg.lastAuditTimestamp()).to.be.gt(0);
    });
  });

  describe("Private DEX", function () {
    beforeEach(async function () {
      // Setup tokens and whitelist
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);
      await usdf.grantRole(await usdf.COMPLIANCE_ROLE(), deployer.address);
      await fthg.connect(custodian).grantRole(await fthg.COMPLIANCE_ROLE(), custodian.address);

      await usdf.setWhitelisted(user1.address, true);
      await usdf.setWhitelisted(dex.target, true);
      await fthg.connect(custodian).setWhitelisted(user1.address, true);
      await fthg.connect(custodian).setWhitelisted(dex.target, true);

      // Mint tokens
      await usdf.mint(user1.address, ethers.parseEther("10000"));
      await fthg.connect(custodian).mint(user1.address, 100); // 100 oz
    });

    it("Should create trading pairs", async function () {
      await dex.grantRole(await dex.OPERATOR_ROLE(), deployer.address);
      await dex.createPair(usdf.target, fthg.target);

      const pairId = await dex.getPairId(usdf.target, fthg.target);
      const pair = await dex.pairs(pairId);
      expect(pair.active).to.be.true;
    });

    it("Should check discount qualification", async function () {
      // User1 has enough USDF to qualify
      const qualified = await dex.isQualifiedForDiscount(user1.address);
      expect(qualified).to.be.true;

      // User2 doesn't have enough
      const notQualified = await dex.isQualifiedForDiscount(user2.address);
      expect(notQualified).to.be.false;
    });
  });

  describe("Vault Proof NFT", function () {
    it("Should mint vault proof NFT", async function () {
      const tokenId = await vaultProof
        .connect(custodian)
        .mintVaultProof.staticCall(
          treasury.target,
          100, // 100 bars
          3110, // 3110 oz
          "ipfs://QmTest",
          "chainlink://proof",
          custodian.address
        );

      await vaultProof
        .connect(custodian)
        .mintVaultProof(
          treasury.target,
          100,
          3110,
          "ipfs://QmTest",
          "chainlink://proof",
          custodian.address
        );

      const proof = await vaultProof.getVaultProof(tokenId);
      expect(proof.goldBars).to.equal(100);
      expect(proof.totalOunces).to.equal(3110);
      expect(proof.verified).to.be.false;
    });

    it("Should allow auditor to verify vault proof", async function () {
      await vaultProof
        .connect(custodian)
        .mintVaultProof(
          treasury.target,
          100,
          3110,
          "ipfs://QmTest",
          "chainlink://proof",
          custodian.address
        );

      await vaultProof.connect(auditor).verifyVaultProof(1);

      const proof = await vaultProof.getVaultProof(1);
      expect(proof.verified).to.be.true;
      expect(await vaultProof.totalVerifiedGold()).to.equal(3110);
    });
  });

  describe("Multi-sig Treasury", function () {
    it("Should require 3 confirmations to execute", async function () {
      const txId = await treasury
        .connect(ceo)
        .proposeTransaction.staticCall(user1.address, 0, "0x");

      await treasury.connect(ceo).proposeTransaction(user1.address, 0, "0x");

      // Confirm from 3 signers
      await treasury.connect(ceo).confirmTransaction(txId);
      await treasury.connect(cfo).confirmTransaction(txId);
      await treasury.connect(custodian).confirmTransaction(txId);

      const tx = await treasury.transactions(txId);
      expect(tx.confirmations).to.equal(3);
    });

    it("Should enforce timelock delay", async function () {
      const txId = await treasury
        .connect(ceo)
        .proposeTransaction.staticCall(user1.address, 0, "0x");

      await treasury.connect(ceo).proposeTransaction(user1.address, 0, "0x");
      await treasury.connect(ceo).confirmTransaction(txId);
      await treasury.connect(cfo).confirmTransaction(txId);
      await treasury.connect(custodian).confirmTransaction(txId);

      // Should fail before timelock expires
      await expect(treasury.connect(ceo).executeTransaction(txId)).to.be.revertedWith(
        "Treasury: timelock active"
      );
    });
  });

  describe("Escrow", function () {
    beforeEach(async function () {
      await usdf.grantRole(await usdf.MINTER_ROLE(), deployer.address);
      await usdf.grantRole(await usdf.COMPLIANCE_ROLE(), deployer.address);
      await usdf.setWhitelisted(treasury.target, true);
      await usdf.setWhitelisted(escrow.target, true);
      await usdf.mint(treasury.target, ethers.parseEther("10000"));
    });

    it("Should create escrow for redemption", async function () {
      const releaseTime = Math.floor(Date.now() / 1000) + 86400; // 1 day from now

      // Get operator role and approve from treasury (needs multi-sig in production)
      await escrow.grantRole(await escrow.OPERATOR_ROLE(), deployer.address);
      await usdf.approve(escrow.target, ethers.parseEther("1000"));

      const escrowId = await escrow
        .createEscrow.staticCall(
          user1.address,
          usdf.target,
          ethers.parseEther("1000"),
          releaseTime,
          "gold"
        );

      await escrow
        .createEscrow(user1.address, usdf.target, ethers.parseEther("1000"), releaseTime, "gold");

      const escrowData = await escrow.getEscrow(escrowId);
      expect(escrowData.beneficiary).to.equal(user1.address);
      expect(escrowData.amount).to.equal(ethers.parseEther("1000"));
    });
  });
});
