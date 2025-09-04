// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

interface ITokenERC20 {
    function addCommissionEarning(address user, uint256 amount) external;
}

/// @title AssetVault - Multi-asset vault with leverage capabilities
contract AssetVault is AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant VAULT_MANAGER_ROLE = keccak256("VAULT_MANAGER_ROLE");
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");

    struct AssetAllocation {
        address asset;
        uint256 targetPercentage; // in basis points (10000 = 100%)
        uint256 currentAmount;
        bool isActive;
    }

    // Vault configuration
    uint256 public constant MAX_LTV_RATIO = 8000; // 80% max loan-to-value
    uint256 public currentLtvRatio = 0;
    uint256 public totalVaultValue;
    
    // Asset allocations
    AssetAllocation[] public allocations;
    mapping(address => uint256) public assetToIndex;
    
    // Depositor tracking
    mapping(address => uint256) public depositorShares;
    mapping(address => uint256) public depositorLockUntil;
    uint256 public totalShares;
    
    // Integration with token contract
    ITokenERC20 public immutable tokenContract;
    
    // Events
    event Deposited(address indexed depositor, uint256 amount, uint256 shares, uint256 lockUntil);
    event AssetAllocated(address indexed asset, uint256 amount, uint256 percentage);
    event LeverageUsed(uint256 collateralValue, uint256 borrowedAmount);
    event AssetAllocationUpdated(address indexed asset, uint256 newPercentage);

    constructor(
        address _tokenContract,
        address admin
    ) {
        tokenContract = ITokenERC20(_tokenContract);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(VAULT_MANAGER_ROLE, admin);
    }

    /// @notice Deposit funds with optional lock period (for early adopters)
    function deposit(uint256 lockDays) external payable nonReentrant {
        require(msg.value > 0, "No deposit");
        
        uint256 shares = totalShares == 0 ? msg.value : (msg.value * totalShares) / totalVaultValue;
        depositorShares[msg.sender] += shares;
        totalShares += shares;
        totalVaultValue += msg.value;
        
        uint256 lockUntil = block.timestamp;
        if (lockDays > 0) {
            lockUntil += lockDays * 1 days;
            depositorLockUntil[msg.sender] = lockUntil;
        }
        
        emit Deposited(msg.sender, msg.value, shares, lockUntil);
        
        // Auto-allocate according to target percentages
        _rebalanceAllocations();
    }

    /// @notice Add or update asset allocation target
    function setAssetAllocation(
        address asset,
        uint256 targetPercentage
    ) external onlyRole(VAULT_MANAGER_ROLE) {
        require(targetPercentage <= 10000, "Invalid percentage");
        
        if (assetToIndex[asset] == 0 && allocations.length == 0) {
            // First allocation
            allocations.push(AssetAllocation({
                asset: asset,
                targetPercentage: targetPercentage,
                currentAmount: 0,
                isActive: true
            }));
            assetToIndex[asset] = allocations.length;
        } else if (assetToIndex[asset] == 0) {
            // New allocation
            allocations.push(AssetAllocation({
                asset: asset,
                targetPercentage: targetPercentage,
                currentAmount: 0,
                isActive: true
            }));
            assetToIndex[asset] = allocations.length;
        } else {
            // Update existing
            uint256 index = assetToIndex[asset] - 1;
            allocations[index].targetPercentage = targetPercentage;
            allocations[index].isActive = targetPercentage > 0;
        }
        
        emit AssetAllocationUpdated(asset, targetPercentage);
    }

    /// @notice Rebalance vault according to target allocations
    function _rebalanceAllocations() internal {
        uint256 vaultBalance = address(this).balance;
        if (vaultBalance == 0) return;
        
        for (uint256 i = 0; i < allocations.length; i++) {
            if (!allocations[i].isActive) continue;
            
            uint256 targetAmount = (vaultBalance * allocations[i].targetPercentage) / 10000;
            uint256 currentAmount = allocations[i].currentAmount;
            
            if (targetAmount > currentAmount) {
                uint256 toAllocate = targetAmount - currentAmount;
                if (toAllocate <= address(this).balance) {
                    allocations[i].currentAmount += toAllocate;
                    emit AssetAllocated(allocations[i].asset, toAllocate, allocations[i].targetPercentage);
                }
            }
        }
    }

    /// @notice Use vault assets as collateral for leverage
    function useLeverage(uint256 collateralValue, uint256 borrowAmount) 
        external 
        onlyRole(VAULT_MANAGER_ROLE) 
        nonReentrant 
    {
        require(collateralValue > 0, "Invalid collateral");
        require(borrowAmount > 0, "Invalid borrow amount");
        
        uint256 newLtvRatio = (borrowAmount * 10000) / collateralValue;
        require(newLtvRatio <= MAX_LTV_RATIO, "LTV too high");
        
        currentLtvRatio = newLtvRatio;
        emit LeverageUsed(collateralValue, borrowAmount);
    }

    /// @notice Withdraw depositor funds (after lock period)
    function withdraw(uint256 shareAmount) external nonReentrant {
        require(depositorShares[msg.sender] >= shareAmount, "Insufficient shares");
        require(block.timestamp >= depositorLockUntil[msg.sender], "Still locked");
        
        uint256 withdrawAmount = (shareAmount * totalVaultValue) / totalShares;
        require(address(this).balance >= withdrawAmount, "Insufficient vault balance");
        
        depositorShares[msg.sender] -= shareAmount;
        totalShares -= shareAmount;
        totalVaultValue -= withdrawAmount;
        
        payable(msg.sender).transfer(withdrawAmount);
    }

    /// @notice Get vault composition and health metrics
    function getVaultMetrics() external view returns (
        uint256 totalValue,
        uint256 totalSharesIssued,
        uint256 ltvRatio,
        uint256 numAllocations
    ) {
        return (totalVaultValue, totalShares, currentLtvRatio, allocations.length);
    }

    /// @notice Get specific asset allocation
    function getAllocation(uint256 index) external view returns (AssetAllocation memory) {
        require(index < allocations.length, "Invalid index");
        return allocations[index];
    }

    receive() external payable {
        totalVaultValue += msg.value;
    }
}