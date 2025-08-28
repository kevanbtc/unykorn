// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title Travel Rule Compliance
/// @notice Emits events with VASP metadata for transfers
contract TravelRuleCompliance {
    /// @notice Emitted when a transfer is notified for Travel Rule
    /// @param from sender address
    /// @param to recipient address
    /// @param amount amount transferred
    /// @param info off-chain encrypted travel rule info
    event TransferNotified(address indexed from, address indexed to, uint256 amount, string info);

    /// @notice Notify a transfer with encrypted Travel Rule metadata
    /// @param from sender address
    /// @param to recipient address
    /// @param amount amount transferred
    /// @param info off-chain encrypted travel rule info
    function notifyTransfer(address from, address to, uint256 amount, string calldata info) external {
        emit TransferNotified(from, to, amount, info);
    }
}
