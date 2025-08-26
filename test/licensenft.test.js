const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UnykornLicenseNFT", function () {
  it("mints license and checks validity", async function () {
    const [user] = await ethers.getSigners();
    const License = await ethers.getContractFactory("UnykornLicenseNFT");
    const license = await License.deploy();

    const duration = 1000;
    await license.mintLicense(user.address, 1, duration); // Pro tier

    expect(await license.isValid(1)).to.equal(true);

    await ethers.provider.send("evm_increaseTime", [duration + 1]);
    await ethers.provider.send("evm_mine");

    expect(await license.isValid(1)).to.equal(false);
  });
});
