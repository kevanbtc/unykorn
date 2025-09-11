# Unykorn Build Guide

This document explains the complete build process for the Unykorn project, a cross-chain token launch factory with smart contracts for both EVM and Solana blockchains.

## Overview

Unykorn is a multi-component project with the following architecture:

```
unykorn/
├── contracts/          # Smart contracts (EVM & Solana)
├── apps/              # Frontend, backend, indexer, agents
├── cli/               # Command-line tools
├── scripts/           # Deployment scripts
├── test/              # Test files
├── infra/             # Docker infrastructure
└── docs/              # Documentation
```

## Prerequisites

### Required Tools
- **Node.js** 18+ and **npm**
- **pnpm** (for workspace management)
- **Rust & Cargo** (for Solana contracts)
- **Docker** (for infrastructure)

### Installation
```bash
# Install Node.js dependencies
npm install

# For Solana development (optional)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Build Components

### 1. EVM Smart Contracts (Primary)

The main build system uses **Hardhat** to compile Solidity smart contracts.

#### Configuration
- **Config file**: `hardhat.config.cjs`
- **Solidity version**: 0.8.24 (pinned)
- **Optimizer**: Enabled with 200 runs
- **Local compiler**: Forces use of local solc to avoid network fetches

#### Available Commands
```bash
# Clean build artifacts
npm run clean

# Compile all Solidity contracts
npm run compile

# Run tests in parallel
npm run test

# Generate test coverage report
npm run coverage
```

#### Build Process Details
1. **Cleaning**: Removes `cache/` and `artifacts/` directories
2. **Compilation**: 
   - Compiles all `.sol` files in `contracts/` directory
   - Uses local solc compiler from `node_modules/solc/soljson.js`
   - Generates ABIs and bytecode in `artifacts/` directory
   - Creates compilation cache in `cache/` directory
3. **Testing**: Runs Mocha tests with 120-second timeout

#### Contract Structure
```
contracts/
├── NFTMarketplace.sol     # NFT trading with marketplace fees
├── NFTStaking.sol         # NFT staking for ETH rewards
├── VTV.sol               # ERC-20 utility token
├── VCHAN.sol             # Governance token
├── VPOINT.sol            # Soulbound loyalty points
├── SubscriptionVault.sol # Monthly subscription contract
├── AffiliateRouter.sol   # Referral commission system
├── evm/                  # Advanced EVM contracts
│   ├── TokenERC20.sol    # Launch-locked ERC-20
│   ├── LiquidityHelper.sol # Liquidity bootstrapping
│   └── MemePass721.sol   # NFT membership passes
└── shared/               # Shared libraries
    └── MerkleLib.sol     # Merkle tree utilities
```

### 2. Solana Smart Contracts

Solana contracts are written in Rust and use Cargo for building.

#### Location
- **Directory**: `contracts/solana/`
- **Workspace**: Defined in `contracts/solana/Cargo.toml`

#### Programs
- **meme_token**: Token program for Solana
- **airdrop_dist**: Airdrop distribution program

#### Build Commands
```bash
cd contracts/solana

# Build all programs
cargo build-bpf

# Run tests
cargo test

# Deploy (requires Solana CLI)
solana program deploy target/deploy/program.so
```

### 3. Applications & Services

The project includes several Node.js applications (currently placeholders):

#### Components
- **Frontend**: Next.js 14 application
- **Backend**: Node.js/Express API server
- **Indexer**: Blockchain event indexer
- **Agents**: Scheduled workers and automation

#### Docker Infrastructure
```bash
# Start all services
cd infra/docker
docker-compose up

# Services available:
# - Backend: http://localhost:3000
# - PostgreSQL: localhost:5432
# - Redis: localhost:6379
```

## Development Workflow

### Quick Start
```bash
# 1. Install dependencies
npm install

# 2. Compile contracts
npm run compile

# 3. Run tests
npm run test

# 4. Deploy locally (optional)
npx hardhat run scripts/deploy.js --network localhost
```

### Development Loop
1. **Edit contracts** in `contracts/` directory
2. **Compile** with `npm run compile`
3. **Test** changes with `npm run test`
4. **Deploy** with deployment scripts in `scripts/`

### Environment Setup
1. Copy `.env.template` to `.env`
2. Fill in required values:
   - RPC URLs for target networks
   - Deployer private keys
   - API keys and secrets

## Testing

### Test Structure
- **Location**: `test/` directory
- **Framework**: Mocha with Chai assertions
- **Network**: Hardhat local network
- **Parallel execution**: Enabled for faster testing

### Current Tests
- `TokenERC20.test.js`: Tests ERC-20 token functionality including launch locks

### Running Tests
```bash
# All tests
npm run test

# Specific test file
npx hardhat test test/TokenERC20.test.js

# With gas reporting (disabled in parallel mode)
npx hardhat test

# Coverage report
npm run coverage
```

## Build Outputs

### Compiled Artifacts
- **Location**: `artifacts/contracts/`
- **Contents**: 
  - Contract ABIs (JSON)
  - Bytecode
  - Debug information
  - Source maps

### Cache Files
- **Location**: `cache/`
- **Purpose**: Speed up incremental compilation
- **Note**: Safe to delete; will be regenerated

## Deployment

### Local Development
```bash
# Start Hardhat local node
npx hardhat node

# Deploy to local network
npx hardhat run scripts/deploy.js --network localhost
```

### Testnet/Mainnet
```bash
# Deploy to specific network
npx hardhat run scripts/deploy.js --network <network-name>

# Available networks configured in hardhat.config.cjs
```

## Troubleshooting

### Common Issues

#### Compilation Errors
- **SPDX License warnings**: Add license identifiers to contract files
- **Solidity version mismatch**: Ensure contracts use `pragma solidity ^0.8.24`
- **Import errors**: Check OpenZeppelin dependency versions

#### Test Failures
- **Timeout errors**: Increase timeout in hardhat.config.cjs (currently 120s)
- **Network issues**: Restart Hardhat network
- **Gas errors**: Check gas limits and ETH balances

#### Build Performance
- **Slow compilation**: Use `npm run clean` to clear cache if builds are inconsistent
- **Memory issues**: Increase Node.js heap size: `NODE_OPTIONS=--max-old-space-size=4096`

### Debug Commands
```bash
# Check Hardhat configuration
npx hardhat config

# List available tasks
npx hardhat help

# Compile with verbose output
npx hardhat compile --verbose

# Run specific test with debug output
DEBUG=* npm run test
```

## Advanced Configuration

### Hardhat Custom Tasks
The build system includes custom Hardhat configuration:
- **Forced local compiler**: Prevents network fetching of Solidity compilers
- **Optimized compilation**: Optimizer enabled for production efficiency
- **Parallel testing**: Speeds up test execution

### Workspace Management
The project uses pnpm workspace for managing multiple packages:
- **Root workspace**: Main contracts and build configuration
- **Sub-packages**: Apps, CLI tools, documentation

### Security Considerations
- **Compiler pinning**: Solidity version 0.8.24 is locked for reproducible builds
- **Dependency audits**: Run `npm audit` regularly
- **Static analysis**: Consider integrating Slither for security analysis

## CI/CD Integration

### Recommended Pipeline
1. **Install dependencies**: `npm install`
2. **Compile contracts**: `npm run compile`
3. **Run tests**: `npm run test`
4. **Generate coverage**: `npm run coverage`
5. **Security audit**: `npm audit`
6. **Deploy**: Use deployment scripts for target networks

### Docker Integration
Use the provided Docker Compose setup for consistent environments:
```bash
cd infra/docker
docker-compose up --build
```

## Resources

- **Hardhat Documentation**: https://hardhat.org/docs
- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts
- **Solana Program Development**: https://docs.solana.com/developing/on-chain-programs
- **Project Architecture**: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- **Security Guidelines**: [docs/SECURITY.md](docs/SECURITY.md)
- **Operations Runbook**: [docs/RUNBOOK.md](docs/RUNBOOK.md)