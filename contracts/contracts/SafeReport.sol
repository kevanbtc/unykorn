// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SafeReport is ERC721URIStorage, Ownable {
    uint256 private _tokenId;

    event ReportMinted(uint256 tokenId, string location);

    constructor() ERC721("Safe Report", "SREPORT") {}

    function mint(address to, string memory tokenURI, string memory location) external onlyOwner returns (uint256) {
        _tokenId++;
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, tokenURI);
        emit ReportMinted(_tokenId, location);
        return _tokenId;
    }
}
