// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ILicenseNFT
/// @notice Interface for subscription licenses in the Unykorn ecosystem
interface ILicenseNFT {
    function mintLicense(address to, uint256 id, uint256 duration) external;
    function isValid(uint256 id, address user) external view returns (bool);
    function expiryOf(uint256 id, address user) external view returns (uint256);
}
