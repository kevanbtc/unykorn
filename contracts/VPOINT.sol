// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

contract VPOINT is ERC20, Ownable {
    IComplianceRegistry public compliance;

    constructor(address registry) ERC20("VPOINT", "VPOINT") Ownable(msg.sender) {
        compliance = IComplianceRegistry(registry);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount) internal override {
        if (from == address(0)) {
            require(compliance.isKYCed(to), "KYC required");
        } else if (to == address(0)) {
            require(compliance.isKYCed(from), "KYC required");
        } else {
            revert("Soulbound");
        }
        super._update(from, to, amount);
    }
}
