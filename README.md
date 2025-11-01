# Unykorn - Cross-Chain Token Launch Factory

This repository contains smart contracts for an NFT marketplace, staking functionality, and the **FTH (Future Tech Holdings) Sovereign Settlement Infrastructure** - a fully-compliant, closed-loop XRPL-native RWA-backed token system with private ledger DEX.

## Table of Contents

- [Legacy Contracts](#legacy-contracts)
- [FTH Sovereign Settlement Infrastructure](#fth-sovereign-settlement-infrastructure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Security & Audit](#security--audit)

## Legacy Contracts

- `NFTMarketplace.sol` – list and purchase ERC‑721 tokens with a marketplace fee.
- `NFTStaking.sol` – stake NFTs to earn ETH rewards over time.
- `VTV.sol` – basic ERC‑20 utility token.
- `VCHAN.sol` – governance token.
- `VPOINT.sol` – soulbound loyalty points that cannot be transferred.
- `SubscriptionVault.sol` – basic monthly subscription contract using an ERC‑20 token.
- `AffiliateRouter.sol` – records and pays out referral commissions.

## FTH Sovereign Settlement Infrastructure

The FTH infrastructure implements a comprehensive gold-backed token ecosystem with:

### Core Components

**Tokens:**
- **USDF** (`contracts/fth/USDFToken.sol`) - USD-pegged stablecoin with whitelist enforcement
- **FTHG** (`contracts/fth/FTHGToken.sol`) - Gold-backed token (1 FTHG = 1 troy oz)
- **FTH Governance** (`contracts/fth/FTHGovernanceToken.sol`) - Protocol governance token

**Infrastructure:**
- **Multi-Sig Treasury** (`contracts/fth/FTHTreasury.sol`) - 3-of-5 multi-signature with 48-hour timelock
- **Private DEX** (`contracts/fth/FTHPrivateDEX.sol`) - AMM with 10% holder discounts
- **Vault Proof NFT** (`contracts/fth/VaultProofNFT.sol`) - Cryptographic gold custody proofs
- **Escrow System** (`contracts/fth/FTHEscrow.sol`) - Secure redemption settlements

### Key Features

✅ **Compliance-First Design**
- KYC/AML whitelist enforcement
- Multi-signature governance
- Pausable for regulatory compliance
- Complete audit trail

✅ **Proof-of-Reserve**
- Daily audits with VaultProofNFT
- IPFS custody documentation
- Chainlink PoR integration ready
- Independent auditor verification

✅ **Trading Benefits**
- 10% discount for qualified holders
- 0.25% base trading fee
- Automated AMM trading pairs
- USDF/FTHG, USDF/XRP, FTHG/XRP

✅ **Security**
- UUPS upgradeable pattern
- Role-based access control
- 48-hour timelock on critical operations
- Emergency pause mechanism

### Documentation

- 📖 [FTH Infrastructure Guide](docs/FTH_INFRASTRUCTURE.md)
- 📋 [Compliance Framework](docs/FTH_COMPLIANCE.md)
- 🔒 [Security Audit](docs/AUDIT_AND_APPRAISAL.md)

### Quick Start (FTH)

```bash
# Compile all contracts
npx hardhat compile

# Run FTH infrastructure tests
npx hardhat test test/FTHInfrastructure.test.js

# Deploy FTH infrastructure
npx hardhat run scripts/deploy-fth.js --network <network>
```

## Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Compile contracts:
   ```bash
   npx hardhat compile
   ```

3. Run tests:
   ```bash
   npx hardhat test
   ```

## Testing

### Run All Tests
```bash
npx hardhat test
```

### Run Specific Test Suites
```bash
# Legacy contracts
npx hardhat test test/TokenERC20.test.js

# FTH infrastructure
npx hardhat test test/FTHInfrastructure.test.js
```

### Coverage
```bash
npx hardhat coverage
```

## Deployment

### Environment Setup

Copy `.env.template` to `.env` and configure:

```env
# Network RPC URLs
ETHEREUM_RPC_URL=
POLYGON_RPC_URL=
ARBITRUM_RPC_URL=

# Deployer private key
PRIVATE_KEY=

# FTH Role Addresses (Multi-sig recommended)
CEO_ADDRESS=
CFO_ADDRESS=
CUSTODIAN_ADDRESS=
AUDITOR_ADDRESS=
COMPLIANCE_ADDRESS=
```

### Deploy Legacy Contracts
```bash
npx hardhat run scripts/deploy.js --network yourNetwork
```

### Deploy FTH Infrastructure
```bash
npx hardhat run scripts/deploy-fth.js --network yourNetwork
```

This will deploy:
1. Multi-Sig Treasury (3-of-5)
2. USDF Stablecoin
3. FTHG Gold Token
4. FTH Governance Token
5. Private DEX
6. Vault Proof NFT System
7. Escrow Contract

Deployment addresses will be saved to `deployments-<network>.json`.

## Security & Audit

### Audits & Reviews

- [Audit and Appraisal Report](docs/AUDIT_AND_APPRAISAL.md)
- [FTH Compliance Framework](docs/FTH_COMPLIANCE.md)

### Security Features

- **Upgradeable Contracts**: UUPS proxy pattern for safe upgrades
- **Access Control**: Role-based permissions with multi-sig requirements
- **Timelock**: 48-hour delay on critical treasury operations
- **Pausable**: Emergency stop mechanism on all tokens
- **Whitelist**: KYC-enforced transfer restrictions
- **Audit Trail**: Complete on-chain event logging

### Best Practices

- All contracts use OpenZeppelin libraries
- Comprehensive test coverage
- Gas optimization enabled
- Strict compiler warnings
- Reentrancy guards on financial operations

## Architecture

```
unykorn/
├── contracts/
│   ├── fth/                    # FTH Infrastructure
│   │   ├── USDFToken.sol
│   │   ├── FTHGToken.sol
│   │   ├── FTHGovernanceToken.sol
│   │   ├── FTHPrivateDEX.sol
│   │   ├── FTHTreasury.sol
│   │   ├── VaultProofNFT.sol
│   │   └── FTHEscrow.sol
│   ├── evm/                    # EVM contracts
│   ├── solana/                 # Solana programs
│   └── *.sol                   # Legacy contracts
├── test/
│   ├── FTHInfrastructure.test.js
│   └── TokenERC20.test.js
├── scripts/
│   ├── deploy-fth.js           # FTH deployment
│   └── deploy.js               # Legacy deployment
└── docs/
    ├── FTH_INFRASTRUCTURE.md   # FTH architecture guide
    ├── FTH_COMPLIANCE.md       # Compliance framework
    └── AUDIT_AND_APPRAISAL.md  # Security audit
```

## Roadmap

### Phase 1: Core Infrastructure ✅
- [x] USDF stablecoin
- [x] FTHG gold token  
- [x] Multi-sig treasury
- [x] Private DEX with discounts
- [x] Vault proof system
- [x] Escrow for redemptions

### Phase 2: Integration (Q1 2025)
- [ ] Chainlink PoR integration
- [ ] KYC provider API
- [ ] IPFS custody system
- [ ] Client portal frontend
- [ ] Mobile wallet support

### Phase 3: Advanced Features (Q2 2025)
- [ ] Staking and yield
- [ ] Cross-chain bridge (XRPL ↔ EVM)
- [ ] Advanced trading (limit orders)
- [ ] Regulatory reporting automation
- [ ] White-label compliance SaaS

## License

MIT

## Support

- **Technical Issues**: [GitHub Issues](https://github.com/kevanbtc/unykorn/issues)
- **FTH Business**: contact@futuretechholdings.com
- **Compliance**: compliance@futuretechholdings.com
