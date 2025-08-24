// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Vault Manager
/// @notice Placeholder contract for managing project-specific vaults.
contract VaultManager {
    mapping(address => address) public projectVaults;

    function setVault(address project, address vault) external {
        projectVaults[project] = vault;
    }
}

