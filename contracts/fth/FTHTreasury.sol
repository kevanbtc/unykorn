// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title FTHTreasury - Multi-signature treasury for FTH sovereign settlement
/// @notice 3-of-5 multi-sig with time-locked operations for security
/// @dev CEO, CFO, Custodian, Auditor, Compliance roles
contract FTHTreasury is AccessControl, ReentrancyGuard {
    bytes32 public constant CEO_ROLE = keccak256("CEO_ROLE");
    bytes32 public constant CFO_ROLE = keccak256("CFO_ROLE");
    bytes32 public constant CUSTODIAN_ROLE = keccak256("CUSTODIAN_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    /// @notice Minimum confirmations required (3 of 5)
    uint256 public constant REQUIRED_CONFIRMATIONS = 3;

    /// @notice Timelock delay for critical operations (48 hours)
    uint256 public constant TIMELOCK_DELAY = 48 hours;

    /// @notice Transaction structure
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
        uint256 proposedAt;
        mapping(address => bool) confirmed;
    }

    /// @notice Transaction ID counter
    uint256 private _nextTxId;

    /// @notice Pending transactions
    mapping(uint256 => Transaction) public transactions;

    /// @notice Authorized signer addresses
    address[] public signers;

    event TransactionProposed(uint256 indexed txId, address indexed proposer, address to, uint256 value, bytes data);
    event TransactionConfirmed(uint256 indexed txId, address indexed signer);
    event TransactionRevoked(uint256 indexed txId, address indexed signer);
    event TransactionExecuted(uint256 indexed txId, address indexed executor);
    event SignerAdded(address indexed signer, bytes32 role);
    event SignerRemoved(address indexed signer, bytes32 role);

    /// @notice Initialize treasury with 5 signers
    constructor(
        address ceo,
        address cfo,
        address custodian,
        address auditor,
        address compliance
    ) {
        require(ceo != address(0) && cfo != address(0) && custodian != address(0), "Treasury: zero address");
        require(auditor != address(0) && compliance != address(0), "Treasury: zero address");

        _grantRole(DEFAULT_ADMIN_ROLE, address(this)); // Self-administered
        _grantRole(CEO_ROLE, ceo);
        _grantRole(CFO_ROLE, cfo);
        _grantRole(CUSTODIAN_ROLE, custodian);
        _grantRole(AUDITOR_ROLE, auditor);
        _grantRole(COMPLIANCE_ROLE, compliance);

        signers.push(ceo);
        signers.push(cfo);
        signers.push(custodian);
        signers.push(auditor);
        signers.push(compliance);

        emit SignerAdded(ceo, CEO_ROLE);
        emit SignerAdded(cfo, CFO_ROLE);
        emit SignerAdded(custodian, CUSTODIAN_ROLE);
        emit SignerAdded(auditor, AUDITOR_ROLE);
        emit SignerAdded(compliance, COMPLIANCE_ROLE);
    }

    /// @notice Propose a new transaction
    /// @param to Target address
    /// @param value ETH value to send
    /// @param data Call data
    function proposeTransaction(
        address to,
        uint256 value,
        bytes calldata data
    ) external onlySigner returns (uint256) {
        uint256 txId = _nextTxId++;

        Transaction storage txn = transactions[txId];
        txn.to = to;
        txn.value = value;
        txn.data = data;
        txn.executed = false;
        txn.confirmations = 0;
        txn.proposedAt = block.timestamp;

        emit TransactionProposed(txId, msg.sender, to, value, data);
        return txId;
    }

    /// @notice Confirm a pending transaction
    /// @param txId Transaction ID
    function confirmTransaction(uint256 txId) external onlySigner {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Treasury: already executed");
        require(!txn.confirmed[msg.sender], "Treasury: already confirmed");

        txn.confirmed[msg.sender] = true;
        txn.confirmations++;

        emit TransactionConfirmed(txId, msg.sender);
    }

    /// @notice Revoke confirmation
    /// @param txId Transaction ID
    function revokeConfirmation(uint256 txId) external onlySigner {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Treasury: already executed");
        require(txn.confirmed[msg.sender], "Treasury: not confirmed");

        txn.confirmed[msg.sender] = false;
        txn.confirmations--;

        emit TransactionRevoked(txId, msg.sender);
    }

    /// @notice Execute a confirmed transaction after timelock
    /// @param txId Transaction ID
    function executeTransaction(uint256 txId) external onlySigner nonReentrant {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Treasury: already executed");
        require(txn.confirmations >= REQUIRED_CONFIRMATIONS, "Treasury: insufficient confirmations");
        require(block.timestamp >= txn.proposedAt + TIMELOCK_DELAY, "Treasury: timelock active");

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Treasury: execution failed");

        emit TransactionExecuted(txId, msg.sender);
    }

    /// @notice Check if address is a signer
    /// @param account Address to check
    function isSigner(address account) public view returns (bool) {
        return hasRole(CEO_ROLE, account) ||
               hasRole(CFO_ROLE, account) ||
               hasRole(CUSTODIAN_ROLE, account) ||
               hasRole(AUDITOR_ROLE, account) ||
               hasRole(COMPLIANCE_ROLE, account);
    }

    /// @notice Get transaction confirmation status
    /// @param txId Transaction ID
    /// @param signer Signer address
    function isConfirmed(uint256 txId, address signer) external view returns (bool) {
        return transactions[txId].confirmed[signer];
    }

    /// @notice Get number of signers
    function getSignerCount() external view returns (uint256) {
        return signers.length;
    }

    /// @notice Receive ETH
    receive() external payable {}

    /// @dev Modifier to restrict to signers only
    modifier onlySigner() {
        require(isSigner(msg.sender), "Treasury: not a signer");
        _;
    }
}
