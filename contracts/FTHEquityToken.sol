// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseRevenueToken.sol";

/// @title Equity token with dividend distribution
contract FTHEquityToken is BaseRevenueToken {
    constructor(address stablecoin) BaseRevenueToken("FTH Equity Token", "FTHE", stablecoin) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

