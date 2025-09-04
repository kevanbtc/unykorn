// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title EnhancedAffiliateRouter - Hierarchical commission system for Hustlers/Advocates
contract EnhancedAffiliateRouter is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    enum UserType { NONE, ADVOCATE, HUSTLER, FOUNDING_BROKER }
    
    struct UserProfile {
        UserType userType;
        address upline;
        uint256 totalEarnings;
        uint256 pendingEarnings;
        uint256 totalReferrals;
        uint256 lockupPeriod;
        bool active;
    }
    
    struct CommissionTiers {
        uint256 advocateRate;      // 10-12%
        uint256 hustlerRate;       // 50% of pack sales
        uint256 brokerRate;        // Override for founding brokers
        uint256 overrideRate;      // Team override rate
    }
    
    mapping(address => UserProfile) public userProfiles;
    mapping(address => address[]) public downlines; // Track direct referrals
    mapping(address => uint256) public vestedBalances; // Locked earnings
    mapping(address => uint256) public vestingSchedule; // When tokens unlock
    
    IERC20 public immutable rewardToken;
    CommissionTiers public commissionTiers;
    
    uint256 public constant VESTING_PERIOD = 60 days; // 60-90 day lockup
    uint256 public totalCommissionsPaid;
    
    event UserRegistered(address indexed user, UserType userType, address indexed upline);
    event CommissionPaid(address indexed user, uint256 amount, string commissionType);
    event TokensVested(address indexed user, uint256 amount);
    event TokensClaimed(address indexed user, uint256 amount);
    
    constructor(address _rewardToken) Ownable(msg.sender) {
        rewardToken = IERC20(_rewardToken);
        commissionTiers = CommissionTiers({
            advocateRate: 1200,    // 12%
            hustlerRate: 5000,     // 50%
            brokerRate: 6000,      // 60% for founding brokers
            overrideRate: 500      // 5% override
        });
    }
    
    /// @notice Register a new user in the affiliate system
    function registerUser(
        address user,
        UserType userType,
        address upline,
        uint256 lockupPeriod
    ) external onlyOwner {
        require(userProfiles[user].userType == UserType.NONE, "User already registered");
        require(userType != UserType.NONE, "Invalid user type");
        
        if (upline != address(0)) {
            require(userProfiles[upline].active, "Upline not active");
            downlines[upline].push(user);
        }
        
        userProfiles[user] = UserProfile({
            userType: userType,
            upline: upline,
            totalEarnings: 0,
            pendingEarnings: 0,
            totalReferrals: 0,
            lockupPeriod: lockupPeriod > 0 ? lockupPeriod : VESTING_PERIOD,
            active: true
        });
        
        emit UserRegistered(user, userType, upline);
    }
    
    /// @notice Record commission for pack sales or other activities
    function recordCommission(
        address user,
        uint256 saleAmount,
        string calldata activityType
    ) external onlyOwner nonReentrant {
        UserProfile storage profile = userProfiles[user];
        require(profile.active, "User not active");
        
        uint256 commissionRate = _getCommissionRate(profile.userType);
        uint256 commission = (saleAmount * commissionRate) / 10000;
        
        // Apply lockup for certain user types and activities
        if (profile.userType == UserType.HUSTLER || 
            keccak256(abi.encodePacked(activityType)) == keccak256("PACK_SALE")) {
            
            vestedBalances[user] += commission;
            vestingSchedule[user] = block.timestamp + profile.lockupPeriod;
            
            emit TokensVested(user, commission);
        } else {
            // Immediate payout for advocates on regular sales
            profile.pendingEarnings += commission;
        }
        
        profile.totalEarnings += commission;
        totalCommissionsPaid += commission;
        
        // Pay team override to upline
        if (profile.upline != address(0)) {
            _payTeamOverride(profile.upline, commission);
        }
        
        emit CommissionPaid(user, commission, activityType);
    }
    
    /// @notice Pay team override commission
    function _payTeamOverride(address upline, uint256 downlineCommission) internal {
        UserProfile storage uplineProfile = userProfiles[upline];
        
        if (uplineProfile.active && 
            (uplineProfile.userType == UserType.HUSTLER || 
             uplineProfile.userType == UserType.FOUNDING_BROKER)) {
            
            uint256 overrideAmount = (downlineCommission * commissionTiers.overrideRate) / 10000;
            uplineProfile.pendingEarnings += overrideAmount;
            uplineProfile.totalEarnings += overrideAmount;
            
            emit CommissionPaid(upline, overrideAmount, "TEAM_OVERRIDE");
        }
    }
    
    /// @notice Claim pending (non-vested) earnings
    function claimPendingEarnings() external nonReentrant {
        UserProfile storage profile = userProfiles[msg.sender];
        uint256 amount = profile.pendingEarnings;
        require(amount > 0, "No pending earnings");
        
        profile.pendingEarnings = 0;
        rewardToken.safeTransfer(msg.sender, amount);
        
        emit TokensClaimed(msg.sender, amount);
    }
    
    /// @notice Claim vested tokens after lockup period
    function claimVestedTokens() external nonReentrant {
        require(block.timestamp >= vestingSchedule[msg.sender], "Tokens still locked");
        uint256 amount = vestedBalances[msg.sender];
        require(amount > 0, "No vested tokens");
        
        vestedBalances[msg.sender] = 0;
        vestingSchedule[msg.sender] = 0;
        
        rewardToken.safeTransfer(msg.sender, amount);
        
        emit TokensClaimed(msg.sender, amount);
    }
    
    /// @notice Get commission rate for user type
    function _getCommissionRate(UserType userType) internal view returns (uint256) {
        if (userType == UserType.ADVOCATE) {
            return commissionTiers.advocateRate;
        } else if (userType == UserType.HUSTLER) {
            return commissionTiers.hustlerRate;
        } else if (userType == UserType.FOUNDING_BROKER) {
            return commissionTiers.brokerRate;
        }
        return 0;
    }
    
    /// @notice Get user's downline
    function getDownline(address user) external view returns (address[] memory) {
        return downlines[user];
    }
    
    /// @notice Check vesting status
    function getVestingInfo(address user) external view returns (
        uint256 vestedAmount,
        uint256 unlockTime,
        bool canClaim
    ) {
        return (
            vestedBalances[user],
            vestingSchedule[user],
            block.timestamp >= vestingSchedule[user] && vestedBalances[user] > 0
        );
    }
    
    /// @notice Update commission tiers (only owner)
    function updateCommissionTiers(
        uint256 advocateRate,
        uint256 hustlerRate,
        uint256 brokerRate,
        uint256 overrideRate
    ) external onlyOwner {
        require(advocateRate <= 2000, "Max 20% for advocates");
        require(hustlerRate <= 6000, "Max 60% for hustlers");
        require(brokerRate <= 7000, "Max 70% for brokers");
        require(overrideRate <= 1000, "Max 10% override");
        
        commissionTiers = CommissionTiers({
            advocateRate: advocateRate,
            hustlerRate: hustlerRate,
            brokerRate: brokerRate,
            overrideRate: overrideRate
        });
    }
    
    /// @notice Deactivate user
    function deactivateUser(address user) external onlyOwner {
        userProfiles[user].active = false;
    }
    
    /// @notice Emergency withdrawal
    function emergencyWithdraw(uint256 amount) external onlyOwner {
        rewardToken.safeTransfer(owner(), amount);
    }
    
    /// @notice Get user statistics
    function getUserStats(address user) external view returns (
        UserType userType,
        address upline,
        uint256 totalEarnings,
        uint256 pendingEarnings,
        uint256 totalReferrals,
        bool active
    ) {
        UserProfile storage profile = userProfiles[user];
        return (
            profile.userType,
            profile.upline,
            profile.totalEarnings,
            profile.pendingEarnings,
            profile.totalReferrals,
            profile.active
        );
    }
    
    /// @notice Calculate team volume (simplified)
    function getTeamVolume(address user) external view returns (uint256) {
        // This would calculate total volume of user's entire downline
        // Simplified for now - would need more complex tracking in production
        return userProfiles[user].totalEarnings;
    }
}