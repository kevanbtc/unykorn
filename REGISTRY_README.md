# 🏛️ Unykorn Registry - Bank-Ready Sovereign Proof Machine

**Professional-grade registry infrastructure with cryptographic validation for L1 chains and verified DeFi addresses.**

## 🚀 Live Dashboard

- **Production**: https://kevanbtc.github.io/unykorn 
- **Registry API**: https://kevanbtc.github.io/unykorn/api/registry.json
- **Validation Status**: https://github.com/kevanbtc/unykorn/actions

## 📋 Table of Contents

- [Overview](#overview)
- [Core Components](#core-components)
- [Getting Started](#getting-started)
- [API Documentation](#api-documentation)
- [Validation Engine](#validation-engine)
- [Security & Compliance](#security--compliance)
- [Deployment](#deployment)
- [Contributing](#contributing)

## 🔍 Overview

The Unykorn Registry is a comprehensive, bank-ready infrastructure for managing and validating L1 blockchain data and verified DeFi protocol addresses. It provides:

- **Cryptographic Validation**: Merkle tree-based proof system
- **Real-time Monitoring**: RPC health checks and chain status
- **Professional UI**: Glassmorphism design with responsive layout
- **Export Utilities**: Regulatory compliance tools
- **Automated CI/CD**: GitHub Actions for validation and deployment

## 🛠️ Core Components

### 1. Registry Data Files

#### `unykorn_l1_chains.csv`
Comprehensive L1 chain registry with:
- Chain ID, name, symbol, RPC endpoints
- Market cap, volume, validator counts
- Consensus algorithms and technical specs
- Bridge addresses and governance tokens

**Sample Fields:**
```csv
chain_id,name,symbol,rpc_url,explorer_url,type,status,market_cap_usd,validator_count
1,Ethereum,ETH,https://mainnet.infura.io/v3/,https://etherscan.io,L1,active,240000000000,900000
```

#### `unykorn_address_book.csv` 
Verified DeFi protocol addresses including:
- DEX routers (Uniswap, SushiSwap)
- Stablecoin contracts (USDC, DAI, USDT)
- Bridge contracts (cross-chain infrastructure)
- Governance tokens and protocol treasuries

**Sample Fields:**
```csv
address,name,protocol,category,chain_id,verified_date,tvl_usd,security_audit
0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D,Uniswap V2 Router,Uniswap,DEX,1,2020-05-18,1200000000,true
```

### 2. Python Validation Engine

**File**: `validate_registry.py`

Professional validation system featuring:
- **Merkle Tree Implementation**: SHA-256 based cryptographic proofs
- **Data Integrity Checks**: CSV format validation and address verification
- **RPC Health Monitoring**: Asynchronous endpoint testing
- **Export Utilities**: JSON/CSV generation for compliance

**Key Features:**
```python
class UnykornValidator:
    def calculate_merkle_roots()  # Generate cryptographic proofs
    def validate_registry()      # Comprehensive validation
    def check_rpc_health()       # Network monitoring
```

### 3. Professional Dashboard

**File**: `index.html`

Bank-grade web interface with:
- **Glassmorphism Design**: Modern, professional UI
- **Real-time Data**: Live chain health and registry statistics  
- **Interactive Tables**: Filterable, sortable chain and address data
- **QR Code Generation**: For mobile/NFC integration
- **Export Tools**: Regulatory compliance downloads

## 🚦 Getting Started

### Prerequisites
- Python 3.12+
- Modern web browser
- Git

### Quick Start

1. **Clone Repository**
```bash
git clone https://github.com/kevanbtc/unykorn.git
cd unykorn
```

2. **Install Dependencies**
```bash
pip install aiohttp requests
```

3. **Validate Registry**
```bash
python validate_registry.py
```

4. **View Dashboard**
```bash
# Open index.html in your browser
open index.html
```

### Environment Setup

Create `.env` file for production:
```bash
# RPC Endpoints (optional - uses public by default)
ETHEREUM_RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY
BSC_RPC_URL=https://bsc-dataseed.binance.org/
POLYGON_RPC_URL=https://polygon-rpc.com/

# Monitoring (optional)
MONITORING_ENABLED=true
HEALTH_CHECK_INTERVAL=300  # 5 minutes
```

## 📡 API Documentation

### REST Endpoints

#### Get Chain Registry
```http
GET /api/chains
Content-Type: text/csv

Returns: Complete L1 chain registry CSV
```

#### Get Address Book  
```http
GET /api/addresses
Content-Type: text/csv

Returns: Verified address book CSV
```

#### Get Merkle Proofs
```http
GET /api/merkle
Content-Type: application/json

Returns: Current Merkle roots and validation metadata
```

### Response Format

**Merkle Proof Response:**
```json
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "chain_count": 20,
  "address_count": 32,
  "merkle_roots": {
    "chains": "9b1a5491536fa801f4d32be06e53975bc297...",
    "addresses": "2a8d7534b9c94b9ee515b748259b59fb00f5...",
    "combined": "abff9f45fd1f0c12d5c303437d8f7a4bd73b..."
  },
  "validation_metadata": {
    "validator_version": "1.0.0",
    "algorithm": "SHA-256",
    "tree_type": "binary_merkle"
  }
}
```

## 🔐 Validation Engine

### Merkle Tree Implementation

The validation engine uses a binary Merkle tree with SHA-256 hashing:

```python
# Create tree from registry data
chain_data = [f"{chain.id}|{chain.name}|{chain.rpc_url}" for chain in chains]
tree = MerkleTree(chain_data)
root = tree.get_root()

# Generate proof for specific chain
proof = tree.get_proof(chain_index)
is_valid = tree.verify_proof(chain_data[chain_index], chain_index, proof)
```

### Validation Workflow

1. **Data Loading**: Parse CSV files and validate format
2. **Integrity Checks**: Verify addresses, chain IDs, URLs
3. **RPC Health**: Test network connectivity
4. **Merkle Generation**: Create cryptographic proofs
5. **Export Results**: Generate compliance reports

### Running Validation

```bash
# Basic validation
python validate_registry.py

# With RPC health checks
python validate_registry.py --check-rpc

# Export validation report
python validate_registry.py --export-report
```

## 🏦 Security & Compliance

### Security Features

- **Data Integrity**: Cryptographic Merkle proofs
- **Input Validation**: Strict CSV format checking  
- **Address Verification**: Checksum validation
- **Audit Trail**: Timestamped validation logs
- **Access Control**: CORS headers and CSP policies

### Compliance Framework

The registry supports regulatory requirements:

- **SOX Compliance**: Audit trails and data integrity
- **GDPR Ready**: No personal data collection
- **Financial Audit**: Exportable validation reports
- **Change Management**: Git-based version control

### Security Audit Checklist

- [ ] All addresses pass checksum validation
- [ ] Merkle roots match expected values
- [ ] No sensitive data in CSV files
- [ ] RPC endpoints use HTTPS
- [ ] Access logs maintained
- [ ] Backup procedures tested

## 🚀 Deployment

### GitHub Pages (Recommended)

Automatic deployment via GitHub Actions:

1. **Enable GitHub Pages**: Settings > Pages > GitHub Actions
2. **Push to Main**: Triggers validation and deployment
3. **Monitor Status**: Actions tab shows deployment progress

### Netlify Deployment

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy site
netlify deploy --prod --dir=.
```

Configuration in `netlify.toml` includes:
- Security headers
- API endpoint redirects  
- SPA routing support

### Docker Deployment

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
```

### Custom Server Setup

For enterprise deployments:

```bash
# Use Python HTTP server
python -m http.server 8080

# Or Node.js serve
npm install -g serve
serve . -p 8080
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

**File**: `.github/workflows/registry-validation.yml`

The automated pipeline includes:

1. **Registry Validation**: Data integrity and format checks
2. **Security Scanning**: Address format and sensitive data checks  
3. **RPC Health Monitoring**: Network connectivity testing
4. **GitHub Pages Deployment**: Automatic site updates
5. **Artifact Generation**: Validation reports and proofs

### Monitoring Schedule

- **On Push**: Full validation and deployment
- **Nightly**: RPC health monitoring (2 AM UTC)
- **On PR**: Validation checks only

## 👥 Contributing

### Development Setup

1. **Fork Repository**
2. **Create Feature Branch**: `git checkout -b feature/new-chain`
3. **Add Data**: Update CSV files following format
4. **Run Validation**: `python validate_registry.py`
5. **Submit PR**: Include validation results

### Adding New Chains

To add a new L1 chain:

1. **Research**: Verify chain parameters and RPC endpoints
2. **Update CSV**: Add row to `unykorn_l1_chains.csv`
3. **Test RPC**: Ensure endpoint responds to `eth_blockNumber`
4. **Run Validation**: Check Merkle root updates
5. **Document**: Update README if needed

### Adding New Addresses

For verified addresses:

1. **Security Audit**: Ensure contract is audited
2. **Verification**: Check address on block explorer
3. **Update CSV**: Add to `unykorn_address_book.csv`
4. **Categorize**: Use appropriate protocol category
5. **Test Export**: Verify in dashboard

## 📞 Support & Contact

### Community

- **Issues**: [GitHub Issues](https://github.com/kevanbtc/unykorn/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kevanbtc/unykorn/discussions)
- **Wiki**: [Project Wiki](https://github.com/kevanbtc/unykorn/wiki)

### Enterprise Support

For institutional deployments:
- Custom validation requirements
- On-premise installations  
- Compliance consultation
- SLA agreements

## 📜 License

MIT License - see `LICENSE` file for details.

## 🏆 Acknowledgments

- **OpenZeppelin**: Security patterns and standards
- **Ethereum Foundation**: EIP specifications
- **DeFi Protocol Teams**: Address verification
- **Security Auditors**: Smart contract reviews

---

**© 2024 Unykorn Registry. Bank-ready sovereign proof infrastructure.**