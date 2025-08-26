// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ESGStablecoin
/// @notice Multi-collateral stablecoin backed by vault tokens (ERC-4626) with upgradeability
contract ESGStablecoin is ERC20Permit, UUPSUpgradeable, Ownable {
    mapping(address => bool) public collateralVaults;
    mapping(address => uint256) public collateralRatios;

    constructor()
        ERC20("ESG Stablecoin", "USDE")
        ERC20Permit("ESG Stablecoin")
    {}

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function addCollateralVault(address vault, uint256 ratio) external onlyOwner {
        collateralVaults[vault] = true;
        collateralRatios[vault] = ratio;
    }

    function mint(address vault, uint256 amount) external {
        require(collateralVaults[vault], "Vault not approved");
        _mint(msg.sender, amount);
    }
}

