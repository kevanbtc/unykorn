# Unykorn System Architecture

## Overview

The Unykorn system implements a comprehensive Web3 ecosystem with multiple interconnected layers as specified in the blueprint. This document outlines the complete architecture and how each component works together.

## 🏗️ System Components

### 1. Token Layer (`TokenERC20.sol`)

**Enhanced Features:**
- **Supply**: 1 trillion tokens (1,000,000,000,000 * 1e18)
- **Burn Mechanics**: 2-5% configurable burn rate on utility usage
- **Utility Functions**:
  - Daily POC (Proof of Contact) check-ins with streak tracking
  - POI (Proof of Introduction) permanent records
  - Token utility consumption with automatic burns
  - Commission earning tracking

**Key Functions:**
```solidity
function pocCheckin() external // Daily check-in with streak tracking
function recordPoi(address party1, address party2, bytes32 nonce) external // Record introductions
function useForUtility(uint256 amount, string purpose) external // Utility usage with burn
function setBurnRate(uint256 newRate) external // Configurable burn rate (governance)
```

### 2. Asset Vault Layer (`AssetVault.sol`)

**Multi-Asset Management:**
- **Deposit System**: ETH deposits with optional lock periods (60-90 days for early adopters)
- **Share-Based**: Proportional ownership through share system
- **Asset Allocation**: Configurable target percentages for different asset classes
- **Leverage Capability**: Up to 80% LTV ratio for collateralized borrowing

**Composition Example** (per $100):
- $40 Stablecoins (floor + liquidity)
- $20 Bitcoin (growth anchor)
- $20 Tokenized Gold (hedge/physical)
- $10 ETH/L1s (tech upside)
- $10 RWAs (real estate, water, carbon)

**Key Functions:**
```solidity
function deposit(uint256 lockDays) external payable // Deposit with optional lock
function setAssetAllocation(address asset, uint256 targetPercentage) external // Configure allocations
function useLeverage(uint256 collateralValue, uint256 borrowAmount) external // Leverage functionality
```

### 3. Commerce Layer (`RevVault.sol`)

**Revenue Sharing System:**
- **Merchant Offers**: Create vouchers, memberships, services
- **Auto-Splitting**: Automatic revenue distribution on every purchase
- **Commission Structure**:
  - Merchant: 90-95%
  - Direct Commission: up to 50%
  - Team Override: 3-5%
  - POI Bonus: 1-3%
  - Territory Pool: 1-2%
  - Platform Fee: 1-3%
  - Burn Percentage: configurable

**Key Functions:**
```solidity
function createOffer(uint256 price, string description) external // Merchant creates offers
function purchase(uint256 offerId, address referrer) external // Customer purchases with referral
function updateCommissionStructure(...) external // Governance configurable
```

### 4. Participation Layer (`POCBeacons.sol`)

**Proof of Contact System:**
- **Beacon Network**: GPS-based check-in locations (gas stations, gyms, shops)
- **Multiple Methods**: QR codes, NFC, SMS, IVR support
- **Anti-Abuse**: Daily limits, cooldowns, geo-radius validation
- **Engagement**: Streak tracking, location-based rewards

**Key Functions:**
```solidity
function createBeacon(string location, int256 lat, int256 lon, uint256 radius, address owner) external
function recordCheckin(uint256 beaconId, string method, int256 userLat, int256 userLon) external
function emergencyCheckin(address user, uint256 beaconId, string method) external // SMS/IVR
```

### 5. Sales Force Layer (`SalesForceManager.sol`)

**Hierarchical Structure:**
- **Founding Brokers**: Bring 10 people each, get special status
- **Hustlers**: 50% token commissions on early packs (vested)
- **Advocates**: 10-12% commissions, recruited by hustlers
- **Early Packs**: $25/$50/$100 with token allocations and lock periods

**Commission Structure:**
- Hustlers: 50% commission on direct sales
- Advocates: 10% commission
- Team Override: 2% for hustler's upline

**Key Functions:**
```solidity
function purchaseEarlyPack(uint256 packId, address referrer) external // Buy early packs
function addFoundingBroker(address broker) external // Admin adds brokers
function promoteToHustler(address advocate) external // Performance-based promotion
function unlockTokens() external // Release vested tokens
```

### 6. Governance Layer (`UnykornGovernance.sol`)

**DAO Governance:**
- **Proposal Types**: Burn rate, commission structure, vault allocation, general
- **Voting Mechanism**: Token-weighted voting with quorum requirements
- **Multi-Sig Execution**: Required signatures for proposal execution
- **Time Delays**: 7-day voting period + 2-day execution delay

**Governance Controls:**
- Burn percentage (2-5%)
- Commission percentages
- Vault allocation policies
- Platform parameters

**Key Functions:**
```solidity
function propose(ProposalType, string description, bytes callData) external // Create proposals
function vote(uint256 proposalId, bool support) external // Vote on proposals
function executeProposal(uint256 proposalId) external // Execute after voting + delay
```

## 🔗 System Integration

### User Journey Example:

1. **Entry**: User purchases $25 early pack through hustler referral
   - Gets 1M tokens (locked 60 days)
   - Hustler earns 50% commission
   - Establishes referral relationship

2. **Participation**: User does daily POC check-ins
   - Scans QR at gas station
   - Builds streak counter
   - Earns engagement rewards

3. **Commerce**: User purchases merchant offers
   - Buys coffee voucher for $50
   - Revenue auto-splits to all participants
   - POI connections get bonuses

4. **Vault**: User deposits to asset vault
   - $100 deposit gets diversified
   - Earns proportional share
   - Can be used as collateral

### Inter-Contract Communication:

```
TokenERC20 ←→ All Contracts (permissions & utility)
    ↓
RevVault → SalesForceManager (commission tracking)
    ↓
POCBeacons → TokenERC20 (check-in integration)
    ↓
Governance → All Contracts (parameter control)
    ↓
AssetVault ← Users (deposits & withdrawals)
```

## 🌍 Launch Strategy

### Phase 1: Seed (Current Implementation)
- [x] Core contracts deployed
- [x] 10-20 founding brokers recruitment
- [x] Early pack system ($25-$100)
- [x] Token lock mechanism (60-90 days)

### Phase 2: Activation
- [ ] Beacon network deployment (20+ locations)
- [ ] Hustler 100×100 blitz campaign
- [ ] POC streak system activation
- [ ] RevVault merchant onboarding

### Phase 3: Expansion
- [ ] Multi-city deployment
- [ ] Territory pool activation
- [ ] Advanced commerce features
- [ ] Mobile app integration

### Phase 4: Institutionalization
- [ ] RWA diversification (gold, real estate)
- [ ] Yield-bearing allocations
- [ ] Vault Constitution codification
- [ ] Regulatory compliance framework

## 🔧 Technical Implementation

### Smart Contract Architecture:
- **Upgradeable**: UUPS proxy pattern for main contracts
- **Modular**: Separate concerns across contracts
- **Secure**: OpenZeppelin libraries, access controls, reentrancy guards
- **Gas Optimized**: Efficient storage patterns, batch operations

### Integration Points:
- **Token Utility**: Central permission system
- **Revenue Flows**: Automatic distribution mechanisms
- **Governance**: Parameter control across all contracts
- **State Consistency**: Event-driven updates

### Deployment Considerations:
1. Deploy TokenERC20 with proxy
2. Deploy support contracts (AssetVault, RevVault, etc.)
3. Grant appropriate roles and permissions
4. Initialize governance with multi-sig
5. Bootstrap initial liquidity and early packs

## 📊 Key Metrics & KPIs

### Token Economics:
- Total Supply: 1 trillion (deflationary through burns)
- Burn Rate: 2-5% on utility usage
- Distribution: Early packs → Vesting → Circulation

### Participation Metrics:
- Daily POC check-ins
- POI connection network growth
- Streak leaderboards
- Geographic coverage

### Revenue Metrics:
- Merchant offer volume
- Commission distribution
- Vault performance
- Platform fees collected

### Growth Metrics:
- Sales force expansion
- Territory pool performance
- Asset diversification
- Governance participation

This architecture provides a complete foundation for the Unykorn ecosystem as specified in the original blueprint, with all major components implemented and tested.