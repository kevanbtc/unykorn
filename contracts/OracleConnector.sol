// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title OracleConnector
/// @notice Stores price feeds supplied by authorized oracles
contract OracleConnector is AccessControl {
    bytes32 public constant ORACLE_ADMIN = keccak256("ORACLE_ADMIN");

    mapping(bytes32 => uint256) private prices;
    mapping(bytes32 => uint256) private updatedAt;

    event PriceUpdated(bytes32 indexed asset, uint256 price);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ADMIN, admin);
    }

    function setPrice(bytes32 asset, uint256 price) external onlyRole(ORACLE_ADMIN) {
        prices[asset] = price;
        updatedAt[asset] = block.timestamp;
        emit PriceUpdated(asset, price);
    }

    function getPrice(bytes32 asset) external view returns (uint256 price, uint256 timestamp) {
        return (prices[asset], updatedAt[asset]);
    }
}

