// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IComplianceOracle {
    function transferAllowed(address from, address to) external view returns (bool);
}

/// @title CTRL Preferred Equity Token (ERC20)
contract CTRLToken is ERC20, Ownable {
    IComplianceOracle public compliance;

    uint256 public constant TOTAL_SUPPLY = 4_000_000 * 1e18;

    constructor(address oracle) ERC20("CTRL Preferred Equity Token", "CTRL") {
        _mint(msg.sender, TOTAL_SUPPLY);
        compliance = IComplianceOracle(oracle);
    }

    function setComplianceOracle(address oracle) external onlyOwner {
        compliance = IComplianceOracle(oracle);
    }

    function _update(address from, address to, uint256 amount) internal override {
        if (from != address(0) && to != address(0)) {
            require(compliance.transferAllowed(from, to), "Transfer not allowed");
        }
        super._update(from, to, amount);
    }
}
