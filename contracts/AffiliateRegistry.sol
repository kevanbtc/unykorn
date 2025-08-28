// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title AffiliateRegistry
/// @notice Tracks affiliate balances and allows them to withdraw rewards
contract AffiliateRegistry is Ownable, Pausable, ReentrancyGuard {
    IERC20 public immutable rewardToken;
    address public bus;

    mapping(address => uint256) public pendingRewards;

    event BusUpdated(address bus);
    event AffiliateCredited(address indexed affiliate, uint256 amount);
    event RewardsWithdrawn(address indexed affiliate, uint256 amount);

    constructor(address token, address _owner) {
        rewardToken = IERC20(token);
        _transferOwnership(_owner);
    }

    /// @notice Set the settlement bus contract that can credit affiliates
    function setBus(address _bus) external onlyOwner {
        bus = _bus;
        emit BusUpdated(_bus);
    }

    /// @notice Pause crediting and withdrawals
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Resume crediting and withdrawals
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Credit an affiliate's balance. Only callable by the settlement bus.
    function credit(address affiliate, uint256 amount) external whenNotPaused {
        require(msg.sender == bus, "only bus");
        pendingRewards[affiliate] += amount;
        emit AffiliateCredited(affiliate, amount);
    }

    /// @notice Withdraw accumulated rewards
    function withdraw() external whenNotPaused nonReentrant {
        uint256 amount = pendingRewards[msg.sender];
        require(amount > 0, "no rewards");
        pendingRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, amount);
        emit RewardsWithdrawn(msg.sender, amount);
    }
}

