// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DAO {
    IERC20 public governanceToken;
    address public admin;

    struct Proposal {
        string description;
        address recipient;
        uint256 value;
        uint256 voteCount;
        uint256 deadline;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public votes;
    uint256 public proposalCount;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can create critical proposals");
        _;
    }

    modifier onlyTokenHolders() {
        require(governanceToken.balanceOf(msg.sender) > 0, "Must be a token holder to vote");
        _;
    }

    constructor(address _governanceToken) {
        governanceToken = IERC20(_governanceToken);
        admin = msg.sender;
    }

    function createProposal(string memory _description, address _recipient, uint256 _value) external onlyTokenHolders {
        proposals[proposalCount] = Proposal({
            description: _description,
            recipient: _recipient,
            value: _value,
            voteCount: 0,
            deadline: block.timestamp + 1 weeks,
            executed: false
        });
        proposalCount++;
    }

    function vote(uint256 _proposalId) external onlyTokenHolders {
        require(block.timestamp <= proposals[_proposalId].deadline, "Voting period has ended");
        require(!votes[msg.sender][_proposalId], "Already voted");

        Proposal storage proposal = proposals[_proposalId];
        proposal.voteCount++;
        votes[msg.sender][_proposalId] = true;
    }

    function executeProposal(uint256 _proposalId) external {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp > proposal.deadline, "Voting period is still active");
        require(!proposal.executed, "Proposal already executed");

        if (proposal.voteCount > governanceToken.totalSupply() / 2) {
            payable(proposal.recipient).transfer(proposal.value);
        }
        proposal.executed = true;
    }

    receive() external payable {}
}
