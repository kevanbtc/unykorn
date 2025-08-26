const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Coverage", function () {
  let coverage, owner, treasury, user, attacker;
  beforeEach(async function () {
    [owner, treasury, user, attacker] = await ethers.getSigners();
    const Coverage = await ethers.getContractFactory("Coverage");
    coverage = await Coverage.deploy(owner.address);
    await coverage.deployed();
    const TREASURY_ROLE = await coverage.TREASURY_ROLE();
    await coverage.connect(owner).grantRole(TREASURY_ROLE, treasury.address);
  });

  it("treasury can issue coverage and pay claim when funded", async function () {
    const amount = ethers.utils.parseEther("1");
    await coverage.connect(treasury).issueCoverage(user.address, amount);
    await owner.sendTransaction({ to: coverage.address, value: amount });

    const before = await ethers.provider.getBalance(user.address);
    await coverage.connect(treasury).payClaim(user.address, amount);
    const after = await ethers.provider.getBalance(user.address);

    expect(after.sub(before)).to.equal(amount);
    expect(await coverage.coverageOf(user.address)).to.equal(0);
  });

  it("non-treasury cannot issue coverage", async function () {
    await expect(
      coverage.connect(attacker).issueCoverage(user.address, 1)
    ).to.be.reverted;
  });

  it("non-treasury cannot pay claim", async function () {
    await expect(
      coverage.connect(attacker).payClaim(user.address, 1)
    ).to.be.reverted;
  });

  it("reverts when vault balance insufficient", async function () {
    const amount = ethers.utils.parseEther("1");
    await coverage.connect(treasury).issueCoverage(user.address, amount);

    await expect(
      coverage.connect(treasury).payClaim(user.address, amount)
    ).to.be.revertedWith("insufficient vault balance");
  });
});

