// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title MultiAssetVault - Diversified vault for stablecoins, BTC, gold, ETH, RWAs
contract MultiAssetVault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    struct AssetAllocation {
        address token;
        uint256 targetPercentage; // In basis points (e.g., 4000 = 40%)
        uint256 currentBalance;
        bool active;
        string assetType; // "STABLE", "BTC", "GOLD", "ETH", "RWA"
    }
    
    struct VaultProofNFT {
        string assetType;
        uint256 amount;
        string proofURI; // IPFS hash or URL to proof
        uint256 timestamp;
    }
    
    mapping(address => AssetAllocation) public allocations;
    mapping(uint256 => VaultProofNFT) public vaultProofs;
    address[] public allocatedTokens;
    
    uint256 public totalValue;
    uint256 public leverageRatio = 8000; // 80% max LTV in basis points
    uint256 public nextProofId = 1;
    
    // Revenue splitting for buy-ins
    uint256 public stablecoinAllocation = 4000; // 40%
    uint256 public bitcoinAllocation = 2000;     // 20%
    uint256 public goldAllocation = 2000;        // 20%
    uint256 public ethAllocation = 1000;         // 10%
    uint256 public rwaAllocation = 1000;         // 10%
    
    event Deposit(address indexed depositor, address indexed token, uint256 amount);
    event AssetRebalanced(address indexed token, uint256 newBalance);
    event VaultProofCreated(uint256 indexed proofId, string assetType, uint256 amount);
    event AllocationUpdated(address indexed token, uint256 newTargetPercentage);
    
    constructor() Ownable(msg.sender) {}
    
    /// @notice Add a new asset to the vault
    function addAsset(
        address token,
        uint256 targetPercentage,
        string calldata assetType
    ) external onlyOwner {
        require(allocations[token].token == address(0), "Asset already exists");
        require(targetPercentage <= 10000, "Invalid percentage");
        
        allocations[token] = AssetAllocation({
            token: token,
            targetPercentage: targetPercentage,
            currentBalance: 0,
            active: true,
            assetType: assetType
        });
        
        allocatedTokens.push(token);
        emit AllocationUpdated(token, targetPercentage);
    }
    
    /// @notice Deposit tokens into vault with automatic allocation
    function deposit(address token, uint256 amount) external payable nonReentrant {
        if (token == address(0)) {
            // ETH deposit
            require(msg.value > 0, "No ETH sent");
            amount = msg.value;
        } else {
            // ERC20 deposit
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
        
        // Auto-allocate based on vault percentages if this is a supported asset
        if (allocations[token].active) {
            allocations[token].currentBalance += amount;
        }
        
        totalValue += amount;
        emit Deposit(msg.sender, token, amount);
        
        // Auto-rebalance if needed (simplified)
        _rebalanceIfNeeded();
    }
    
    /// @notice Manual rebalancing (owner only)
    function rebalance() external onlyOwner {
        _rebalanceIfNeeded();
    }
    
    /// @notice Create a vault proof NFT for physical/external assets
    function createVaultProof(
        string calldata assetType,
        uint256 amount,
        string calldata proofURI
    ) external onlyOwner {
        uint256 proofId = nextProofId++;
        
        vaultProofs[proofId] = VaultProofNFT({
            assetType: assetType,
            amount: amount,
            proofURI: proofURI,
            timestamp: block.timestamp
        });
        
        emit VaultProofCreated(proofId, assetType, amount);
    }
    
    /// @notice Update asset allocation percentages
    function updateAllocation(address token, uint256 newTargetPercentage) external onlyOwner {
        require(allocations[token].active, "Asset not active");
        require(newTargetPercentage <= 10000, "Invalid percentage");
        
        allocations[token].targetPercentage = newTargetPercentage;
        emit AllocationUpdated(token, newTargetPercentage);
    }
    
    /// @notice Get vault composition
    function getVaultComposition() external view returns (
        address[] memory tokens,
        uint256[] memory balances,
        uint256[] memory percentages,
        string[] memory assetTypes
    ) {
        tokens = new address[](allocatedTokens.length);
        balances = new uint256[](allocatedTokens.length);
        percentages = new uint256[](allocatedTokens.length);
        assetTypes = new string[](allocatedTokens.length);
        
        for (uint256 i = 0; i < allocatedTokens.length; i++) {
            address token = allocatedTokens[i];
            AssetAllocation storage allocation = allocations[token];
            
            tokens[i] = token;
            balances[i] = allocation.currentBalance;
            percentages[i] = allocation.targetPercentage;
            assetTypes[i] = allocation.assetType;
        }
    }
    
    /// @notice Calculate available collateral for leverage
    function getAvailableCollateral() external view returns (uint256) {
        return (totalValue * leverageRatio) / 10000;
    }
    
    /// @notice Set leverage ratio (max LTV)
    function setLeverageRatio(uint256 newRatio) external onlyOwner {
        require(newRatio <= 9000, "Max 90% LTV"); // Max 90%
        leverageRatio = newRatio;
    }
    
    /// @notice Emergency withdraw (owner only)
    function emergencyWithdraw(address token, uint256 amount) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(amount);
        } else {
            IERC20(token).safeTransfer(owner(), amount);
        }
    }
    
    /// @notice Get ETH balance
    function getETHBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Internal rebalancing logic (simplified)
    function _rebalanceIfNeeded() internal {
        // This is a simplified rebalancing - in practice would be more sophisticated
        for (uint256 i = 0; i < allocatedTokens.length; i++) {
            address token = allocatedTokens[i];
            AssetAllocation storage allocation = allocations[token];
            
            if (!allocation.active) continue;
            
            uint256 targetAmount = (totalValue * allocation.targetPercentage) / 10000;
            uint256 currentAmount = allocation.currentBalance;
            
            // Emit rebalancing event if significant deviation
            if (currentAmount != targetAmount) {
                emit AssetRebalanced(token, currentAmount);
            }
        }
    }
    
    /// @notice Receive ETH
    receive() external payable {
        totalValue += msg.value;
    }
    
    /// @notice Get vault proof details
    function getVaultProof(uint256 proofId) external view returns (
        string memory assetType,
        uint256 amount,
        string memory proofURI,
        uint256 timestamp
    ) {
        VaultProofNFT storage proof = vaultProofs[proofId];
        return (proof.assetType, proof.amount, proof.proofURI, proof.timestamp);
    }
    
    /// @notice Calculate total vault value in USD (would need price oracles in production)
    function getTotalValue() external view returns (uint256) {
        return totalValue;
    }
}