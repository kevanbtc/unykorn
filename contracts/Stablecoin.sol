// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface IComplianceManager {
    function isWhitelisted(address user) external view returns (bool);
}

/// @title Stablecoin
/// @notice ERC20 stablecoin with role-based mint/burn and compliance checks
contract Stablecoin is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    IComplianceManager public immutable compliance;

    event Minted(address indexed to, uint256 amount, bytes32 rwaRef);
    event Burned(address indexed from, uint256 amount, bytes32 rwaRef);

    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        address compliance_
    ) ERC20(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(MINTER_ROLE, admin_);
        _grantRole(BURNER_ROLE, admin_);
        compliance = IComplianceManager(compliance_);
    }

    modifier onlyWhitelisted(address user) {
        require(compliance.isWhitelisted(user), "Not whitelisted");
        _;
    }

    /// @notice Mints tokens to a whitelisted address
    function mint(address to, uint256 amount, bytes32 rwaRef)
        external
        onlyRole(MINTER_ROLE)
        onlyWhitelisted(to)
    {
        _mint(to, amount);
        emit Minted(to, amount, rwaRef);
    }

    /// @notice Burns tokens from a whitelisted address
    function burn(address from, uint256 amount, bytes32 rwaRef)
        external
        onlyRole(BURNER_ROLE)
        onlyWhitelisted(from)
    {
        _burn(from, amount);
        emit Burned(from, amount, rwaRef);
    }
}

