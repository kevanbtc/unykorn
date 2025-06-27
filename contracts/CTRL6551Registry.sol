// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title CTRL6551Registry
/// @notice Minimal ERC-6551 registry mapping Vault NFTs to smart accounts
contract CTRL6551Registry is Ownable {
    mapping(uint256 => address) public accounts; // vaultId => account address

    event AccountRegistered(uint256 indexed tokenId, address account);

    function registerAccount(uint256 tokenId, address account) external onlyOwner {
        require(accounts[tokenId] == address(0), "Account exists");
        accounts[tokenId] = account;
        emit AccountRegistered(tokenId, account);
    }

    function getAccount(uint256 tokenId) external view returns (address) {
        return accounts[tokenId];
    }
}
