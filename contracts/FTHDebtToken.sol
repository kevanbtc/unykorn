// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

/// @title FTH Debt Token
/// @notice Redeemable debt token with compliance registry and FX checks.
contract FTHDebtToken is ERC20, Ownable {
    uint256 public maturityDate;
    ComplianceRegistry public complianceRegistry;

    constructor(uint256 _maturity, address registry) ERC20("FTH Debt Token", "FTH-DEBT") {
        maturityDate = _maturity;
        complianceRegistry = ComplianceRegistry(registry);
    }

    /// @notice Mint debt tokens to investor after compliance checks.
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

    /// @notice Redeem tokens after maturity.
    function redeem() external {
        require(block.timestamp >= maturityDate, "Not matured");
        _burn(msg.sender, balanceOf(msg.sender));
        // Repayment handled off-chain or by RevenueRouter.
    }
}

