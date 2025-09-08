# ⚙️ EVM Command Line Tools

[![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow.svg)](https://hardhat.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-Ready-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Status](https://img.shields.io/badge/Status-In%20Development-yellow)](../../README.md)

## 📖 Overview

EVM CLI tools provide command-line utilities for deploying, managing, and interacting with Ethereum Virtual Machine compatible smart contracts across multiple networks.

## 🎯 Purpose

- **Contract Deployment** - Automated deployment scripts for all networks
- **Network Management** - Multi-chain configuration and switching
- **Batch Operations** - Efficient batch processing for airdrops and transfers
- **Contract Interaction** - Direct smart contract method calls
- **Verification** - Automated contract verification on block explorers

## 🛠️ Technology Stack

- **Framework:** Hardhat with TypeScript
- **Networks:** Ethereum, Polygon, BSC, Arbitrum, Optimism
- **Deployment:** Hardhat Deploy plugin
- **Verification:** Etherscan integration
- **Gas Optimization:** Multicall batching

## 📁 Structure

```
cli/evm/
├── scripts/              # Deployment and utility scripts
│   ├── deploy/           # Contract deployment scripts
│   ├── verify/           # Contract verification scripts
│   ├── airdrop/          # Airdrop management scripts
│   └── utils/            # General utility scripts
├── tasks/                # Custom Hardhat tasks
├── config/               # Network configurations
├── deployments/          # Deployment artifacts per network
└── templates/            # Contract and script templates
```

## 🚀 Available Commands

### Deployment Commands
```bash
# Deploy all contracts to a network
npx hardhat deploy --network mainnet

# Deploy specific contract
npx hardhat deploy --tags NFTMarketplace --network polygon

# Verify deployed contracts
npx hardhat verify --network mainnet <CONTRACT_ADDRESS>
```

### Airdrop Commands
```bash
# Process airdrop from CSV file
npx hardhat airdrop:process --file ./samples/airdrop.csv --network polygon

# Check airdrop eligibility
npx hardhat airdrop:check --address 0x123... --network mainnet

# Generate merkle tree for airdrop
npx hardhat airdrop:merkle --file ./samples/eligibility.csv
```

### Utility Commands
```bash
# Get contract information
npx hardhat contract:info --address 0x123... --network mainnet

# Batch transfer tokens
npx hardhat token:batch-transfer --file ./samples/transfers.csv --network polygon

# Check gas prices across networks
npx hardhat gas:prices
```

## 🌐 Supported Networks

### Mainnet Networks
- **Ethereum** - Mainnet with full feature support
- **Polygon** - Low-cost transactions with MATIC
- **BSC** - Binance Smart Chain compatibility
- **Arbitrum** - Layer 2 scaling solution
- **Optimism** - Optimistic rollup network

### Testnet Networks
- **Goerli** - Ethereum testnet
- **Mumbai** - Polygon testnet
- **BSC Testnet** - Binance Smart Chain testnet
- **Arbitrum Goerli** - Arbitrum testnet
- **Optimism Goerli** - Optimism testnet

## 🔧 Configuration

### Network Setup
```typescript
// hardhat.config.ts
const config: HardhatUserConfig = {
  networks: {
    mainnet: {
      url: process.env.ETHEREUM_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      gasPrice: 'auto',
      gasMultiplier: 1.2
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY],
      gasPrice: 'auto'
    }
  }
};
```

### Environment Variables
```bash
# Network RPC URLs
ETHEREUM_RPC_URL=https://eth-mainnet.alchemyapi.io/v2/your-key
POLYGON_RPC_URL=https://polygon-mainnet.alchemyapi.io/v2/your-key
BSC_RPC_URL=https://bsc-dataseed.binance.org/

# Deployer Configuration
DEPLOYER_PRIVATE_KEY=your-private-key
DEPLOYER_ADDRESS=your-deployer-address

# API Keys for Verification
ETHERSCAN_API_KEY=your-etherscan-key
POLYGONSCAN_API_KEY=your-polygonscan-key
BSCSCAN_API_KEY=your-bscscan-key
```

## 📊 Deployment Strategy

### Contract Deployment Order
1. **Base Tokens** - VTV, VCHAN, VPOINT
2. **Core Contracts** - NFTMarketplace, NFTStaking
3. **Utility Contracts** - SubscriptionVault, AffiliateRouter
4. **Helper Contracts** - LiquidityHelper, TokenERC20

### Gas Optimization
```typescript
// Deployment with gas optimization
const deploymentTx = await deploy('NFTMarketplace', {
  from: deployer,
  args: [feeRecipient, marketplaceFee],
  gasLimit: 2000000,
  gasPrice: utils.parseUnits('20', 'gwei')
});
```

## 🔍 Contract Verification

### Automatic Verification
```bash
# Verify all contracts after deployment
npx hardhat deploy --network mainnet --verify

# Verify specific contract with constructor args
npx hardhat verify --network mainnet 0x123... "arg1" "arg2"
```

### Manual Verification
```bash
# Generate verification script
npx hardhat verification:generate --network mainnet

# Submit to multiple explorers
npx hardhat verify:multi --network polygon --contract NFTMarketplace
```

## 🔄 Batch Operations

### Airdrop Processing
```typescript
// Process large airdrop efficiently
async function processAirdrop(recipients: AirdropRecipient[]) {
  const batchSize = 100;
  const batches = chunk(recipients, batchSize);
  
  for (const batch of batches) {
    await multicall.aggregate(
      batch.map(r => token.interface.encodeFunctionData('transfer', [r.address, r.amount]))
    );
  }
}
```

### Multi-Network Deployment
```bash
# Deploy to multiple networks simultaneously
npx hardhat deploy:multi --networks mainnet,polygon,bsc --tags core
```

## 🧪 Testing & Validation

### Pre-Deployment Testing
```bash
# Run full test suite
npx hardhat test

# Gas usage analysis
npx hardhat test --gas-reporter

# Coverage analysis
npx hardhat coverage
```

### Post-Deployment Validation
```bash
# Validate deployment state
npx hardhat validate:deployment --network mainnet

# Check contract ownership
npx hardhat check:ownership --network polygon
```

## 📚 Related Documentation

- [Smart Contracts](../../contracts/README.md)
- [Solana CLI Tools](../solana/README.md)
- [Deployment Guide](../../docs/DEPLOYMENT.md)
