// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title UnykornLicenseNFT
/// @notice Subscription licensing NFT with tiered levels
contract UnykornLicenseNFT is ERC1155, Ownable {
    enum Tier {
        Basic,
        Pro,
        Enterprise
    }

    mapping(uint256 => uint256) public expiries;

    constructor() ERC1155("https://api.unykorn.com/license/{id}.json") {}

    function mintLicense(address to, Tier tier, uint256 duration) external onlyOwner {
        uint256 id = uint256(tier);
        _mint(to, id, 1, "");
        expiries[id] = block.timestamp + duration;
    }

    function isValid(uint256 id) public view returns (bool) {
        return block.timestamp < expiries[id];
    }
}

