const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ForwardingRegistry", function () {
  let owner, user, registry;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("ForwardingRegistry");
    registry = await Registry.deploy(owner.address);
  });

  it("non-owner cannot approve forwarders", async function () {
    await expect(
      registry.connect(user).approveForwarder(user.address)
    ).to.be.revertedWithCustomError(registry, "OwnableUnauthorizedAccount");
  });

  it("non-owner cannot revoke forwarders", async function () {
    // first approve as owner so revoke is meaningful
    await registry.approveForwarder(user.address);
    await expect(
      registry.connect(user).revokeForwarder(user.address)
    ).to.be.revertedWithCustomError(registry, "OwnableUnauthorizedAccount");
  });
});
