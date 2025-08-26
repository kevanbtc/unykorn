const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ESGOracle", function () {
  it("sets and reads a mock price", async function () {
    const Oracle = await ethers.getContractFactory("ESGOracle");
    const oracle = await Oracle.deploy();

    await oracle.setPrice(100);
    expect(await oracle.latestPrice()).to.equal(100);
  });
});
