// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title VaultProofNFT - Cryptographic proof of physical gold custody
/// @notice Each NFT represents verified gold bars in FTH vault with metadata
/// @dev Links to IPFS/Chainlink PoR for audit trail
contract VaultProofNFT is
    Initializable,
    ERC721Upgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant AUDITOR_ROLE = keccak256("AUDITOR_ROLE");

    /// @notice Vault proof metadata
    struct VaultProof {
        uint256 goldBars;          // Number of gold bars
        uint256 totalOunces;       // Total troy ounces
        string ipfsHash;           // IPFS custody documentation
        string chainlinkPoR;       // Chainlink Proof-of-Reserve reference
        uint256 auditTimestamp;    // Last audit date
        address custodian;         // Physical custodian
        bool verified;             // Auditor verification status
    }

    /// @notice Token ID counter
    uint256 private _nextTokenId;

    /// @notice Vault proofs by token ID
    mapping(uint256 => VaultProof) public vaultProofs;

    /// @notice Total verified gold across all vaults
    uint256 public totalVerifiedGold;

    event VaultProofMinted(uint256 indexed tokenId, uint256 goldBars, uint256 ounces, address custodian);
    event VaultProofUpdated(uint256 indexed tokenId, string ipfsHash, string chainlinkPoR);
    event VaultProofVerified(uint256 indexed tokenId, address indexed auditor, uint256 timestamp);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the VaultProofNFT
    /// @param treasury Treasury address with admin privileges
    /// @param custodian Initial custodian address
    /// @param auditor Independent auditor address
    function initialize(
        address treasury,
        address custodian,
        address auditor
    ) public initializer {
        __ERC721_init("FTH Vault Proof", "FTHVAULT");
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, treasury);
        _grantRole(MINTER_ROLE, custodian);
        _grantRole(AUDITOR_ROLE, auditor);

        _nextTokenId = 1;
    }

    /// @notice Mint a new vault proof NFT
    /// @param to Recipient (typically FTH treasury)
    /// @param goldBars Number of gold bars
    /// @param totalOunces Total troy ounces
    /// @param ipfsHash IPFS documentation hash
    /// @param chainlinkPoR Chainlink PoR reference
    /// @param custodian Physical custodian address
    function mintVaultProof(
        address to,
        uint256 goldBars,
        uint256 totalOunces,
        string calldata ipfsHash,
        string calldata chainlinkPoR,
        address custodian
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _nextTokenId++;

        vaultProofs[tokenId] = VaultProof({
            goldBars: goldBars,
            totalOunces: totalOunces,
            ipfsHash: ipfsHash,
            chainlinkPoR: chainlinkPoR,
            auditTimestamp: block.timestamp,
            custodian: custodian,
            verified: false
        });

        _safeMint(to, tokenId);

        emit VaultProofMinted(tokenId, goldBars, totalOunces, custodian);
        return tokenId;
    }

    /// @notice Update vault proof metadata
    /// @param tokenId Token ID to update
    /// @param ipfsHash New IPFS hash
    /// @param chainlinkPoR New Chainlink PoR reference
    function updateVaultProof(
        uint256 tokenId,
        string calldata ipfsHash,
        string calldata chainlinkPoR
    ) external onlyRole(MINTER_ROLE) {
        require(ownerOf(tokenId) != address(0), "VaultProof: token does not exist");

        VaultProof storage proof = vaultProofs[tokenId];
        proof.ipfsHash = ipfsHash;
        proof.chainlinkPoR = chainlinkPoR;
        proof.auditTimestamp = block.timestamp;

        emit VaultProofUpdated(tokenId, ipfsHash, chainlinkPoR);
    }

    /// @notice Verify vault proof after audit
    /// @param tokenId Token ID to verify
    function verifyVaultProof(uint256 tokenId) external onlyRole(AUDITOR_ROLE) {
        require(ownerOf(tokenId) != address(0), "VaultProof: token does not exist");

        VaultProof storage proof = vaultProofs[tokenId];
        
        if (!proof.verified) {
            totalVerifiedGold += proof.totalOunces;
            proof.verified = true;
        }
        
        proof.auditTimestamp = block.timestamp;

        emit VaultProofVerified(tokenId, msg.sender, block.timestamp);
    }

    /// @notice Get vault proof details
    /// @param tokenId Token ID to query
    function getVaultProof(uint256 tokenId) external view returns (VaultProof memory) {
        require(ownerOf(tokenId) != address(0), "VaultProof: token does not exist");
        return vaultProofs[tokenId];
    }

    /// @notice Get total number of minted proofs
    function totalProofs() external view returns (uint256) {
        return _nextTokenId - 1;
    }

    /// @dev Required by UUPS
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}

    /// @dev Override to prevent transfers (soulbound to treasury)
    function _update(address to, uint256 tokenId, address auth)
        internal
        override
        returns (address)
    {
        address from = _ownerOf(tokenId);
        // Allow minting and admin transfers only
        if (from != address(0)) {
            require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "VaultProof: transfers restricted");
        }
        return super._update(to, tokenId, auth);
    }

    /// @dev Override supportsInterface for multiple inheritance
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
