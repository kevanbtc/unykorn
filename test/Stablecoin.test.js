const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Stablecoin", function () {
  it("has correct name", async function () {
    const Stablecoin = await ethers.getContractFactory("Stablecoin");
    const stable = await Stablecoin.deploy();
    await stable.deployed();
    expect(await stable.name()).to.equal("UnykornUSD");
  });
});
