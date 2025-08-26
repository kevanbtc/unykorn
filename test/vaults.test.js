const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WaterVault", function () {
  it("deposits and withdraws underlying assets", async function () {
    const [owner, user] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("MockERC20");
    const token = await Token.connect(owner).deploy("Water Token", "WAT");

    const Vault = await ethers.getContractFactory("WaterVault");
    const vault = await Vault.deploy(token.address);

    await token.mint(user.address, 1000);
    await token.connect(user).approve(vault.address, 500);

    await vault.connect(user).deposit(500, user.address);
    expect(await vault.balanceOf(user.address)).to.equal(500);

    await vault.connect(user).withdraw(200, user.address, user.address);

    expect(await vault.balanceOf(user.address)).to.equal(300);
    expect(await token.balanceOf(user.address)).to.equal(700);
  });
});
