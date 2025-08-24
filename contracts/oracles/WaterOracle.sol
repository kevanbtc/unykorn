// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title WaterOracle
/// @notice Feeds water usage/availability data on-chain from IoT or satellites.
contract WaterOracle {
    address public reporter;
    mapping(bytes32 => uint256) public data;

    event DataReported(bytes32 indexed key, uint256 value);

    constructor(address _reporter) {
        reporter = _reporter;
    }

    function reportData(bytes32 key, uint256 value) external {
        require(msg.sender == reporter, "Only reporter");
        data[key] = value;
        emit DataReported(key, value);
    }

    function getData(bytes32 key) external view returns (uint256) {
        return data[key];
    }
}
