// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

contract VCHAN is ERC20, ERC20Burnable, Pausable, Ownable {
    ComplianceRegistry public immutable complianceRegistry;

    modifier onlyCompliant(address account) {
        require(
            account == address(0) || complianceRegistry.isCompliant(account),
            "Non-compliant participant"
        );
        _;
    }

    constructor(address registry) ERC20("VCHAN", "VCHAN") Ownable(msg.sender) {
        complianceRegistry = ComplianceRegistry(registry);
        _mint(msg.sender, 100_000 ether);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _update(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
        onlyCompliant(from)
        onlyCompliant(to)
    {
        super._update(from, to, amount);
    }
}
