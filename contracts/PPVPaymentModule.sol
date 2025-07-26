// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title PPVPaymentModule
/// @notice Simplified pay-per-view unlock logic.
contract PPVPaymentModule {
    event AccessGranted(address indexed user, uint256 contentId);

    mapping(uint256 => uint256) public ticketPrice;
    mapping(uint256 => mapping(address => bool)) public hasAccess;

    /// @notice Set the ticket price for a given contentId.
    function setPrice(uint256 contentId, uint256 price) external {
        ticketPrice[contentId] = price;
    }

    /// @notice Purchase access to content.
    function buyTicket(uint256 contentId) external payable {
        uint256 price = ticketPrice[contentId];
        require(price > 0, "No ticket available");
        require(msg.value >= price, "Insufficient payment");

        hasAccess[contentId][msg.sender] = true;
        emit AccessGranted(msg.sender, contentId);
    }
}
