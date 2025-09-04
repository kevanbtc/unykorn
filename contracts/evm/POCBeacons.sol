// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ITokenERC20 {
    function pocCheckin() external;
    function pocStreaks(address user) external view returns (uint256);
    function useForUtility(uint256 amount, string calldata purpose) external;
}

/// @title POCBeacons - Proof of Contact beacon system
contract POCBeacons is AccessControl, ReentrancyGuard {
    bytes32 public constant BEACON_MANAGER_ROLE = keccak256("BEACON_MANAGER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    struct Beacon {
        string location;
        int256 latitude;
        int256 longitude;
        uint256 radius; // in meters
        bool isActive;
        address owner;
        uint256 totalCheckins;
    }

    struct CheckinRecord {
        uint256 beaconId;
        uint256 timestamp;
        string method; // "QR", "NFC", "SMS", "IVR"
    }

    // State variables
    ITokenERC20 public immutable token;
    
    mapping(uint256 => Beacon) public beacons;
    mapping(address => mapping(uint256 => uint256)) public lastCheckinTime; // user => beaconId => timestamp
    mapping(address => CheckinRecord[]) public userCheckins;
    mapping(address => uint256) public dailyCheckinCount;
    mapping(address => uint256) public lastCheckinDate;
    
    uint256 public nextBeaconId = 1;
    uint256 public constant MAX_DAILY_CHECKINS = 10;
    uint256 public constant MIN_CHECKIN_INTERVAL = 24 hours;
    uint256 public constant GEO_RADIUS_LIMIT = 1000; // 1km max
    
    // Events
    event BeaconCreated(uint256 indexed beaconId, string location, address indexed owner);
    event CheckinRecorded(
        address indexed user, 
        uint256 indexed beaconId, 
        uint256 timestamp, 
        string method,
        uint256 streak
    );
    event BeaconUpdated(uint256 indexed beaconId, bool isActive);

    constructor(address _token, address admin) {
        token = ITokenERC20(_token);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(BEACON_MANAGER_ROLE, admin);
        _grantRole(OPERATOR_ROLE, admin);
    }

    /// @notice Create a new POC beacon
    function createBeacon(
        string calldata location,
        int256 latitude,
        int256 longitude,
        uint256 radius,
        address owner
    ) external onlyRole(BEACON_MANAGER_ROLE) returns (uint256 beaconId) {
        require(radius <= GEO_RADIUS_LIMIT, "Radius too large");
        require(bytes(location).length > 0, "Invalid location");
        
        beaconId = nextBeaconId++;
        beacons[beaconId] = Beacon({
            location: location,
            latitude: latitude,
            longitude: longitude,
            radius: radius,
            isActive: true,
            owner: owner,
            totalCheckins: 0
        });
        
        emit BeaconCreated(beaconId, location, owner);
    }

    /// @notice Record a check-in at a beacon
    function recordCheckin(
        uint256 beaconId,
        string calldata method,
        int256 userLatitude,
        int256 userLongitude
    ) external nonReentrant {
        Beacon storage beacon = beacons[beaconId];
        require(beacon.isActive, "Beacon not active");
        
        // Anti-abuse: Check daily limits
        uint256 today = block.timestamp / 1 days;
        if (lastCheckinDate[msg.sender] != today) {
            dailyCheckinCount[msg.sender] = 0;
            lastCheckinDate[msg.sender] = today;
        }
        require(dailyCheckinCount[msg.sender] < MAX_DAILY_CHECKINS, "Daily limit reached");
        
        // Anti-abuse: One checkin per beacon per day
        require(
            lastCheckinTime[msg.sender][beaconId] + MIN_CHECKIN_INTERVAL <= block.timestamp,
            "Already checked in today"
        );
        
        // Geo-fence validation (simplified distance check)
        require(
            _isWithinRadius(userLatitude, userLongitude, beacon.latitude, beacon.longitude, beacon.radius),
            "Outside beacon radius"
        );
        
        // Record checkin
        lastCheckinTime[msg.sender][beaconId] = block.timestamp;
        dailyCheckinCount[msg.sender]++;
        beacon.totalCheckins++;
        
        userCheckins[msg.sender].push(CheckinRecord({
            beaconId: beaconId,
            timestamp: block.timestamp,
            method: method
        }));
        
        // Trigger token contract POC functionality
        try token.pocCheckin() {
            // Success - get updated streak
            uint256 streak = token.pocStreaks(msg.sender);
            emit CheckinRecorded(msg.sender, beaconId, block.timestamp, method, streak);
        } catch {
            // Handle error gracefully
            emit CheckinRecorded(msg.sender, beaconId, block.timestamp, method, 0);
        }
    }

    /// @notice Simplified distance check (not production-ready geographic calculation)
    function _isWithinRadius(
        int256 userLat,
        int256 userLon,
        int256 beaconLat,
        int256 beaconLon,
        uint256 radius
    ) internal pure returns (bool) {
        // Very simplified distance calculation for demo purposes
        // In production, would use proper haversine formula
        int256 latDiff = userLat - beaconLat;
        int256 lonDiff = userLon - beaconLon;
        uint256 distanceSquared = uint256(latDiff * latDiff + lonDiff * lonDiff);
        uint256 radiusSquared = radius * radius;
        
        return distanceSquared <= radiusSquared;
    }

    /// @notice Get user's checkin history
    function getUserCheckins(address user) external view returns (CheckinRecord[] memory) {
        return userCheckins[user];
    }

    /// @notice Get beacon details
    function getBeacon(uint256 beaconId) external view returns (Beacon memory) {
        return beacons[beaconId];
    }

    /// @notice Update beacon status
    function setBeaconActive(uint256 beaconId, bool isActive) external onlyRole(BEACON_MANAGER_ROLE) {
        beacons[beaconId].isActive = isActive;
        emit BeaconUpdated(beaconId, isActive);
    }

    /// @notice Get user's daily checkin stats
    function getDailyStats(address user) external view returns (uint256 count, uint256 date) {
        return (dailyCheckinCount[user], lastCheckinDate[user]);
    }

    /// @notice Emergency checkin method (for SMS/IVR systems)
    function emergencyCheckin(
        address user,
        uint256 beaconId,
        string calldata method
    ) external onlyRole(OPERATOR_ROLE) {
        Beacon storage beacon = beacons[beaconId];
        require(beacon.isActive, "Beacon not active");
        
        // Skip geo-validation for emergency checkins
        lastCheckinTime[user][beaconId] = block.timestamp;
        beacon.totalCheckins++;
        
        userCheckins[user].push(CheckinRecord({
            beaconId: beaconId,
            timestamp: block.timestamp,
            method: method
        }));
        
        emit CheckinRecorded(user, beaconId, block.timestamp, method, 0);
    }
}