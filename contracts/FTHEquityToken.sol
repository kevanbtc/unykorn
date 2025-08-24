// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

/// @title FTH Equity Token
/// @notice Equity token that checks a compliance registry and FX limits.
contract FTHEquityToken is ERC20, Ownable {
    ComplianceRegistry public complianceRegistry;

    constructor(address registry) ERC20("FTH Equity Token", "FTH-EQ") {
        complianceRegistry = ComplianceRegistry(registry);
    }

    /// @notice Mint new equity tokens to an investor after compliance checks.
    function mint(address to, uint256 amount) external onlyOwner {
        require(complianceRegistry.isCompliant(to), "Not compliant");
        complianceRegistry.checkAndRecordForeignInvestment(to, amount);
        _mint(to, amount);
    }

    /// @notice Transfer overridden to enforce compliance and FX checks.
    function transfer(address to, uint256 amount)
        public
        override
        returns (bool)
    {
        require(complianceRegistry.isCompliant(to), "Not compliant");
        complianceRegistry.checkAndRecordForeignInvestment(to, amount);
        return super.transfer(to, amount);
    }
}

