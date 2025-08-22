// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

/**
 * @title CompliantNFT
 * @notice Simple ERC721 token that enforces KYC checks and stores
 *         per-token geo restrictions and tax rates.
 */
contract CompliantNFT is ERC721, Ownable {
    struct Meta { string geo; uint256 taxBps; }
    mapping(uint256 => Meta) public metadata;
    uint256 public nextId;

    IComplianceRegistry public compliance;

    constructor(address registry) ERC721("V-Channel .tv", "VCTV") Ownable(msg.sender) {
        compliance = IComplianceRegistry(registry);
    }

    function mint(address to, string memory geo, uint256 taxBps) external onlyOwner {
        require(compliance.isKYCed(to), "KYC required");
        nextId++;
        metadata[nextId] = Meta(geo, taxBps);
        _safeMint(to, nextId);
    }

    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0)) require(compliance.isKYCed(from), "KYC required");
        if (to != address(0)) require(compliance.isKYCed(to), "KYC required");
        return super._update(to, tokenId, auth);
    }
}

