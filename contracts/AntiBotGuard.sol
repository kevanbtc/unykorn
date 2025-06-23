// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AntiBotGuard {
    uint256 public immutable deployTime;
    address public token;

    mapping(address => bool) public whitelist;

    constructor(address _token) {
        deployTime = block.timestamp;
        token = _token;
        whitelist[msg.sender] = true;
    }

    function addWhitelist(address account) external {
        require(block.timestamp < deployTime + 1 hours, "Expired");
        whitelist[account] = true;
    }

    function check(address from, address to) external view returns (bool) {
        if(block.timestamp < deployTime + 1 hours) {
            return whitelist[from] && whitelist[to];
        }
        return true;
    }
}
