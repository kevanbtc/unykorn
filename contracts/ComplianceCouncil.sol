// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title ComplianceCouncil
/// @notice Minimal DAO-style council that can freeze addresses involved in
///         regulated flows. Other contracts may query `isFrozen` to block
///         interactions with flagged parties.
contract ComplianceCouncil is AccessControl {
    bytes32 public constant COUNCIL_ROLE = keccak256("COUNCIL_ROLE");

    mapping(address => bool) private _frozen;

    event CouncilMemberAdded(address indexed member);
    event CouncilMemberRemoved(address indexed member);
    event AddressFrozen(address indexed target, bool frozen);

    constructor(address[] memory members) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        for (uint256 i = 0; i < members.length; i++) {
            _grantRole(COUNCIL_ROLE, members[i]);
            emit CouncilMemberAdded(members[i]);
        }
    }

    /// @notice Add a council member
    function addMember(address member) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(COUNCIL_ROLE, member);
        emit CouncilMemberAdded(member);
    }

    /// @notice Remove a council member
    function removeMember(address member) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(COUNCIL_ROLE, member);
        emit CouncilMemberRemoved(member);
    }

    /// @notice Freeze or unfreeze a target address
    function setFrozen(address target, bool frozen) external onlyRole(COUNCIL_ROLE) {
        _frozen[target] = frozen;
        emit AddressFrozen(target, frozen);
    }

    /// @notice Returns true if the address is frozen
    function isFrozen(address target) external view returns (bool) {
        return _frozen[target];
    }
}

