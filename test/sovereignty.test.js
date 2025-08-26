const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UnykornSovereigntyRegistry", function () {
  it("records sovereignty information", async function () {
    const Registry = await ethers.getContractFactory(
      "UnykornSovereigntyRegistry"
    );
    const registry = await Registry.deploy();

    const id = ethers.utils.formatBytes32String("asset1");
    await registry.register(id, "US", "hash");

    const record = await registry.records(id);
    expect(record.owner).to.exist;
    expect(record.jurisdiction).to.equal("US");
    expect(record.hash).to.equal("hash");
  });
});
