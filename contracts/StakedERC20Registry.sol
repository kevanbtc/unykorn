// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Registry for approved staked ERC20 tokens
/// @notice Allows the owner to approve or revoke tokens
contract StakedERC20Registry is Ownable {
    mapping(address => bool) public approved;

    event Approved(address indexed token);
    event Revoked(address indexed token);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function approve(address token) external onlyOwner {
        approved[token] = true;
        emit Approved(token);
    }

    function revoke(address token) external onlyOwner {
        approved[token] = false;
        emit Revoked(token);
    }
}

