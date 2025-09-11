const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Stablecoin", function () {
  let deployer, minter, user, other;
  let compliance, token;

  beforeEach(async function () {
    [deployer, minter, user, other] = await ethers.getSigners();

    const Compliance = await ethers.getContractFactory("ComplianceManager");
    compliance = await Compliance.deploy(deployer.address);

    const Stablecoin = await ethers.getContractFactory("Stablecoin");
    token = await Stablecoin.deploy("RWA Dollar", "rUSD", deployer.address, await compliance.getAddress());

    const MINTER_ROLE = ethers.id("MINTER_ROLE");
    const BURNER_ROLE = ethers.id("BURNER_ROLE");
    await token.grantRole(MINTER_ROLE, minter.address);
    await token.grantRole(BURNER_ROLE, minter.address);
    await compliance.setWhitelist(user.address, true);
  });

  it("mints to whitelisted address", async function () {
    const ref = ethers.id("US_TREASURY");
    await token.connect(minter).mint(user.address, 1000n, ref);
    expect(await token.balanceOf(user.address)).to.equal(1000n);
  });

  it("reverts mint to non-whitelisted", async function () {
    const ref = ethers.id("US_TREASURY");
    await expect(token.connect(minter).mint(other.address, 1000n, ref)).to.be.revertedWith("Not whitelisted");
  });

  it("burns from whitelisted address", async function () {
    const ref = ethers.id("US_TREASURY");
    await token.connect(minter).mint(user.address, 1000n, ref);
    await token.connect(minter).burn(user.address, 400n, ref);
    expect(await token.balanceOf(user.address)).to.equal(600n);
  });
});

