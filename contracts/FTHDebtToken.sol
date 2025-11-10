// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseRevenueToken.sol";

/// @title Senior debt token with revenue distribution
contract FTHDebtToken is BaseRevenueToken {
    constructor(address stablecoin) BaseRevenueToken("FTH Debt Token", "FTHD", stablecoin) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

