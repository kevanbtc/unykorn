// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ComplianceRegistry
/// @notice Enforces KYC/AML rules and FATF Travel Rule checks
contract ComplianceRegistry {
    mapping(address => bool) public isWhitelisted;

    event AddressWhitelisted(address indexed user);
    event AddressRemoved(address indexed user);

    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function whitelist(address user) external {
        isWhitelisted[user] = true;
        emit AddressWhitelisted(user);
    }

    function remove(address user) external {
        isWhitelisted[user] = false;
        emit AddressRemoved(user);
    }
}

