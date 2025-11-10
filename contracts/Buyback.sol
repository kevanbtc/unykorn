// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Buyback
 * @dev Allows an authorized treasury to repurchase tokens from sellers.
 *      The treasury must approve this contract to spend payment tokens and
 *      sellers must approve their tokens to be bought back. Pricing is handled
 *      via a configurable price per token.
 */
contract Buyback is AccessControl {
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    IERC20 public immutable token;        // token being bought back
    IERC20 public immutable paymentToken; // token used for payment
    uint256 public pricePerToken;         // price per token in paymentToken units

    event BuybackCompleted(address indexed seller, uint256 amount, uint256 purchasePrice);

    constructor(address _token, address _paymentToken, uint256 _price, address treasury) {
        token = IERC20(_token);
        paymentToken = IERC20(_paymentToken);
        pricePerToken = _price;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TREASURY_ROLE, treasury);
    }

    /**
     * @dev Updates the price per token. Only callable by admin.
     */
    function setPrice(uint256 newPrice) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePerToken = newPrice;
    }

    /**
     * @dev Executes a buyback from `seller` for `amount` tokens.
     *      Caller must have TREASURY_ROLE. Treasury and seller must
     *      both provide sufficient allowances.
     */
    function buyback(address seller, uint256 amount) external onlyRole(TREASURY_ROLE) {
        require(seller != address(0), "seller zero address");
        require(amount > 0, "amount zero");

        uint256 purchasePrice = amount * pricePerToken;

        require(paymentToken.allowance(msg.sender, address(this)) >= purchasePrice, "treasury allowance");
        require(token.allowance(seller, address(this)) >= amount, "seller allowance");

        require(paymentToken.transferFrom(msg.sender, seller, purchasePrice), "payment failed");
        require(token.transferFrom(seller, msg.sender, amount), "transfer failed");

        emit BuybackCompleted(seller, amount, purchasePrice);
    }
}

