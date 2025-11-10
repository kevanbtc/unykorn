// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRegLogic {
    function validate(address user) external view returns (bool);
}

/// @title WaterFlow
/// @notice Tracks water allocations and usage with jurisdictional validation.
contract WaterFlow is Ownable {
    IRegLogic public regLogic;
    address public regulator;

    mapping(address => uint256) public allocations;
    mapping(address => uint256) public usage;
    mapping(address => uint256) public balances;

    /// @param _regLogic Address of the regulatory logic contract.
    /// @param _regulator Address allowed to report usage alongside the owner.
    constructor(address _regLogic, address _regulator) Ownable(msg.sender) {
        regLogic = IRegLogic(_regLogic);
        regulator = _regulator;
    }

    modifier onlyAuthorized() {
        require(msg.sender == regulator || msg.sender == owner(), "not authorized");
        _;
    }

    /// @notice Records water usage for a user. Restricted to regulator or vault owner.
    /// @param user Address of the user.
    /// @param amount Amount of usage to report.
    function reportUsage(address user, uint256 amount) external onlyAuthorized {
        usage[user] += amount;
    }

    /// @notice Settles recorded usage against allocations with jurisdiction checks.
    /// @param user Address of the user being settled.
    function settleFlow(address user) external onlyAuthorized {
        uint256 used = usage[user];
        uint256 allocated = allocations[user];
        require(used <= allocated, "usage exceeds allocation");
        require(regLogic.validate(user), "jurisdiction invalid");
        allocations[user] = allocated - used;
        balances[user] += used;
        usage[user] = 0;
    }
}

