// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

contract VPOINT is ERC20, Ownable {
    ComplianceRegistry public immutable complianceRegistry;

    modifier onlyCompliant(address account) {
        require(
            account == address(0) || complianceRegistry.isCompliant(account),
            "Non-compliant participant"
        );
        _;
    }

    constructor(address registry) ERC20("VPOINT", "VPOINT") Ownable(msg.sender) {
        complianceRegistry = ComplianceRegistry(registry);
    }

    function mint(address to, uint256 amount) external onlyOwner onlyCompliant(to) {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount)
        internal
        override
        onlyCompliant(from)
        onlyCompliant(to)
    {
        require(from == address(0) || to == address(0), "Soulbound");
        super._update(from, to, amount);
    }
}
