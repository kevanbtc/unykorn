// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/water/WaterFlow.sol";
import "../contracts/oracles/WaterOracle.sol";
import "../contracts/stablecoin/ESGStablecoin.sol";
import "../contracts/settlement/CBDCBridge.sol";

contract IntegrationTest is Test {
    WaterFlow flow;
    WaterOracle oracle;
    ESGStablecoin stable;
    CBDCBridge bridge;

    address regulator = address(1);
    address reporter = address(2);
    address user = address(this);

    function setUp() public {
        flow = new WaterFlow(regulator);
        oracle = new WaterOracle(reporter);
        stable = new ESGStablecoin("UnykornUSD", "wUSDx");
        bridge = new CBDCBridge(address(0));
    }

    function testFullPipeline() public {
        vm.prank(regulator);
        flow.setAllocation(user, 100);

        vm.prank(reporter);
        bytes32 key = keccak256("usage");
        oracle.reportData(key, 25);

        flow.reportUsage(user, oracle.getData(key));

        uint256 remaining = flow.settleFlow(user);
        assertEq(remaining, 75);

        stable.mint(user, 1000);
        stable.transfer(address(bridge), 200);
        bridge.bridge(200);

        assertEq(stable.balanceOf(user), 800);
        assertEq(stable.balanceOf(address(bridge)), 200);
    }
}

