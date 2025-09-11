// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title RWARegistry
/// @notice Tracks proofs and collateral data for real-world assets
contract RWARegistry is AccessControl {
    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    struct Asset {
        bytes32 id;
        uint256 collateralRatio; // basis points
        uint256 lastUpdated;
        bytes32 proofHash; // Merkle root or attestation reference
        bool frozen;
    }

    mapping(bytes32 => Asset) public assets;

    event AssetUpdated(bytes32 indexed id, uint256 ratio, bytes32 proofHash);
    event AssetFrozen(bytes32 indexed id, bool status);

    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_ROLE, admin);
    }

    /// @notice Updates collateral data for an asset
    function updateAsset(bytes32 id, uint256 collateralRatio, bytes32 proofHash)
        external
        onlyRole(ORACLE_ROLE)
    {
        require(!assets[id].frozen, "Asset frozen");
        assets[id] = Asset({
            id: id,
            collateralRatio: collateralRatio,
            lastUpdated: block.timestamp,
            proofHash: proofHash,
            frozen: false
        });
        emit AssetUpdated(id, collateralRatio, proofHash);
    }

    /// @notice Freezes or unfreezes an asset
    function freezeAsset(bytes32 id, bool status) external onlyRole(DEFAULT_ADMIN_ROLE) {
        assets[id].frozen = status;
        emit AssetFrozen(id, status);
    }

    /// @notice Retrieves data for an asset
    function getAsset(bytes32 id) external view returns (Asset memory) {
        return assets[id];
    }
}

