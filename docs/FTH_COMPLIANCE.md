# FTH Compliance & Regulatory Framework

## Overview

The FTH Sovereign Settlement Infrastructure implements a multi-layered compliance framework designed to meet regulatory requirements for digital asset securities, commodity-backed tokens, and electronic money transmission.

## Compliance Modes

### Three-Tier Compliance Model

1. **Off Mode** (Development/Testing)
   - No compliance checks
   - Used for development and testing only
   - NOT for production use

2. **Light Mode** (Basic Compliance)
   - Address whitelist enforcement
   - Basic transaction monitoring
   - Suitable for regulated sandbox environments

3. **Strict Mode** (Full Compliance) **← PRODUCTION**
   - Comprehensive KYC/AML verification
   - Sanctions screening (OFAC, UN, EU)
   - Transaction pause controls
   - Real-time monitoring and reporting
   - Mandatory for production deployment

## Regulatory Alignment

### Securities Regulations

#### Token Classification
- **USDF**: May be classified as e-money or stablecoin under local regulations
- **FTHG**: Commodity-backed security; subject to commodity trading regulations
- **FTH**: Governance token; may constitute investment contract/security

#### Compliance Measures
- ✅ **Accredited Investor Requirements**: Whitelist enforces pre-verified status
- ✅ **Transfer Restrictions**: All transfers require whitelist approval
- ✅ **Custody Controls**: Multi-sig treasury with timelock
- ✅ **Audit Trail**: Complete on-chain transaction history
- ✅ **Proof-of-Reserve**: Daily audits with VaultProofNFT system

### KYC/AML Framework

#### Identity Verification (KYC)
```
Required Information:
├── Individual
│   ├── Full legal name
│   ├── Date of birth
│   ├── Government-issued ID
│   ├── Proof of address
│   └── Source of funds declaration
└── Entity
    ├── Corporate registration
    ├── Beneficial ownership (UBO)
    ├── Business purpose
    ├── Financial statements
    └── Authorized signers
```

#### Anti-Money Laundering (AML)
- **Transaction Monitoring**: Real-time analysis of patterns
- **Risk Scoring**: Automated risk assessment per address
- **Enhanced Due Diligence**: Required for high-risk jurisdictions
- **Suspicious Activity Reporting**: Integrated SAR filing mechanism
- **Record Retention**: 7 years minimum (configurable)

#### Sanctions Screening
- **OFAC SDN List**: Daily updates and screening
- **UN Sanctions**: Consolidated list integration
- **EU Sanctions**: Council regulations compliance
- **Address Blocking**: Automatic rejection of sanctioned addresses
- **Continuous Monitoring**: Periodic re-screening of existing users

### Commodity Regulations

#### Physical Gold Backing (FTHG)
- **1:1 Reserve Ratio**: Each FTHG backed by 1 troy oz physical gold
- **Independent Custody**: Third-party vault operators
- **Regular Audits**: Monthly physical audits by independent auditor
- **Insurance Coverage**: Comprehensive vault insurance
- **Serial Number Tracking**: Each bar tracked via VaultProofNFT

#### Proof-of-Reserve Requirements
```solidity
// Daily audit attestation
function recordAudit(uint256 physicalGold) external onlyRole(AUDITOR_ROLE)

// Vault proof update
function updateVaultProof(string calldata uri) external onlyRole(AUDITOR_ROLE)

// NFT for each custody lot
function mintVaultProof(
    address to,
    uint256 goldBars,
    uint256 totalOunces,
    string calldata ipfsHash,
    string calldata chainlinkPoR,
    address custodian
) external onlyRole(MINTER_ROLE)
```

### Payment Services Regulations

#### Electronic Money (USDF)
- **Safeguarding**: 100% reserve backing for USDF
- **Redemption Rights**: On-demand redemption to fiat
- **Segregated Accounts**: Client funds separated from operational funds
- **Capital Requirements**: Adequate capital buffer maintained
- **Issuance Limits**: Per-client and aggregate limits enforced

#### Money Transmission License Requirements
- **State Licenses**: Required in applicable US states
- **Money Services Business (MSB)**: FinCEN registration
- **Anti-Fraud Measures**: Real-time fraud detection
- **Consumer Protection**: Dispute resolution mechanism
- **Fee Transparency**: Clear disclosure of all fees

## Smart Contract Controls

### Role-Based Access Control

#### Treasury Roles (Multi-sig 3-of-5)
- **CEO**: Strategic decisions, emergency actions
- **CFO**: Financial operations, treasury management
- **Custodian**: Physical gold custody, vault operations
- **Auditor**: Independent verification, PoR attestation
- **Compliance**: KYC/AML, regulatory reporting

#### Token Roles
```solidity
MINTER_ROLE      // Authorized to mint new tokens
BURNER_ROLE      // Authorized to burn/redeem tokens
PAUSER_ROLE      // Emergency pause capability
COMPLIANCE_ROLE  // Whitelist management
AUDITOR_ROLE     // Proof-of-reserve verification
OPERATOR_ROLE    // DEX and system operations
```

### Whitelist Enforcement

#### Address Whitelisting
```solidity
// Add address to whitelist (after KYC)
function setWhitelisted(address account, bool status) 
    external onlyRole(COMPLIANCE_ROLE)

// Transfer validation
function _update(address from, address to, uint256 amount) internal override {
    if (from != address(0) && to != address(0)) {
        require(whitelisted[from] && whitelisted[to], "Transfer not allowed");
    }
    super._update(from, to, amount);
}
```

#### Automatic Enforcement
- ❌ Non-whitelisted addresses cannot receive tokens
- ❌ Non-whitelisted addresses cannot send tokens (except redemption)
- ✅ Minting and burning bypass whitelist (controlled by roles)
- ✅ Emergency pause stops all transfers globally

### Transaction Monitoring

#### Real-Time Analysis
- **Velocity Limits**: Maximum transfer amount per time period
- **Pattern Detection**: Unusual transaction sequences flagged
- **Threshold Alerts**: Large transactions trigger manual review
- **Network Analysis**: Graph analysis to detect structuring

#### Reporting Capabilities
- **Transaction Logs**: Complete audit trail on-chain
- **Compliance Reports**: Automated regulatory filing formats
- **Suspicious Activity**: Integrated SAR generation
- **Customer Analytics**: Per-address activity summaries

## Operational Procedures

### Onboarding Workflow

1. **KYC Collection**
   - Client submits identity documents to KYC provider
   - Enhanced due diligence for high-risk profiles
   - Sanctions screening against global lists

2. **Risk Assessment**
   - Automated scoring based on jurisdiction, amount, purpose
   - Manual review for medium/high risk scores
   - Compliance officer approval required for high-risk

3. **Whitelist Addition**
   - Compliance officer adds address to whitelist
   - Event logged on-chain: `Whitelisted(address, true)`
   - Client can now receive and hold tokens

4. **Ongoing Monitoring**
   - Periodic re-screening (annual minimum)
   - Transaction monitoring for suspicious patterns
   - Automatic de-listing if sanctions hit

### Redemption Workflow

1. **Request Initiation**
   ```solidity
   // For USDF → fiat
   usdf.requestRedemption(amount)
   
   // For FTHG → physical gold
   fthg.requestPhysicalRedemption(ounces)
   ```

2. **Escrow Creation**
   - Treasury creates escrow with time-lock
   - Tokens moved to escrow contract
   - Redemption type recorded ("fiat" or "gold")

3. **Fulfillment**
   - Physical delivery or wire transfer
   - Proof uploaded to IPFS
   - Escrow released with proof hash

4. **Token Burn**
   - Redeemed tokens burned from escrow
   - Supply decreases to maintain 1:1 backing
   - Event logged for transparency

### Emergency Procedures

#### Pause Mechanism
```solidity
// Pause all token transfers
function pause() external onlyRole(PAUSER_ROLE)

// Resume operations
function unpause() external onlyRole(PAUSER_ROLE)
```

**Use Cases:**
- Security incident detected
- Regulatory order received
- Technical vulnerability discovered
- Oracle failure or manipulation

#### Compliance Freeze
- Individual address can be removed from whitelist
- Existing holdings frozen (cannot transfer)
- Redemption rights preserved (can burn to exit)
- Requires documented legal basis

## Regulatory Reporting

### Required Reports

#### Daily
- ✅ Proof-of-Reserve attestation
- ✅ Transaction volume summaries
- ✅ New account creations

#### Weekly
- ✅ Large transaction reports (>$10,000 equivalent)
- ✅ Suspicious activity monitoring results
- ✅ Whitelist additions/removals

#### Monthly
- ✅ Independent custody audit
- ✅ Financial statements (reserves vs. supply)
- ✅ Compliance exceptions log
- ✅ User growth and churn metrics

#### Annual
- ✅ External audit of smart contracts
- ✅ Penetration testing results
- ✅ KYC re-verification completion rate
- ✅ Regulator engagement summary

### Audit Trail Requirements

All compliance-relevant events are logged on-chain:
```solidity
event Whitelisted(address indexed account, bool status);
event RedemptionRequested(address indexed account, uint256 amount);
event VaultProofUpdated(string newURI, uint256 timestamp);
event AuditCompleted(uint256 physicalGold, uint256 tokenSupply, uint256 timestamp);
event EscrowCreated(uint256 indexed escrowId, address indexed beneficiary, ...);
```

Immutable, timestamped, publicly verifiable.

## Jurisdictional Considerations

### United States
- **FinCEN**: MSB registration required
- **State MTLs**: Money transmitter licenses per state
- **SEC**: Commodity-backed tokens may be securities
- **CFTC**: Gold derivatives regulation

### European Union
- **MiCA**: Markets in Crypto-Assets Regulation
- **EMD2**: Electronic Money Directive
- **AMLD6**: 6th Anti-Money Laundering Directive
- **GDPR**: Personal data protection

### United Kingdom
- **FCA**: Financial Conduct Authority registration
- **EMR**: Electronic Money Regulations
- **MLR**: Money Laundering Regulations

### Switzerland
- **FINMA**: Licensing for payment tokens/asset tokens
- **AML Act**: Due diligence and reporting requirements

### Other Jurisdictions
Each jurisdiction requires separate legal analysis and licensing.

## Data Protection

### GDPR Compliance

- **Lawful Basis**: Legitimate interest (fraud prevention) or consent
- **Data Minimization**: Only essential KYC data collected
- **Right to Erasure**: Off-chain data deletable; on-chain pseudonymized
- **Data Processing Agreement**: With KYC provider
- **Privacy by Design**: Whitelist uses addresses, not identities on-chain

### Data Retention
- **KYC Records**: 7 years post-relationship
- **Transaction Logs**: Blockchain (permanent) + off-chain summaries (7 years)
- **Audit Reports**: 10 years
- **Compliance Exceptions**: 7 years

## Disaster Recovery

### Business Continuity Plan
1. **Hot Wallet Compromise**: Pause contracts, migrate to new addresses
2. **Oracle Failure**: Manual intervention by auditor role
3. **Custody Breach**: Insurance claim + proof of remaining reserves
4. **Smart Contract Bug**: Pause, emergency upgrade via multi-sig

### Backup Procedures
- **Multi-sig Keys**: Geographically distributed, hardware wallets
- **Off-chain Data**: Daily backups, encrypted, offsite storage
- **Documentation**: Runbooks maintained and tested quarterly

## Third-Party Service Providers

### KYC Provider
- **Requirements**: Licensed, API integration, sanctions screening
- **SLA**: 24-hour turnaround for standard cases
- **Data Handling**: GDPR-compliant, encrypted transit/rest

### Custody Partner
- **Requirements**: Independent, insured, audited
- **Reporting**: Daily inventory reports
- **Access**: Physical audits by FTH auditor role

### Oracle (Chainlink PoR)
- **Function**: Verify off-chain gold reserves
- **Frequency**: Daily updates
- **Failover**: Manual auditor attestation if oracle down

## Contact

**Compliance Officer**: compliance@futuretechholdings.com  
**Legal Counsel**: legal@futuretechholdings.com  
**Auditor Relations**: audit@futuretechholdings.com

---

*This document is subject to change as regulations evolve. Last updated: 2024.*
