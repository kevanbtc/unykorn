// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title RegistryNotary
 * @dev On-chain notarization of Unykorn registry snapshots for institutional compliance
 */
contract RegistryNotary is AccessControl {
    bytes32 public constant NOTARY_ROLE = keccak256("NOTARY_ROLE");
    
    struct RegistrySnapshot {
        bytes32 merkleRoot;
        string ipfsCid;
        uint256 timestamp;
        string version;
        string label;
        address notarizedBy;
    }
    
    // Snapshot ID => Registry Snapshot
    mapping(uint256 => RegistrySnapshot) public snapshots;
    
    // Merkle root => Snapshot ID (for quick lookups)
    mapping(bytes32 => uint256) public rootToSnapshotId;
    
    uint256 public nextSnapshotId = 1;
    uint256 public totalSnapshots = 0;
    
    event RegistryNotarized(
        uint256 indexed snapshotId,
        bytes32 indexed merkleRoot,
        string ipfsCid,
        string version,
        string label,
        address indexed notarizedBy,
        uint256 timestamp
    );
    
    event SnapshotVerified(
        uint256 indexed snapshotId,
        bytes32 indexed merkleRoot,
        address indexed verifiedBy
    );
    
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(NOTARY_ROLE, admin);
    }
    
    /**
     * @dev Notarize a registry snapshot on-chain
     * @param merkleRoot The Merkle root of the registry data
     * @param ipfsCid IPFS CID where the data is stored
     * @param version Registry version string
     * @param label Human-readable label for this snapshot
     */
    function notarizeSnapshot(
        bytes32 merkleRoot,
        string calldata ipfsCid,
        string calldata version,
        string calldata label
    ) external onlyRole(NOTARY_ROLE) returns (uint256) {
        require(merkleRoot != bytes32(0), "Invalid Merkle root");
        require(bytes(ipfsCid).length > 0, "IPFS CID required");
        require(rootToSnapshotId[merkleRoot] == 0, "Merkle root already notarized");
        
        uint256 snapshotId = nextSnapshotId++;
        
        snapshots[snapshotId] = RegistrySnapshot({
            merkleRoot: merkleRoot,
            ipfsCid: ipfsCid,
            timestamp: block.timestamp,
            version: version,
            label: label,
            notarizedBy: msg.sender
        });
        
        rootToSnapshotId[merkleRoot] = snapshotId;
        totalSnapshots++;
        
        emit RegistryNotarized(
            snapshotId,
            merkleRoot,
            ipfsCid,
            version,
            label,
            msg.sender,
            block.timestamp
        );
        
        return snapshotId;
    }
    
    /**
     * @dev Verify a Merkle root exists in the registry
     * @param merkleRoot The Merkle root to verify
     * @return exists Whether the root exists
     * @return snapshotId The snapshot ID if it exists
     */
    function verifyMerkleRoot(bytes32 merkleRoot) 
        external 
        returns (bool exists, uint256 snapshotId) 
    {
        snapshotId = rootToSnapshotId[merkleRoot];
        exists = (snapshotId != 0);
        
        if (exists) {
            emit SnapshotVerified(snapshotId, merkleRoot, msg.sender);
        }
        
        return (exists, snapshotId);
    }
    
    /**
     * @dev Get complete snapshot details
     */
    function getSnapshot(uint256 snapshotId) 
        external 
        view 
        returns (RegistrySnapshot memory) 
    {
        require(snapshotId > 0 && snapshotId < nextSnapshotId, "Invalid snapshot ID");
        return snapshots[snapshotId];
    }
    
    /**
     * @dev Get the latest notarized snapshot
     */
    function getLatestSnapshot() 
        external 
        view 
        returns (uint256 snapshotId, RegistrySnapshot memory snapshot) 
    {
        require(totalSnapshots > 0, "No snapshots exist");
        snapshotId = nextSnapshotId - 1;
        snapshot = snapshots[snapshotId];
        return (snapshotId, snapshot);
    }
    
    /**
     * @dev Grant notary role to an address
     */
    function grantNotaryRole(address notary) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(NOTARY_ROLE, notary);
    }
    
    /**
     * @dev Revoke notary role from an address
     */
    function revokeNotaryRole(address notary) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(NOTARY_ROLE, notary);
    }
}