// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ITokenERC20 {
    function mint(address to, uint256 amount) external;
    function addCommissionEarning(address user, uint256 amount) external;
}

/// @title SalesForceManager - Manage hustlers, brokers, and advocates
contract SalesForceManager is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant BROKER_ROLE = keccak256("BROKER_ROLE");
    bytes32 public constant HUSTLER_ROLE = keccak256("HUSTLER_ROLE");
    bytes32 public constant ADVOCATE_ROLE = keccak256("ADVOCATE_ROLE");

    struct EarlyPack {
        uint256 price;        // $25, $50, $100
        uint256 tokenAmount;  // Allocated tokens
        uint256 lockDays;     // 60-90 days
        bool isActive;
    }

    struct SalesRecord {
        address seller;
        address buyer;
        uint256 packId;
        uint256 amount;
        uint256 timestamp;
        uint256 commission;
        bool commissionPaid;
    }

    struct SalesforceStats {
        uint256 totalSales;
        uint256 totalCommissions;
        uint256 teamSize;
        uint256 directRecruits;
        bool isFoundingBroker;
    }

    // State variables
    ITokenERC20 public immutable token;
    IERC20 public immutable paymentToken;
    
    mapping(uint256 => EarlyPack) public earlyPacks;
    mapping(address => SalesforceStats) public salesStats;
    mapping(address => address) public upline; // Direct referrer
    mapping(address => address[]) public downline; // Direct recruits
    mapping(address => uint256[]) public salesHistory; // Sale IDs
    mapping(uint256 => SalesRecord) public sales;
    mapping(address => uint256) public lockedTokens;
    mapping(address => uint256) public unlockTime;
    
    uint256 public nextSaleId = 1;
    uint256 public nextPackId = 1;
    uint256 public constant HUSTLER_COMMISSION = 5000; // 50% in basis points
    uint256 public constant ADVOCATE_COMMISSION = 1000; // 10%
    uint256 public constant OVERRIDE_COMMISSION = 200; // 2%
    uint256 public constant FOUNDING_BROKER_TARGET = 10; // Must bring 10 each

    // Events
    event PackCreated(uint256 indexed packId, uint256 price, uint256 tokenAmount, uint256 lockDays);
    event PackPurchased(
        uint256 indexed packId,
        address indexed buyer,
        address indexed seller,
        uint256 amount,
        uint256 tokens
    );
    event CommissionPaid(address indexed recipient, uint256 amount, string commissionType);
    event TeamMemberAdded(address indexed upline, address indexed newMember, bytes32 role);
    event TokensUnlocked(address indexed user, uint256 amount);

    constructor(
        address _token,
        address _paymentToken,
        address admin
    ) {
        token = ITokenERC20(_token);
        paymentToken = IERC20(_paymentToken);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        
        // Create default early packs
        _createEarlyPack(25e18, 1_000_000e18, 60); // $25 = 1M tokens, 60 days
        _createEarlyPack(50e18, 2_500_000e18, 75); // $50 = 2.5M tokens, 75 days  
        _createEarlyPack(100e18, 6_000_000e18, 90); // $100 = 6M tokens, 90 days
    }

    /// @notice Create new early pack offering
    function createEarlyPack(
        uint256 price,
        uint256 tokenAmount,
        uint256 lockDays
    ) external onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 packId) {
        return _createEarlyPack(price, tokenAmount, lockDays);
    }

    function _createEarlyPack(
        uint256 price,
        uint256 tokenAmount,
        uint256 lockDays
    ) internal returns (uint256 packId) {
        packId = nextPackId++;
        earlyPacks[packId] = EarlyPack({
            price: price,
            tokenAmount: tokenAmount,
            lockDays: lockDays,
            isActive: true
        });
        
        emit PackCreated(packId, price, tokenAmount, lockDays);
    }

    /// @notice Purchase early pack with referrer
    function purchaseEarlyPack(
        uint256 packId,
        address referrer
    ) external nonReentrant {
        EarlyPack storage pack = earlyPacks[packId];
        require(pack.isActive, "Pack not active");
        require(pack.price > 0, "Invalid pack");
        
        // Transfer payment
        paymentToken.safeTransferFrom(msg.sender, address(this), pack.price);
        
        // Set upline if first purchase and valid referrer
        if (upline[msg.sender] == address(0) && referrer != address(0) && referrer != msg.sender) {
            upline[msg.sender] = referrer;
            downline[referrer].push(msg.sender);
            salesStats[referrer].directRecruits++;
            
            // Grant roles based on referrer status
            if (hasRole(HUSTLER_ROLE, referrer)) {
                _grantRole(ADVOCATE_ROLE, msg.sender);
                emit TeamMemberAdded(referrer, msg.sender, ADVOCATE_ROLE);
            }
        }
        
        // Record sale
        uint256 saleId = nextSaleId++;
        sales[saleId] = SalesRecord({
            seller: referrer,
            buyer: msg.sender,
            packId: packId,
            amount: pack.price,
            timestamp: block.timestamp,
            commission: 0,
            commissionPaid: false
        });
        
        salesHistory[msg.sender].push(saleId);
        if (referrer != address(0)) {
            salesHistory[referrer].push(saleId);
            salesStats[referrer].totalSales += pack.price;
        }
        
        // Mint and lock tokens
        token.mint(address(this), pack.tokenAmount);
        lockedTokens[msg.sender] += pack.tokenAmount;
        unlockTime[msg.sender] = block.timestamp + (pack.lockDays * 1 days);
        
        // Calculate and pay commissions
        _payCommissions(saleId, pack.price, referrer);
        
        emit PackPurchased(packId, msg.sender, referrer, pack.price, pack.tokenAmount);
    }

    /// @notice Internal commission calculation and payment
    function _payCommissions(uint256 saleId, uint256 saleAmount, address directReferrer) internal {
        if (directReferrer == address(0)) return;
        
        uint256 commission = 0;
        
        // Direct commission based on role
        if (hasRole(HUSTLER_ROLE, directReferrer)) {
            commission = (saleAmount * HUSTLER_COMMISSION) / 10000; // 50%
        } else if (hasRole(ADVOCATE_ROLE, directReferrer)) {
            commission = (saleAmount * ADVOCATE_COMMISSION) / 10000; // 10%
        }
        
        if (commission > 0) {
            paymentToken.safeTransfer(directReferrer, commission);
            token.addCommissionEarning(directReferrer, commission);
            salesStats[directReferrer].totalCommissions += commission;
            
            sales[saleId].commission = commission;
            sales[saleId].commissionPaid = true;
            
            emit CommissionPaid(directReferrer, commission, "Direct");
        }
        
        // Team override for hustler's upline
        address teamLead = upline[directReferrer];
        if (teamLead != address(0) && hasRole(HUSTLER_ROLE, teamLead)) {
            uint256 overrideAmount = (saleAmount * OVERRIDE_COMMISSION) / 10000; // 2%
            paymentToken.safeTransfer(teamLead, overrideAmount);
            token.addCommissionEarning(teamLead, overrideAmount);
            emit CommissionPaid(teamLead, overrideAmount, "Team Override");
        }
    }

    /// @notice Unlock vested tokens after lock period
    function unlockTokens() external nonReentrant {
        require(block.timestamp >= unlockTime[msg.sender], "Still locked");
        require(lockedTokens[msg.sender] > 0, "No locked tokens");
        
        uint256 amount = lockedTokens[msg.sender];
        lockedTokens[msg.sender] = 0;
        
        // Transfer unlocked tokens to user
        IERC20(address(token)).safeTransfer(msg.sender, amount);
        
        emit TokensUnlocked(msg.sender, amount);
    }

    /// @notice Add founding broker (admin function)
    function addFoundingBroker(address broker) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BROKER_ROLE, broker);
        _grantRole(HUSTLER_ROLE, broker); // Brokers are also hustlers
        salesStats[broker].isFoundingBroker = true;
        emit TeamMemberAdded(address(0), broker, BROKER_ROLE);
    }

    /// @notice Promote advocate to hustler (based on performance)
    function promoteToHustler(address advocate) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(hasRole(ADVOCATE_ROLE, advocate), "Not an advocate");
        _grantRole(HUSTLER_ROLE, advocate);
        emit TeamMemberAdded(upline[advocate], advocate, HUSTLER_ROLE);
    }

    /// @notice Get salesforce statistics
    function getStats(address user) external view returns (SalesforceStats memory) {
        return salesStats[user];
    }

    /// @notice Get team structure
    function getDownline(address user) external view returns (address[] memory) {
        return downline[user];
    }

    /// @notice Get sales history
    function getSalesHistory(address user) external view returns (uint256[] memory) {
        return salesHistory[user];
    }

    /// @notice Get early pack details
    function getEarlyPack(uint256 packId) external view returns (EarlyPack memory) {
        return earlyPacks[packId];
    }

    /// @notice Check token lock status
    function getTokenLockInfo(address user) external view returns (uint256 locked, uint256 unlocks) {
        return (lockedTokens[user], unlockTime[user]);
    }

    /// @notice Deactivate early pack
    function deactivateEarlyPack(uint256 packId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        earlyPacks[packId].isActive = false;
    }

    /// @notice Withdraw platform funds
    function withdrawFunds(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        paymentToken.safeTransfer(to, amount);
    }
}