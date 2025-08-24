// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title FTH Carbon Token
/// @notice Placeholder token representing carbon credits.
contract FTHCarbonToken is ERC20 {
    constructor() ERC20("FTH Carbon Token", "FTH-CO2") {}
}

