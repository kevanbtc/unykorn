// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VCHANToken is ERC20Burnable, Ownable {
    constructor(uint256 initialSupply) ERC20("V-CHANNEL Token", "VCHAN") {
        _mint(msg.sender, initialSupply);
    }
}
