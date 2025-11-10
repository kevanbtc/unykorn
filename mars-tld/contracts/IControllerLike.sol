// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IControllerLike {
    // Generic mint; change signature if your controller differs
    function mint(address to, string calldata label, string calldata tld) external returns (uint256 tokenId);
}
