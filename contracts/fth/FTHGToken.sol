// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title FTHGToken - Future Tech Holdings Gold-backed token
/// @notice 1 FTHG = 1 troy oz of physical gold in FTH vault
/// @dev Linked to VaultProofNFT for custody verification
contract FTHGToken is
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
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    /// @notice Whitelist for compliant addresses
    mapping(address => bool) public whitelisted;
    
    /// @notice Physical gold redemption requests (in troy oz)
    mapping(address => uint256) public physicalRedemptions;
    
    /// @notice Vault proof reference (IPFS hash or Chainlink PoR reference)
    string public vaultProofURI;
    
    /// @notice Last audit timestamp
    uint256 public lastAuditTimestamp;
    
    /// @notice Total physical gold backing (in troy oz)
    uint256 public totalPhysicalGold;

    event Whitelisted(address indexed account, bool status);
    event PhysicalRedemptionRequested(address indexed account, uint256 ounces);
    event PhysicalRedemptionFulfilled(address indexed account, uint256 ounces);
    event VaultProofUpdated(string newURI, uint256 timestamp);
    event AuditCompleted(uint256 physicalGold, uint256 tokenSupply, uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the FTHG token
    /// @param treasury Address of the FTH treasury
    /// @param custodian Address of the gold custodian
    /// @param auditor Address of the independent auditor
    function initialize(
        address treasury,
        address custodian,
        address auditor
    ) public initializer {
        __ERC20_init("FTH Gold", "FTHG");
        __ERC20Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(MINTER_ROLE, custodian);
        _grantRole(BURNER_ROLE, custodian);
        _grantRole(PAUSER_ROLE, treasury);
        _grantRole(COMPLIANCE_ROLE, treasury);
        _grantRole(AUDITOR_ROLE, auditor);
    }

    /// @notice Mint FTHG tokens backed by physical gold deposit
    /// @param to Recipient address (must be whitelisted)
    /// @param ounces Number of troy ounces to mint
    function mint(address to, uint256 ounces) external onlyRole(MINTER_ROLE) {
        require(whitelisted[to], "FTHG: recipient not whitelisted");
        totalPhysicalGold += ounces;
        _mint(to, ounces * 1e18); // 1 token = 1 oz (with 18 decimals)
    }

    /// @notice Burn FTHG tokens
    /// @param from Address to burn from
    /// @param ounces Number of troy ounces to burn
    function burn(address from, uint256 ounces) external onlyRole(BURNER_ROLE) {
        totalPhysicalGold -= ounces;
        _burn(from, ounces * 1e18);
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

    /// @notice Request physical gold redemption
    /// @param ounces Number of troy ounces to redeem
    function requestPhysicalRedemption(uint256 ounces) external {
        uint256 requiredBalance = ounces * 1e18;
        require(balanceOf(msg.sender) >= requiredBalance, "FTHG: insufficient balance");
        physicalRedemptions[msg.sender] += ounces;
        emit PhysicalRedemptionRequested(msg.sender, ounces);
    }

    /// @notice Fulfill physical redemption and burn tokens
    /// @param account Address requesting redemption
    /// @param ounces Number of troy ounces to fulfill
    function fulfillPhysicalRedemption(address account, uint256 ounces)
        external
        onlyRole(BURNER_ROLE)
    {
        require(physicalRedemptions[account] >= ounces, "FTHG: no redemption request");
        physicalRedemptions[account] -= ounces;
        totalPhysicalGold -= ounces;
        _burn(account, ounces * 1e18);
        emit PhysicalRedemptionFulfilled(account, ounces);
    }

    /// @notice Update vault proof URI (IPFS/Chainlink reference)
    /// @param uri New proof URI
    function updateVaultProof(string calldata uri) external onlyRole(AUDITOR_ROLE) {
        vaultProofURI = uri;
        lastAuditTimestamp = block.timestamp;
        emit VaultProofUpdated(uri, block.timestamp);
    }

    /// @notice Record audit completion
    /// @param physicalGold Verified physical gold in vault (troy oz)
    function recordAudit(uint256 physicalGold) external onlyRole(AUDITOR_ROLE) {
        require(physicalGold >= totalPhysicalGold, "FTHG: insufficient gold backing");
        lastAuditTimestamp = block.timestamp;
        emit AuditCompleted(physicalGold, totalSupply(), block.timestamp);
    }

    /// @dev Enforce whitelist on transfers
    function _update(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        if (from != address(0) && to != address(0)) {
            require(whitelisted[from] && whitelisted[to], "FTHG: transfer not allowed");
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
