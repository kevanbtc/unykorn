// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

interface IERC5192 {
    event Locked(uint256 tokenId);
    event Unlocked(uint256 tokenId);
    function locked(uint256 tokenId) external view returns (bool);
}

/// @title MemePass721 - NFT pass with optional soulbound mode and royalties
contract MemePass721 is ERC721, ERC2981, Ownable2Step, Pausable, IERC5192 {
    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant MINT_PRICE = 0.01 ether;

    uint256 private _tokenIdTracker;
    bool public soulbound;
    string private baseUri;

    constructor(string memory name_, string memory symbol_, string memory baseUri_, address royaltyReceiver)
        ERC721(name_, symbol_)
        Ownable(msg.sender)
    {
        _setDefaultRoyalty(royaltyReceiver, 500); // 5%
        baseUri = baseUri_;
    }

    /// @notice Mint Meme Passes
    function mint(uint256 amount) external payable whenNotPaused {
        require(msg.value == amount * MINT_PRICE, "price");
        for (uint256 i = 0; i < amount; i++) {
            require(_tokenIdTracker < MAX_SUPPLY, "sold out");
            _tokenIdTracker += 1;
            uint256 tokenId = _tokenIdTracker;
            _safeMint(msg.sender, tokenId);
            if (soulbound) {
                emit Locked(tokenId);
            }
        }
    }

    function setSoulbound(bool bound) external onlyOwner {
        soulbound = bound;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw(address payable to) external onlyOwner {
        to.transfer(address(this).balance);
    }

    function locked(uint256 tokenId) external view override returns (bool) {
        return soulbound && _ownerOf(tokenId) != address(0);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        whenNotPaused
        returns (address)
    {
        address from = _ownerOf(tokenId);
        require(!soulbound || from == address(0) || to == address(0), "SBT");
        return super._update(to, tokenId, auth);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return interfaceId == type(IERC5192).interfaceId || super.supportsInterface(interfaceId);
    }
}
