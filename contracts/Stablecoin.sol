// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Stablecoin is ERC20, AccessControl {
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;

    constructor() ERC20("TrustUSD", "TUSD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(whitelisted[to], "Not KYC approved");
        require(!blacklisted[to], "Blacklisted address");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(from, amount);
    }

    function whitelist(address user) external onlyRole(COMPLIANCE_ROLE) {
        whitelisted[user] = true;
    }

    function blacklist(address user) external onlyRole(COMPLIANCE_ROLE) {
        blacklisted[user] = true;
    }
}
