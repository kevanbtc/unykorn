// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract AgglayerBridge {
    IERC20 public token;
    address public owner;

    event Deposited(address indexed user, uint256 amount, string destinationChain, address recipient);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function deposit(uint256 amount, string calldata destinationChain, address recipient) external {
        require(amount > 0, "Zero deposit");
        token.transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount, destinationChain, recipient);
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        token.transfer(owner, amount);
        emit Withdrawn(owner, amount);
    }
}
