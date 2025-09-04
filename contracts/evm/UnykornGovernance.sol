// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title UnykornGovernance - DAO controls for burn rates, commissions, and vault allocations
contract UnykornGovernance is Ownable, ReentrancyGuard {
    
    struct Proposal {
        address proposer;
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        bool passed;
        ProposalType proposalType;
        bytes executionData;
    }
    
    enum ProposalType {
        BURN_RATE,
        COMMISSION_RATE,
        VAULT_ALLOCATION,
        PLATFORM_PARAMETER,
        TREASURY_SPEND
    }
    
    struct VotingPower {
        uint256 stakedTokens;
        uint256 votingPower;
        uint256 lastVoteBlock;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => VotingPower) public voterPower;
    mapping(address => uint256) public stakedBalances;
    
    IERC20 public immutable governanceToken;
    uint256 public nextProposalId = 1;
    uint256 public votingPeriod = 7 days;
    uint256 public proposalThreshold = 1000000 * 1e18; // 1M tokens to propose
    uint256 public quorumThreshold = 5000; // 50% in basis points
    uint256 public passThreshold = 6000; // 60% to pass
    
    // Current system parameters
    uint256 public currentBurnRate = 300; // 3%
    uint256 public currentCommissionRate = 1000; // 10%
    mapping(string => uint256) public vaultAllocations;
    
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string title,
        ProposalType proposalType
    );
    
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 votes
    );
    
    event ProposalExecuted(uint256 indexed proposalId, bool passed);
    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);
    event ParameterUpdated(string parameter, uint256 oldValue, uint256 newValue);
    
    constructor(address _governanceToken) Ownable(msg.sender) {
        governanceToken = IERC20(_governanceToken);
        
        // Initialize vault allocations
        vaultAllocations["STABLECOIN"] = 4000; // 40%
        vaultAllocations["BITCOIN"] = 2000;    // 20%
        vaultAllocations["GOLD"] = 2000;       // 20%
        vaultAllocations["ETH"] = 1000;        // 10%
        vaultAllocations["RWA"] = 1000;        // 10%
    }
    
    /// @notice Stake tokens for voting power
    function stakeTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be positive");
        
        governanceToken.transferFrom(msg.sender, address(this), amount);
        
        stakedBalances[msg.sender] += amount;
        voterPower[msg.sender].stakedTokens += amount;
        voterPower[msg.sender].votingPower = _calculateVotingPower(msg.sender);
        
        emit TokensStaked(msg.sender, amount);
    }
    
    /// @notice Unstake tokens (with cooldown period)
    function unstakeTokens(uint256 amount) external nonReentrant {
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        require(
            block.number > voterPower[msg.sender].lastVoteBlock + 50400, // ~7 days
            "Must wait 7 days after last vote"
        );
        
        stakedBalances[msg.sender] -= amount;
        voterPower[msg.sender].stakedTokens -= amount;
        voterPower[msg.sender].votingPower = _calculateVotingPower(msg.sender);
        
        governanceToken.transfer(msg.sender, amount);
        
        emit TokensUnstaked(msg.sender, amount);
    }
    
    /// @notice Create a new proposal
    function createProposal(
        string calldata title,
        string calldata description,
        ProposalType proposalType,
        bytes calldata executionData
    ) external returns (uint256) {
        require(
            voterPower[msg.sender].stakedTokens >= proposalThreshold,
            "Insufficient tokens to propose"
        );
        
        uint256 proposalId = nextProposalId++;
        
        proposals[proposalId] = Proposal({
            proposer: msg.sender,
            title: title,
            description: description,
            startTime: block.timestamp,
            endTime: block.timestamp + votingPeriod,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            passed: false,
            proposalType: proposalType,
            executionData: executionData
        });
        
        emit ProposalCreated(proposalId, msg.sender, title, proposalType);
        return proposalId;
    }
    
    /// @notice Vote on a proposal
    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(voterPower[msg.sender].votingPower > 0, "No voting power");
        
        hasVoted[proposalId][msg.sender] = true;
        voterPower[msg.sender].lastVoteBlock = block.number;
        
        uint256 votes = voterPower[msg.sender].votingPower;
        
        if (support) {
            proposal.votesFor += votes;
        } else {
            proposal.votesAgainst += votes;
        }
        
        emit VoteCast(proposalId, msg.sender, support, votes);
    }
    
    /// @notice Execute a proposal after voting ends
    function executeProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting still active");
        require(!proposal.executed, "Already executed");
        
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 totalSupply = governanceToken.totalSupply();
        uint256 quorum = (totalSupply * quorumThreshold) / 10000;
        
        // Check quorum and passing threshold
        if (totalVotes >= quorum) {
            uint256 supportPercent = (proposal.votesFor * 10000) / totalVotes;
            if (supportPercent >= passThreshold) {
                proposal.passed = true;
                _executeProposalAction(proposal);
            }
        }
        
        proposal.executed = true;
        emit ProposalExecuted(proposalId, proposal.passed);
    }
    
    /// @notice Execute the actual proposal action
    function _executeProposalAction(Proposal storage proposal) internal {
        if (proposal.proposalType == ProposalType.BURN_RATE) {
            uint256 newRate = abi.decode(proposal.executionData, (uint256));
            require(newRate <= 500, "Max 5% burn rate");
            
            emit ParameterUpdated("BURN_RATE", currentBurnRate, newRate);
            currentBurnRate = newRate;
            
        } else if (proposal.proposalType == ProposalType.COMMISSION_RATE) {
            uint256 newRate = abi.decode(proposal.executionData, (uint256));
            require(newRate <= 2000, "Max 20% commission rate");
            
            emit ParameterUpdated("COMMISSION_RATE", currentCommissionRate, newRate);
            currentCommissionRate = newRate;
            
        } else if (proposal.proposalType == ProposalType.VAULT_ALLOCATION) {
            (string memory assetType, uint256 newAllocation) = abi.decode(
                proposal.executionData,
                (string, uint256)
            );
            require(newAllocation <= 5000, "Max 50% per asset");
            
            emit ParameterUpdated(assetType, vaultAllocations[assetType], newAllocation);
            vaultAllocations[assetType] = newAllocation;
        }
    }
    
    /// @notice Calculate voting power based on staked tokens and time
    function _calculateVotingPower(address user) internal view returns (uint256) {
        // Simple 1:1 ratio for now - could add time multipliers, delegation, etc.
        return voterPower[user].stakedTokens;
    }
    
    /// @notice Get proposal details
    function getProposal(uint256 proposalId) external view returns (
        address proposer,
        string memory title,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        uint256 votesFor,
        uint256 votesAgainst,
        bool executed,
        bool passed,
        ProposalType proposalType
    ) {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.proposer,
            proposal.title,
            proposal.description,
            proposal.startTime,
            proposal.endTime,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.executed,
            proposal.passed,
            proposal.proposalType
        );
    }
    
    /// @notice Update governance parameters (emergency only)
    function updateGovernanceParameters(
        uint256 newVotingPeriod,
        uint256 newProposalThreshold,
        uint256 newQuorumThreshold,
        uint256 newPassThreshold
    ) external onlyOwner {
        require(newVotingPeriod >= 1 days && newVotingPeriod <= 30 days, "Invalid voting period");
        require(newQuorumThreshold <= 10000, "Invalid quorum threshold");
        require(newPassThreshold <= 10000, "Invalid pass threshold");
        
        votingPeriod = newVotingPeriod;
        proposalThreshold = newProposalThreshold;
        quorumThreshold = newQuorumThreshold;
        passThreshold = newPassThreshold;
    }
    
    /// @notice Get current system parameters
    function getSystemParameters() external view returns (
        uint256 burnRate,
        uint256 commissionRate,
        uint256 stablecoinAlloc,
        uint256 bitcoinAlloc,
        uint256 goldAlloc,
        uint256 ethAlloc,
        uint256 rwaAlloc
    ) {
        return (
            currentBurnRate,
            currentCommissionRate,
            vaultAllocations["STABLECOIN"],
            vaultAllocations["BITCOIN"],
            vaultAllocations["GOLD"],
            vaultAllocations["ETH"],
            vaultAllocations["RWA"]
        );
    }
    
    /// @notice Emergency pause (owner only)
    function emergencyPause() external onlyOwner {
        // Implementation for emergency pause
    }
}