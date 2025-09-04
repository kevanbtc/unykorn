// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ITokenERC20 {
    function useForUtility(uint256 amount, string calldata purpose) external;
    function addCommissionEarning(address user, uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
}

/// @title RevVault - Revenue sharing commerce layer
contract RevVault is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant MERCHANT_ROLE = keccak256("MERCHANT_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct Offer {
        address merchant;
        uint256 price;
        string description;
        bool isActive;
        uint256 totalSales;
    }

    struct CommissionStructure {
        uint256 merchantPercentage;    // e.g., 9000 = 90%
        uint256 directCommission;      // e.g., 5000 = 50% (of remaining)
        uint256 teamOverride;          // e.g., 300 = 3%
        uint256 poiBonus;             // e.g., 100 = 1%
        uint256 territoryPool;        // e.g., 200 = 2%
        uint256 platformFee;          // e.g., 300 = 3%
        uint256 burnPercentage;       // e.g., 100 = 1%
    }

    // State variables
    ITokenERC20 public immutable token;
    IERC20 public immutable paymentToken;
    
    mapping(uint256 => Offer) public offers;
    mapping(address => address) public directReferrer;
    mapping(address => address[]) public referrals;
    mapping(address => uint256) public territoryPoolBalance;
    mapping(address => bool) public isHustler;
    
    uint256 public nextOfferId = 1;
    CommissionStructure public defaultCommission;
    
    // Events
    event OfferCreated(uint256 indexed offerId, address indexed merchant, uint256 price, string description);
    event Purchase(
        uint256 indexed offerId, 
        address indexed buyer, 
        address indexed referrer,
        uint256 amount,
        uint256 merchantAmount,
        uint256 commissionAmount
    );
    event CommissionPaid(address indexed recipient, uint256 amount, string commissionType);
    event HustlerStatusUpdated(address indexed user, bool isHustler);

    constructor(
        address _token,
        address _paymentToken,
        address admin
    ) {
        token = ITokenERC20(_token);
        paymentToken = IERC20(_paymentToken);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
        
        // Default commission structure
        defaultCommission = CommissionStructure({
            merchantPercentage: 9000,    // 90%
            directCommission: 5000,      // 50% of remaining
            teamOverride: 300,           // 3%
            poiBonus: 100,              // 1%
            territoryPool: 200,         // 2%
            platformFee: 300,           // 3%
            burnPercentage: 100         // 1%
        });
    }

    /// @notice Create merchant offer
    function createOffer(
        uint256 price,
        string calldata description
    ) external returns (uint256 offerId) {
        require(hasRole(MERCHANT_ROLE, msg.sender) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not authorized");
        require(price > 0, "Invalid price");
        
        offerId = nextOfferId++;
        offers[offerId] = Offer({
            merchant: msg.sender,
            price: price,
            description: description,
            isActive: true,
            totalSales: 0
        });
        
        emit OfferCreated(offerId, msg.sender, price, description);
    }

    /// @notice Purchase offer with automatic commission distribution
    function purchase(uint256 offerId, address referrer) external nonReentrant {
        Offer storage offer = offers[offerId];
        require(offer.isActive, "Offer not active");
        require(offer.price > 0, "Invalid offer");
        
        // Transfer payment from buyer
        paymentToken.safeTransferFrom(msg.sender, address(this), offer.price);
        
        // Set referrer if not already set
        if (referrer != address(0) && directReferrer[msg.sender] == address(0)) {
            directReferrer[msg.sender] = referrer;
            referrals[referrer].push(msg.sender);
        }
        
        // Calculate and distribute commissions
        _distributeRevenue(offerId, msg.sender, offer.price);
        
        offer.totalSales++;
        
        emit Purchase(offerId, msg.sender, directReferrer[msg.sender], offer.price, 0, 0);
    }

    /// @notice Internal revenue distribution logic
    function _distributeRevenue(uint256 offerId, address buyer, uint256 totalAmount) internal {
        Offer storage offer = offers[offerId];
        CommissionStructure memory comm = defaultCommission;
        
        // 1. Merchant gets their percentage (90-95%)
        uint256 merchantAmount = (totalAmount * comm.merchantPercentage) / 10000;
        paymentToken.safeTransfer(offer.merchant, merchantAmount);
        
        uint256 remainingAmount = totalAmount - merchantAmount;
        
        // 2. Direct commission (up to 50% of remaining)
        address referrer = directReferrer[buyer];
        if (referrer != address(0)) {
            uint256 directAmount = (remainingAmount * comm.directCommission) / 10000;
            paymentToken.safeTransfer(referrer, directAmount);
            token.addCommissionEarning(referrer, directAmount);
            emit CommissionPaid(referrer, directAmount, "Direct");
            remainingAmount -= directAmount;
        }
        
        // 3. Team override (3-5%)
        uint256 teamAmount = (totalAmount * comm.teamOverride) / 10000;
        if (referrer != address(0)) {
            address teamLead = directReferrer[referrer];
            if (teamLead != address(0) && isHustler[teamLead]) {
                paymentToken.safeTransfer(teamLead, teamAmount);
                token.addCommissionEarning(teamLead, teamAmount);
                emit CommissionPaid(teamLead, teamAmount, "Team Override");
            }
        }
        
        // 4. POI bonus (1-3%)
        uint256 poiAmount = (totalAmount * comm.poiBonus) / 10000;
        // Note: POI bonus logic would connect to POI records in token contract
        
        // 5. Territory pool (1-2%)
        uint256 territoryAmount = (totalAmount * comm.territoryPool) / 10000;
        territoryPoolBalance[address(this)] += territoryAmount;
        
        // 6. Platform fee (1-3%)
        uint256 platformAmount = (totalAmount * comm.platformFee) / 10000;
        // Platform fee stays in contract
        
        // 7. Burn percentage
        uint256 burnAmount = (totalAmount * comm.burnPercentage) / 10000;
        // This would trigger token burn via token contract integration
    }

    /// @notice Set hustler status for team overrides
    function setHustlerStatus(address user, bool status) external onlyRole(OPERATOR_ROLE) {
        isHustler[user] = status;
        emit HustlerStatusUpdated(user, status);
    }

    /// @notice Update commission structure
    function updateCommissionStructure(
        uint256 merchantPercentage,
        uint256 directCommission,
        uint256 teamOverride,
        uint256 poiBonus,
        uint256 territoryPool,
        uint256 platformFee,
        uint256 burnPercentage
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            merchantPercentage + teamOverride + poiBonus + territoryPool + platformFee + burnPercentage <= 10000,
            "Total exceeds 100%"
        );
        
        defaultCommission = CommissionStructure({
            merchantPercentage: merchantPercentage,
            directCommission: directCommission,
            teamOverride: teamOverride,
            poiBonus: poiBonus,
            territoryPool: territoryPool,
            platformFee: platformFee,
            burnPercentage: burnPercentage
        });
    }

    /// @notice Grant merchant role
    function addMerchant(address merchant) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MERCHANT_ROLE, merchant);
    }

    /// @notice Get offer details
    function getOffer(uint256 offerId) external view returns (Offer memory) {
        return offers[offerId];
    }

    /// @notice Get user's referral network
    function getReferrals(address user) external view returns (address[] memory) {
        return referrals[user];
    }

    /// @notice Deactivate offer
    function deactivateOffer(uint256 offerId) external {
        require(
            offers[offerId].merchant == msg.sender || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Not authorized"
        );
        offers[offerId].isActive = false;
    }
}