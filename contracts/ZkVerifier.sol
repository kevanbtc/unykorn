// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ZkVerifier {
    address public verifier;

    event ProofVerified(address indexed caller, bool valid);

    constructor(address _verifier) {
        verifier = _verifier;
    }

    function verifyProof(bytes calldata proof, bytes32[] calldata inputs) external returns (bool) {
        bool valid = (proof.length > 0 && inputs.length > 0);
        emit ProofVerified(msg.sender, valid);
        return valid;
    }
}
