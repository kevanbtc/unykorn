// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ComplianceRegistry is AccessControl {
    bytes32 public constant COMPLIANCE_ADMIN = keccak256("COMPLIANCE_ADMIN");
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(COMPLIANCE_ADMIN, msg.sender);
    }

    function whitelist(address user) external onlyRole(COMPLIANCE_ADMIN) {
        whitelisted[user] = true;
    }

    function blacklist(address user) external onlyRole(COMPLIANCE_ADMIN) {
        blacklisted[user] = true;
    }
}
