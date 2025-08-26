const { expect } = require("chai");
const { ethers } = require("hardhat");

for (const name of ["FTHEquityToken", "FTHDebtToken"]) {
  describe(name, function () {
    let owner, investor1, investor2, token;
    this.timeout(0);

    beforeEach(async function () {
      [owner, investor1, investor2] = await ethers.getSigners();
      const Token = await ethers.getContractFactory(name);
      token = await Token.deploy();
      await token.deployed?.();
    });

    it("enforces max investors on mint", async function () {
      for (let i = 0; i < 199; i++) {
        const wallet = ethers.Wallet.createRandom();
        await token.mint(wallet.address, 1);
      }
      await expect(token.mint(investor1.address, 1))
        .to.emit(token, "MaxInvestorsReached")
        .withArgs(200);
      await expect(token.mint(ethers.Wallet.createRandom().address, 1)).to.be.revertedWith(
        "Investor limit reached"
      );
    });

    it("enforces max investors on transfer", async function () {
      for (let i = 0; i < 199; i++) {
        const wallet = ethers.Wallet.createRandom();
        await token.mint(wallet.address, 1);
      }
      await token.mint(investor1.address, 2);
      await expect(token.connect(investor1).transfer(investor2.address, 1)).to.be.revertedWith(
        "Investor limit reached"
      );
      await token.connect(investor1).transfer(investor2.address, 2);
      expect(await token.investorCount()).to.equal(200);
    });
  });
}

