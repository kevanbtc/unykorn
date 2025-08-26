// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ComplianceLib
/// @notice Helper functions for whitelist and Travel Rule enforcement
library ComplianceLib {
    function requireWhitelisted(mapping(address => bool) storage whitelist, address account) internal view {
        require(whitelist[account], "Not whitelisted");
    }
}
