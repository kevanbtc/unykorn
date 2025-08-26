// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IERC20Vault
/// @notice Interface for ERC-4626 compliant vaults used by the Unykorn stablecoin
interface IERC20Vault {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function asset() external view returns (address);
    function totalAssets() external view returns (uint256);
}
