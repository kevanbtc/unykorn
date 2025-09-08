# 📜 Smart Contracts

[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.4.0-4E5EE4?logo=openzeppelin)](https://openzeppelin.com/)
[![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow.svg)](https://hardhat.org/)
[![License](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)

## 📖 Overview

This directory contains the smart contract suite for the Unykorn ecosystem, including NFT marketplace functionality, staking mechanisms, token standards, and cross-chain utilities.

## 🎯 Contract Categories

### 🛒 Core Marketplace Contracts
- **NFTMarketplace.sol** - Complete NFT trading platform with fees and royalties
- **NFTStaking.sol** - Stake NFTs to earn ETH rewards over time
- **AffiliateRouter.sol** - Referral system with commission tracking

### 🪙 Token Standards
- **VTV.sol** - Utility token for platform operations (ERC-20)
- **VCHAN.sol** - Governance token for DAO voting (ERC-20)
- **VPOINT.sol** - Soulbound loyalty points (Non-transferable ERC-20)

### 💳 Subscription & Payments
- **SubscriptionVault.sol** - Recurring payment system using ERC-20 tokens
- **AuditTrail.sol** - Transaction logging and compliance tracking

### 🔧 EVM Utilities (`evm/`)
- **TokenERC20.sol** - Enhanced ERC-20 implementation with additional features
- **MemePass721.sol** - NFT pass system for meme token launches
- **LiquidityHelper.sol** - DEX liquidity management utilities

### 🌉 Cross-Chain (`shared/`)
- **MerkleLib.sol** - Merkle tree verification for cross-chain proofs

### ⚡ Solana Programs (`solana/`)
- **meme_token/** - SPL token implementation for meme launches
- **airdrop_dist/** - Efficient token distribution program

## 🏗️ Contract Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    🎯 User Interface                        │
│          Frontend App ←→ Web3 Provider ←→ Wallet           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  📜 Smart Contract Layer                    │
├─────────────────┬─────────────────┬─────────────────────────┤
│  Core Contracts │  Token Contracts│   Utility Contracts     │
│                 │                 │                         │
│ • Marketplace   │ • VTV (ERC-20)  │ • LiquidityHelper      │
│ • Staking       │ • VCHAN (Gov)   │ • MerkleLib            │
│ • Subscription  │ • VPOINT (SBT)  │ • AuditTrail           │
│ • Affiliate     │ • MemePass721   │                        │
└─────────────────┴─────────────────┴─────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   ⛓️ Blockchain Networks                    │
├─────────────────┬─────────────────┬─────────────────────────┤
│   EVM Networks  │  Solana Network │    Storage Layer        │
│                 │                 │                         │
│ • Ethereum      │ • Mainnet-beta  │ • IPFS (Metadata)     │
│ • Polygon       │ • Devnet/Test   │ • Arweave (Backup)    │
│ • BSC/Arbitrum  │                 │                        │
└─────────────────┴─────────────────┴─────────────────────────┘
```

## 🔒 Security Features

### OpenZeppelin Integration
All contracts leverage battle-tested OpenZeppelin libraries:
- **Access Control** - Role-based permissions with `AccessControlUpgradeable`
- **Upgradeability** - UUPS proxy pattern for secure upgrades
- **Reentrancy Protection** - `ReentrancyGuardUpgradeable` guards
- **Pause Functionality** - Emergency stop mechanisms

### Security Best Practices
- **Input Validation** - Comprehensive parameter checking
- **Overflow Protection** - SafeMath operations (Solidity 0.8.24+)
- **Access Controls** - Multi-signature requirements for critical functions
- **Event Logging** - Complete audit trail for all operations

## 💰 Gas Optimization

### Efficient Design Patterns
- **Packed Structs** - Optimized storage layout
- **Batch Operations** - Multiple operations in single transaction
- **Minimal Proxy Pattern** - Cost-effective contract deployment
- **Storage Optimization** - Reduced SSTORE operations

### Gas Usage Examples
| Contract | Deployment | Transfer | Complex Operation |
|----------|------------|----------|-------------------|
| VTV Token | ~800k gas | ~21k gas | ~45k gas |
| NFT Marketplace | ~2.1M gas | ~85k gas | ~120k gas |
| Staking Contract | ~1.8M gas | ~65k gas | ~95k gas |

## 🧪 Testing Strategy

### Test Coverage
```bash
# Run comprehensive test suite
npm run test

# Generate coverage report
npm run coverage

# Gas usage analysis
npm run test:gas
```

### Testing Frameworks
- **Hardhat Test Runner** - Primary testing framework
- **Chai Assertions** - Readable test assertions
- **Waffle Matchers** - Ethereum-specific test utilities
- **Coverage Reports** - Istanbul integration for coverage analysis

### Test Categories
- **Unit Tests** - Individual contract function testing
- **Integration Tests** - Multi-contract interaction testing
- **Gas Tests** - Gas usage optimization validation
- **Security Tests** - Vulnerability and edge case testing

## 🚀 Deployment Strategy

### Network Configuration
```typescript
// Supported networks with gas optimization
const networks = {
  mainnet: { gasPrice: 'auto', gasMultiplier: 1.2 },
  polygon: { gasPrice: 'auto', gasMultiplier: 1.1 },
  bsc: { gasPrice: 'auto', gasMultiplier: 1.0 },
  arbitrum: { gasPrice: 'auto' },
  optimism: { gasPrice: 'auto' }
};
```

### Deployment Order
1. **Base Infrastructure** - Proxy admin, implementation contracts
2. **Token Contracts** - VTV, VCHAN, VPOINT tokens
3. **Core Functionality** - Marketplace, staking, subscription contracts  
4. **Utility Contracts** - Helpers, libraries, and auxiliary contracts
5. **Integration Setup** - Configure contract interactions and permissions

### Verification Strategy
```bash
# Automatic verification post-deployment
npx hardhat verify --network mainnet <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>

# Batch verification for multiple contracts
npx hardhat verify:batch --network polygon --deployments ./deployments/polygon
```

## 📊 Contract Interactions

### Token Flow Diagram
```
User Wallet
     │
     ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   VTV Token │ ←→ │ Marketplace │ ←→ │ NFT Contract│
└─────────────┘    └─────────────┘    └─────────────┘
     │                      │                   │
     ▼                      ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Staking   │    │ Subscription│    │   Royalty   │
│  Contract   │    │   Vault     │    │  Registry   │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Event System
All contracts emit comprehensive events for indexing and monitoring:
```solidity
// Marketplace events
event ListingCreated(uint256 indexed tokenId, address seller, uint256 price);
event Purchase(uint256 indexed tokenId, address buyer, uint256 price);

// Staking events
event Staked(address indexed user, uint256 indexed tokenId, uint256 timestamp);
event Unstaked(address indexed user, uint256 indexed tokenId, uint256 reward);

// Token events (ERC-20 standard + custom)
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
```

## 🔗 Integration Guidelines

### Frontend Integration
```typescript
// Contract interaction example
import { ethers } from 'ethers';
import { VTV__factory } from './typechain';

const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
const vtvContract = VTV__factory.connect(contractAddress, signer);

// Transfer tokens
const tx = await vtvContract.transfer(recipient, amount);
await tx.wait();
```

### Backend Integration
```typescript
// Server-side contract interaction
import { JsonRpcProvider } from 'ethers';
import { NFTMarketplace__factory } from './typechain';

const provider = new JsonRpcProvider(RPC_URL);
const marketplace = NFTMarketplace__factory.connect(contractAddress, provider);

// Listen for events
marketplace.on('Purchase', (tokenId, buyer, price) => {
  console.log(`NFT ${tokenId} sold to ${buyer} for ${price}`);
});
```

## 📋 Contract Specifications

### VTV Token (Utility)
- **Standard:** ERC-20 with extensions
- **Features:** Mintable, Burnable, Permit (EIP-2612)
- **Max Supply:** 1,000,000,000 VTV
- **Decimals:** 18

### VCHAN Token (Governance)
- **Standard:** ERC-20 with voting extensions
- **Features:** Votes, VotesComp, Permit
- **Max Supply:** 100,000,000 VCHAN
- **Voting Power:** 1 token = 1 vote

### VPOINT Token (Loyalty)
- **Standard:** ERC-20 (Non-transferable)
- **Features:** Mintable by authorized contracts only
- **Transfer:** Disabled except for minting/burning
- **Use Case:** Loyalty rewards and achievements

## 📚 Related Documentation

- [Security Audit Report](../docs/AUDIT_AND_APPRAISAL.md)
- [Deployment Guide](../docs/DEPLOYMENT.md)
- [API Integration](../docs/API.md)
- [Testing Guidelines](../docs/TESTING.md)

## 🤝 Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on:
- Code style and formatting
- Security considerations
- Testing requirements
- Pull request process