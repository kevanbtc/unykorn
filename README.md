# Unykorn

Cross-chain token launch factory with smart contracts for EVM and Solana blockchains.

## Repository Structure

```
apps/        - frontend, backend, indexer and scheduled agents
contracts/   - smart contracts for EVM and Solana
  evm/       - Solidity contracts for Ethereum and EVM-compatible chains
  solana/    - Rust contracts for Solana
  shared/    - Shared utilities and libraries
cli/         - command line tools for deployment and airdrops
infra/       - docker-compose and CI stubs  
samples/     - example CSV files for airdrops and allocations
docs/        - documentation and specifications
```

## EVM Contracts

Located in `contracts/evm/`:

- `TokenERC20.sol` – upgradeable ERC‑20 token with permit and controlled mint/burn
- `NFTMarketplace.sol` – list and purchase ERC‑721 tokens with a marketplace fee
- `NFTStaking.sol` – stake NFTs to earn ETH rewards over time
- `MemePass721.sol` – ERC‑721 NFT with royalties and pausing
- `LiquidityHelper.sol` – liquidity management utilities
- `VTV.sol` – basic ERC‑20 utility token
- `VCHAN.sol` – governance token
- `VPOINT.sol` – soulbound loyalty points that cannot be transferred
- `SubscriptionVault.sol` – basic monthly subscription contract using an ERC‑20 token
- `AffiliateRouter.sol` – records and pays out referral commissions
- `AuditTrail.sol` – audit and compliance tracking

## Solana Contracts

Located in `contracts/solana/`:

- `airdrop_dist` – Merkle-tree based airdrop distribution
- `meme_token` – Token creation and management utilities

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

## Security & Audit

See the [Audit and Appraisal Report](docs/AUDIT_AND_APPRAISAL.md) for security findings, compliance guidance, and value assessment.
