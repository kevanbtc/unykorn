// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title RevVault - Commerce layer with automatic revenue splitting
contract RevVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    struct Offer {
        address merchant;
        string title;
        string description;
        uint256 price;
        bool active;
        uint256 totalSales;
        string offerType; // "VOUCHER", "MEMBERSHIP", "SERVICE"
    }
    
    struct Commission {
        uint256 merchant;      // 90-95%
        uint256 direct;        // up to 50% 
        uint256 teamOverride;  // 3-5%
        uint256 poiBonus;      // 1-3%
        uint256 territory;     // 1-2%
        uint256 platform;      // 1-3%
        uint256 burn;          // remainder
    }
    
    struct Purchase {
        uint256 offerId;
        address buyer;
        address referrer;
        address teamLead;
        uint256 amount;
        uint256 timestamp;
        bool fulfilled;
    }
    
    mapping(uint256 => Offer) public offers;
    mapping(address => uint256[]) public merchantOffers;
    mapping(address => uint256) public territories; // User territory assignments
    mapping(address => address) public teamStructure; // User => team lead
    mapping(bytes32 => Purchase) public purchases;
    mapping(address => uint256) public pendingPayouts;
    
    uint256 public nextOfferId = 1;
    Commission public defaultCommission = Commission({
        merchant: 9000,    // 90%
        direct: 5000,      // 50% of commission pool
        teamOverride: 500, // 5%
        poiBonus: 200,     // 2%
        territory: 150,    // 1.5%
        platform: 150,     // 1.5%
        burn: 0           // Calculated remainder
    });
    
    IERC20 public immutable paymentToken;
    address public immutable burnContract;
    address public territoryPool;
    address public platformTreasury;
    
    event OfferCreated(uint256 indexed offerId, address indexed merchant, string title, uint256 price);
    event PurchaseMade(
        bytes32 indexed purchaseId,
        uint256 indexed offerId,
        address indexed buyer,
        address referrer,
        uint256 amount
    );
    event PayoutDistributed(address indexed recipient, uint256 amount, string payoutType);
    event CommissionUpdated(string commissionType, uint256 newRate);
    
    constructor(
        address _paymentToken,
        address _burnContract,
        address _territoryPool,
        address _platformTreasury
    ) Ownable(msg.sender) {
        paymentToken = IERC20(_paymentToken);
        burnContract = _burnContract;
        territoryPool = _territoryPool;
        platformTreasury = _platformTreasury;
    }
    
    /// @notice Create a new offer
    function createOffer(
        string calldata title,
        string calldata description,
        uint256 price,
        string calldata offerType
    ) external returns (uint256) {
        uint256 offerId = nextOfferId++;
        
        offers[offerId] = Offer({
            merchant: msg.sender,
            title: title,
            description: description,
            price: price,
            active: true,
            totalSales: 0,
            offerType: offerType
        });
        
        merchantOffers[msg.sender].push(offerId);
        
        emit OfferCreated(offerId, msg.sender, title, price);
        return offerId;
    }
    
    /// @notice Purchase an offer with automatic revenue splitting
    function purchase(
        uint256 offerId,
        address referrer,
        bytes32 poiProof
    ) external nonReentrant returns (bytes32) {
        Offer storage offer = offers[offerId];
        require(offer.active, "Offer not active");
        require(offer.merchant != msg.sender, "Cannot buy own offer");
        
        // Transfer payment from buyer
        paymentToken.safeTransferFrom(msg.sender, address(this), offer.price);
        
        // Generate purchase ID
        bytes32 purchaseId = keccak256(abi.encodePacked(
            offerId,
            msg.sender,
            block.timestamp,
            block.number
        ));
        
        // Record purchase
        purchases[purchaseId] = Purchase({
            offerId: offerId,
            buyer: msg.sender,
            referrer: referrer,
            teamLead: teamStructure[referrer],
            amount: offer.price,
            timestamp: block.timestamp,
            fulfilled: false
        });
        
        // Distribute payments
        _distributePayout(offer, referrer, poiProof);
        
        offer.totalSales += offer.price;
        
        emit PurchaseMade(purchaseId, offerId, msg.sender, referrer, offer.price);
        return purchaseId;
    }
    
    /// @notice Distribute payment according to commission structure
    function _distributePayout(
        Offer storage offer,
        address referrer,
        bytes32 poiProof
    ) internal {
        uint256 totalAmount = offer.price;
        uint256 merchantShare = (totalAmount * defaultCommission.merchant) / 10000;
        uint256 commissionPool = totalAmount - merchantShare;
        
        // Pay merchant immediately
        paymentToken.safeTransfer(offer.merchant, merchantShare);
        emit PayoutDistributed(offer.merchant, merchantShare, "MERCHANT");
        
        // Distribute commissions from remaining pool
        if (referrer != address(0)) {
            uint256 directCommission = (commissionPool * defaultCommission.direct) / 10000;
            pendingPayouts[referrer] += directCommission;
            emit PayoutDistributed(referrer, directCommission, "DIRECT");
            
            // Team override
            address teamLead = teamStructure[referrer];
            if (teamLead != address(0)) {
                uint256 teamOverride = (commissionPool * defaultCommission.teamOverride) / 10000;
                pendingPayouts[teamLead] += teamOverride;
                emit PayoutDistributed(teamLead, teamOverride, "TEAM_OVERRIDE");
            }
        }
        
        // POI bonus (if proof provided)
        if (poiProof != bytes32(0)) {
            uint256 poiBonus = (commissionPool * defaultCommission.poiBonus) / 10000;
            // In production, would verify POI proof and pay connector
            emit PayoutDistributed(address(0), poiBonus, "POI_BONUS");
        }
        
        // Territory pool
        uint256 territoryShare = (commissionPool * defaultCommission.territory) / 10000;
        paymentToken.safeTransfer(territoryPool, territoryShare);
        emit PayoutDistributed(territoryPool, territoryShare, "TERRITORY");
        
        // Platform treasury
        uint256 platformShare = (commissionPool * defaultCommission.platform) / 10000;
        paymentToken.safeTransfer(platformTreasury, platformShare);
        emit PayoutDistributed(platformTreasury, platformShare, "PLATFORM");
        
        // Burn remainder
        uint256 burnAmount = paymentToken.balanceOf(address(this)) - _calculateTotalPendingPayouts();
        if (burnAmount > 0) {
            paymentToken.safeTransfer(burnContract, burnAmount);
            emit PayoutDistributed(burnContract, burnAmount, "BURN");
        }
    }
    
    /// @notice Claim pending payouts
    function claimPayout() external nonReentrant {
        uint256 amount = pendingPayouts[msg.sender];
        require(amount > 0, "No pending payout");
        
        pendingPayouts[msg.sender] = 0;
        paymentToken.safeTransfer(msg.sender, amount);
        
        emit PayoutDistributed(msg.sender, amount, "CLAIMED");
    }
    
    /// @notice Set team structure
    function setTeamLead(address user, address teamLead) external onlyOwner {
        teamStructure[user] = teamLead;
    }
    
    /// @notice Assign territory
    function setTerritory(address user, uint256 territoryId) external onlyOwner {
        territories[user] = territoryId;
    }
    
    /// @notice Update commission rates
    function updateCommission(
        uint256 merchant,
        uint256 direct,
        uint256 teamOverride,
        uint256 poiBonus,
        uint256 territory,
        uint256 platform
    ) external onlyOwner {
        require(merchant + direct + teamOverride + poiBonus + territory + platform <= 10000, "Invalid total");
        
        defaultCommission = Commission({
            merchant: merchant,
            direct: direct,
            teamOverride: teamOverride,
            poiBonus: poiBonus,
            territory: territory,
            platform: platform,
            burn: 0
        });
    }
    
    /// @notice Get merchant's offers
    function getMerchantOffers(address merchant) external view returns (uint256[] memory) {
        return merchantOffers[merchant];
    }
    
    /// @notice Get offer details
    function getOffer(uint256 offerId) external view returns (
        address merchant,
        string memory title,
        string memory description,
        uint256 price,
        bool active,
        uint256 totalSales,
        string memory offerType
    ) {
        Offer storage offer = offers[offerId];
        return (
            offer.merchant,
            offer.title,
            offer.description,
            offer.price,
            offer.active,
            offer.totalSales,
            offer.offerType
        );
    }
    
    /// @notice Toggle offer status
    function toggleOffer(uint256 offerId) external {
        require(offers[offerId].merchant == msg.sender, "Not your offer");
        offers[offerId].active = !offers[offerId].active;
    }
    
    /// @notice Calculate total pending payouts
    function _calculateTotalPendingPayouts() internal view returns (uint256) {
        // This is a simplified calculation - in production would track more efficiently
        return 0; // Placeholder
    }
    
    /// @notice Emergency withdraw
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        paymentToken.safeTransfer(owner(), amount);
    }
}