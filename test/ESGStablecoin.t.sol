// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/stablecoin/ESGStablecoin.sol";

contract ESGStablecoinTest is Test {
    ESGStablecoin coin;

    function setUp() public {
        coin = new ESGStablecoin("UnykornUSD", "wUSDx");
    }

    function testMint() public {
        coin.mint(address(this), 1000);
        assertEq(coin.balanceOf(address(this)), 1000);
    }
}
