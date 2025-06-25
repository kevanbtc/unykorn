const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TokenStakingPool", function () {
  let stakingToken, rewardToken, pool, owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    const ERC20 = await ethers.getContractFactory("MockERC20");
    stakingToken = await ERC20.deploy("Stake", "STK", ethers.parseEther("1000"));
    rewardToken = await ERC20.deploy("Reward", "RWD", ethers.parseEther("1000"));
    const Pool = await ethers.getContractFactory("TokenStakingPool");
    pool = await Pool.deploy(stakingToken.getAddress(), rewardToken.getAddress());

    await stakingToken.transfer(user.address, ethers.parseEther("100"));
    await stakingToken.connect(user).approve(pool.getAddress(), ethers.parseEther("100"));
  });

  it("allows staking and earning rewards", async function () {
    await pool.connect(user).stake(ethers.parseEther("10"));
    // mine a few blocks
    for (let i = 0; i < 5; i++) {
      await ethers.provider.send("evm_mine");
    }
    const rewards = await pool.calculateRewards(user.address);
    expect(rewards).to.be.gt(0);
    await pool.connect(user).claimRewards();
    expect(await rewardToken.balanceOf(user.address)).to.equal(rewards);
  });
});
