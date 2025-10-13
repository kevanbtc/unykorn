// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title FTHEscrow - Secure escrow for gold redemptions and settlements
/// @notice Time-locked escrow with multi-party release conditions
contract FTHEscrow is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable
{
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant FULFILLER_ROLE = keccak256("FULFILLER_ROLE");

    /// @notice Escrow status enum
    enum EscrowStatus { Pending, Released, Refunded, Disputed }

    /// @notice Escrow entry
    struct Escrow {
        address beneficiary;
        address token;
        uint256 amount;
        uint256 createdAt;
        uint256 releaseTime;
        EscrowStatus status;
        string redemptionType; // "gold", "fiat", "token"
        string fulfillmentProof; // IPFS or tracking reference
    }

    /// @notice Escrow ID counter
    uint256 private _nextEscrowId;

    /// @notice Escrows by ID
    mapping(uint256 => Escrow) public escrows;

    event EscrowCreated(uint256 indexed escrowId, address indexed beneficiary, address token, uint256 amount, uint256 releaseTime);
    event EscrowReleased(uint256 indexed escrowId, address indexed beneficiary, uint256 amount, string proof);
    event EscrowRefunded(uint256 indexed escrowId, address indexed beneficiary, uint256 amount);
    event EscrowDisputed(uint256 indexed escrowId, address indexed initiator);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize escrow contract
    /// @param treasury Treasury address
    /// @param fulfiller Fulfillment operator address
    function initialize(address treasury, address fulfiller) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(OPERATOR_ROLE, treasury);
        _grantRole(FULFILLER_ROLE, fulfiller);

        _nextEscrowId = 1;
    }

    /// @notice Create a new escrow
    /// @param beneficiary Who will receive upon release
    /// @param token Token to escrow
    /// @param amount Amount to escrow
    /// @param releaseTime Earliest release timestamp
    /// @param redemptionType Type of redemption ("gold", "fiat", "token")
    function createEscrow(
        address beneficiary,
        address token,
        uint256 amount,
        uint256 releaseTime,
        string calldata redemptionType
    ) external onlyRole(OPERATOR_ROLE) returns (uint256) {
        require(beneficiary != address(0), "Escrow: zero address");
        require(releaseTime > block.timestamp, "Escrow: invalid release time");

        // Transfer tokens to escrow
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        uint256 escrowId = _nextEscrowId++;

        escrows[escrowId] = Escrow({
            beneficiary: beneficiary,
            token: token,
            amount: amount,
            createdAt: block.timestamp,
            releaseTime: releaseTime,
            status: EscrowStatus.Pending,
            redemptionType: redemptionType,
            fulfillmentProof: ""
        });

        emit EscrowCreated(escrowId, beneficiary, token, amount, releaseTime);
        return escrowId;
    }

    /// @notice Release escrow after fulfillment
    /// @param escrowId Escrow ID to release
    /// @param fulfillmentProof IPFS or tracking proof
    function releaseEscrow(uint256 escrowId, string calldata fulfillmentProof)
        external
        onlyRole(FULFILLER_ROLE)
        nonReentrant
    {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Pending, "Escrow: not pending");
        require(block.timestamp >= escrow.releaseTime, "Escrow: too early");

        escrow.status = EscrowStatus.Released;
        escrow.fulfillmentProof = fulfillmentProof;

        IERC20(escrow.token).transfer(escrow.beneficiary, escrow.amount);

        emit EscrowReleased(escrowId, escrow.beneficiary, escrow.amount, fulfillmentProof);
    }

    /// @notice Refund escrow (if redemption cancelled)
    /// @param escrowId Escrow ID to refund
    /// @param refundTo Address to refund to
    function refundEscrow(uint256 escrowId, address refundTo)
        external
        onlyRole(OPERATOR_ROLE)
        nonReentrant
    {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.status == EscrowStatus.Pending, "Escrow: not pending");

        escrow.status = EscrowStatus.Refunded;

        IERC20(escrow.token).transfer(refundTo, escrow.amount);

        emit EscrowRefunded(escrowId, escrow.beneficiary, escrow.amount);
    }

    /// @notice Mark escrow as disputed
    /// @param escrowId Escrow ID
    function disputeEscrow(uint256 escrowId) external {
        Escrow storage escrow = escrows[escrowId];
        require(escrow.beneficiary == msg.sender || hasRole(OPERATOR_ROLE, msg.sender), "Escrow: not authorized");
        require(escrow.status == EscrowStatus.Pending, "Escrow: not pending");

        escrow.status = EscrowStatus.Disputed;

        emit EscrowDisputed(escrowId, msg.sender);
    }

    /// @notice Get escrow details
    /// @param escrowId Escrow ID
    function getEscrow(uint256 escrowId) external view returns (Escrow memory) {
        return escrows[escrowId];
    }

    /// @dev Required by UUPS
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
