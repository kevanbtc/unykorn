// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Stablecoin.sol";

contract VaultManager {
    Stablecoin public stable;

    constructor(address stablecoin) {
        stable = Stablecoin(stablecoin);
    }

    function depositCollateral() external payable {
        // Placeholder: tie collateral assets here
    }

    function redeem(uint256 amount) external {
        // Placeholder: redemption logic
        stable.burn(msg.sender, amount);
    }
}
