// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title EnergyVault
/// @notice ERC-4626 vault representing tokenized renewable energy credits
contract EnergyVault is ERC4626 {
    constructor(ERC20 energyToken)
        ERC4626(energyToken)
        ERC20("Energy Credit Vault", "ENERGY-VLT")
    {}
}

