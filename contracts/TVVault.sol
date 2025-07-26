// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title TVVault
/// @notice ERC-6551 style vault for controlling streaming channels and media.
contract TVVault {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }

    /// @notice Simple example allowing deposit of ERC721 tokens to the vault.
    function depositERC721(address token, uint256 tokenId) external onlyOwner {
        IERC721(token).transferFrom(msg.sender, address(this), tokenId);
    }

    /// @notice Withdraw an ERC721 token from the vault.
    function withdrawERC721(address token, uint256 tokenId, address to) external onlyOwner {
        IERC721(token).transferFrom(address(this), to, tokenId);
    }
}
