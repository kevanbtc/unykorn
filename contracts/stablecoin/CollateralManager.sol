// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CollateralManager
/// @notice Manages collateral deposits backing the ESGStablecoin.
contract CollateralManager {
    mapping(address => uint256) public collateral;
    event CollateralDeposited(address indexed from, uint256 amount);
    event CollateralWithdrawn(address indexed to, uint256 amount);

    function deposit() external payable {
        collateral[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "insufficient collateral");
        collateral[msg.sender] -= amount;
        emit CollateralWithdrawn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}
