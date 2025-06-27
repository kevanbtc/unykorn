// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TLDRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title SubdomainMinter
contract SubdomainMinter is Ownable {
    TLDRegistry public registry;

    constructor(address registryAddress) {
        registry = TLDRegistry(registryAddress);
    }

    function mint(address to, string memory subdomain, string memory tokenURI) external onlyOwner returns (uint256) {
        return registry.mintSubdomain(to, subdomain, tokenURI);
    }
}
