// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/settlement/CBDCBridge.sol";

contract CBDCBridgeTest is Test {
    CBDCBridge bridge;

    function setUp() public {
        bridge = new CBDCBridge(address(this));
    }

    function testBridgeAndRedeem() public {
        bridge.bridge(100);
        bridge.redeem(address(1), 100);
    }
}
