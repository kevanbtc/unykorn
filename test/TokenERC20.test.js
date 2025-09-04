const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");

describe("TokenERC20", function () {
  let token, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("TokenERC20");
    token = await Token.deploy();
    await token.waitForDeployment();
    await token.initialize("Meme", "MEME");
  });

  it("mints initial supply to deployer", async function () {
    const bal = await token.balanceOf(owner.address);
    expect(bal).to.equal(ethers.parseEther("1000000000000")); // 1 trillion tokens
  });

  it("enforces launch lock", async function () {
    await expect(token.transfer(user.address, 1)).to.be.revertedWith("TRANSFERS_LOCKED");
    await time.increase(7 * 24 * 60 * 60 + 1);
    await expect(token.transfer(user.address, 1)).to.emit(token, "Transfer");
  });
});
