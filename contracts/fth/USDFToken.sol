// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title USDFToken - Future Tech Holdings USD-pegged stable token
/// @notice Compliant stablecoin for FTH sovereign settlement layer
/// @dev Treasury-controlled minting with whitelist enforcement
contract USDFToken is
    Initializable,
    ERC20Upgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    /// @notice Whitelist registry for compliant addresses
    mapping(address => bool) public whitelisted;
    
    /// @notice Redemption requests tracking
    mapping(address => uint256) public redemptionRequests;

    event Whitelisted(address indexed account, bool status);
    event RedemptionRequested(address indexed account, uint256 amount);
    event RedemptionFulfilled(address indexed account, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the USDF token
    /// @param treasury Address of the FTH treasury (multi-sig recommended)
    function initialize(address treasury) public initializer {
        __ERC20_init("FTH USD", "USDF");
        __ERC20Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(MINTER_ROLE, treasury);
        _grantRole(BURNER_ROLE, treasury);
        _grantRole(PAUSER_ROLE, treasury);
        _grantRole(COMPLIANCE_ROLE, treasury);
    }

    /// @notice Mint USDF to whitelisted addresses
    /// @param to Recipient address (must be whitelisted)
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(whitelisted[to], "USDF: recipient not whitelisted");
        _mint(to, amount);
    }

    /// @notice Burn USDF from an address
    /// @param from Address to burn from
    /// @param amount Amount to burn
    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }

    /// @notice Pause all transfers
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause transfers
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Update whitelist status
    /// @param account Address to whitelist/unwhitelist
    /// @param status Whitelist status
    function setWhitelisted(address account, bool status) external onlyRole(COMPLIANCE_ROLE) {
        whitelisted[account] = status;
        emit Whitelisted(account, status);
    }

    /// @notice Request redemption of USDF for fiat settlement
    /// @param amount Amount to redeem
    function requestRedemption(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "USDF: insufficient balance");
        redemptionRequests[msg.sender] += amount;
        emit RedemptionRequested(msg.sender, amount);
    }

    /// @notice Fulfill redemption and burn tokens
    /// @param account Address requesting redemption
    /// @param amount Amount to fulfill
    function fulfillRedemption(address account, uint256 amount) external onlyRole(BURNER_ROLE) {
        require(redemptionRequests[account] >= amount, "USDF: no redemption request");
        redemptionRequests[account] -= amount;
        _burn(account, amount);
        emit RedemptionFulfilled(account, amount);
    }

    /// @dev Enforce whitelist on transfers
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        // Allow minting (from == address(0)) and burning (to == address(0))
        if (from != address(0) && to != address(0)) {
            require(whitelisted[from] && whitelisted[to], "USDF: transfer not allowed");
        }
        super._update(from, to, amount);
    }

    /// @dev Required by UUPS
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
