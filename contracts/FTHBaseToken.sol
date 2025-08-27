// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract FTHBaseToken is ERC20, Ownable {
    uint256 public investorCount;
    uint256 public constant maxInvestors = 200;

    event MaxInvestorsReached(uint256 maxInvestors);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount) internal override {
        if (from == to) {
            super._update(from, to, amount);
            return;
        }

        bool fromWillBeZero = from != address(0) && balanceOf(from) == amount;
        bool toIsNew = to != address(0) && balanceOf(to) == 0;

        if (toIsNew && !fromWillBeZero) {
            require(investorCount < maxInvestors, "Investor limit reached");
            unchecked {
                investorCount++;
            }
            if (investorCount == maxInvestors) {
                emit MaxInvestorsReached(maxInvestors);
            }
        }

        super._update(from, to, amount);

        if (fromWillBeZero && !toIsNew) {
            unchecked {
                investorCount--;
            }
        }
    }
}

