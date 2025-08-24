// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CBDCBridge
/// @notice Generic bridge for routing stablecoin settlements to CBDC networks.
contract CBDCBridge {
    address public settlementGateway;

    event Bridged(address indexed from, uint256 amount);
    event Redeemed(address indexed to, uint256 amount);

    constructor(address _settlementGateway) {
        settlementGateway = _settlementGateway;
    }

    function bridge(uint256 amount) external {
        // TODO: hook into external CBDC gateway
        emit Bridged(msg.sender, amount);
    }

    function redeem(address to, uint256 amount) external {
        // TODO: receive funds from CBDC rail
        emit Redeemed(to, amount);
    }
}
