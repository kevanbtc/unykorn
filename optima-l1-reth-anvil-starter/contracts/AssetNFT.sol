// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
contract AssetNFT is ERC721 {
    uint256 public nextId=1;
    constructor() ERC721("AssetNFT","ASSET") {}
    function mint(address to) external returns (uint256 id) { id = nextId++; _mint(to,id); }
}
