// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CBDCBridge
/// @notice Mock bridge emitting ISO 20022-style events
contract CBDCBridge {
    event CBDCMinted(address indexed to, uint256 amount);
    event CBDCBurned(address indexed from, uint256 amount);

    function mint(address to, uint256 amount) external {
        emit CBDCMinted(to, amount);
    }

    function burn(address from, uint256 amount) external {
        emit CBDCBurned(from, amount);
    }
}
