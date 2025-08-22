// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

contract VTV is ERC20, ERC20Burnable, Pausable, Ownable {
    IComplianceRegistry public compliance;

    constructor(address registry) ERC20("VTV", "VTV") Ownable(msg.sender) {
        compliance = IComplianceRegistry(registry);
        _mint(msg.sender, 1_000_000 ether);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 amount) internal override whenNotPaused {
        if (from != address(0)) {
            require(compliance.isKYCed(from), "KYC required");
        }
        if (to != address(0)) {
            require(compliance.isKYCed(to), "KYC required");
        }
        super._update(from, to, amount);
    }
}
