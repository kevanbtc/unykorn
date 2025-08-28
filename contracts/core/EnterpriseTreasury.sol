// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./USDxEnterprise.sol";

/// @title Enterprise Treasury
/// @notice Manages reserves and mints/burns USDx against settlements
contract EnterpriseTreasury is AccessControl, ReentrancyGuard {
    /// @dev Role allowed to execute settlements
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    USDxEnterprise public immutable usdx;

    /// @notice Settlement mint request
    struct MintRequest {
        uint256 amount;
        address beneficiary;
        string reference;
        address sender;
    }

    /// @notice Emitted when tokens are minted after settlement
    /// @param beneficiary receiver of minted tokens
    /// @param amount amount minted
    /// @param reference settlement reference id
    event MintedFromSettlement(address indexed beneficiary, uint256 amount, string reference);

    constructor(address token, address admin) {
        usdx = USDxEnterprise(token);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(COMPLIANCE_ROLE, admin);
    }

    /// @notice Mint USDx based on off-chain settlement
    /// @param req settlement mint request data
    error ZeroAmount();

    function mintFromSettlement(MintRequest calldata req)
        external
        onlyRole(COMPLIANCE_ROLE)
        nonReentrant
        returns (uint256)
    {
        if (req.amount == 0) revert ZeroAmount();
        usdx.mint(req.beneficiary, req.amount, req.reference);
        emit MintedFromSettlement(req.beneficiary, req.amount, req.reference);
        return req.amount;
    }
}
