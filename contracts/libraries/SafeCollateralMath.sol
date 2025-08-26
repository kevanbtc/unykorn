// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SafeCollateralMath
/// @notice Helper library for collateral calculations
library SafeCollateralMath {
    function maxMint(uint256 collateralValue, uint256 ltvBps) internal pure returns (uint256) {
        return (collateralValue * ltvBps) / 10_000;
    }
}
