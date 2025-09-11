const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RWARegistry", function () {
  let deployer, oracle;
  let registry;

  beforeEach(async function () {
    [deployer, oracle] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("RWARegistry");
    registry = await Registry.deploy(deployer.address);
    const ORACLE_ROLE = ethers.id("ORACLE_ROLE");
    await registry.grantRole(ORACLE_ROLE, oracle.address);
  });

  it("stores asset data", async function () {
    const id = ethers.id("TREASURY");
    const proof = ethers.id("PROOF");
    await registry.connect(oracle).updateAsset(id, 10000, proof);
    const asset = await registry.getAsset(id);
    expect(asset.collateralRatio).to.equal(10000);
    expect(asset.proofHash).to.equal(proof);
    expect(asset.frozen).to.equal(false);
  });

  it("freezes asset", async function () {
    const id = ethers.id("TREASURY");
    await registry.freezeAsset(id, true);
    const asset = await registry.getAsset(id);
    expect(asset.frozen).to.equal(true);
  });
});

