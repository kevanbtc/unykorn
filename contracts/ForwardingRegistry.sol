// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Registry of trusted forwarder addresses
/// @notice Only the owner may approve or revoke forwarders
contract ForwardingRegistry is Ownable {
    mapping(address => bool) public isForwarderApproved;

    event ForwarderApproved(address indexed forwarder);
    event ForwarderRevoked(address indexed forwarder);

    constructor(address initialOwner) Ownable(initialOwner) {}

    function approveForwarder(address forwarder) external onlyOwner {
        isForwarderApproved[forwarder] = true;
        emit ForwarderApproved(forwarder);
    }

    function revokeForwarder(address forwarder) external onlyOwner {
        isForwarderApproved[forwarder] = false;
        emit ForwarderRevoked(forwarder);
    }
}

