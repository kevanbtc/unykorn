// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC6551Registry {
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external returns (address);
    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address);
}

contract SoulboundSafe is ERC721, ERC721URIStorage, Ownable {
    bool public mintLocked = false;
    string public constant TLD = ".safe";
    IERC6551Registry public registry;
    address public accountImpl;
    mapping(uint256 => string) private _labels;

    constructor(address _registry, address _accountImpl) ERC721("SafeDomain", "SAFE") Ownable(msg.sender) {
        registry = IERC6551Registry(_registry);
        accountImpl = _accountImpl;
    }

    modifier notLocked() {
        require(!mintLocked, "Minting locked");
        _;
    }

    function toggleMint(bool locked) external onlyOwner {
        mintLocked = locked;
    }

    function mint(address to, uint256 tokenId, string memory label, string memory uri) external notLocked onlyOwner {
        require(_ownerOf(tokenId) == address(0), "token exists");
        require(bytes(label).length > 0, "invalid label");
        _safeMint(to, tokenId);
        _labels[tokenId] = string.concat(label, TLD);
        _setTokenURI(tokenId, uri);
        registry.createAccount(accountImpl, block.chainid, address(this), tokenId, 0, "");
    }

    function burn(uint256 tokenId) external {
        address owner = _requireOwned(tokenId);
        require(_isAuthorized(owner, _msgSender(), tokenId), "not owner nor approved");
        _burn(tokenId);
    }

    function labelOf(uint256 tokenId) external view returns (string memory) {
        _requireOwned(tokenId);
        return _labels[tokenId];
    }

    // Soulbound: prevent transfers
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0) && to != address(0)) {
            revert("Soulbound");
        }
        return super._update(to, tokenId, auth);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }
}
