# 🦄 Unykorn Registry - Complete Deployment Guide

## 🚀 Quick Start

Your Unykorn Registry infrastructure is now complete and ready for deployment! This guide will help you activate all features.

### 1. Enable GitHub Pages

1. Go to your repository settings
2. Navigate to **Pages** section  
3. Set source to: **Deploy from a branch**
4. Select: **main** branch → **/docs** folder
5. Save settings

Your registry will be live at: `https://yourusername.github.io/unykorn`

### 2. Validate Registry Data

```bash
# Run complete validation suite
python3 scripts/validate_registry.py

# Expected output:
# ✅ All validations passed! Registry data is clean.
```

### 3. Test RPC Health Monitoring

```bash
# Check RPC endpoint health (will fail with placeholder URLs)
python3 scripts/rpc_health.py --quiet

# Update RPC URLs in exports/unykorn_l1_chains.csv with real endpoints
# Then re-run for actual health monitoring
```

### 4. Deploy Smart Contract (Optional)

```bash
# Deploy the RegistryNotary contract for on-chain notarization
npx hardhat run scripts/deploy_notary.js --network your-network

# Update the contract address in scripts/notarize_registry.py
# Then run: python3 scripts/notarize_registry.py
```

## 🔧 Configuration

### Update CSV Data

Edit the registry files in `exports/`:
- `unykorn_l1_chains.csv` - Add/update L1 chain information
- `unykorn_address_book.csv` - Add verified contract addresses

After editing, run validation:
```bash
python3 scripts/validate_registry.py
```

### Set Real RPC URLs

Replace placeholder URLs in `exports/unykorn_l1_chains.csv` with actual RPC endpoints:
```csv
chain_id,name,symbol,rpc_url,block_explorer,status,native_token,bridge_contract,last_validated
1,Ethereum,ETH,https://mainnet.infura.io/v3/YOUR_API_KEY,https://etherscan.io,active,ETH,0x...,2024-01-15T10:30:00Z
```

### Configure GitHub Actions Secrets

For advanced features, add these repository secrets:
- `RPC_URLS` - JSON object with chain_id -> RPC URL mappings
- `PRIVATE_KEY` - For contract deployment (if using on-chain notarization)

## 📊 Features Overview

### ✅ What's Working Now
- **Professional Dashboard** - Glassmorphism UI with live data
- **CSV Validation** - Automated integrity checking
- **Merkle Proof Generation** - Cryptographic tamper evidence
- **GitHub Pages Hosting** - Public registry interface
- **GitHub Actions** - Automated validation on PRs
- **Documentation** - Complete integration guides

### 🔧 Requires Configuration
- **RPC Health Monitoring** - Update URLs for real endpoint testing
- **On-Chain Notarization** - Deploy smart contract and configure
- **IPFS Integration** - Install IPFS and run pinning scripts

## 🌐 Live Dashboard

Once GitHub Pages is enabled, your dashboard will show:

- **Live Statistics** - 9 L1 chains, 15+ verified addresses
- **Download Links** - One-click CSV exports
- **Merkle Proofs** - Cryptographic validation data
- **Copy Functions** - Easy integration with external systems
- **Dark/Light Mode** - Professional UI for all users

![Unykorn Registry Dashboard](https://github.com/user-attachments/assets/5d98953d-28fe-444b-9d3e-eefc8baaef2d)

## 🔐 Security Features

### Tamper-Evident Storage
- **Merkle Trees** - Cryptographic proof of data integrity
- **File Hashes** - SHA-256 verification of registry files  
- **GitHub Actions** - Automatic blocking of corrupted data
- **Audit Trails** - Complete change history and validation

### Institutional Compliance
- **Downloadable Proofs** - JSON metadata with cryptographic validation
- **Professional Documentation** - Bank-ready integration guides
- **IPFS Ready** - Immutable storage capability
- **Smart Contract Integration** - On-chain notarization support

## 📋 Maintenance

### Regular Tasks
1. **Update RPC URLs** - Keep endpoints current
2. **Monitor Health Checks** - Review automated reports
3. **Validate Data** - Run validation before major changes
4. **Review GitHub Issues** - Address automated health alerts

### Data Updates
```bash
# 1. Edit CSV files in exports/
# 2. Run validation
python3 scripts/validate_registry.py

# 3. Commit changes (GitHub Actions will validate)
git add exports/
git commit -m "Update registry data"
git push

# 4. GitHub Pages automatically updates
```

## 🎯 Success Metrics

Your Unykorn Registry now provides:

- ✅ **Documented** - Complete professional documentation
- ✅ **Auditable** - Cryptographic proofs and validation
- ✅ **Bank-Ready** - Institutional-grade security and compliance
- ✅ **Automated** - Self-maintaining with GitHub Actions
- ✅ **Professional** - Modern UI with glassmorphism design

## 🚀 Next Steps

1. **Enable GitHub Pages** to make your registry live
2. **Update CSV data** with your actual chain/address information  
3. **Configure RPC URLs** for real-time health monitoring
4. **Share the dashboard** with your institutional partners

Your sovereign proof machine is ready! 🦄

---

**Need help?** Check the complete documentation:
- [Registry README](REGISTRY_README.md) - Full feature documentation
- [IPFS Integration](docs/IPFS_INTEGRATION.md) - Advanced deployment guide