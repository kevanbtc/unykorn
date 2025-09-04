# Architecture

## Core Components

### Smart Contracts
```
contracts/evm/           - Enhanced EVM contracts
├── TokenERC20.sol      - Enhanced token with burn mechanics and pack sales
├── ProofOfContact.sol  - Daily check-in system with streaks and rewards
├── ProofOfIntroduction.sol - Introduction tracking and connector payments
├── MultiAssetVault.sol - Diversified vault for stablecoins, BTC, gold, ETH, RWAs
├── RevVault.sol        - Commerce layer with automatic revenue splitting
├── EnhancedAffiliateRouter.sol - Hierarchical commission system
├── UnykornGovernance.sol - DAO controls for system parameters
├── LiquidityHelper.sol - Liquidity bootstrapping and team allocation
└── MemePass721.sol     - NFT passes with optional soulbound mode

contracts/shared/        - Shared utilities
└── MerkleLib.sol       - Merkle tree verification for airdrops

Legacy contracts:
├── AffiliateRouter.sol - Basic affiliate system
├── AuditTrail.sol     - Transaction logging
├── NFTMarketplace.sol - NFT trading
├── NFTStaking.sol     - NFT reward staking
├── SubscriptionVault.sol - Monthly subscriptions
├── VCHAN.sol          - Governance token
├── VPOINT.sol         - Soulbound loyalty points
└── VTV.sol            - Utility token
```

### Applications
```
apps/        - Frontend, backend, indexer and scheduled agents
contracts/   - Smart contracts for EVM and Solana
cli/         - Command line tools for deployment and airdrops
infra/       - Docker-compose and CI stubs
samples/     - Example CSV files for airdrops and allocations
```

## System Architecture

### 1. **Token Layer**
- **Supply:** 1 trillion tokens (psychology - people hold "millions")
- **Burn Mechanics:** Configurable 2-5% burn on every transfer
- **Pack Sales:** Early buy-in tiers ($25/$50/$100) with token allocations and lockup periods
- **Lockup System:** 60-90 day lockup for early adopters to prevent dumping

### 2. **Wallet Layer**
- Auto-created wallets for participants (via token holdings)
- Entity tracking system:
  - Token balances and lockup status
  - POC streak records
  - POI connection history
  - Commission earnings and payouts

### 3. **Vault/Trust Layer (MultiAssetVault)**
- **Diversified Holdings:**
  - 40% Stablecoins (USDC/USDT)
  - 20% Bitcoin proxy tokens
  - 20% Tokenized Gold
  - 10% ETH/L1 tokens
  - 10% RWAs (real estate, commodities)
- **Leverage:** Up to 80% LTV for collateralized borrowing
- **Proof System:** VaultProof NFTs for physical asset verification

### 4. **Commerce Layer (RevVault)**
- Merchant marketplace for vouchers, memberships, services
- Automatic revenue splitting:
  - 90-95% to merchant
  - Up to 50% direct commission
  - 3-5% team override
  - 1-3% POI bonus
  - 1-2% territory pool
  - 1-3% platform fee
  - Remainder burned
- Non-custodial, transparent payments

### 5. **Participation Layer**
- **POC (Proof of Contact):** Daily check-ins via QR/NFC/SMS/IVR
  - Streak building with bonus rewards
  - Anti-abuse mechanisms (daily limits, geo-radius, device checks)
  - Beacon network at gas stations, gyms, shops
- **POI (Proof of Introduction):** Permanent connection records
  - Two-party confirmation required
  - Connector earnings on future transactions
  - Bidirectional connection registry

### 6. **Sales Force/Affiliate Layer**
- **Hierarchical Structure:**
  - Founding Brokers (60% commissions)
  - Hustlers (50% commission on pack sales, vested)
  - Advocates (10-12% on sales)
- **Team Overrides:** 5% override for uplines
- **Vesting:** 60-90 day lockup for Hustler earnings

### 7. **Governance Layer**
- DAO controls via token staking and voting
- Governance over:
  - Burn rates (max 5%)
  - Commission percentages
  - Vault allocation policies
  - Platform parameters
- Proposal system with quorum and passing thresholds

## Key Features

### Enhanced Token (TokenERC20)
- 1 trillion initial supply for psychological appeal
- Configurable burn rate (default 3%)
- Pack tier system for early sales
- User-specific lockup periods
- Upgradeable contract with role-based access

### Proof Systems
- **POC:** Daily engagement tracking with streak bonuses
- **POI:** Permanent relationship mapping with commission tracking
- Anti-gaming measures and cooldown periods

### Revenue Distribution
- Automatic splitting across multiple stakeholders
- Transparent, on-chain commission tracking
- Immediate merchant payouts (90-95%)
- Deferred and vested affiliate rewards

### Multi-Asset Backing
- Diversified treasury for stability
- Leverage capabilities for growth
- Physical asset verification via NFTs
- Rebalancing mechanisms

## Launch Strategy

### Phase 1: Seed (Early Packs)
- Recruit 10-20 founding brokers
- Each brings 10 buyers ($25-$100 packs)
- 60-90 day token lockup
- Initial liquidity pool seeding

### Phase 2: Activation (POC Network)
- Deploy QR codes at 20+ locations
- Hustler recruitment and 100x100 blitz
- POC streak system activation
- POI relationship tracking

### Phase 3: Expansion (Commerce)
- Merchant onboarding for offers
- Territory pool activation
- Multi-city expansion
- Enhanced features rollout

### Phase 4: Institutionalization
- RWA diversification (gold, property, water rights)
- Yield-bearing asset allocation
- Governance system activation
- "Vault Constitution" publication

The repository structure supports this comprehensive system with modular, upgradeable smart contracts and a complete testing suite.
