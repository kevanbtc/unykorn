const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComplianceRegistry", function () {
  it("tracks whitelist and blacklist", async function () {
    const [admin, user] = await ethers.getSigners();
    const registry = await (await ethers.getContractFactory("ComplianceRegistry")).deploy();
    await registry.deployed();

    await registry.whitelist(user.address);
    expect(await registry.whitelisted(user.address)).to.equal(true);

    await registry.blacklist(user.address);
    expect(await registry.blacklisted(user.address)).to.equal(true);
  });
});
