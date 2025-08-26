// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title FeeSplitter
/// @notice Distributes ERC20 fees using Unykorn's 60/25/15 share model
library FeeSplitter {
    using SafeERC20 for IERC20;

    function split(
        IERC20 token,
        uint256 amount,
        address creator,
        address platform,
        address governance
    ) internal {
        uint256 creatorShare = (amount * 60) / 100;
        uint256 platformShare = (amount * 25) / 100;
        uint256 governanceShare = amount - creatorShare - platformShare;

        token.safeTransfer(creator, creatorShare);
        token.safeTransfer(platform, platformShare);
        token.safeTransfer(governance, governanceShare);
    }
}
