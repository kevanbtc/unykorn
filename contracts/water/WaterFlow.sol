// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../compliance/RegLogic.sol";
import "./interfaces/IWaterFlow.sol";

/// @title WaterFlow
/// @notice Handles allocation, flow reporting, and settlement for tokenized water rights.
contract WaterFlow is IWaterFlow {
    address public regulator;
    mapping(address => uint256) public allocations;
    mapping(address => uint256) public usage;

    event AllocationSet(address indexed user, uint256 amount);
    event UsageReported(address indexed user, uint256 amount);
    event FlowSettled(address indexed user, uint256 amount);

    constructor(address _regulator) {
        regulator = _regulator;
    }

    function setAllocation(address user, uint256 amount) external override {
        require(msg.sender == regulator, "Only regulator");
        allocations[user] = amount;
        emit AllocationSet(user, amount);
    }

    function reportUsage(address user, uint256 amount) external override {
        usage[user] += amount;
        emit UsageReported(user, amount);
    }

    function settleFlow(address user) external override returns (uint256) {
        uint256 balance = allocations[user] - usage[user];
        emit FlowSettled(user, balance);
        return balance;
    }
}
