// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";

/// @title FTHGovernanceToken - Future Tech Holdings governance token
/// @notice Voting token for FTH protocol governance and profit-sharing
contract FTHGovernanceToken is
    Initializable,
    ERC20Upgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the FTH governance token
    /// @param treasury Address of the FTH treasury
    function initialize(address treasury) public initializer {
        __ERC20_init("FTH Governance", "FTH");
        __EIP712_init("FTH Governance", "1");
        __ERC20Votes_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(MINTER_ROLE, treasury);
        
        // Mint initial governance supply to treasury
        _mint(treasury, 100_000_000 * 1e18); // 100M tokens
    }

    /// @notice Mint new governance tokens (for profit-sharing or incentives)
    /// @param to Recipient address
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @dev Required overrides for ERC20Votes
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, amount);
    }

    /// @dev Required by UUPS
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
