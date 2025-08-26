// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ISovereigntyRegistry
/// @notice Interface for recording IP sovereignty proofs
interface ISovereigntyRegistry {
    function register(bytes32 id, string calldata jurisdiction, string calldata hash) external;
    function recordOf(bytes32 id)
        external
        view
        returns (address owner, string memory jurisdiction, string memory hash, uint256 timestamp);
}
