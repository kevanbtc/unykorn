// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title FedNowAdapter
/// @notice Example adapter for interfacing with the FedNow instant payment system.
contract FedNowAdapter {
    event PaymentInitiated(address indexed sender, uint256 amount, bytes32 reference);
    event PaymentSettled(bytes32 reference);

    function initiatePayment(uint256 amount, bytes32 reference) external {
        // TODO: call FedNow rail or off-chain service
        emit PaymentInitiated(msg.sender, amount, reference);
    }

    function confirmSettlement(bytes32 reference) external {
        // TODO: verify settlement via oracle or off-chain callback
        emit PaymentSettled(reference);
    }
}
