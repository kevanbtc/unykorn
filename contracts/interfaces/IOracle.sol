// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IOracle
/// @notice Simplified price feed interface for Unykorn modules
interface IOracle {
    function latestAnswer() external view returns (int256);
    function decimals() external view returns (uint8);
    function updateAnswer(int256 answer) external;
}
