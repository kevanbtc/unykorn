const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAO Governance", function () {
  it("should allow creating and voting on a proposal", async function () {
    const [owner, voter] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("GovernanceToken");
    const token = await Token.deploy(ethers.parseEther("1000"));
    await token.waitForDeployment();

    await token.mint(voter.address, ethers.parseEther("10"));

    const DAO = await ethers.getContractFactory("DAO");
    const dao = await DAO.deploy(token.target);
    await dao.waitForDeployment();

    await dao.connect(voter).createProposal("Test proposal", voter.address, 0);
    await dao.connect(voter).vote(0);

    const proposal = await dao.proposals(0);
    expect(proposal.voteCount).to.equal(1);
  });
});
