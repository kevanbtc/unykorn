// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RegLogic
 * @notice Provides role based access control for compliance officers and
 *         exposes hooks that vaults and token contracts can call to validate
 *         addresses before performing critical actions.
 */
contract RegLogic is AccessControl {
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");

    struct Record {
        bytes32 jurisdiction;
        bool kyc;
        bool aml;
    }

    mapping(address => Record) private _records;

    event JurisdictionWhitelisted(address indexed account, bytes32 indexed jurisdiction);
    event KYCFlagUpdated(address indexed account, bool status);
    event AMLFlagUpdated(address indexed account, bool status);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REGULATOR_ROLE, msg.sender);
    }

    function whitelistAddress(address account, bytes32 jurisdiction) external onlyRole(REGULATOR_ROLE) {
        _records[account].jurisdiction = jurisdiction;
        emit JurisdictionWhitelisted(account, jurisdiction);
    }

    function setKYCFlag(address account, bool status) external onlyRole(REGULATOR_ROLE) {
        _records[account].kyc = status;
        emit KYCFlagUpdated(account, status);
    }

    function setAMLFlag(address account, bool status) external onlyRole(REGULATOR_ROLE) {
        _records[account].aml = status;
        emit AMLFlagUpdated(account, status);
    }

    function getCompliance(address account) external view returns (bytes32 jurisdiction, bool kyc, bool aml) {
        Record memory r = _records[account];
        return (r.jurisdiction, r.kyc, r.aml);
    }

    function isCompliant(address account) public view returns (bool) {
        Record memory r = _records[account];
        return r.jurisdiction != bytes32(0) && r.kyc && r.aml;
    }

    function isCompliant(address account, bytes32 jurisdiction) public view returns (bool) {
        Record memory r = _records[account];
        return r.jurisdiction == jurisdiction && r.kyc && r.aml;
    }

    function requireCompliance(address account) external view {
        require(isCompliant(account), "RegLogic: address not compliant");
    }

    function requireCompliance(address account, bytes32 jurisdiction) external view {
        require(isCompliant(account, jurisdiction), "RegLogic: address not compliant for jurisdiction");
    }

    function requireTransferCompliance(address from, address to, bytes32 jurisdiction) external view {
        require(isCompliant(from, jurisdiction) && isCompliant(to, jurisdiction), "RegLogic: transfer not compliant");
    }
}

