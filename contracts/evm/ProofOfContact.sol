// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ProofOfContact - Daily check-in system via various methods
contract ProofOfContact is Ownable, ReentrancyGuard {
    IERC20 public immutable rewardToken;
    
    struct Beacon {
        string location;
        bool active;
        uint256 rewardAmount;
        address owner;
    }
    
    struct CheckIn {
        uint256 timestamp;
        uint256 beaconId;
        string method; // "QR", "NFC", "SMS", "IVR"
    }
    
    struct UserStats {
        uint256 currentStreak;
        uint256 longestStreak;
        uint256 totalCheckIns;
        uint256 lastCheckInDay;
        uint256 totalRewards;
    }
    
    mapping(uint256 => Beacon) public beacons;
    mapping(address => UserStats) public userStats;
    mapping(address => mapping(uint256 => mapping(uint256 => bool))) public dailyCheckIns; // user => beaconId => day => checked
    mapping(address => CheckIn[]) public userCheckIns;
    
    uint256 public nextBeaconId = 1;
    uint256 public baseReward = 100 * 1e18; // Base reward tokens
    uint256 public constant STREAK_BONUS = 10; // 10% bonus per streak day
    uint256 public constant MAX_STREAK_BONUS = 200; // Max 200% bonus
    
    event BeaconCreated(uint256 indexed beaconId, string location, address owner);
    event CheckInRecorded(address indexed user, uint256 indexed beaconId, string method, uint256 reward);
    event StreakMilestone(address indexed user, uint256 streak);
    
    constructor(address _rewardToken) Ownable(msg.sender) {
        rewardToken = IERC20(_rewardToken);
    }
    
    /// @notice Create a new beacon location
    function createBeacon(string calldata location, uint256 rewardAmount) external returns (uint256) {
        uint256 beaconId = nextBeaconId++;
        beacons[beaconId] = Beacon({
            location: location,
            active: true,
            rewardAmount: rewardAmount > 0 ? rewardAmount : baseReward,
            owner: msg.sender
        });
        
        emit BeaconCreated(beaconId, location, msg.sender);
        return beaconId;
    }
    
    /// @notice Record a check-in (called by authorized validators)
    function recordCheckIn(
        address user,
        uint256 beaconId,
        string calldata method
    ) external onlyOwner nonReentrant {
        require(beacons[beaconId].active, "Beacon inactive");
        
        uint256 currentDay = block.timestamp / 1 days;
        require(!dailyCheckIns[user][beaconId][currentDay], "Already checked in today");
        
        // Mark check-in for today
        dailyCheckIns[user][beaconId][currentDay] = true;
        
        // Update user stats
        UserStats storage stats = userStats[user];
        
        // Update streak
        if (stats.lastCheckInDay == currentDay - 1) {
            stats.currentStreak++;
        } else if (stats.lastCheckInDay < currentDay - 1) {
            stats.currentStreak = 1; // Reset streak
        }
        
        stats.lastCheckInDay = currentDay;
        stats.totalCheckIns++;
        
        if (stats.currentStreak > stats.longestStreak) {
            stats.longestStreak = stats.currentStreak;
            
            // Emit milestone events
            if (stats.currentStreak % 10 == 0) {
                emit StreakMilestone(user, stats.currentStreak);
            }
        }
        
        // Calculate reward with streak bonus
        uint256 baseAmount = beacons[beaconId].rewardAmount;
        uint256 streakBonusPercent = (stats.currentStreak * STREAK_BONUS);
        if (streakBonusPercent > MAX_STREAK_BONUS) {
            streakBonusPercent = MAX_STREAK_BONUS;
        }
        
        uint256 reward = baseAmount + (baseAmount * streakBonusPercent / 100);
        
        // Transfer reward
        require(rewardToken.transfer(user, reward), "Reward transfer failed");
        stats.totalRewards += reward;
        
        // Record check-in
        userCheckIns[user].push(CheckIn({
            timestamp: block.timestamp,
            beaconId: beaconId,
            method: method
        }));
        
        emit CheckInRecorded(user, beaconId, method, reward);
    }
    
    /// @notice Get user's check-in history
    function getUserCheckIns(address user) external view returns (CheckIn[] memory) {
        return userCheckIns[user];
    }
    
    /// @notice Check if user can check in today at beacon
    function canCheckInToday(address user, uint256 beaconId) external view returns (bool) {
        uint256 currentDay = block.timestamp / 1 days;
        return !dailyCheckIns[user][beaconId][currentDay] && beacons[beaconId].active;
    }
    
    /// @notice Update beacon status
    function setBeaconActive(uint256 beaconId, bool active) external {
        require(beacons[beaconId].owner == msg.sender || msg.sender == owner(), "Not authorized");
        beacons[beaconId].active = active;
    }
    
    /// @notice Set base reward amount
    function setBaseReward(uint256 amount) external onlyOwner {
        baseReward = amount;
    }
    
    /// @notice Emergency withdraw tokens
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
    
    /// @notice Get current day number
    function getCurrentDay() external view returns (uint256) {
        return block.timestamp / 1 days;
    }
}