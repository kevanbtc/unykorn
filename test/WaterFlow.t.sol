// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/water/WaterFlow.sol";

contract WaterFlowTest is Test {
    WaterFlow wf;

    function setUp() public {
        wf = new WaterFlow(address(this));
    }

    function testAllocationAndUsage() public {
        wf.setAllocation(address(1), 100);
        wf.reportUsage(address(1), 20);
        uint256 balance = wf.settleFlow(address(1));
        assertEq(balance, 80);
    }
}
