// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Vault NFT representing investor positions
contract CtrlVaultNFT is ERC721, Ownable {
    struct VaultData {
        uint256 shares;
        uint256 mintedAt;
        bytes32 kycHash;
        string certificateCID; // IPFS CID
    }

    mapping(uint256 => VaultData) private _vaults;
    mapping(uint256 => bool) private _transferrable;
    uint256 private _nextId = 1;

    constructor() ERC721("CTRL Vault", "CTRL-V") {}

    function mint(address to, uint256 shares, bytes32 kycHash, string memory certCID) external onlyOwner returns (uint256) {
        uint256 id = _nextId++;
        _safeMint(to, id);
        _vaults[id] = VaultData({shares: shares, mintedAt: block.timestamp, kycHash: kycHash, certificateCID: certCID});
        return id;
    }

    function getVault(uint256 id) external view returns (VaultData memory) {
        return _vaults[id];
    }

    /// @notice make token transferrable by admin if needed
    function setTransferrable(uint256 id, bool allowed) external onlyOwner {
        _transferrable[id] = allowed;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        if (from != address(0) && to != address(0)) {
            require(_transferrable[tokenId], "Soulbound");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
