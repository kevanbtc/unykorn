// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WaterVaultNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    constructor() ERC721("WaterVault", "WATER") {}

    function mintVault(address to, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds += 1;
        uint256 newId = _tokenIds;
        _mint(to, newId);
        _setTokenURI(newId, tokenURI);
        return newId;
    }
}
