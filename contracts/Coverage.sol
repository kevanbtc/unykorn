// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Simple coverage vault that pays claims from ETH balance
/// @notice Coverage can only be issued and claims paid by accounts with the TREASURY_ROLE
contract Coverage is Ownable, AccessControl {
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    // Track how much coverage each policy holder has
    mapping(address => uint256) public coverageOf;

    constructor(address owner) Ownable(owner) {
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(TREASURY_ROLE, owner);
    }

    /// @notice Issue coverage to a policy holder
    /// @param to Address receiving coverage
    /// @param amount Coverage amount to credit
    function issueCoverage(address to, uint256 amount) external onlyRole(TREASURY_ROLE) {
        coverageOf[to] += amount;
    }

    /// @notice Pay an insurance claim to a policy holder
    /// @param to Address receiving the claim payment
    /// @param amount Amount of ETH to pay
    function payClaim(address to, uint256 amount) external onlyRole(TREASURY_ROLE) {
        require(coverageOf[to] >= amount, "not covered");
        require(address(this).balance >= amount, "insufficient vault balance");
        coverageOf[to] -= amount;
        (bool ok, ) = payable(to).call{value: amount}("");
        require(ok, "transfer failed");
    }

    /// @notice Allow the contract to receive ETH to fund claims
    receive() external payable {}
}

