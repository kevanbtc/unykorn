pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BondToken.sol";

contract BondManager is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    address public immutable treasury;
    BondToken public immutable bondToken;

    constructor(address _treasury, address _bondToken) {
        treasury = _treasury;
        bondToken = BondToken(_bondToken);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function issueBond(address to, uint256 amount) external {
        require(msg.sender == treasury || hasRole(MANAGER_ROLE, msg.sender), "Unauthorized");
        // bond issuance logic omitted
    }

    function redeemBond(uint256 amount) external {
        require(msg.sender == treasury || hasRole(MANAGER_ROLE, msg.sender), "Unauthorized");
        // bond redemption logic omitted
    }

    function payCoupon(address to, uint256 amount) external {
        require(msg.sender == treasury || hasRole(MANAGER_ROLE, msg.sender), "Unauthorized");
        bondToken.payCoupon(to, amount);
    }
}

