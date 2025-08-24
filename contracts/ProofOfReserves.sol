// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

interface AggregatorV3Interface {
    function latestAnswer() external view returns (int256);
}

contract ProofOfReserves is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");
    AggregatorV3Interface public aggregator;

    constructor(address _aggregator) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        aggregator = AggregatorV3Interface(_aggregator);
    }

    function setAggregator(address _aggregator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        aggregator = AggregatorV3Interface(_aggregator);
    }

    function getLatestReserve() external view returns (int256) {
        return aggregator.latestAnswer();
    }
}
