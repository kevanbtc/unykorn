// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CarbonVault {
    string public projectId;
    uint256 public credits;
    address public owner;

    event CreditsRetired(uint256 amount, uint256 timestamp);

    constructor(string memory _projectId, uint256 _credits, address _owner) {
        projectId = _projectId;
        credits = _credits;
        owner = _owner;
    }

    function retireCredits(uint256 amount) external {
        require(msg.sender == owner, "Not authorized");
        require(amount <= credits, "Exceeds balance");
        credits -= amount;
        emit CreditsRetired(amount, block.timestamp);
    }
}

