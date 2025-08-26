// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title CarbonVault
/// @notice ERC-4626 vault representing tokenized carbon credits
contract CarbonVault is ERC4626 {
    constructor(ERC20 carbonToken)
        ERC4626(carbonToken)
        ERC20("Carbon Credit Vault", "CARBON-VLT")
    {}
}

