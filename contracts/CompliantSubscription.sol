// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ComplianceRegistry.sol";

/**
 * @title CompliantSubscription
 * @notice Handles subscription payments in an ERC20 token while enforcing
 *         KYC checks through a ComplianceRegistry and distributing affiliate
 *         commissions.
 */
contract CompliantSubscription is Ownable {
    IERC20 public immutable paymentToken;
    IComplianceRegistry public immutable compliance;

    uint256 public price; // price per period in token units
    uint256 public affiliateBps; // commission in basis points (1% = 100)
    uint256 public constant PERIOD = 30 days;

    // maps subscriber to expiration timestamp
    mapping(address => uint256) public expiry;

    event Subscribed(address indexed user, uint256 periods, address indexed affiliate);
    event PriceUpdated(uint256 newPrice);
    event AffiliateBpsUpdated(uint256 newBps);

    constructor(address registry, address token, uint256 _price, uint256 _affiliateBps)
        Ownable(msg.sender)
    {
        require(registry != address(0) && token != address(0), "zero address");
        compliance = IComplianceRegistry(registry);
        paymentToken = IERC20(token);
        price = _price;
        affiliateBps = _affiliateBps;
    }

    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
        emit PriceUpdated(newPrice);
    }

    function setAffiliateBps(uint256 newBps) external onlyOwner {
        affiliateBps = newBps;
        emit AffiliateBpsUpdated(newBps);
    }

    function isActive(address user) public view returns (bool) {
        return expiry[user] >= block.timestamp;
    }

    function subscribe(uint256 periods, address affiliate) external {
        require(periods > 0, "periods=0");
        require(compliance.isKYCed(msg.sender), "KYC required");
        uint256 amount = price * periods;
        uint256 commission;
        if (affiliate != address(0) && affiliate != msg.sender) {
            commission = amount * affiliateBps / 10000;
            paymentToken.transferFrom(msg.sender, affiliate, commission);
        }
        paymentToken.transferFrom(msg.sender, owner(), amount - commission);

        uint256 end = block.timestamp + periods * PERIOD;
        if (expiry[msg.sender] < block.timestamp) {
            expiry[msg.sender] = end;
        } else {
            expiry[msg.sender] += periods * PERIOD;
        }
        emit Subscribed(msg.sender, periods, affiliate);
    }
}

