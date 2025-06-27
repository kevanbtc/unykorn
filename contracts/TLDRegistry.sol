// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title TLDRegistry
/// @notice Soulbound registry for `.ctrl` domains
contract TLDRegistry is ERC721URIStorage, Ownable {
    uint256 private constant ROOT_TOKEN_ID = 0;
    uint256 private _nextSubdomain = 1;

    constructor() ERC721("CTRL Domain", "CTRL-D") {
        _mint(msg.sender, ROOT_TOKEN_ID); // mint .ctrl root domain to deployer
    }

    /// @notice mint subdomain token to an address
    function mintSubdomain(address to, string memory subdomain, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 id = _nextSubdomain++;
        _safeMint(to, id);
        _setTokenURI(id, tokenURI); // optional metadata with IPFS
        emit SubdomainMinted(to, subdomain, id);
        return id;
    }

    event SubdomainMinted(address indexed to, string subdomain, uint256 tokenId);

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        if (tokenId == ROOT_TOKEN_ID && from != address(0) && to != address(0)) {
            revert("Root domain soulbound");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
