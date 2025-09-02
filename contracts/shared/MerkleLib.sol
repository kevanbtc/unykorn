// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library MerkleLib {
    /// @notice verify that a leaf is part of a Merkle tree defined by root
    /// @param proof sibling hashes on the branch from the leaf to the root
    /// @param root root of the Merkle tree
    /// @param leaf leaf to verify
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computed = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computed <= proofElement) {
                computed = keccak256(abi.encodePacked(computed, proofElement));
            } else {
                computed = keccak256(abi.encodePacked(proofElement, computed));
            }
        }
        return computed == root;
    }

    /// @notice helper to compute leaf hash from account and amount
    function leaf(address account, uint256 amount) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, amount));
    }
}

