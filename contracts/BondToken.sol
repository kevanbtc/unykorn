pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract BondToken is ERC20, AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    address public immutable treasury;

    event CouponPaid(address indexed to, uint256 amount);

    constructor(address _treasury) ERC20("BondToken", "BND") {
        treasury = _treasury;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function payCoupon(address to, uint256 amount) external {
        require(msg.sender == treasury || hasRole(MANAGER_ROLE, msg.sender), "Unauthorized");
        emit CouponPaid(to, amount);
    }
}

