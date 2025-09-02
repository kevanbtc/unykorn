// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

/// @title LiquidityHelper - bootstrap liquidity and lock team allocation
contract LiquidityHelper is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    IUniswapV2Router02 public immutable router;
    address public immutable team;
    uint256 public immutable releaseTime;
    uint256 public lockedTeam;

    constructor(address token_, address router_, address team_, uint256 releaseTime_) Ownable(msg.sender) {
        require(releaseTime_ > block.timestamp, "release in past");
        token = IERC20(token_);
        router = IUniswapV2Router02(router_);
        team = team_;
        releaseTime = releaseTime_;
    }

    /// @notice seed initial liquidity with 90/10 community/team split
    function seedLiquidity(uint256 tokenAmount) external payable onlyOwner nonReentrant {
        require(msg.value > 0, "ETH required");
        token.safeTransferFrom(msg.sender, address(this), tokenAmount);
        uint256 lpAmount = (tokenAmount * 90) / 100;
        uint256 teamAmount = tokenAmount - lpAmount;

        token.forceApprove(address(router), lpAmount);
        router.addLiquidityETH{value: msg.value}(
            address(token),
            lpAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
        lockedTeam += teamAmount;
        // teamAmount remains in this contract locked until release
    }

    /// @notice release locked team tokens after vesting
    function releaseTeamTokens() external nonReentrant {
        require(block.timestamp >= releaseTime, "locked");
        uint256 amount = lockedTeam;
        lockedTeam = 0;
        token.safeTransfer(team, amount);
    }

    receive() external payable {}
}
