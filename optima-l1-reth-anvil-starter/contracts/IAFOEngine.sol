// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
interface IAFOEngine {
    struct Preflight {
        address buyer; address seller; address asset;
        uint256 price; bytes32 policyId; bytes proofCID;
    }
    function preflight(Preflight calldata p) external returns (bool ok, bytes memory memo);
}
