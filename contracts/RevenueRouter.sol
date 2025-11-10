// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./FTHDebtToken.sol";
import "./FTHEquityToken.sol";
import "./ComplianceRegistry.sol";

/// @title Routes incoming revenues to debt, equity and reserves
contract RevenueRouter {
    IERC20 public stablecoin;
    FTHDebtToken public debt;
    FTHEquityToken public equity;
    ComplianceRegistry public compliance;

    address public reserveWallet;
    uint256 public debtShare;
    uint256 public equityShare;
    uint256 public reserveShare;

    constructor(
        address _stablecoin,
        address _debt,
        address _equity,
        address _reserveWallet,
        address _compliance,
        uint256 _debtShare,
        uint256 _equityShare,
        uint256 _reserveShare
    ) {
        stablecoin = IERC20(_stablecoin);
        debt = FTHDebtToken(_debt);
        equity = FTHEquityToken(_equity);
        reserveWallet = _reserveWallet;
        compliance = ComplianceRegistry(_compliance);
        debtShare = _debtShare;
        equityShare = _equityShare;
        reserveShare = _reserveShare;
    }

    function distribute(uint256 amount) external {
        require(compliance.isWhitelisted(msg.sender), "not compliant");
        require(stablecoin.transferFrom(msg.sender, address(this), amount), "transfer failed");

        uint256 toDebt = (amount * debtShare) / 100;
        uint256 toEquity = (amount * equityShare) / 100;
        uint256 toReserve = (amount * reserveShare) / 100;

        stablecoin.transfer(address(debt), toDebt);
        stablecoin.transfer(address(equity), toEquity);
        stablecoin.transfer(reserveWallet, toReserve);

        debt.distribute(toDebt);
        equity.distribute(toEquity);
    }
}

