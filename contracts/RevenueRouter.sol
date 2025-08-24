// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

/// @title RevenueRouter with jurisdiction-based tax withholding and ISO20022 events
contract RevenueRouter is Ownable {
    IERC20 public stablecoin;
    address public debt;
    address public equity;
    address public reserve;
    ComplianceRegistry public registry;

    uint256 public debtShare;
    uint256 public equityShare;
    address public taxAuthority;

    // Tax rates in basis points
    uint256 public domesticTaxRate = 1000; // 10%
    uint256 public foreignTaxRate = 2000;  // 20%

    event RevenueDistributed(uint256 grossAmount, uint256 totalTax, uint256 netAmount);
    event ISO20022Event(string messageType, address indexed from, address indexed to, uint256 amount, string jurisdiction);

    constructor(
        address _stablecoin,
        address _debt,
        address _equity,
        address _reserve,
        address _registry,
        address _taxAuthority,
        uint256 _debtShare,
        uint256 _equityShare
    ) {
        stablecoin = IERC20(_stablecoin);
        debt = _debt;
        equity = _equity;
        reserve = _reserve;
        registry = ComplianceRegistry(_registry);
        taxAuthority = _taxAuthority;
        debtShare = _debtShare;
        equityShare = _equityShare;
    }

    /// @notice Distribute revenue applying jurisdiction-based withholding
    /// @param amount Gross amount to distribute
    /// @param investor Investor whose jurisdiction determines tax rate
    /// @param jurisdiction ISO country code used in events
    function distribute(uint256 amount, address investor, string memory jurisdiction) external onlyOwner {
        stablecoin.transferFrom(msg.sender, address(this), amount);

        uint256 rate = registry.foreignInvestor(investor) ? foreignTaxRate : domesticTaxRate;
        uint256 tax = (amount * rate) / 10000;
        uint256 netAmount = amount - tax;

        // send tax
        stablecoin.transfer(taxAuthority, tax);

        // distribute net revenue
        uint256 debtAmount = (netAmount * debtShare) / 100;
        uint256 equityAmount = (netAmount * equityShare) / 100;
        stablecoin.transfer(debt, debtAmount);
        stablecoin.transfer(equity, equityAmount);
        stablecoin.transfer(reserve, netAmount - debtAmount - equityAmount);

        emit RevenueDistributed(amount, tax, netAmount);
        emit ISO20022Event("pacs.008", msg.sender, debt, debtAmount, jurisdiction);
        emit ISO20022Event("pacs.008", msg.sender, equity, equityAmount, jurisdiction);
        emit ISO20022Event("pacs.008", msg.sender, taxAuthority, tax, jurisdiction);
    }

    /// @notice Update tax rates for domestic and foreign investors
    function updateTaxRates(uint256 _domestic, uint256 _foreign) external onlyOwner {
        require(_domestic <= 5000 && _foreign <= 5000, "Max 50%");
        domesticTaxRate = _domestic;
        foreignTaxRate = _foreign;
    }

    /// @notice Update tax authority address
    function updateTaxAuthority(address _taxAuthority) external onlyOwner {
        taxAuthority = _taxAuthority;
    }
}
