// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/water/WaterVault.sol";

contract WaterVaultTest is Test {
    WaterVault vault;

    function setUp() public {
        vault = new WaterVault("Test River", 1000, address(this));
    }

    function testTransferAllocation() public {
        vault.transferAllocation(address(0xBEEF), 100);
        assertEq(vault.allocationLiters(), 900);
    }

    function testReportUsage() public {
        vault.reportUsage(200);
    }
}
