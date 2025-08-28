// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IComplianceRegistry} from "../interfaces/IComplianceRegistry.sol";

contract SimpleComplianceRegistry is IComplianceRegistry {
    mapping(address => bool) public allowed;
    mapping(address => bytes32) public juris;
    mapping(address => uint8)  public kyc;
    address public admin;

    event SetAllowed(address indexed user, bool allowed);
    event SetJurisdiction(address indexed user, bytes32 juris);
    event SetKYCLevel(address indexed user, uint8 level);
    event SetAdmin(address indexed newAdmin);

    modifier onlyAdmin() { require(msg.sender == admin, "not admin"); _; }

    constructor(address _admin) {
        require(_admin != address(0), "admin=0");
        admin = _admin;
    }

    function setAdmin(address _admin) external onlyAdmin {
        require(_admin != address(0), "admin=0");
        admin = _admin;
        emit SetAdmin(_admin);
    }

    function setAllowed(address user, bool isAllowed) external onlyAdmin {
        allowed[user] = isAllowed;
        emit SetAllowed(user, isAllowed);
    }

    function setJurisdiction(address user, bytes32 j) external onlyAdmin {
        juris[user] = j;
        emit SetJurisdiction(user, j);
    }

    function setKYCLevel(address user, uint8 lvl) external onlyAdmin {
        kyc[user] = lvl;
        emit SetKYCLevel(user, lvl);
    }

    function isAllowed(address addr) external view returns (bool) { return allowed[addr]; }
    function jurisdictionOf(address addr) external view returns (bytes32) { return juris[addr]; }
    function kycLevel(address addr) external view returns (uint8) { return kyc[addr]; }
}
