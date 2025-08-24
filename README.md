# Unykorn Contracts

This repository contains example Solidity smart contracts for an NFT marketplace and staking functionality. Additional contracts showcase a simple token suite and subscription logic inspired by the V-CHANNEL specification.

## Contracts

- `NFTMarketplace.sol` – list and purchase ERC‑721 tokens with a marketplace fee.
- `NFTStaking.sol` – stake NFTs to earn ETH rewards over time.
- `VTV.sol` – basic ERC‑20 utility token.
- `VCHAN.sol` – governance token.
- `VPOINT.sol` – soulbound loyalty points that cannot be transferred.
- `SubscriptionVault.sol` – basic monthly subscription contract using an ERC‑20 token.
- `AffiliateRouter.sol` – records and pays out referral commissions.

## Development

1. Install dependencies:
   ```bash
   npm install
   ```
2. Compile contracts:
   ```bash
   npx hardhat compile
   ```
3. Deploy (example script):
   ```bash
   npx hardhat run scripts/deploy.js --network yourNetwork
   ```

Copy `.env.template` to `.env` and fill in your RPC URL and deployer private key for network configuration.

## Static Analysis

Slither is used to run static analysis on the Solidity contracts.

1. Install Slither:
   ```bash
   pip install slither-analyzer
   ```
2. Run the analysis:
   ```bash
   npm run slither
   ```
