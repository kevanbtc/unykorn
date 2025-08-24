// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Base token that can distribute stablecoin revenues pro rata
abstract contract BaseRevenueToken is ERC20, Ownable {
    IERC20 public stablecoin;
    address public revenueRouter;

    uint256 public magnifiedDividendPerShare;
    mapping(address => uint256) public withdrawnDividends;
    uint256 internal constant MAGNITUDE = 1e18;

    constructor(string memory name_, string memory symbol_, address stable_) ERC20(name_, symbol_) {
        stablecoin = IERC20(stable_);
    }

    function setRevenueRouter(address router) external onlyOwner {
        revenueRouter = router;
    }

    /// @dev Called by the revenue router after transferring stablecoin
    function distribute(uint256 amount) external {
        require(msg.sender == revenueRouter, "not router");
        require(totalSupply() > 0, "no supply");
        magnifiedDividendPerShare += (amount * MAGNITUDE) / totalSupply();
    }

    function claim() public {
        uint256 withdrawable = ((magnifiedDividendPerShare * balanceOf(msg.sender)) / MAGNITUDE) - withdrawnDividends[msg.sender];
        withdrawnDividends[msg.sender] += withdrawable;
        if (withdrawable > 0) {
            stablecoin.transfer(msg.sender, withdrawable);
        }
    }
}

