// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SovereigntyUtils
/// @notice Utilities for encoding jurisdiction codes and creating proof identifiers
library SovereigntyUtils {
    function idFor(address owner, string memory jurisdiction, string memory hash) internal pure returns (bytes32) {
        return keccak256(abi.encode(owner, jurisdiction, hash));
    }
}
