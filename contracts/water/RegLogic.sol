// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RegLogic
/// @notice Minimal jurisdiction validation logic for demonstration purposes.
contract RegLogic {
    mapping(address => bool) public permitted;

    /// @notice Allows configuration of whether an address passes jurisdictional checks.
    /// @param user The address to configure.
    /// @param status Whether the address is permitted.
    function setPermission(address user, bool status) external {
        permitted[user] = status;
    }

    /// @notice Validates whether a user is permitted in the current jurisdiction.
    /// @param user The address to validate.
    /// @return True if the user is permitted, false otherwise.
    function validate(address user) external view returns (bool) {
        return permitted[user];
    }
}

