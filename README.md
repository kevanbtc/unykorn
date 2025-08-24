# Unykorn Contracts

This repository contains Solidity smart contracts and tooling for an ESG-focused real‑world asset platform. It includes an NFT marketplace, staking logic, and a growing suite of vaults and stablecoins for tokenizing water, carbon, and other sustainability assets.

## Contracts

- `NFTMarketplace.sol` – list and purchase ERC‑721 tokens with a marketplace fee.
- `NFTStaking.sol` – stake NFTs to earn ETH rewards over time.
- `VTV.sol` – basic ERC‑20 utility token.
- `VCHAN.sol` – governance token.
- `VPOINT.sol` – soulbound loyalty points that cannot be transferred.
- `SubscriptionVault.sol` – basic monthly subscription contract using an ERC‑20 token.
- `AffiliateRouter.sol` – records and pays out referral commissions.
- `water/WaterVault.sol` – sample vault for managing water allocations.
- `carbon/CarbonVault.sol` – sample vault for retiring carbon credits.
- `stablecoin/ESGStablecoin.sol` – minimal mintable token backed by ESG vaults.
- `settlement/RLNBridge.sol` – placeholder bridge to CBDC settlement rails.

## Development

1. Install dependencies:
   ```bash
   npm install
   ```
2. Compile contracts:
   ```bash
   npm run compile
   ```
3. Run tests with Hardhat:
   ```bash
   npm test
   ```
4. Deploy example vaults:
   ```bash
   npm run deploy:water
   npm run deploy:carbon
   npm run deploy:stablecoin
   ```
5. Run Foundry tests:
   ```bash
   forge test -vv
   ```

Copy `.env` with your RPC URLs and private key for network configuration.

## ESG RWA Template Structure

This repository also provides a skeleton for a global ESG real‑world asset platform.

```
contracts/
  water/        # tokenized water rights
  carbon/       # verified carbon credits
  energy/       # renewable energy assets
  realestate/   # real estate and housing projects
  biodiversity/ # biodiversity and habitat offsets
  waste/        # recycling and circular economy assets
  insurance/    # parametric climate insurance
  sukuk/        # shariah-compliant green bonds
  governance/   # DAO and trust contracts
  compliance/   # shared regulatory logic
  oracles/      # data feed connectors
  settlement/   # CBDC and instant payment bridges
ai/             # AI orchestration hooks
  agents/       # Claude-based automation scripts
frontend/       # marketplace web interface and stablecoin desk
docs/
  compliance/   # jurisdictional regulations and reporting
  business/     # monetization strategies
```

Each folder contains a README placeholder to guide further development.
