// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OverVault is ERC4626, Ownable {
    address public agent;

    event AgentUpdated(address indexed newAgent);
    event ArbitrageExecuted(address[] routers);

    constructor(IERC20 asset) ERC20("Overdog Vault Share", "OVS") ERC4626(asset) {}

    function setAgent(address _agent) external onlyOwner {
        agent = _agent;
        emit AgentUpdated(_agent);
    }

    modifier onlyAgent() {
        require(msg.sender == agent, "Not agent");
        _;
    }

    function executeArbitrage(address[] memory routers) external onlyAgent {
        emit ArbitrageExecuted(routers);
        // Placeholder for arbitrage logic
    }
}
