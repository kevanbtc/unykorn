// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenStakingPool is Ownable {
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    uint256 public rewardRate = 1000; // reward per block per token staked
    uint256 public totalStaked;

    struct Staker {
        uint256 stakedAmount;
        uint256 lastStakedBlock;
        uint256 rewards;
    }

    mapping(address => Staker) public stakers;

    constructor(address _stakingToken, address _rewardToken) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than zero");
        stakingToken.transferFrom(msg.sender, address(this), _amount);

        Staker storage staker = stakers[msg.sender];
        staker.rewards = calculateRewards(msg.sender);
        staker.stakedAmount += _amount;
        staker.lastStakedBlock = block.number;
        totalStaked += _amount;
    }

    function unstake(uint256 _amount) external {
        Staker storage staker = stakers[msg.sender];
        require(staker.stakedAmount >= _amount, "Insufficient balance");

        staker.rewards = calculateRewards(msg.sender);
        staker.stakedAmount -= _amount;
        totalStaked -= _amount;

        stakingToken.transfer(msg.sender, _amount);
    }

    function calculateRewards(address _user) public view returns (uint256) {
        Staker storage staker = stakers[_user];
        uint256 blocksStaked = block.number - staker.lastStakedBlock;
        uint256 reward = staker.stakedAmount * blocksStaked * rewardRate;
        return reward;
    }

    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint256 rewardsToClaim = staker.rewards + calculateRewards(msg.sender);
        require(rewardsToClaim > 0, "No rewards available");

        staker.rewards = 0;
        staker.lastStakedBlock = block.number;

        rewardToken.transfer(msg.sender, rewardsToClaim);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 contractBalance = stakingToken.balanceOf(address(this));
        stakingToken.transfer(owner(), contractBalance);
    }
}
