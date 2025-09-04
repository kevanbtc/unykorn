// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Simple KYC/AML whitelist
contract ComplianceRegistry is Ownable {
    mapping(address => bool) private _whitelisted;

    event Whitelisted(address indexed account);
    event Removed(address indexed account);

    function add(address account) external onlyOwner {
        _whitelisted[account] = true;
        emit Whitelisted(account);
    }

    function remove(address account) external onlyOwner {
        _whitelisted[account] = false;
        emit Removed(account);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return _whitelisted[account];
    }
}

