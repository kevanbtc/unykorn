// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {CompliantStablecoin} from "./CompliantStablecoin.sol";

contract CompliantStableFactory {
    address public immutable implementation;
    address public owner;

    event StableDeployed(address proxy, string name, string symbol, string currencyCode, string collateralType);
    event OwnerChanged(address indexed owner);

    modifier onlyOwner() { require(msg.sender == owner, "not owner"); _; }

    constructor(address impl) {
        require(impl != address(0), "impl=0");
        implementation = impl;
        owner = msg.sender;
        emit OwnerChanged(owner);
    }

    function setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "owner=0");
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    struct Params {
        string name;
        string symbol;
        uint8  decimals;
        address admin;
        address complianceRegistry;
        address oracle;
        uint16 minCollateralRatioBps;
        string currencyCode;
        string collateralType;
        bytes32 jurisdiction;
        string policyURI;
        address lawEnforcementEscrow;
    }

    function createStable(Params calldata p) external onlyOwner returns (address proxy) {
        bytes memory initData = abi.encodeWithSelector(
            CompliantStablecoin.initialize.selector,
            p.name, p.symbol, p.decimals, p.admin,
            p.complianceRegistry, p.oracle, p.minCollateralRatioBps,
            p.currencyCode, p.collateralType, p.jurisdiction, p.policyURI, p.lawEnforcementEscrow
        );
        proxy = address(new ERC1967Proxy(implementation, initData));
        emit StableDeployed(proxy, p.name, p.symbol, p.currencyCode, p.collateralType);
    }
}
