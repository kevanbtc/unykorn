// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title GenesisCertificate
/// @notice Issues IPFS pinned certificates for CTRL investors and assets
contract GenesisCertificate is ERC721URIStorage, Ownable {
    uint256 private _nextId = 1;

    constructor() ERC721("Genesis Certificate", "CERT") {}

    /// @notice mint certificate to recipient with tokenURI (IPFS CID)
    function mintCertificate(address to, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 id = _nextId++;
        _safeMint(to, id);
        _setTokenURI(id, tokenURI);
        return id;
    }
}
