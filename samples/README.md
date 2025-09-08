# 📊 Sample Data Files

[![Status](https://img.shields.io/badge/Status-Reference%20Examples-yellow)](../README.md)

## 📖 Overview

This directory contains example CSV files and templates for various operations within the Unykorn ecosystem. These files serve as references for data formats and can be used for testing and development.

## 📁 File Structure

```
samples/
├── README.md               # This documentation file
├── airdrop.csv            # Airdrop recipient data format
├── allocations.csv        # Token allocation examples
├── influencers.csv        # Influencer/referral tracking
├── templates/             # Template files for various operations
│   ├── airdrop-template.csv
│   ├── nft-metadata-template.json
│   └── token-config-template.json
└── test-data/             # Test data for development
    ├── large-airdrop.csv
    └── sample-nfts.json
```

## 🎯 File Descriptions

### Airdrop Files
- **`airdrop.csv`** - Standard airdrop recipient format with addresses and amounts
- **`allocations.csv`** - Token allocation distribution for different stakeholder groups
- **`influencers.csv`** - Influencer tracking and commission structure

### Template Files
- **`templates/airdrop-template.csv`** - Empty template for new airdrops
- **`templates/nft-metadata-template.json`** - NFT metadata structure
- **`templates/token-config-template.json`** - Token configuration parameters

### Test Data
- **`test-data/large-airdrop.csv`** - Large dataset for performance testing
- **`test-data/sample-nfts.json`** - Sample NFT data for development

## 📋 Data Formats

### Airdrop CSV Format
```csv
address,amount,eligibility_type,lock_period
0x123...,1000000000000000000,early_supporter,0
0x456...,500000000000000000,community_member,30
```

**Fields:**
- `address` - Recipient wallet address (checksummed)
- `amount` - Token amount in wei (18 decimals)
- `eligibility_type` - Category of recipient
- `lock_period` - Lock period in days (0 = immediate)

### Allocations CSV Format
```csv
category,percentage,amount,vesting_schedule,description
community,50,500000000,linear_12_months,Community airdrop and rewards
liquidity,30,300000000,immediate,Initial liquidity provision
team,10,100000000,cliff_12_vesting_24,Team allocation with cliff
treasury,10,100000000,governance_controlled,Treasury for operations
```

### Influencer CSV Format
```csv
address,username,tier,commission_rate,referral_code,status
0x789...,cryptoinfluencer1,gold,5.0,CRYPTO2024,active
0xabc...,nftcollector,silver,3.0,NFT2024,active
```

## 🔧 Usage Examples

### CLI Tools
```bash
# Process airdrop using sample data
npx hardhat airdrop:process --file ./samples/airdrop.csv --network polygon

# Validate allocation data
npx hardhat validate:allocations --file ./samples/allocations.csv

# Import influencer data
npx hardhat influencer:import --file ./samples/influencers.csv
```

### API Integration
```typescript
// Load airdrop data in backend
import fs from 'fs';
import csv from 'csv-parser';

const airdropData: AirdropRecipient[] = [];

fs.createReadStream('./samples/airdrop.csv')
  .pipe(csv())
  .on('data', (row) => {
    airdropData.push({
      address: row.address,
      amount: BigInt(row.amount),
      eligibilityType: row.eligibility_type,
      lockPeriod: parseInt(row.lock_period)
    });
  })
  .on('end', () => {
    console.log('Airdrop data loaded:', airdropData.length, 'recipients');
  });
```

## ⚠️ Important Notes

### Security Considerations
- **Never commit real private keys** or sensitive data
- **Validate all addresses** before processing
- **Use test networks** for development and testing
- **Backup important data** before making changes

### Data Validation
- All Ethereum addresses must be checksummed
- Token amounts should be in wei (smallest unit)
- CSV files must include headers
- Required fields cannot be empty

### File Size Limits
- **Small files** (< 1MB) - Suitable for quick testing
- **Medium files** (1-10MB) - Standard operational use
- **Large files** (> 10MB) - Use batch processing

## 🧪 Testing Guidelines

### Validation Checklist
- [ ] All addresses are valid and checksummed
- [ ] Amounts are positive and within expected ranges
- [ ] No duplicate addresses in airdrop files
- [ ] CSV headers match expected format
- [ ] Total allocation percentages sum to 100%

### Test Commands
```bash
# Validate CSV format
npm run validate:csv ./samples/airdrop.csv

# Check address checksums
npm run validate:addresses ./samples/airdrop.csv

# Dry run airdrop processing
npm run airdrop:dry-run ./samples/airdrop.csv
```

## 📚 Related Documentation

- [CLI Tools Documentation](../cli/README.md)
- [Smart Contracts](../contracts/README.md)
- [Backend API](../apps/backend/README.md)
- [Contributing Guidelines](../CONTRIBUTING.md)

## 🤝 Contributing Sample Data

When contributing new sample files:

1. **Follow naming conventions** - Use descriptive, kebab-case names
2. **Include documentation** - Add descriptions and usage examples
3. **Validate data format** - Ensure compatibility with existing tools
4. **Remove sensitive data** - Use placeholder addresses and amounts
5. **Test thoroughly** - Verify files work with CLI tools and scripts

## 📄 License

Sample data files are provided for reference and testing purposes only. They are subject to the same license terms as the Unykorn project.