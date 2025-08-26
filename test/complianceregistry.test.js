const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComplianceRegistry", function () {
  it("whitelists and removes addresses", async function () {
    const [user] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await Registry.deploy();

    await registry.whitelist(user.address);
    expect(await registry.isWhitelisted(user.address)).to.equal(true);

    await registry.remove(user.address);
    expect(await registry.isWhitelisted(user.address)).to.equal(false);
  });
});
