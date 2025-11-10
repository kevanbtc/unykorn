// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
contract VaultUSD is ERC20 {
    constructor() ERC20("VaultUSD.t", "VUSDt") { _mint(msg.sender, 1_000_000e18); }
    function mint(address to, uint256 amt) external { _mint(to, amt); }
}
