// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract POLStaking {
    IERC20 public polToken;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakingTime;
    uint256 public totalStaked;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _polToken) {
        polToken = IERC20(_polToken);
    }

    function stake(uint256 amount) external {
        require(amount > 0, "Nothing to stake");
        polToken.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        stakingTime[msg.sender] = block.timestamp;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external {
        require(amount > 0 && balances[msg.sender] >= amount, "Invalid unstake");
        balances[msg.sender] -= amount;
        totalStaked -= amount;
        polToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }
}
