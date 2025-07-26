// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title GlacierMint - registrar for .tv vaults
/// @notice Simplified ERC721 contract used to mint soulbound .tv domains that map to TVVaults.
contract GlacierMint is ERC721URIStorage, Ownable {
    uint256 public nextId;

    constructor() ERC721("Glacier TV", "GLTV") {}

    /// @notice Mint a new .tv top level domain to a user.
    /// @dev For demonstration only. Real implementation would enforce soulbound behavior.
    function mint(address to, string calldata uri) external onlyOwner returns (uint256) {
        uint256 tokenId = ++nextId;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
}
