const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SoulboundSafe", function () {
  it("Should lock minting", async function () {
    const [owner, addr1] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("SoulboundSafe");
    const contract = await Contract.deploy(ethers.constants.AddressZero, ethers.constants.AddressZero);
    await contract.deployed();

    await contract.toggleMint(true);
    await expect(contract.mint(addr1.address, 1, "name", "uri")).to.be.revertedWith("Minting locked");
  });
});
