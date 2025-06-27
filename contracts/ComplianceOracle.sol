// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ComplianceOracle
/// @notice Manages KYC whitelists for CTRL token transfers
contract ComplianceOracle is Ownable {
    mapping(address => bool) private _whitelist;

    event Whitelisted(address indexed account, bool status);

    /// @notice set whitelist status for an address
    function setWhitelisted(address account, bool status) external onlyOwner {
        _whitelist[account] = status;
        emit Whitelisted(account, status);
    }

    /// @notice check if account is whitelisted
    function isWhitelisted(address account) public view returns (bool) {
        return _whitelist[account];
    }

    /// @notice check if transfer between parties is allowed
    function transferAllowed(address from, address to) external view returns (bool) {
        return _whitelist[from] && _whitelist[to];
    }
}
