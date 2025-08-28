// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title USDx Enterprise Token
/// @notice ERC20 stablecoin with compliance and role-based controls
contract USDxEnterprise is ERC20, Pausable, AccessControl, ReentrancyGuard {
    /// @dev Role allowed to mint and burn tokens
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    /// @dev Role allowed to pause transfers
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    /// @notice Emitted when tokens are minted
    /// @param to recipient address
    /// @param amount amount minted
    /// @param reference settlement reference
    event Minted(address indexed to, uint256 amount, string reference);

    /// @notice Emitted when tokens are burned
    /// @param from address tokens burned from
    /// @param amount amount burned
    /// @param reference reference identifier
    event Burned(address indexed from, uint256 amount, string reference);

    constructor(address admin) ERC20("USDx Enterprise", "USDx") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(COMPLIANCE_ROLE, admin);
    }

    /// @notice Mint tokens after off-chain settlement
    /// @param to receiver of minted tokens
    /// @param amount quantity to mint
    /// @param reference settlement reference id
    function mint(address to, uint256 amount, string calldata reference)
        external
        onlyRole(TREASURY_ROLE)
        whenNotPaused
        nonReentrant
    {
        _mint(to, amount);
        emit Minted(to, amount, reference);
    }

    /// @notice Burn tokens for redemption
    /// @param from address holding tokens
    /// @param amount quantity to burn
    /// @param reference redemption reference id
    function burn(address from, uint256 amount, string calldata reference)
        external
        onlyRole(TREASURY_ROLE)
        whenNotPaused
        nonReentrant
    {
        _burn(from, amount);
        emit Burned(from, amount, reference);
    }

    /// @notice Pause token transfers
    function pause() external onlyRole(COMPLIANCE_ROLE) {
        _pause();
    }

    /// @notice Unpause token transfers
    function unpause() external onlyRole(COMPLIANCE_ROLE) {
        _unpause();
    }

    /// @dev Hook enforcing pause state
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
