// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title WaterVault
/// @notice ERC-4626 vault representing tokenized water rights
contract WaterVault is ERC4626 {
    constructor(ERC20 waterToken)
        ERC4626(waterToken)
        ERC20("Water Rights Vault", "WATER-VLT")
    {}
}

