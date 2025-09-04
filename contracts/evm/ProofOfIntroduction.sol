// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ProofOfIntroduction - Track introductions and pay connectors
contract ProofOfIntroduction is Ownable, ReentrancyGuard {
    IERC20 public immutable paymentToken;
    
    struct Introduction {
        address introducer;
        address partyA;
        address partyB;
        uint256 timestamp;
        bool confirmed;
        bool paymentTriggered;
        uint256 totalTransactionValue;
    }
    
    struct ConnectorStats {
        uint256 totalIntroductions;
        uint256 confirmedIntroductions;
        uint256 totalEarnings;
        uint256 pendingEarnings;
    }
    
    mapping(bytes32 => Introduction) public introductions;
    mapping(address => ConnectorStats) public connectorStats;
    mapping(address => mapping(address => address)) public connectionRegistry; // partyA => partyB => introducer
    mapping(address => bytes32[]) public userIntroductions;
    
    uint256 public commissionRate = 500; // 5% in basis points
    uint256 public minimumTransactionValue = 1000 * 1e18; // Minimum value to trigger payment
    
    event IntroductionCreated(
        bytes32 indexed introId,
        address indexed introducer,
        address indexed partyA,
        address partyB
    );
    
    event IntroductionConfirmed(bytes32 indexed introId);
    event ConnectorPaid(address indexed connector, uint256 amount, bytes32 indexed introId);
    event TransactionRecorded(
        address indexed partyA,
        address indexed partyB,
        uint256 value,
        address indexed connector
    );
    
    constructor(address _paymentToken) Ownable(msg.sender) {
        paymentToken = IERC20(_paymentToken);
    }
    
    /// @notice Create a new introduction record
    function createIntroduction(
        address partyA,
        address partyB
    ) external returns (bytes32) {
        require(partyA != partyB, "Cannot introduce to self");
        require(partyA != msg.sender && partyB != msg.sender, "Cannot introduce yourself");
        
        // Check if connection already exists
        require(connectionRegistry[partyA][partyB] == address(0), "Connection already exists");
        require(connectionRegistry[partyB][partyA] == address(0), "Connection already exists");
        
        bytes32 introId = keccak256(abi.encodePacked(
            msg.sender,
            partyA,
            partyB,
            block.timestamp,
            block.number
        ));
        
        introductions[introId] = Introduction({
            introducer: msg.sender,
            partyA: partyA,
            partyB: partyB,
            timestamp: block.timestamp,
            confirmed: false,
            paymentTriggered: false,
            totalTransactionValue: 0
        });
        
        // Register the connection (bidirectional)
        connectionRegistry[partyA][partyB] = msg.sender;
        connectionRegistry[partyB][partyA] = msg.sender;
        
        // Add to user's introduction list
        userIntroductions[msg.sender].push(introId);
        userIntroductions[partyA].push(introId);
        userIntroductions[partyB].push(introId);
        
        connectorStats[msg.sender].totalIntroductions++;
        
        emit IntroductionCreated(introId, msg.sender, partyA, partyB);
        return introId;
    }
    
    /// @notice Confirm an introduction (called by either party)
    function confirmIntroduction(bytes32 introId) external {
        Introduction storage intro = introductions[introId];
        require(intro.timestamp > 0, "Introduction does not exist");
        require(!intro.confirmed, "Already confirmed");
        require(
            msg.sender == intro.partyA || msg.sender == intro.partyB,
            "Only parties can confirm"
        );
        
        intro.confirmed = true;
        connectorStats[intro.introducer].confirmedIntroductions++;
        
        emit IntroductionConfirmed(introId);
    }
    
    /// @notice Record a transaction between introduced parties (triggers payment)
    function recordTransaction(
        address partyA,
        address partyB,
        uint256 transactionValue
    ) external onlyOwner nonReentrant {
        require(transactionValue >= minimumTransactionValue, "Transaction too small");
        
        address connector = connectionRegistry[partyA][partyB];
        require(connector != address(0), "No introduction found");
        
        // Find the introduction
        bytes32 introId = _findIntroduction(connector, partyA, partyB);
        require(introId != bytes32(0), "Introduction not found");
        
        Introduction storage intro = introductions[introId];
        require(intro.confirmed, "Introduction not confirmed");
        
        // Calculate commission
        uint256 commission = (transactionValue * commissionRate) / 10000;
        
        // Pay the connector
        require(paymentToken.transfer(connector, commission), "Payment failed");
        
        // Update stats
        connectorStats[connector].totalEarnings += commission;
        intro.totalTransactionValue += transactionValue;
        intro.paymentTriggered = true;
        
        emit ConnectorPaid(connector, commission, introId);
        emit TransactionRecorded(partyA, partyB, transactionValue, connector);
    }
    
    /// @notice Get introducer for a connection
    function getIntroducer(address partyA, address partyB) external view returns (address) {
        return connectionRegistry[partyA][partyB];
    }
    
    /// @notice Get user's introduction history
    function getUserIntroductions(address user) external view returns (bytes32[] memory) {
        return userIntroductions[user];
    }
    
    /// @notice Set commission rate (only owner)
    function setCommissionRate(uint256 newRate) external onlyOwner {
        require(newRate <= 2000, "Max 20% commission"); // Max 20%
        commissionRate = newRate;
    }
    
    /// @notice Set minimum transaction value
    function setMinimumTransactionValue(uint256 newValue) external onlyOwner {
        minimumTransactionValue = newValue;
    }
    
    /// @notice Check if two parties have been introduced
    function areConnected(address partyA, address partyB) external view returns (bool) {
        return connectionRegistry[partyA][partyB] != address(0);
    }
    
    /// @notice Emergency withdraw tokens
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner(), amount);
    }
    
    /// @dev Internal function to find introduction ID
    function _findIntroduction(
        address connector,
        address partyA,
        address partyB
    ) internal view returns (bytes32) {
        bytes32[] memory intros = userIntroductions[connector];
        
        for (uint256 i = 0; i < intros.length; i++) {
            Introduction storage intro = introductions[intros[i]];
            if (
                intro.introducer == connector &&
                ((intro.partyA == partyA && intro.partyB == partyB) ||
                 (intro.partyA == partyB && intro.partyB == partyA))
            ) {
                return intros[i];
            }
        }
        
        return bytes32(0);
    }
    
    /// @notice Get detailed introduction info
    function getIntroductionDetails(bytes32 introId) 
        external 
        view 
        returns (
            address introducer,
            address partyA,
            address partyB,
            uint256 timestamp,
            bool confirmed,
            bool paymentTriggered,
            uint256 totalTransactionValue
        ) 
    {
        Introduction storage intro = introductions[introId];
        return (
            intro.introducer,
            intro.partyA,
            intro.partyB,
            intro.timestamp,
            intro.confirmed,
            intro.paymentTriggered,
            intro.totalTransactionValue
        );
    }
}