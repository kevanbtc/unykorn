const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Integration", function () {
  it("mints and burns with registry and compliance", async function () {
    const [admin, oracle, user] = await ethers.getSigners();

    const Compliance = await ethers.getContractFactory("ComplianceManager");
    const compliance = await Compliance.deploy(admin.address);

    const Stablecoin = await ethers.getContractFactory("Stablecoin");
    const token = await Stablecoin.deploy("RWA Dollar", "rUSD", admin.address, await compliance.getAddress());

    const Registry = await ethers.getContractFactory("RWARegistry");
    const registry = await Registry.deploy(admin.address);

    const ORACLE_ROLE = ethers.id("ORACLE_ROLE");
    await registry.grantRole(ORACLE_ROLE, oracle.address);

    const assetId = ethers.id("TREASURY");
    const proof = ethers.id("PROOF");
    await registry.connect(oracle).updateAsset(assetId, 10000, proof);

    await compliance.setWhitelist(user.address, true);
    const MINTER_ROLE = ethers.id("MINTER_ROLE");
    const BURNER_ROLE = ethers.id("BURNER_ROLE");
    await token.grantRole(MINTER_ROLE, admin.address);
    await token.grantRole(BURNER_ROLE, admin.address);

    await token.mint(user.address, 500n, assetId);
    await token.burn(user.address, 200n, assetId);
    expect(await token.balanceOf(user.address)).to.equal(300n);
  });
});

