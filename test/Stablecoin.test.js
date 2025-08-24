const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Stablecoin", function () {
  it("mints only for whitelisted addresses", async function () {
    const [admin, user] = await ethers.getSigners();
    const token = await (await ethers.getContractFactory("Stablecoin")).deploy();
    await token.deployed();

    await token.whitelist(user.address);
    await token.mint(user.address, 1000);
    expect(await token.balanceOf(user.address)).to.equal(1000);
  });
});
