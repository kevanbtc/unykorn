const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ComplianceManager", function () {
  it("manages whitelist", async function () {
    const [admin, user] = await ethers.getSigners();
    const Compliance = await ethers.getContractFactory("ComplianceManager");
    const compliance = await Compliance.deploy(admin.address);

    expect(await compliance.isWhitelisted(user.address)).to.equal(false);
    await compliance.setWhitelist(user.address, true);
    expect(await compliance.isWhitelisted(user.address)).to.equal(true);
  });
});

