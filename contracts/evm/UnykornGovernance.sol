// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ITokenERC20 {
    function setBurnRate(uint256 newRate) external;
    function balanceOf(address account) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IAssetVault {
    function setAssetAllocation(address asset, uint256 targetPercentage) external;
    function getVaultMetrics() external view returns (uint256, uint256, uint256, uint256);
}

interface IRevVault {
    function updateCommissionStructure(
        uint256 merchantPercentage,
        uint256 directCommission,
        uint256 teamOverride,
        uint256 poiBonus,
        uint256 territoryPool,
        uint256 platformFee,
        uint256 burnPercentage
    ) external;
}

/// @title UnykornGovernance - DAO governance for protocol parameters
contract UnykornGovernance is AccessControl, ReentrancyGuard {
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    enum ProposalType {
        BurnRate,
        CommissionStructure,
        VaultAllocation,
        General
    }

    struct Proposal {
        uint256 id;
        address proposer;
        ProposalType proposalType;
        string description;
        bytes callData;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        bool cancelled;
        mapping(address => bool) hasVoted;
        mapping(address => uint256) voteWeight;
    }

    struct VaultAllocationProposal {
        address asset;
        uint256 targetPercentage;
    }

    struct CommissionProposal {
        uint256 merchantPercentage;
        uint256 directCommission;
        uint256 teamOverride;
        uint256 poiBonus;
        uint256 territoryPool;
        uint256 platformFee;
        uint256 burnPercentage;
    }

    // State variables
    ITokenERC20 public immutable token;
    IAssetVault public assetVault;
    IRevVault public revVault;
    
    mapping(uint256 => Proposal) public proposals;
    uint256 public nextProposalId = 1;
    
    // Governance parameters
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant PROPOSAL_THRESHOLD = 1000000e18; // 1M tokens to propose
    uint256 public constant QUORUM_THRESHOLD = 5000; // 50% in basis points
    uint256 public constant EXECUTION_DELAY = 2 days;
    
    // Multi-sig requirements
    mapping(bytes32 => uint256) public requiredSignatures;
    mapping(bytes32 => mapping(address => bool)) public isSigner;
    mapping(uint256 => mapping(address => bool)) public hasSignedExecution;
    mapping(uint256 => uint256) public executionSignatures;
    
    // Events
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        ProposalType proposalType,
        string description
    );
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);
    event SignerAdded(bytes32 indexed role, address indexed signer);
    event ExecutionSigned(uint256 indexed proposalId, address indexed signer);

    constructor(
        address _token,
        address admin
    ) {
        token = ITokenERC20(_token);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PROPOSER_ROLE, admin);
        _grantRole(EXECUTOR_ROLE, admin);
        
        // Default multi-sig requirements
        requiredSignatures[EXECUTOR_ROLE] = 2;
        isSigner[EXECUTOR_ROLE][admin] = true;
    }

    /// @notice Set contract addresses after deployment
    function setContracts(
        address _assetVault,
        address _revVault
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assetVault = IAssetVault(_assetVault);
        revVault = IRevVault(_revVault);
    }

    /// @notice Create governance proposal
    function propose(
        ProposalType proposalType,
        string calldata description,
        bytes calldata callData
    ) external returns (uint256 proposalId) {
        require(
            token.balanceOf(msg.sender) >= PROPOSAL_THRESHOLD,
            "Insufficient tokens to propose"
        );
        
        proposalId = nextProposalId++;
        Proposal storage proposal = proposals[proposalId];
        
        proposal.id = proposalId;
        proposal.proposer = msg.sender;
        proposal.proposalType = proposalType;
        proposal.description = description;
        proposal.callData = callData;
        proposal.startTime = block.timestamp;
        proposal.endTime = block.timestamp + VOTING_PERIOD;
        proposal.executed = false;
        proposal.cancelled = false;
        
        emit ProposalCreated(proposalId, msg.sender, proposalType, description);
    }

    /// @notice Vote on proposal
    function vote(uint256 proposalId, bool support) external nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!proposal.hasVoted[msg.sender], "Already voted");
        require(!proposal.executed && !proposal.cancelled, "Proposal not active");
        
        uint256 weight = token.balanceOf(msg.sender);
        require(weight > 0, "No voting power");
        
        proposal.hasVoted[msg.sender] = true;
        proposal.voteWeight[msg.sender] = weight;
        
        if (support) {
            proposal.forVotes += weight;
        } else {
            proposal.againstVotes += weight;
        }
        
        emit VoteCast(msg.sender, proposalId, support, weight);
    }

    /// @notice Execute proposal after voting period and delay
    function executeProposal(uint256 proposalId) external nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting still active");
        require(block.timestamp >= proposal.endTime + EXECUTION_DELAY, "Execution delay not met");
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        
        // Check quorum and majority
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes;
        uint256 totalSupply = token.totalSupply();
        require((totalVotes * 10000) / totalSupply >= QUORUM_THRESHOLD, "Quorum not met");
        require(proposal.forVotes > proposal.againstVotes, "Proposal rejected");
        
        // Check multi-sig requirements for execution
        require(
            executionSignatures[proposalId] >= requiredSignatures[EXECUTOR_ROLE],
            "Insufficient signatures"
        );
        
        proposal.executed = true;
        
        // Execute based on proposal type
        _executeProposalAction(proposal);
        
        emit ProposalExecuted(proposalId);
    }

    /// @notice Sign proposal execution (multi-sig)
    function signExecution(uint256 proposalId) external {
        require(isSigner[EXECUTOR_ROLE][msg.sender], "Not authorized signer");
        require(!hasSignedExecution[proposalId][msg.sender], "Already signed");
        
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp > proposal.endTime, "Voting still active");
        require(!proposal.executed && !proposal.cancelled, "Proposal not pending");
        
        hasSignedExecution[proposalId][msg.sender] = true;
        executionSignatures[proposalId]++;
        
        emit ExecutionSigned(proposalId, msg.sender);
    }

    /// @notice Internal execution logic
    function _executeProposalAction(Proposal storage proposal) internal {
        if (proposal.proposalType == ProposalType.BurnRate) {
            uint256 newRate = abi.decode(proposal.callData, (uint256));
            token.setBurnRate(newRate);
        } else if (proposal.proposalType == ProposalType.VaultAllocation) {
            VaultAllocationProposal memory vaultProp = abi.decode(proposal.callData, (VaultAllocationProposal));
            assetVault.setAssetAllocation(vaultProp.asset, vaultProp.targetPercentage);
        } else if (proposal.proposalType == ProposalType.CommissionStructure) {
            CommissionProposal memory commProp = abi.decode(proposal.callData, (CommissionProposal));
            revVault.updateCommissionStructure(
                commProp.merchantPercentage,
                commProp.directCommission,
                commProp.teamOverride,
                commProp.poiBonus,
                commProp.territoryPool,
                commProp.platformFee,
                commProp.burnPercentage
            );
        }
        // General proposals would need custom execution logic
    }

    /// @notice Cancel proposal (admin emergency function)
    function cancelProposal(uint256 proposalId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        proposal.cancelled = true;
        emit ProposalCancelled(proposalId);
    }

    /// @notice Add multi-sig signer
    function addSigner(bytes32 role, address signer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isSigner[role][signer] = true;
        emit SignerAdded(role, signer);
    }

    /// @notice Update signature requirements
    function setSignatureRequirement(bytes32 role, uint256 required) external onlyRole(DEFAULT_ADMIN_ROLE) {
        requiredSignatures[role] = required;
    }

    /// @notice Get proposal details
    function getProposal(uint256 proposalId) external view returns (
        uint256 id,
        address proposer,
        ProposalType proposalType,
        string memory description,
        uint256 forVotes,
        uint256 againstVotes,
        uint256 startTime,
        uint256 endTime,
        bool executed,
        bool cancelled
    ) {
        Proposal storage proposal = proposals[proposalId];
        return (
            proposal.id,
            proposal.proposer,
            proposal.proposalType,
            proposal.description,
            proposal.forVotes,
            proposal.againstVotes,
            proposal.startTime,
            proposal.endTime,
            proposal.executed,
            proposal.cancelled
        );
    }

    /// @notice Check if user has voted
    function hasVoted(uint256 proposalId, address voter) external view returns (bool) {
        return proposals[proposalId].hasVoted[voter];
    }

    /// @notice Get vote weight
    function getVoteWeight(uint256 proposalId, address voter) external view returns (uint256) {
        return proposals[proposalId].voteWeight[voter];
    }
}