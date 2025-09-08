# 🦄 Unykorn - Cross-Chain Token Launch Factory

[![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)](https://opensource.org/licenses/ISC)
[![Hardhat](https://img.shields.io/badge/Built%20with-Hardhat-yellow.svg)](https://hardhat.org/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.24-363636?logo=solidity)](https://soliditylang.org/)
[![OpenZeppelin](https://img.shields.io/badge/OpenZeppelin-5.4.0-4E5EE4?logo=openzeppelin)](https://openzeppelin.com/)

A comprehensive monorepo providing scaffolding for launching cross-chain tokens on EVM and Solana with advanced airdrop, marketing, and DeFi tooling.

## 📖 Table of Contents

- [🏗️ Architecture Overview](#️-architecture-overview)
- [📁 Repository Structure](#-repository-structure)
- [🚀 Quick Start](#-quick-start)
- [💼 Smart Contracts](#-smart-contracts)
- [🛠️ Development](#️-development)
- [📱 Applications](#-applications)
- [⚙️ CLI Tools](#️-cli-tools)
- [📚 Documentation](#-documentation)
- [🔒 Security & Audit](#-security--audit)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

## 🏗️ Architecture Overview

Unykorn is designed as a modular ecosystem for token launches and community building:

```
┌─────────────────┬─────────────────┬─────────────────┐
│   Frontend      │    Backend      │    Indexer      │
│   (Next.js)     │  (Node/Express) │   (Postgres)    │
└─────────────────┴─────────────────┴─────────────────┘
           │                 │                 │
           └─────────────────┼─────────────────┘
                             │
    ┌────────────────────────┼────────────────────────┐
    │                       │                        │
┌───▼───┐              ┌────▼────┐              ┌────▼────┐
│  EVM  │              │  Solana │              │   CLI   │
│Contracts│            │Contracts│              │  Tools  │
└───────┘              └─────────┘              └─────────┘
```

For detailed architecture information, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## 📁 Repository Structure

```
unykorn/
├── 📱 apps/                    # Frontend applications and services
│   ├── frontend/               # Next.js marketing and claim interface
│   ├── backend/                # API server for metadata and proofs
│   ├── indexer/                # Blockchain event indexer
│   └── agents/                 # Scheduled tasks and automation
├── 📜 contracts/               # Smart contracts
│   ├── *.sol                   # Core EVM contracts
│   ├── evm/                    # Additional EVM utilities
│   ├── solana/                 # Solana program source
│   └── shared/                 # Cross-chain libraries
├── ⚙️ cli/                     # Command line tools
│   ├── evm/                    # EVM deployment and management
│   └── solana/                 # Solana program utilities
├── 📚 docs/                    # Comprehensive documentation
├── 🐳 infra/                   # Infrastructure and deployment
├── 📊 samples/                 # Example CSV files and templates
├── 🧪 scripts/                 # Deployment and utility scripts
└── 🧪 test/                    # Test suites
```

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm
- Git

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/kevanbtc/unykorn.git
   cd unykorn
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment:**
   ```bash
   cp .env.template .env
   # Edit .env with your configuration
   ```

4. **Compile contracts:**
   ```bash
   npm run compile
   ```

5. **Run tests:**
   ```bash
   npm run test
   ```

## 💼 Smart Contracts

### Core Contracts

| Contract | Description | Purpose |
|----------|-------------|---------|
| **NFTMarketplace.sol** | 🛒 NFT trading platform | List and purchase ERC-721 tokens with marketplace fees |
| **NFTStaking.sol** | 🥩 Staking rewards system | Stake NFTs to earn ETH rewards over time |
| **VTV.sol** | 🪙 Utility token | Basic ERC-20 token for platform operations |
| **VCHAN.sol** | 🗳️ Governance token | DAO governance and voting mechanisms |
| **VPOINT.sol** | 🏆 Loyalty system | Soulbound points that cannot be transferred |
| **SubscriptionVault.sol** | 💳 Subscription service | Monthly recurring payments using ERC-20 tokens |
| **AffiliateRouter.sol** | 🤝 Referral system | Track and distribute referral commissions |

### Additional Utilities

- **evm/TokenERC20.sol** - Enhanced ERC-20 implementation
- **evm/MemePass721.sol** - NFT pass system for meme token launches
- **evm/LiquidityHelper.sol** - DEX liquidity management utilities
- **shared/MerkleLib.sol** - Cross-chain Merkle proof verification

For detailed contract documentation, see [docs/AUDIT_AND_APPRAISAL.md](docs/AUDIT_AND_APPRAISAL.md).

## 🛠️ Development

### Build System

```bash
# Clean build artifacts
npm run clean

# Compile contracts
npm run compile

# Run tests with parallel execution
npm run test

# Generate coverage report
npm run coverage
```

### Configuration

The project uses Hardhat with the following key configurations:
- **Solidity Version:** 0.8.24
- **Optimizer:** Enabled (200 runs)
- **Testing:** Parallel execution with 120s timeout
- **Upgrades:** OpenZeppelin upgradeable contracts support

Copy `.env.template` to `.env` and configure:
- RPC URLs for target networks
- Deployer private keys
- API keys for services

## 📱 Applications

### Frontend (`apps/frontend/`)
- **Technology:** Next.js 14
- **Purpose:** Marketing site and token claim interface
- **Status:** 🚧 In Development

### Backend (`apps/backend/`)
- **Technology:** Node.js/Express
- **Purpose:** API server for metadata, airdrop proofs, and influencer redirects
- **Status:** 🚧 In Development

### Indexer (`apps/indexer/`)
- **Technology:** PostgreSQL integration
- **Purpose:** Blockchain event indexing and data aggregation
- **Status:** 🚧 In Development

### Agents (`apps/agents/`)
- **Technology:** Scheduled task automation
- **Purpose:** Background jobs, monitoring, and maintenance
- **Status:** 🚧 In Development

## ⚙️ CLI Tools

### EVM Tools (`cli/evm/`)
- Contract deployment automation
- Network configuration management
- Batch operations for airdrops

### Solana Tools (`cli/solana/`)
- Program deployment utilities
- SPL token management
- Cross-chain bridge operations

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture and component overview |
| [AUDIT_AND_APPRAISAL.md](docs/AUDIT_AND_APPRAISAL.md) | Security audit findings and recommendations |
| [SECURITY.md](docs/SECURITY.md) | Security best practices and guidelines |
| [RUNBOOK.md](docs/RUNBOOK.md) | Operational procedures and monitoring |
| [COMPLIANCE.md](docs/COMPLIANCE.md) | Regulatory compliance features |
| [TOKENOMICS.md](docs/TOKENOMICS.md) | Token distribution and economics |
| [MARKETING.md](docs/MARKETING.md) | Marketing strategy and materials |

## 🔒 Security & Audit

This project prioritizes security through:

- **🛡️ OpenZeppelin Contracts** - Battle-tested, secure smart contract libraries
- **🔍 Comprehensive Testing** - Extensive test coverage with parallel execution
- **📋 Security Audits** - Regular security assessments and code reviews
- **⚡ Static Analysis** - Automated vulnerability scanning
- **🔐 Upgradeable Patterns** - UUPS proxy pattern for secure upgrades

**Current Security Rating:** B (Moderate Risk)

See the complete [Audit and Appraisal Report](docs/AUDIT_AND_APPRAISAL.md) for detailed security findings, compliance guidance, and value assessment.

## 🤝 Contributing

We welcome contributions! Please see our [contribution guidelines](CONTRIBUTING.md) for details on:

- Code style and standards
- Pull request process
- Issue reporting
- Development workflow

## 📄 License

This project is licensed under the ISC License. See the [LICENSE](LICENSE) file for details.
