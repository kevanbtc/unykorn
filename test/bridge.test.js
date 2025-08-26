const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CBDCBridge", function () {
  it("emits mint and burn events", async function () {
    const [, user] = await ethers.getSigners();
    const Bridge = await ethers.getContractFactory("CBDCBridge");
    const bridge = await Bridge.deploy();

    await expect(bridge.mint(user.address, 100))
      .to.emit(bridge, "CBDCMinted")
      .withArgs(user.address, 100);

    await expect(bridge.burn(user.address, 50))
      .to.emit(bridge, "CBDCBurned")
      .withArgs(user.address, 50);
  });
});
