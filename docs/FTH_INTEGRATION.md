# FTH Integration Guide

## Overview

This guide provides step-by-step instructions for integrating with the FTH Sovereign Settlement Infrastructure.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Token Integration](#token-integration)
3. [DEX Integration](#dex-integration)
4. [Custody & Vault Integration](#custody--vault-integration)
5. [Compliance Integration](#compliance-integration)
6. [Frontend Integration](#frontend-integration)
7. [API Reference](#api-reference)

## Quick Start

### Prerequisites

```bash
# Node.js 18+ and npm
node --version
npm --version

# Hardhat
npm install --save-dev hardhat

# OpenZeppelin contracts & upgrades
npm install @openzeppelin/contracts @openzeppelin/contracts-upgradeable
npm install @openzeppelin/hardhat-upgrades
```

### Installation

```bash
# Clone repository
git clone https://github.com/kevanbtc/unykorn.git
cd unykorn

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

### Environment Configuration

Create `.env` file:

```env
# Network RPCs
ETHEREUM_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
POLYGON_RPC_URL=https://polygon-mainnet.g.alchemy.com/v2/YOUR_KEY
ARBITRUM_RPC_URL=https://arb-mainnet.g.alchemy.com/v2/YOUR_KEY

# Deployer (use hardware wallet or secure key management in production)
PRIVATE_KEY=your_private_key_here

# FTH Multi-sig Addresses (PRODUCTION - use actual multi-sig wallets)
CEO_ADDRESS=0x...
CFO_ADDRESS=0x...
CUSTODIAN_ADDRESS=0x...
AUDITOR_ADDRESS=0x...
COMPLIANCE_ADDRESS=0x...

# External Integrations
KYC_PROVIDER_API_KEY=
CHAINLINK_PoR_ADDRESS=
IPFS_API_KEY=
```

## Token Integration

### 1. USDF Stablecoin Integration

#### Minting USDF (Treasury/Authorized Minters)

```javascript
const { ethers } = require("ethers");

// Connect to USDF contract
const usdfAddress = "0x..."; // Deployed USDF address
const usdfABI = [...]; // USDF contract ABI
const usdf = new ethers.Contract(usdfAddress, usdfABI, signer);

// First, ensure recipient is whitelisted
await usdf.setWhitelisted(recipientAddress, true);

// Mint USDF tokens
const amount = ethers.parseEther("1000"); // 1000 USDF
await usdf.mint(recipientAddress, amount);

console.log("Minted 1000 USDF to", recipientAddress);
```

#### Redemption Request

```javascript
// User requests redemption
const redeemAmount = ethers.parseEther("500");
await usdf.requestRedemption(redeemAmount);

// Check redemption request
const pending = await usdf.redemptionRequests(userAddress);
console.log("Pending redemption:", ethers.formatEther(pending), "USDF");
```

#### Fulfill Redemption (Treasury)

```javascript
// After off-chain fiat transfer is confirmed
await usdf.fulfillRedemption(userAddress, redeemAmount);
// Tokens are burned and redemption request cleared
```

### 2. FTHG Gold Token Integration

#### Minting Gold-Backed Tokens

```javascript
const fthg = new ethers.Contract(fthgAddress, fthgABI, custodianSigner);

// Whitelist recipient
await fthg.setWhitelisted(clientAddress, true);

// Mint 10 troy ounces of gold tokens
const ounces = 10;
await fthg.mint(clientAddress, ounces);
// Client receives 10 * 10^18 token units (10 FTHG)
```

#### Physical Gold Redemption

```javascript
// Client requests physical gold delivery
const ouncesToRedeem = 5;
await fthg.requestPhysicalRedemption(ouncesToRedeem);

// Custodian fulfills after physical delivery
await fthg.connect(custodianSigner).fulfillPhysicalRedemption(clientAddress, ouncesToRedeem);
```

#### Update Vault Proof (Auditor)

```javascript
// Daily or after custody changes
const ipfsHash = "QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
await fthg.connect(auditorSigner).updateVaultProof(ipfsHash);

// Record audit
const verifiedGold = 1000; // 1000 troy oz verified
await fthg.connect(auditorSigner).recordAudit(verifiedGold);
```

### 3. FTH Governance Token

```javascript
// Delegate voting power
await fthToken.delegate(delegateAddress);

// Check voting power
const votingPower = await fthToken.getVotes(accountAddress);

// Used in governance proposals (DAO integration)
```

## DEX Integration

### 1. Create Trading Pairs

```javascript
const dex = new ethers.Contract(dexAddress, dexABI, operatorSigner);

// Create USDF/FTHG pair
await dex.createPair(usdfAddress, fthgAddress);

// Get pair ID
const pairId = await dex.getPairId(usdfAddress, fthgAddress);
console.log("Pair created:", pairId);
```

### 2. Add Liquidity

```javascript
// Approve tokens
await usdf.approve(dexAddress, ethers.parseEther("10000"));
await fthg.approve(dexAddress, ethers.parseEther("100"));

// Add liquidity (10,000 USDF + 100 FTHG)
await dex.addLiquidity(
  usdfAddress,
  fthgAddress,
  ethers.parseEther("10000"),
  ethers.parseEther("100")
);
```

### 3. Execute Swap

```javascript
// Check if user qualifies for discount
const qualified = await dex.isQualifiedForDiscount(userAddress);
console.log("Discount eligible:", qualified); // true if holdings >= threshold

// Approve input token
await usdf.approve(dexAddress, ethers.parseEther("1000"));

// Swap 1000 USDF for FTHG (with automatic discount if qualified)
const amountIn = ethers.parseEther("1000");
const minAmountOut = ethers.parseEther("9"); // 9 FTHG minimum (slippage protection)

await dex.swap(
  usdfAddress,      // tokenIn
  fthgAddress,      // tokenOut
  amountIn,
  minAmountOut
);
```

### 4. Remove Liquidity

```javascript
const liquidityToRemove = ethers.parseEther("100");

await dex.removeLiquidity(
  usdfAddress,
  fthgAddress,
  liquidityToRemove
);
```

## Custody & Vault Integration

### 1. Mint Vault Proof NFT

```javascript
const vaultProof = new ethers.Contract(vaultProofAddress, vaultProofABI, custodianSigner);

// When gold is deposited in vault
const tokenId = await vaultProof.mintVaultProof(
  treasuryAddress,                          // recipient
  100,                                      // number of gold bars
  3110,                                     // total troy ounces
  "ipfs://QmXXXXX...",                      // IPFS custody documentation
  "chainlink://0xXXXX",                     // Chainlink PoR reference
  custodianAddress                          // physical custodian
);

console.log("Vault Proof NFT minted:", tokenId);
```

### 2. Update Proof After Audit

```javascript
// Update proof with new documentation
await vaultProof.updateVaultProof(
  tokenId,
  "ipfs://QmNewHash...",
  "chainlink://0xNewPoR"
);
```

### 3. Auditor Verification

```javascript
// Independent auditor verifies proof
await vaultProof.connect(auditorSigner).verifyVaultProof(tokenId);

// Check total verified gold
const totalGold = await vaultProof.totalVerifiedGold();
console.log("Total verified gold:", totalGold, "troy oz");
```

### 4. Query Vault Proof

```javascript
const proof = await vaultProof.getVaultProof(tokenId);
console.log({
  goldBars: proof.goldBars,
  totalOunces: proof.totalOunces,
  ipfsHash: proof.ipfsHash,
  chainlinkPoR: proof.chainlinkPoR,
  custodian: proof.custodian,
  verified: proof.verified,
  auditTimestamp: new Date(proof.auditTimestamp * 1000)
});
```

## Compliance Integration

### 1. KYC Onboarding Flow

```javascript
// Example KYC provider integration
async function onboardClient(clientData) {
  // 1. Submit to KYC provider
  const kycResult = await kycProvider.verify({
    name: clientData.name,
    dateOfBirth: clientData.dob,
    idDocument: clientData.idDoc,
    address: clientData.address
  });

  if (!kycResult.approved) {
    throw new Error("KYC verification failed");
  }

  // 2. Sanctions screening
  const sanctionsCheck = await sanctionsService.screen(clientData.name);
  if (sanctionsCheck.isMatch) {
    throw new Error("Sanctions list match");
  }

  // 3. Add to whitelist
  const usdf = new ethers.Contract(usdfAddress, usdfABI, complianceSigner);
  await usdf.setWhitelisted(clientData.walletAddress, true);

  // 4. Log compliance event
  await complianceDB.log({
    type: "KYC_APPROVED",
    address: clientData.walletAddress,
    kycId: kycResult.id,
    timestamp: Date.now()
  });

  return { approved: true, walletAddress: clientData.walletAddress };
}
```

### 2. Transaction Monitoring

```javascript
// Listen to transfer events
usdf.on("Transfer", async (from, to, amount, event) => {
  const txData = {
    from,
    to,
    amount: ethers.formatEther(amount),
    txHash: event.log.transactionHash,
    timestamp: Date.now()
  };

  // Check velocity limits
  const dailyVolume = await getDailyVolume(from);
  if (dailyVolume + amount > MAX_DAILY_LIMIT) {
    await flagTransaction(txData, "VELOCITY_EXCEEDED");
  }

  // Pattern detection
  if (await detectStructuring(from, txData)) {
    await flagTransaction(txData, "STRUCTURING_SUSPECTED");
  }

  // Log all transactions
  await transactionDB.insert(txData);
});
```

### 3. Periodic Re-screening

```javascript
// Run daily
async function reScreenWhitelist() {
  const whitelisted = await getAllWhitelistedAddresses();

  for (const address of whitelisted) {
    const userData = await getUserData(address);
    
    // Re-screen against sanctions lists
    const sanctionsCheck = await sanctionsService.screen(userData.name);
    
    if (sanctionsCheck.isMatch) {
      // Remove from whitelist
      await usdf.connect(complianceSigner).setWhitelisted(address, false);
      
      // Alert compliance team
      await sendAlert({
        type: "SANCTIONS_HIT",
        address,
        details: sanctionsCheck
      });
    }
  }
}
```

## Frontend Integration

### 1. Web3 Connection (ethers.js)

```javascript
import { ethers } from "ethers";

// Connect to user's wallet
async function connectWallet() {
  if (typeof window.ethereum !== 'undefined') {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    return { provider, signer };
  }
  throw new Error("MetaMask not installed");
}

// Initialize contracts
const { provider, signer } = await connectWallet();
const usdf = new ethers.Contract(USDF_ADDRESS, USDF_ABI, signer);
const fthg = new ethers.Contract(FTHG_ADDRESS, FTHG_ABI, signer);
const dex = new ethers.Contract(DEX_ADDRESS, DEX_ABI, signer);
```

### 2. Display Balances

```javascript
async function getBalances(address) {
  const [usdfBalance, fthgBalance, fthBalance] = await Promise.all([
    usdf.balanceOf(address),
    fthg.balanceOf(address),
    fthToken.balanceOf(address)
  ]);

  return {
    usdf: ethers.formatEther(usdfBalance),
    fthg: ethers.formatEther(fthgBalance),
    fth: ethers.formatEther(fthBalance)
  };
}
```

### 3. Execute Trade (React Example)

```jsx
import { useState } from 'react';

function SwapInterface() {
  const [amountIn, setAmountIn] = useState("");
  const [estimatedOut, setEstimatedOut] = useState("0");

  async function executeSwap() {
    // Approve USDF
    const tx1 = await usdf.approve(DEX_ADDRESS, ethers.parseEther(amountIn));
    await tx1.wait();

    // Execute swap
    const minOut = ethers.parseEther(estimatedOut) * 95n / 100n; // 5% slippage
    const tx2 = await dex.swap(
      USDF_ADDRESS,
      FTHG_ADDRESS,
      ethers.parseEther(amountIn),
      minOut
    );
    await tx2.wait();

    alert("Swap successful!");
  }

  return (
    <div>
      <input 
        type="number" 
        value={amountIn} 
        onChange={(e) => setAmountIn(e.target.value)} 
        placeholder="Amount USDF"
      />
      <p>Estimated output: {estimatedOut} FTHG</p>
      <button onClick={executeSwap}>Swap</button>
    </div>
  );
}
```

### 4. Redemption Request

```jsx
async function requestRedemption(amount, type) {
  if (type === 'fiat') {
    const tx = await usdf.requestRedemption(ethers.parseEther(amount));
    await tx.wait();
    
    // Create escrow off-chain
    await api.post('/redemptions', {
      address: await signer.getAddress(),
      amount,
      type: 'fiat'
    });
  } else if (type === 'physical') {
    const tx = await fthg.requestPhysicalRedemption(parseInt(amount));
    await tx.wait();
    
    await api.post('/redemptions', {
      address: await signer.getAddress(),
      ounces: amount,
      type: 'physical'
    });
  }
}
```

## API Reference

### USDF Token

```solidity
// Minting
function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE)

// Burning
function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE)

// Whitelist management
function setWhitelisted(address account, bool status) external onlyRole(COMPLIANCE_ROLE)
function whitelisted(address account) external view returns (bool)

// Redemptions
function requestRedemption(uint256 amount) external
function fulfillRedemption(address account, uint256 amount) external onlyRole(BURNER_ROLE)
function redemptionRequests(address account) external view returns (uint256)

// Pausable
function pause() external onlyRole(PAUSER_ROLE)
function unpause() external onlyRole(PAUSER_ROLE)
```

### FTHG Token

```solidity
// Minting (1 token = 1 troy oz)
function mint(address to, uint256 ounces) external onlyRole(MINTER_ROLE)
function burn(address from, uint256 ounces) external onlyRole(BURNER_ROLE)

// Physical redemption
function requestPhysicalRedemption(uint256 ounces) external
function fulfillPhysicalRedemption(address account, uint256 ounces) external onlyRole(BURNER_ROLE)

// Proof of Reserve
function updateVaultProof(string calldata uri) external onlyRole(AUDITOR_ROLE)
function recordAudit(uint256 physicalGold) external onlyRole(AUDITOR_ROLE)
function vaultProofURI() external view returns (string)
function totalPhysicalGold() external view returns (uint256)
```

### Private DEX

```solidity
// Pair management
function createPair(address tokenA, address tokenB) external onlyRole(OPERATOR_ROLE)
function getPairId(address tokenA, address tokenB) public pure returns (bytes32)

// Liquidity
function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external
function removeLiquidity(address tokenA, address tokenB, uint256 liquidity) external

// Trading
function swap(address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external
function isQualifiedForDiscount(address account) public view returns (bool)
function setQualificationThreshold(uint256 newThreshold) external onlyRole(OPERATOR_ROLE)
```

### Multi-sig Treasury

```solidity
// Transaction lifecycle
function proposeTransaction(address to, uint256 value, bytes calldata data) external returns (uint256)
function confirmTransaction(uint256 txId) external
function revokeConfirmation(uint256 txId) external
function executeTransaction(uint256 txId) external

// Queries
function isSigner(address account) public view returns (bool)
function isConfirmed(uint256 txId, address signer) external view returns (bool)
```

## Testing Integration

```javascript
// test/integration.test.js
const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("FTH Integration Tests", function() {
  it("Should complete full user journey", async function() {
    // 1. Deploy infrastructure
    // 2. Whitelist user
    // 3. Mint USDF
    // 4. Mint FTHG
    // 5. Create DEX pair
    // 6. Add liquidity
    // 7. Execute swap
    // 8. Request redemption
    // 9. Fulfill redemption
  });
});
```

## Production Checklist

- [ ] Deploy with multi-sig addresses (not EOAs)
- [ ] Verify contracts on block explorer
- [ ] Set up Chainlink PoR integration
- [ ] Configure KYC provider API
- [ ] Set up IPFS node for custody docs
- [ ] Implement monitoring & alerts
- [ ] Configure gas price oracle
- [ ] Set up backup/disaster recovery
- [ ] Complete security audit
- [ ] Obtain necessary licenses
- [ ] Deploy compliance dashboard
- [ ] Set up customer support system

## Support

- **Documentation**: https://github.com/kevanbtc/unykorn/docs
- **Technical Issues**: https://github.com/kevanbtc/unykorn/issues
- **Integration Support**: integration@futuretechholdings.com
