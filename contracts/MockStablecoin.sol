// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Simple mintable ERC20 used as stablecoin
contract MockStablecoin is ERC20, Ownable {
    constructor() ERC20("MockStable", "MSC") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

