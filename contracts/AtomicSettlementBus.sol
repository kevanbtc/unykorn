// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IAffiliateRegistry {
    function credit(address affiliate, uint256 amount) external;
}

/// @title AtomicSettlementBus
/// @notice Minimal stablecoin settlement layer with optional affiliate payout hook
contract AtomicSettlementBus is Ownable, Pausable, ReentrancyGuard {
    mapping(address => bool) public supportedTokens;
    IAffiliateRegistry public affiliateRegistry;

    event TokenSupportUpdated(address token, bool supported);
    event AffiliateRegistryUpdated(address registry);
    event Settled(address indexed token, address indexed payer, address indexed payee, uint256 amount, address affiliate);

    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    /// @notice Pause all settlements in case of emergency
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Resume settlements after the emergency has passed
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Configure the affiliate registry contract
    function setAffiliateRegistry(address registry) external onlyOwner {
        affiliateRegistry = IAffiliateRegistry(registry);
        emit AffiliateRegistryUpdated(registry);
    }

    /// @notice Enable or disable a payment token
    function setTokenSupported(address token, bool supported) external onlyOwner {
        supportedTokens[token] = supported;
        emit TokenSupportUpdated(token, supported);
    }

    /// @notice Perform an atomic transfer of a supported token to a payee
    /// @dev If an affiliate is provided and a registry is configured, the affiliate is credited
    function settle(address token, address payee, uint256 amount, address affiliate)
        external
        whenNotPaused
        nonReentrant
    {
        require(supportedTokens[token], "token not supported");
        IERC20(token).transferFrom(msg.sender, payee, amount);
        emit Settled(token, msg.sender, payee, amount, affiliate);

        if (affiliate != address(0) && address(affiliateRegistry) != address(0)) {
            affiliateRegistry.credit(affiliate, amount);
        }
    }
}

