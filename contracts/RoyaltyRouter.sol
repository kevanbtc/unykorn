// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

/// @title RoyaltyRouter
/// @notice Splits incoming revenue between recipients based on basis points.
contract RoyaltyRouter {
    using Address for address payable;

    struct Recipient {
        address payable account;
        uint96 bps; // out of 10,000
    }

    Recipient[] public recipients;

    constructor(Recipient[] memory _recipients) {
        uint256 totalBps;
        for (uint256 i = 0; i < _recipients.length; i++) {
            recipients.push(_recipients[i]);
            totalBps += _recipients[i].bps;
        }
        require(totalBps == 10000, "Invalid bps");
    }

    receive() external payable {
        uint256 amount = msg.value;
        for (uint256 i = 0; i < recipients.length; i++) {
            uint256 share = (amount * recipients[i].bps) / 10000;
            recipients[i].account.sendValue(share);
        }
    }
}
