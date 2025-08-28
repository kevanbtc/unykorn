// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BatchProcessor {
    address public owner;
    uint256 public maxBatchSize;

    event BatchExecuted(address indexed executor, uint256 txCount);

    constructor(uint256 _maxBatchSize) {
        owner = msg.sender;
        maxBatchSize = _maxBatchSize;
    }

    function executeBatch(address[] calldata targets, bytes[] calldata data) external {
        require(targets.length == data.length, "Mismatched inputs");
        require(targets.length <= maxBatchSize, "Batch too large");
        for (uint256 i = 0; i < targets.length; i++) {
            (bool ok, ) = targets[i].call(data[i]);
            require(ok, "Tx failed");
        }
        emit BatchExecuted(msg.sender, targets.length);
    }
}
