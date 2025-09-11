// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title ComplianceManager
/// @notice Admin-controlled whitelist for KYC/AML compliance
contract ComplianceManager is AccessControl {
    bytes32 public constant COMPLIANCE_ADMIN = keccak256("COMPLIANCE_ADMIN");

    mapping(address => bool) private whitelisted;

    event Whitelisted(address indexed user, bool status);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(COMPLIANCE_ADMIN, admin);
    }

    /// @notice Adds or removes a user from the whitelist
    function setWhitelist(address user, bool status) external onlyRole(COMPLIANCE_ADMIN) {
        whitelisted[user] = status;
        emit Whitelisted(user, status);
    }

    /// @notice Returns true if the user is whitelisted
    function isWhitelisted(address user) external view returns (bool) {
        return whitelisted[user];
    }
}

