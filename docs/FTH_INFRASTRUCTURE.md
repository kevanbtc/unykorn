# FTH Sovereign Settlement Infrastructure

## Overview

This repository implements the **FTH (Future Tech Holdings) Sovereign Settlement Infrastructure** - a fully-compliant, closed-loop EVM-compatible RWA-backed token system with a private ledger DEX that ties directly into the Future Tech Holdings gold ecosystem.

## Architecture

### Three-Layer Stack

#### 1. Core Ledger – Token Layer (EVM-Compatible)
- **USDF Token** (`USDFToken.sol`) - USD-pegged stablecoin with whitelist enforcement
- **FTHG Token** (`FTHGToken.sol`) - Gold-backed token (1 FTHG = 1 troy oz physical gold)
- **FTH Governance** (`FTHGovernanceToken.sol`) - Voting token for protocol governance

#### 2. Tokenization / Vault Layer
- **VaultProofNFT** (`VaultProofNFT.sol`) - Cryptographic custody proofs for physical gold
- **FTH Treasury** (`FTHTreasury.sol`) - 3-of-5 multi-signature treasury with timelock
- **FTH Escrow** (`FTHEscrow.sol`) - Secure escrow for redemptions and settlements

#### 3. DEX & Trading Layer
- **FTHPrivateDEX** (`FTHPrivateDEX.sol`) - Private AMM with 10% discount for qualified holders
- Trading pairs: USDF/FTHG, USDF/XRP, FTHG/XRP
- Automated discount mechanism based on holdings threshold

## Core Business Model

### Flow
1. **FTH Clients onboard** → KYC → vault creation → token mint
2. **Receive/buy tokens**:
   - **USDF** (stable unit of account)
   - **FTHG** (gold-backed token)
3. **Inside the Private DEX**:
   - Hold or stake for yield
   - Buy physical-linked gold at 10% below market using tokens
   - Swap among internal pairs
4. **Redemption** via on-chain Escrow tied to vault proofs

## Key Features

### Compliance & Security
- **Whitelist Registry**: Only KYC-verified addresses can hold/transfer tokens
- **Multi-signature Treasury**: 3-of-5 signatures required (CEO, CFO, Custodian, Auditor, Compliance)
- **48-hour Timelock**: All critical treasury operations delayed for security
- **Role-based Access**: Granular permissions for mint, burn, pause, compliance operations
- **Pausable Tokens**: Emergency stop mechanism

### Proof-of-Reserve
- **VaultProofNFT**: Each NFT represents verified gold bars with:
  - IPFS custody documentation
  - Chainlink PoR references
  - Audit timestamps
  - Custodian attestation
- **Daily Audits**: Auditor role can verify and update vault proofs
- **On-chain Transparency**: Total verified gold tracked on-chain

### Trading & Discounts
- **Holder Discount**: 10% trading fee discount for qualified holders
- **Qualification Threshold**: Configurable minimum holdings (default: 1000 USDF or FTHG)
- **AMM Model**: Constant product formula (x * y = k)
- **Liquidity Provision**: LP role can add/remove liquidity
- **Fee Collection**: 0.25% trading fee (0.225% with discount)

## Contracts

### Core Tokens

#### USDFToken
```solidity
// Mint USDF to whitelisted address
function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE)

// Request redemption for fiat settlement
function requestRedemption(uint256 amount) external

// Fulfill redemption and burn tokens
function fulfillRedemption(address account, uint256 amount) external onlyRole(BURNER_ROLE)
```

#### FTHGToken
```solidity
// Mint gold-backed tokens (1 token = 1 oz)
function mint(address to, uint256 ounces) external onlyRole(MINTER_ROLE)

// Request physical gold redemption
function requestPhysicalRedemption(uint256 ounces) external

// Update vault proof URI (IPFS/Chainlink)
function updateVaultProof(string calldata uri) external onlyRole(AUDITOR_ROLE)

// Record audit completion
function recordAudit(uint256 physicalGold) external onlyRole(AUDITOR_ROLE)
```

### Infrastructure

#### FTHPrivateDEX
```solidity
// Create trading pair
function createPair(address tokenA, address tokenB) external onlyRole(OPERATOR_ROLE)

// Add liquidity to pair
function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB)

// Swap with automatic discount
function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut)

// Check discount qualification
function isQualifiedForDiscount(address account) public view returns (bool)
```

#### FTHTreasury (Multi-sig)
```solidity
// Propose transaction
function proposeTransaction(address to, uint256 value, bytes calldata data) returns (uint256)

// Confirm transaction (requires 3 of 5)
function confirmTransaction(uint256 txId)

// Execute after timelock (48 hours)
function executeTransaction(uint256 txId)
```

#### VaultProofNFT
```solidity
// Mint vault proof for gold custody
function mintVaultProof(
    address to,
    uint256 goldBars,
    uint256 totalOunces,
    string calldata ipfsHash,
    string calldata chainlinkPoR,
    address custodian
) returns (uint256 tokenId)

// Verify vault proof after audit
function verifyVaultProof(uint256 tokenId) external onlyRole(AUDITOR_ROLE)
```

#### FTHEscrow
```solidity
// Create escrow for redemption
function createEscrow(
    address beneficiary,
    address token,
    uint256 amount,
    uint256 releaseTime,
    string calldata redemptionType
) returns (uint256 escrowId)

// Release escrow after fulfillment
function releaseEscrow(uint256 escrowId, string calldata fulfillmentProof)
```

## Deployment

### Prerequisites
```bash
npm install
```

### Compile Contracts
```bash
npx hardhat compile
```

### Run Tests
```bash
npx hardhat test
```

### Deploy (Example)
```javascript
const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer, ceo, cfo, custodian, auditor, compliance] = await ethers.getSigners();

  // 1. Deploy Treasury
  const Treasury = await ethers.getContractFactory("FTHTreasury");
  const treasury = await Treasury.deploy(
    ceo.address, cfo.address, custodian.address,
    auditor.address, compliance.address
  );

  // 2. Deploy USDF Token
  const USDF = await ethers.getContractFactory("USDFToken");
  const usdf = await upgrades.deployProxy(USDF, [treasury.address], { kind: "uups" });

  // 3. Deploy FTHG Token
  const FTHG = await ethers.getContractFactory("FTHGToken");
  const fthg = await upgrades.deployProxy(
    FTHG,
    [treasury.address, custodian.address, auditor.address],
    { kind: "uups" }
  );

  // 4. Deploy DEX
  const DEX = await ethers.getContractFactory("FTHPrivateDEX");
  const dex = await upgrades.deployProxy(
    DEX,
    [treasury.address, usdf.address, fthg.address, ethers.parseEther("1000")],
    { kind: "uups" }
  );

  console.log("Treasury:", treasury.address);
  console.log("USDF:", usdf.address);
  console.log("FTHG:", fthg.address);
  console.log("DEX:", dex.address);
}

main();
```

## Monetization

1. **10% Gold Discount Spread** - Internal wholesale advantage
2. **DEX Liquidity Fees** - 0.25% trading fee shared with LPs
3. **Vault Setup & Storage Fees** - Per-account reserve service charge
4. **RegTech SaaS** - White-label USDF vault compliance for other issuers
5. **Yield Module** - Stake USDF to finance RWA projects with on-chain interest flows

## Strategic Outcome

This stack makes FTH the first closed-loop precious-metal clearinghouse operating on EVM-compatible logic:

- ✅ **Every bar of gold** = cryptographically auditable NFT
- ✅ **Every token** = legally redeemable asset
- ✅ **Every client** = whitelisted vault identity
- ✅ **Every trade** = compliant, discounted, and final in <4 seconds

## Security Considerations

1. **Upgradeable Contracts**: All core contracts use UUPS proxy pattern
2. **Role Separation**: Different roles for minting, burning, pausing, compliance
3. **Multi-sig Treasury**: Requires 3 of 5 signatures + 48-hour timelock
4. **Whitelist Enforcement**: Transfers blocked for non-KYC addresses
5. **Pausable**: Emergency stop mechanism on all tokens
6. **Auditable**: VaultProofNFT with IPFS and Chainlink PoR integration

## Compliance Framework

### KYC/AML
- Off-chain KYC provider integration required
- On-chain whitelist enforcement
- Address-level compliance tracking

### Regulatory Alignment
- ISO 20022 compatible token formats
- Proof-of-Reserve with independent auditor
- Multi-signature governance
- Time-locked critical operations

## Roadmap

### Phase 1: Core Infrastructure ✅
- [x] USDF stablecoin
- [x] FTHG gold token
- [x] FTH governance token
- [x] Multi-sig treasury
- [x] Vault proof NFTs
- [x] Escrow system
- [x] Private DEX with discounts

### Phase 2: Integration (In Progress)
- [ ] Chainlink PoR integration
- [ ] IPFS custody documentation system
- [ ] KYC provider API integration
- [ ] Client portal frontend
- [ ] QR code generation for redemptions
- [ ] Real-time price oracle integration

### Phase 3: Advanced Features
- [ ] Staking and yield distribution
- [ ] Cross-chain bridge (XRPL ↔ EVM)
- [ ] Advanced trading features (limit orders, etc.)
- [ ] Mobile wallet integration
- [ ] Regulatory reporting automation
- [ ] White-label compliance SaaS

## Testing

Run comprehensive test suite:
```bash
npx hardhat test test/FTHInfrastructure.test.js
```

### Test Coverage
- Token minting and burning
- Whitelist enforcement
- Redemption workflows
- Multi-sig treasury operations
- DEX trading and discounts
- Vault proof verification
- Escrow creation and release

## License

MIT

## Support

For questions about FTH infrastructure:
- Technical: [GitHub Issues](https://github.com/kevanbtc/unykorn/issues)
- Business: contact@futuretechholdings.com
