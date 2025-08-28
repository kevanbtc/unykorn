// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/// @title ComplianceMiddleware
/// @notice Enforces basic KYC requirements and provides a circuit breaker
/// @dev Contracts interacting with regulated flows can query `check` to
///      ensure an address has passed KYC verification.
contract ComplianceMiddleware is AccessControl, Pausable {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    mapping(address => bytes32) public kycHashes;

    event KYCUpdated(address indexed user, bytes32 kycHash);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Record the KYC hash for a user. Callable by approved verifiers.
    function setKYC(address user, bytes32 hash) external onlyRole(VERIFIER_ROLE) {
        kycHashes[user] = hash;
        emit KYCUpdated(user, hash);
    }

    /// @notice Pause all compliance checks.
    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    /// @notice Unpause compliance checks.
    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @notice Reverts if the user has not been KYC verified.
    function check(address user) external view whenNotPaused {
        require(kycHashes[user] != bytes32(0), "KYC missing");
    }
}

