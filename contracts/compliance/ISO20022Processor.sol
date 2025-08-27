// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title ISO20022 Message Processor
/// @notice Logs hashes of processed ISO20022 messages
contract ISO20022Processor {
    /// @notice Emitted when a message is processed
    /// @param messageId unique message identifier
    /// @param xmlHash hash of the XML payload
    event MessageProcessed(bytes32 indexed messageId, string xmlHash);

    /// @notice Record processing of an ISO20022 message
    /// @param messageId unique message identifier
    /// @param xmlHash hash of the XML payload
    function processMessage(bytes32 messageId, string calldata xmlHash) external {
        emit MessageProcessed(messageId, xmlHash);
    }
}
