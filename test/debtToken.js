const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("FTHDebtToken", function () {
  it("blocks transfers to non-compliant addresses", async function () {
    const [owner, investor1, investor2] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await Registry.deploy();
    await registry.addInvestor(investor1.address, false, "IN");

    const now = (await ethers.provider.getBlock("latest")).timestamp;
    const Debt = await ethers.getContractFactory("FTHDebtToken");
    const debt = await Debt.deploy(now + 3600, registry.address);

    await debt.mint(investor1.address, ethers.utils.parseEther("1"));

    await expect(
      debt.connect(investor1).transfer(investor2.address, ethers.utils.parseEther("1"))
    ).to.be.revertedWith("Not compliant");
  });

  it("enforces FX limits via registry", async function () {
    const [owner, foreign] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await Registry.deploy();
    await registry.addInvestor(foreign.address, true, "US");
    await registry.setFXLimitPerInvestor(100);

    const now = (await ethers.provider.getBlock("latest")).timestamp;
    const Debt = await ethers.getContractFactory("FTHDebtToken");
    const debt = await Debt.deploy(now + 3600, registry.address);

    await debt.mint(foreign.address, 100);
    await expect(debt.mint(foreign.address, 1)).to.be.revertedWith(
      "FX limit per investor exceeded"
    );
  });
});
