const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ESGStablecoin", function () {
  it("mints when vault approved", async function () {
    const Token = await ethers.getContractFactory("MockERC20");
    const token = await Token.deploy("Water", "WAT");

    const Vault = await ethers.getContractFactory("WaterVault");
    const vault = await Vault.deploy(token.address);

    const Stablecoin = await ethers.getContractFactory("ESGStablecoin");
    const stable = await Stablecoin.deploy();

    await stable.addCollateralVault(vault.address, 50);
    await expect(stable.mint(vault.address, 100)).to.emit(stable, "Transfer");
  });

  it("mints and burns tokens for user", async function () {
    const [, user] = await ethers.getSigners();

    const Stablecoin = await ethers.getContractFactory("ESGStablecoin");
    const stable = await Stablecoin.deploy();

    await stable.mint(user.address, 1000);
    expect(await stable.balanceOf(user.address)).to.equal(1000);

    await stable.connect(user).burn(400);
    expect(await stable.balanceOf(user.address)).to.equal(600);
  });

  it("reverts for unapproved vault", async function () {
    const Stablecoin = await ethers.getContractFactory("ESGStablecoin");
    const stable = await Stablecoin.deploy();

    await expect(
      stable.mint(ethers.constants.AddressZero, 100)
    ).to.be.revertedWith("Vault not approved");
  });
});
