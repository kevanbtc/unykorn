const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProofOfReserves", function () {
  it("reads value from aggregator", async function () {
    const Mock = await ethers.getContractFactory("MockAggregator");
    const mock = await Mock.deploy(123);
    await mock.deployed();

    const Proof = await ethers.getContractFactory("ProofOfReserves");
    const proof = await Proof.deploy(mock.address);
    await proof.deployed();

    expect(await proof.getLatestReserve()).to.equal(123);
  });
});
