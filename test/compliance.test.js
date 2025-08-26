const assert = require("assert");
const { ethers } = require("hardhat");

describe("Compliance checks", function () {
  let registry;
  let token;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("ComplianceRegistry");
    registry = await Registry.deploy();
    await registry.deployed();

    await registry.setKycPassed(owner.address, true);
    await registry.setAmlPassed(owner.address, true);

    const VCHAN = await ethers.getContractFactory("VCHAN");
    token = await VCHAN.deploy(registry.address);
    await token.deployed();
  });

  it("blocks transfers to non-compliant recipients", async function () {
    await assert.rejects(token.transfer(user1.address, 1), /Non-compliant/);
    await registry.setKycPassed(user1.address, true);
    await assert.rejects(token.transfer(user1.address, 1), /Non-compliant/);
    await registry.setAmlPassed(user1.address, true);
    await token.transfer(user1.address, 1);
  });

  it("blocks transfers from non-compliant senders", async function () {
    await registry.setKycPassed(user1.address, true);
    await registry.setAmlPassed(user1.address, true);
    await token.transfer(user1.address, 1);

    await registry.setKycPassed(user1.address, false);
    await assert.rejects(
      token.connect(user1).transfer(user2.address, 1),
      /Non-compliant/
    );
  });
});
