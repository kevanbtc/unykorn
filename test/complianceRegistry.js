const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComplianceRegistry", function () {
  it("adds investors and marks KYC", async function () {
    const [owner, investor] = await ethers.getSigners();
    const ComplianceRegistry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await ComplianceRegistry.deploy();
    await registry.addInvestor(investor.address, false, "IN");
    expect(await registry.kycCompleted(investor.address)).to.equal(true);
  });

  it("enforces max investor count", async function () {
    const ComplianceRegistry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await ComplianceRegistry.deploy();
    const max = await registry.maxInvestors();
    for (let i = 0; i < max; i++) {
      const wallet = ethers.Wallet.createRandom();
      await registry.addInvestor(wallet.address, false, "IN");
    }
    const extra = ethers.Wallet.createRandom();
    await expect(registry.addInvestor(extra.address, false, "IN")).to.be.revertedWith(
      "Max investor limit reached"
    );
  });

  it("enforces FX caps per investor and aggregate", async function () {
    const [owner, f1, f2] = await ethers.getSigners();
    const ComplianceRegistry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await ComplianceRegistry.deploy();
    await registry.setFXLimitPerInvestor(100);
    await registry.setMaxTotalForeignInvestment(150);
    await registry.addInvestor(f1.address, true, "US");
    await registry.addInvestor(f2.address, true, "US");

    await registry.checkAndRecordForeignInvestment(f1.address, 100);
    await expect(
      registry.checkAndRecordForeignInvestment(f1.address, 1)
    ).to.be.revertedWith("FX limit per investor exceeded");

    await registry.checkAndRecordForeignInvestment(f2.address, 50);
    await expect(
      registry.checkAndRecordForeignInvestment(f2.address, 1)
    ).to.be.revertedWith("Total foreign investment limit exceeded");
  });
});
