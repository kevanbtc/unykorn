// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/oracles/WaterOracle.sol";

contract WaterOracleTest is Test {
    WaterOracle oracle;

    function setUp() public {
        oracle = new WaterOracle(address(this));
    }

    function testReportAndGetData() public {
        bytes32 key = keccak256("region1");
        oracle.reportData(key, 500);
        assertEq(oracle.getData(key), 500);
    }
}
