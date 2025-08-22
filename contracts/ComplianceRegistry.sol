// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IComplianceRegistry {
    function isKYCed(address user) external view returns (bool);
}

contract ComplianceRegistry is Ownable, IComplianceRegistry {
    mapping(address => bool) private _kyc;

    event KYCSet(address indexed user, bool approved);

    constructor() Ownable(msg.sender) {}

    function setKYC(address user, bool approved) external onlyOwner {
        _kyc[user] = approved;
        emit KYCSet(user, approved);
    }

    function isKYCed(address user) external view override returns (bool) {
        return _kyc[user];
    }
}
