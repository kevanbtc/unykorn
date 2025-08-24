// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IWaterFlow {
    function setAllocation(address user, uint256 amount) external;
    function reportUsage(address user, uint256 amount) external;
    function settleFlow(address user) external returns (uint256);
}
