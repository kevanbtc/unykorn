const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RevenueRouter", function () {
  it("withholds tax based on jurisdiction", async function () {
    const [owner, debt, equity, reserve, investorDomestic, investorForeign, taxAuth] = await ethers.getSigners();

    const Stable = await ethers.getContractFactory("MockStablecoin");
    const stable = await Stable.deploy();

    const Registry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await Registry.deploy();
    await registry.addInvestor(investorDomestic.address, false, "IN");
    await registry.addInvestor(investorForeign.address, true, "US");

    const Router = await ethers.getContractFactory("RevenueRouter");
    const router = await Router.deploy(
      stable.address,
      debt.address,
      equity.address,
      reserve.address,
      registry.address,
      taxAuth.address,
      50,
      50
    );

    // Domestic investor
    await stable.mint(owner.address, 1000);
    await stable.approve(router.address, 1000);
    await router.distribute(1000, investorDomestic.address, "IN");
    // 10% tax = 100
    expect(await stable.balanceOf(taxAuth.address)).to.equal(100);

    // Foreign investor
    await stable.mint(owner.address, 1000);
    await stable.approve(router.address, 1000);
    await router.distribute(1000, investorForeign.address, "US");
    // additional 20% tax = 200 (total 100 + 200 = 300)
    expect(await stable.balanceOf(taxAuth.address)).to.equal(300);
  });
});
