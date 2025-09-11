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
    bytes32 public constant UTILITY_ROLE = keccak256("UTILITY_ROLE");

    uint256 public constant INITIAL_SUPPLY = 1_000_000_000_000 * 1e18; // Trillions as per spec
    uint256 private constant LOCK_PERIOD = 7 days;
    uint256 public launchTime;

    // Burn rate configuration (in basis points, 100 = 1%)
    uint256 public burnRate = 300; // 3% default
    uint256 public constant MAX_BURN_RATE = 500; // 5% max
    
    // Utility tracking
    mapping(address => uint256) public pocStreaks;
    mapping(address => uint256) public lastPocTime;
    mapping(bytes32 => bool) public poiRecords;
    mapping(address => uint256) public commissionEarnings;
    
    // Events
    event BurnRateUpdated(uint256 oldRate, uint256 newRate);
    event PocCheckin(address indexed user, uint256 streak);
    event PoiRecorded(bytes32 indexed poiId, address indexed connector, address party1, address party2);
    event UtilityUsed(address indexed user, uint256 amount, string purpose);

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
        _grantRole(UTILITY_ROLE, msg.sender);

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

    /// @notice pause all token transfers
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice unpause token transfers
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Set burn rate for utility usage
    function setBurnRate(uint256 newRate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newRate <= MAX_BURN_RATE, "Rate too high");
        uint256 oldRate = burnRate;
        burnRate = newRate;
        emit BurnRateUpdated(oldRate, newRate);
    }

    /// @notice Daily POC check-in
    function pocCheckin() external whenNotPaused nonReentrant {
        require(block.timestamp >= lastPocTime[msg.sender] + 1 days, "Already checked in today");
        
        if (lastPocTime[msg.sender] + 2 days > block.timestamp) {
            pocStreaks[msg.sender]++;
        } else {
            pocStreaks[msg.sender] = 1; // Reset streak if missed a day
        }
        
        lastPocTime[msg.sender] = block.timestamp;
        emit PocCheckin(msg.sender, pocStreaks[msg.sender]);
    }

    /// @notice Record POI (Proof of Introduction) between two parties
    function recordPoi(address party1, address party2, bytes32 nonce) external onlyRole(UTILITY_ROLE) {
        require(party1 != party2, "Invalid parties");
        bytes32 poiId = keccak256(abi.encodePacked(msg.sender, party1, party2, nonce));
        require(!poiRecords[poiId], "POI already exists");
        
        poiRecords[poiId] = true;
        emit PoiRecorded(poiId, msg.sender, party1, party2);
    }

    /// @notice Use tokens for utility functions with burn mechanism
    function useForUtility(uint256 amount, string calldata purpose) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        uint256 burnAmount = (amount * burnRate) / 10000;
        uint256 remainingAmount = amount - burnAmount;
        
        if (burnAmount > 0) {
            _burn(msg.sender, burnAmount);
        }
        
        // The remaining amount stays with user but is "consumed" for utility
        emit UtilityUsed(msg.sender, amount, purpose);
    }

    /// @notice Track commission earnings (called by revenue distribution contracts)
    function addCommissionEarning(address user, uint256 amount) external onlyRole(UTILITY_ROLE) {
        commissionEarnings[user] += amount;
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
        super._update(from, to, amount);
    }
}
