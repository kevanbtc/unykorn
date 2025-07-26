// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title V-CHANNEL Domain NFTs (.tv)
contract VChannelDomain is ERC721URIStorage, Ownable {
    uint256 public nextId;

    constructor() ERC721("V-CHANNEL Domain", "VCD") {}

    function mint(address to, string memory uri) external onlyOwner returns (uint256 tokenId) {
        tokenId = ++nextId;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal override
    {
        require(from == address(0), "Soulbound token");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
