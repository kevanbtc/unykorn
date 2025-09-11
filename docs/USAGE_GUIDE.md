# Unykorn System Usage Guide

## 🚀 Quick Start

### For Developers

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Compile Contracts**
   ```bash
   npm run compile
   ```

3. **Run Tests**
   ```bash
   npm test
   ```

4. **Deploy System**
   ```bash
   npx hardhat run scripts/deploy-system.js --network localhost
   ```

### For Users

1. **Purchase Early Pack** ($25/$50/$100)
   - Connect wallet
   - Choose pack size
   - Get millions of tokens (locked 60-90 days)
   - Start earning commissions immediately

2. **Daily POC Check-ins**
   - Visit beacon locations (gas stations, gyms, shops)
   - Scan QR code or use NFC/SMS/IVR
   - Build streaks for rewards
   - One check-in per beacon per day

3. **Refer Others (POI)**
   - Introduce people to system
   - Permanent connection record
   - Earn when they transact
   - Build your network

4. **Use Commerce Layer**
   - Buy merchant offers
   - Automatic revenue splitting
   - Support your referrers
   - Enjoy token burns

## 🏗️ System Architecture

### Contract Addresses (After Deployment)
- **Main Token**: `[from deployment output]`
- **Asset Vault**: `[from deployment output]`
- **Revenue Vault**: `[from deployment output]`
- **POC Beacons**: `[from deployment output]`
- **Sales Force**: `[from deployment output]`
- **Governance**: `[from deployment output]`

### Key Functions

#### Token Contract
```javascript
// Daily check-in
await token.pocCheckin();

// Record introduction
await token.recordPoi(party1, party2, nonce);

// Use tokens for utility
await token.useForUtility(amount, "purpose");
```

#### Sales Force
```javascript
// Purchase early pack
await salesForce.purchaseEarlyPack(packId, referrer);

// Unlock vested tokens
await salesForce.unlockTokens();
```

#### Asset Vault
```javascript
// Deposit with lock
await assetVault.deposit(lockDays, { value: amount });

// Withdraw after lock period
await assetVault.withdraw(shares);
```

#### POC Beacons
```javascript
// Check in at beacon
await pocBeacons.recordCheckin(beaconId, "QR", lat, lon);
```

#### Revenue Vault
```javascript
// Create merchant offer
await revVault.createOffer(price, "description");

// Purchase offer
await revVault.purchase(offerId, referrer);
```

## 📊 Understanding the Economics

### Token Supply & Burns
- **Initial Supply**: 1 trillion tokens
- **Burn Rate**: 2-5% on utility usage
- **Deflationary**: Supply decreases over time
- **Result**: Stronger token value

### Commission Structure
- **Hustlers**: 50% on direct sales
- **Advocates**: 10% on direct sales
- **Team Override**: 2% to upline
- **Early Pack Locks**: 60-90 days vesting

### Vault Composition (Example)
Per $100 deposited:
- $40 → Stablecoins (floor + liquidity)
- $20 → Bitcoin (growth)
- $20 → Gold (hedge)
- $10 → ETH/L1s (tech)
- $10 → RWAs (real assets)

### Revenue Splitting (Per Purchase)
- 90-95% → Merchant
- Up to 50% → Direct referrer
- 3-5% → Team override
- 1-3% → POI bonus
- 1-2% → Territory pool
- 1-3% → Platform
- Variable% → Token burn

## 🎯 Best Practices

### For Brokers/Hustlers
1. **Recruit Quality**: Focus on engaged participants
2. **Support Team**: Help advocates succeed
3. **Use System**: Be active in POC/commerce
4. **Long-term View**: Build sustainable networks

### For Users
1. **Daily Engagement**: Consistent POC check-ins
2. **Network Building**: Introduce quality people
3. **Commerce Participation**: Support the ecosystem
4. **Hold Strong**: Benefit from deflationary mechanics

### For Merchants
1. **Quality Offers**: Provide real value
2. **Fair Pricing**: Attract customers
3. **System Support**: Use token for operations
4. **Community Building**: Engage with users

## 🔧 Technical Notes

### Gas Optimization
- Batch operations when possible
- Use approval patterns for tokens
- Consider layer 2 deployment for scale

### Security
- All contracts use OpenZeppelin libraries
- Multi-sig required for governance
- Time delays on critical functions
- Comprehensive access controls

### Upgradability
- UUPS proxy pattern for main token
- Governance-controlled upgrades
- Emergency pause capabilities
- Version tracking

## 🌍 Deployment Networks

### Testnet (Development)
- Lower gas costs
- Easy testing
- Reset capabilities
- Full functionality

### Mainnet (Production)
- Real value
- Permanent deployment
- Higher gas costs
- Security critical

## 📈 Monitoring & Analytics

### Key Metrics to Track
- Total supply (should decrease over time)
- Daily POC check-ins
- Revenue vault volume
- Asset vault performance
- Governance participation
- Network growth

### Dashboard Components
- Token burn tracker
- Vault composition
- Commission distributions
- POC/POI activity
- Sales force performance

## 🆘 Troubleshooting

### Common Issues
1. **Transaction Reverts**: Check permissions and balances
2. **Lock Periods**: Verify timing for withdrawals
3. **Gas Limits**: Increase for complex operations
4. **Role Management**: Ensure proper access controls

### Support Resources
- Contract documentation
- Test suite examples
- Deployment scripts
- Community forums

## 🔮 Future Enhancements

### Planned Features
- Mobile app integration
- Layer 2 deployment
- Cross-chain bridges
- Advanced analytics
- Automated rebalancing

### Community Requests
- Additional asset types
- Enhanced governance
- Mobile POC methods
- Territory features

This guide provides everything needed to understand and use the Unykorn system effectively. For technical support, refer to the contract documentation and test examples.