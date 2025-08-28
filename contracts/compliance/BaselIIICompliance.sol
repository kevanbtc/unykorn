// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title Basel III Compliance Library
/// @notice Provides capital ratio calculations
contract BaselIIICompliance {
    /// @notice Compute Tier1 capital ratio
    /// @param tier1 tier1 capital amount
    /// @param riskWeightedAssets total risk weighted assets
    /// @return ratio capital ratio scaled by 1e18
    error ZeroRiskWeightedAssets();

    function capitalRatio(uint256 tier1, uint256 riskWeightedAssets) external pure returns (uint256 ratio) {
        if (riskWeightedAssets == 0) revert ZeroRiskWeightedAssets();
        return (tier1 * 1e18) / riskWeightedAssets;
    }
}
