// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Real World Asset Vault
/// @notice Tracks collateral asset values with role-based controls
contract RWAVault is AccessControl {
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    mapping(string => uint256) public assetValues;

    /// @notice Emitted when an asset value is reported
    /// @param assetId identifier of the asset
    /// @param value reported value
    event AssetValueReported(string assetId, uint256 value);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(AUDITOR_ROLE, admin);
    }

    /// @notice Report value for a given asset
    /// @param assetId identifier string
    /// @param value latest valuation
    function reportAssetValue(string calldata assetId, uint256 value)
        external
        onlyRole(AUDITOR_ROLE)
    {
        assetValues[assetId] = value;
        emit AssetValueReported(assetId, value);
    }
}
