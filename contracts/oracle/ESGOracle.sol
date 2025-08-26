// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ESGOracle
/// @notice Simple mock oracle for ESG data feeds
contract ESGOracle {
    int256 private price;

    /// @notice Sets a mock price value
    function setPrice(int256 newPrice) external {
        price = newPrice;
    }

    /// @notice Reads the latest mock price
    function latestPrice() external view returns (int256) {
        return price;
    }
}
