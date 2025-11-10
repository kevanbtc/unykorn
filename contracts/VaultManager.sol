// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Minimal registry for asset vaults
contract VaultManager is Ownable {
    mapping(uint256 => address) public vaults;
    event VaultRegistered(uint256 indexed assetId, address vault);

    function registerVault(uint256 assetId, address vault) external onlyOwner {
        vaults[assetId] = vault;
        emit VaultRegistered(assetId, vault);
    }
}

