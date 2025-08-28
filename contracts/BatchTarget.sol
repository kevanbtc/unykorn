// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BatchTarget {
    uint256 public value;

    function setValue(uint256 v) external {
        value = v;
    }
}
