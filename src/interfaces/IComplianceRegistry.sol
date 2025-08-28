// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IComplianceRegistry {
    function isAllowed(address addr) external view returns (bool);
    function jurisdictionOf(address addr) external view returns (bytes32);
    function kycLevel(address addr) external view returns (uint8);
}
