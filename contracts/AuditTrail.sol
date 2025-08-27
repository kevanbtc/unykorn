// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract AuditTrail is AccessControl {
    bytes32 public constant LOGGER_ROLE = keccak256("LOGGER_ROLE");

    struct Record {
        address user;
        uint256 amount;
        uint256 timestamp;
    }

    event TransactionLogged(address indexed user, uint256 amount, uint256 timestamp);

    Record[] public records;

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    function logTransaction(address user, uint256 amount) external onlyRole(LOGGER_ROLE) {
        records.push(Record(user, amount, block.timestamp));
        emit TransactionLogged(user, amount, block.timestamp);
    }
}

