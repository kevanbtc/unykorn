const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakedERC20Registry", function () {
  let owner, user, registry;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("StakedERC20Registry");
    registry = await Registry.deploy(owner.address);
  });

  it("non-owner cannot approve tokens", async function () {
    await expect(
      registry.connect(user).approve(user.address)
    ).to.be.revertedWithCustomError(registry, "OwnableUnauthorizedAccount");
  });

  it("non-owner cannot revoke tokens", async function () {
    await registry.approve(user.address);
    await expect(
      registry.connect(user).revoke(user.address)
    ).to.be.revertedWithCustomError(registry, "OwnableUnauthorizedAccount");
  });
});
