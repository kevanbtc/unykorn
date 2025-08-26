// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title UnykornSovereigntyRegistry
/// @notice Global ownership and jurisdiction registry for IP proofs
contract UnykornSovereigntyRegistry {
    struct Record {
        address owner;
        string jurisdiction;
        string hash;
        uint256 timestamp;
    }

    mapping(bytes32 => Record) public records;

    event SovereigntyRegistered(bytes32 indexed id, address indexed owner, string jurisdiction);

    function register(bytes32 id, string memory jurisdiction, string memory hash) external {
        records[id] = Record(msg.sender, jurisdiction, hash, block.timestamp);
        emit SovereigntyRegistered(id, msg.sender, jurisdiction);
    }
}

