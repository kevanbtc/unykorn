const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComplianceRegistry", function () {
  it("can whitelist", async function () {
    const Compliance = await ethers.getContractFactory("ComplianceRegistry");
    const registry = await Compliance.deploy();
    await registry.deployed();
    const [addr] = await ethers.getSigners();
    await registry.addToWhitelist(addr.address);
    expect(await registry.whitelisted(addr.address)).to.equal(true);
  });
});
