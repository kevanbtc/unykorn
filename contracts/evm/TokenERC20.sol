// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/// @title TokenERC20 - upgradeable ERC20 token with permit and controlled mint/burn
contract TokenERC20 is
    Initializable,
    ERC20Upgradeable,
    ERC20PermitUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    Ownable2StepUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant INITIAL_SUPPLY = 1_000_000_000_000 * 1e18; // Trillions for psychology
    uint256 private constant LOCK_PERIOD = 7 days;
    uint256 public launchTime;
    
    // Burn mechanism - configurable burn rate for transactions
    uint256 public burnRate = 300; // 3% default (basis points: 300/10000)
    bool public burnEnabled = true;
    
    // Early pack system
    struct PackTier {
        uint256 price;      // ETH price for pack
        uint256 tokens;     // Token allocation
        uint256 lockPeriod; // Additional lock period beyond standard
        bool active;        // Whether tier is available
    }
    
    mapping(uint256 => PackTier) public packTiers;
    mapping(address => uint256) public lockedUntil; // User-specific lock periods
    uint256 public nextPackId = 1;
    
    event PackPurchased(address indexed buyer, uint256 packId, uint256 ethPaid, uint256 tokensReceived);
    event BurnRateUpdated(uint256 newRate);
    event TokensBurned(address indexed from, uint256 amount);

    /// @notice Initializer for upgradeable contract
    function initialize(string memory name_, string memory symbol_) public initializer {
        __ERC20_init(name_, symbol_);
        __ERC20Permit_init(name_);
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __Ownable2Step_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        
        _transferOwnership(msg.sender); // Ensure msg.sender is the owner

        _mint(msg.sender, INITIAL_SUPPLY);
        launchTime = block.timestamp;
    }

    /// @notice mint new tokens
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    /// @notice burn tokens
    function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
    
    /// @notice Set up a new pack tier
    function setupPackTier(uint256 packId, uint256 price, uint256 tokens, uint256 lockPeriod) external onlyOwner {
        packTiers[packId] = PackTier({
            price: price,
            tokens: tokens,
            lockPeriod: lockPeriod,
            active: true
        });
    }
    
    /// @notice Purchase an early pack
    function buyPack(uint256 packId) external payable nonReentrant {
        PackTier storage tier = packTiers[packId];
        require(tier.active, "Pack not available");
        require(msg.value >= tier.price, "Insufficient payment");
        
        // Lock tokens for buyer
        uint256 lockUntil = block.timestamp + tier.lockPeriod;
        if (lockedUntil[msg.sender] < lockUntil) {
            lockedUntil[msg.sender] = lockUntil;
        }
        
        // Mint tokens to buyer
        _mint(msg.sender, tier.tokens);
        
        // Refund excess payment
        if (msg.value > tier.price) {
            payable(msg.sender).transfer(msg.value - tier.price);
        }
        
        emit PackPurchased(msg.sender, packId, tier.price, tier.tokens);
    }
    
    /// @notice Update burn rate (only admin)
    function setBurnRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newRate <= 500, "Max 5% burn"); // Max 5%
        burnRate = newRate;
        emit BurnRateUpdated(newRate);
    }
    
    /// @notice Toggle burn mechanism
    function setBurnEnabled(bool enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        burnEnabled = enabled;
    }


    /// @notice pause all token transfers
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice unpause token transfers
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @dev required by UUPS
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @dev hook to prevent transfers while paused or during launch lock
    function _update(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        if (block.timestamp < launchTime + LOCK_PERIOD) {
            require(from == address(0) || to == address(0), "TRANSFERS_LOCKED");
        }
        
        // Check user-specific lock periods for early pack buyers
        if (from != address(0) && lockedUntil[from] > block.timestamp) {
            require(to == address(0), "TOKENS_LOCKED"); // Only burns allowed
        }
        
        // Apply burn if this is a transfer (not mint/burn) and burn is enabled
        if (from != address(0) && to != address(0) && burnEnabled) {
            uint256 burnAmount = (amount * burnRate) / 10000;
            if (burnAmount > 0) {
                super._update(from, address(0), burnAmount); // Burn tokens
                emit TokensBurned(from, burnAmount);
                amount = amount - burnAmount;
            }
        }
        
        super._update(from, to, amount);
    }
    
    /// @notice Withdraw ETH from pack sales
    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    /// @notice Check if address has locked tokens
    function isLocked(address account) external view returns (bool) {
        return lockedUntil[account] > block.timestamp;
    }
}
