// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ComplianceRegistry {
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;

    event Whitelisted(address indexed user);
    event Blacklisted(address indexed user);

    function addToWhitelist(address user) external {
        whitelisted[user] = true;
        emit Whitelisted(user);
    }

    function addToBlacklist(address user) external {
        blacklisted[user] = true;
        emit Blacklisted(user);
    }

    function isCompliant(address user) external view returns (bool) {
        return whitelisted[user] && !blacklisted[user];
    }
}
