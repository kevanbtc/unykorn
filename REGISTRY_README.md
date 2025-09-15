# 🦄 Unykorn Registry - Sovereign Proof Machine

[![Registry Validation](https://github.com/kevanbtc/unykorn/actions/workflows/registry-validation.yml/badge.svg)](https://github.com/kevanbtc/unykorn/actions/workflows/registry-validation.yml)
[![RPC Health Monitor](https://github.com/kevanbtc/unykorn/actions/workflows/rpc-health-monitor.yml/badge.svg)](https://github.com/kevanbtc/unykorn/actions/workflows/rpc-health-monitor.yml)

**Bank-ready, institutional-grade registry infrastructure with cryptographic validation and automated monitoring.**

🌐 **[Live Registry Dashboard](https://kevanbtc.github.io/unykorn)** - Professional interface with downloadable CSV exports

## 🚀 What Is This?

The Unykorn Registry transforms raw CSV data into a **sovereign proof machine** that provides:

- ✅ **Tamper-evident storage** through Merkle tree cryptography
- ✅ **Institutional-grade validation** with automated integrity checks  
- ✅ **Bank-ready documentation** and audit trails
- ✅ **Real-time monitoring** of L1 chain RPC endpoints
- ✅ **Professional dashboard** with glassmorphism UI
- ✅ **IPFS-ready exports** for immutable storage

## 📊 Registry Contents

### L1 Chains Registry (`unykorn_l1_chains.csv`)
Complete registry of monitored Layer 1 blockchain networks:
- **9 major L1 chains** (Ethereum, BSC, Polygon, Arbitrum, etc.)
- **RPC endpoint monitoring** with automated health checks
- **Block explorer links** and native token information
- **Bridge contract addresses** for cross-chain operations

### Verified Address Book (`unykorn_address_book.csv`)  
Curated collection of verified smart contract addresses:
- **15+ verified contracts** across multiple chains
- **Security status** (audited, verified, deprecated)
- **Contract type classification** (ERC20, DEX, etc.)
- **ABI verification status** for integration confidence

## 🔐 Cryptographic Security

Every registry file is secured with **Merkle tree proofs** that provide:

```json
{
  "files": {
    "unykorn_l1_chains.csv": {
      "merkle_root": "c934589d2b5d965c64cd0fd388ed57282aa4dec039766570541c118ffe060e22",
      "file_hash": "5540a95ae8ab3bf3eb69b488488832105ce4926d0cd3feb367f478e53d559d9e",
      "row_count": 9,
      "last_updated": "2024-01-15T10:30:00Z"
    }
  }
}
```

### 🛡️ Validation Features
- **Automated CSV structure validation**
- **Merkle proof generation and verification**
- **File integrity checking with SHA-256 hashes**
- **Data consistency validation**
- **GitHub Actions blocking corrupted data**

## 🏗️ Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/kevanbtc/unykorn.git
cd unykorn
npm install
```

### 2. Validate Registry Data
```bash
# Run the validation suite
python3 scripts/validate_registry.py

# Validate with custom directory
python3 scripts/validate_registry.py --exports-dir path/to/csv/files
```

### 3. Deploy GitHub Pages (Optional)
```bash
# Enable GitHub Pages in repository settings
# Point to: main branch → /docs folder
# Your registry will be live at: https://yourusername.github.io/unykorn
```

## 📈 Integration Guide

### For Institutions & Compliance Teams

#### Download Registry Files
```bash
# L1 chains registry
curl -O https://kevanbtc.github.io/unykorn/unykorn_l1_chains.csv

# Verified address book  
curl -O https://kevanbtc.github.io/unykorn/unykorn_address_book.csv

# Cryptographic proofs
curl -O https://kevanbtc.github.io/unykorn/MERKLE_ROOTS.json
```

#### Verify Data Integrity
```python
import hashlib
import json

# Load the registry file and proof metadata
with open('unykorn_l1_chains.csv', 'rb') as f:
    file_content = f.read()

with open('MERKLE_ROOTS.json', 'r') as f:
    proofs = json.load(f)

# Compute file hash
actual_hash = hashlib.sha256(file_content).hexdigest()
expected_hash = proofs['files']['unykorn_l1_chains.csv']['file_hash']

# Verify integrity
assert actual_hash == expected_hash, "File integrity check failed!"
print("✅ Registry data integrity verified")
```

### For Developers

#### CSV Structure - L1 Chains
```csv
chain_id,name,symbol,rpc_url,block_explorer,status,native_token,bridge_contract,last_validated
1,Ethereum,ETH,https://mainnet.infura.io/v3/YOUR_KEY,https://etherscan.io,active,ETH,0x...,2024-01-15T10:30:00Z
```

#### CSV Structure - Address Book
```csv
address,label,chain_id,contract_type,description,abi_verified,security_status,created_date
0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,WBTC,1,ERC20,Wrapped Bitcoin,true,audited,2024-01-01T00:00:00Z
```

## 🤖 Automation & CI/CD

### GitHub Actions Workflows

#### Registry Validation (`registry-validation.yml`)
- **Triggers:** PR/push to CSV files
- **Validates:** CSV structure, data integrity, Merkle proof generation
- **Blocks:** Corrupted or invalid registry data
- **Updates:** GitHub Pages with latest validated data

#### RPC Health Monitor (`rpc-health-monitor.yml`)  
- **Schedule:** Every 6 hours
- **Monitors:** All active RPC endpoints
- **Reports:** Response times, availability, chain ID verification
- **Alerts:** Creates GitHub issues for failed endpoints

### Validation Script Features
```bash
# Full validation suite
python3 scripts/validate_registry.py

✓ exports/unykorn_l1_chains.csv: 9 rows validated
✓ exports/unykorn_address_book.csv: 15 rows validated  
✓ Computed Merkle root for unykorn_l1_chains.csv: c934589d2b5d965c...
✓ Merkle roots saved to: exports/MERKLE_ROOTS.json
✅ All validations passed! Registry data is clean.
```

## 🌐 IPFS Integration

### Pin Registry to IPFS
```bash
# Pin CSV files to IPFS for immutable storage
ipfs add -Q exports/unykorn_l1_chains.csv   # => QmYourCIDHere
ipfs add -Q exports/unykorn_address_book.csv # => QmAnotherCIDHere

# Verify integrity matches on-chain registry
echo "Registry pinned to IPFS with CID verification"
```

### On-Chain Notarization (Solidity Example)
```solidity
// Registry event for on-chain proof storage
event RegistrySnapshot(
    bytes32 indexed merkleRoot,
    string ipfsCid,
    uint256 timestamp,
    string label
);

function notarizeRegistry(
    bytes32 _merkleRoot,
    string memory _ipfsCid,
    string memory _label
) external onlyOwner {
    emit RegistrySnapshot(_merkleRoot, _ipfsCid, block.timestamp, _label);
}
```

## 🏦 For Banks & Financial Institutions

### Compliance Features
- ✅ **Audit trail** with complete transaction history
- ✅ **Merkle proof verification** for tamper detection
- ✅ **Automated monitoring** with alerting
- ✅ **Cryptographic signatures** on all registry updates
- ✅ **IPFS integration** for regulatory immutable storage

### Risk Management
- **Contract verification status** for all addresses
- **Security audit flags** (audited/verified/deprecated)
- **RPC endpoint monitoring** for operational risk
- **Automated integrity checking** prevents data corruption

### Integration Support
- **RESTful CSV exports** via GitHub Pages
- **JSON metadata** with cryptographic proofs  
- **Real-time validation** through GitHub Actions
- **Professional documentation** and support materials

## 📱 Professional Dashboard

The **glassmorphism-designed dashboard** provides:

- 🎨 **Modern UI** with frosted glass effects and smooth animations
- 📊 **Live statistics** showing registry status and health
- 💾 **One-click downloads** for all registry files
- 🔐 **Merkle proof display** with copy-to-clipboard functionality
- 📱 **Responsive design** for desktop and mobile
- 🌙 **Dark/light mode** support

**Access at:** https://kevanbtc.github.io/unykorn

## 🔧 Development

### Project Structure
```
unykorn/
├── exports/                 # Registry CSV files and proofs
│   ├── unykorn_l1_chains.csv
│   ├── unykorn_address_book.csv  
│   └── MERKLE_ROOTS.json
├── docs/                    # GitHub Pages dashboard
│   ├── index.html
│   └── *.csv (copied from exports/)
├── scripts/                 # Validation and utilities
│   └── validate_registry.py
├── .github/workflows/       # CI/CD automation
│   ├── registry-validation.yml
│   └── rpc-health-monitor.yml
└── contracts/               # Smart contracts (existing)
```

### Adding New Chains
1. Add chain data to `exports/unykorn_l1_chains.csv`
2. Run `python3 scripts/validate_registry.py`  
3. Commit changes (GitHub Actions will validate)
4. GitHub Pages automatically updates

### Adding New Addresses
1. Add address to `exports/unykorn_address_book.csv`
2. Include security status and verification info
3. Validation runs automatically on PR/push

## 🚀 Why It's Fast & Accessible

### Performance Optimizations
- **Static file serving** via GitHub Pages CDN
- **Minimal JavaScript** with progressive enhancement
- **Optimized CSS** with efficient selectors
- **Compressed assets** and responsive images

### Accessibility Features (WCAG AA)
- **High contrast ratios** (≥4.5:1) in all modes
- **Keyboard navigation** for all interactive elements
- **Screen reader support** with proper ARIA labels
- **Semantic HTML** structure throughout
- **Focus management** with visible indicators

### Mobile-First Design
- **Responsive grid layouts** that work on any screen
- **Touch-friendly buttons** with adequate spacing
- **Optimized performance** on slower connections
- **Progressive enhancement** for older devices

## 🛠️ Troubleshooting

### GitHub Pages 404 Issues
If your GitHub Pages site shows 404 errors:

1. **Check repository settings:** Settings → Pages → Source should be "Deploy from branch" → main → /docs
2. **Verify file structure:** Ensure `docs/index.html` exists
3. **Check file permissions:** All files should be readable
4. **Wait for deployment:** GitHub Pages can take a few minutes to update

### Validation Errors
If registry validation fails:
```bash
# Run validation with verbose output
python3 scripts/validate_registry.py --exports-dir exports

# Common issues:
# - Missing required CSV columns
# - Invalid chain IDs (must be numeric)
# - Malformed Ethereum addresses  
# - Empty required fields
```

### RPC Health Check Failures
If RPC endpoints are failing:
1. **Check RPC URLs** - providers may have changed endpoints
2. **Verify chain IDs** - ensure they match the actual network
3. **Update status** - mark chains as 'inactive' if permanently unavailable
4. **Check rate limits** - some providers have strict request limits

## 🤝 Contributing

### Adding New Features
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-registry-feature`
3. Make your changes and test thoroughly
4. Run the validation suite: `python3 scripts/validate_registry.py`
5. Create a pull request with description

### Registry Data Updates
- **L1 chain additions:** Add new chains with complete metadata
- **Address verification:** Include security audit status
- **RPC endpoint updates:** Test endpoints before submitting
- **Documentation:** Update README for significant changes

### Code Standards
- **Python:** Follow PEP 8 formatting
- **JavaScript:** Use modern ES6+ features
- **HTML/CSS:** Semantic markup with accessible design
- **Documentation:** Clear, comprehensive, bank-ready

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🎯 Roadmap

### Phase 2: Enhanced Features
- [ ] **PDF export** generation for institutional reports
- [ ] **Genesis certificate** NFT minting for L1 chains  
- [ ] **Subgraph integration** for live blockchain data
- [ ] **Multi-signature validation** for critical registry updates

### Phase 3: Enterprise Features  
- [ ] **API endpoints** for programmatic access
- [ ] **Webhook notifications** for registry changes
- [ ] **Custom dashboard** white-labeling
- [ ] **Enterprise SLA** monitoring and support

---

**Built with ❤️ for institutional Web3 adoption**

Transform your CSV dumps into a sovereign proof machine. Make your registry documented, auditable, and bank-ready.

🌐 **[Live Dashboard](https://kevanbtc.github.io/unykorn)** | 📖 **[Documentation](https://github.com/kevanbtc/unykorn)** | 🚀 **[Get Started](#-quick-start)**