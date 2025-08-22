# Unykorn Contracts

This repository contains example Solidity smart contracts for an NFT marketplace and staking functionality. Additional contracts showcase a compliant token suite, NFT registry, and subscription logic inspired by the V-CHANNEL specification.

## Contracts

- `NFTMarketplace.sol` – list and purchase ERC‑721 tokens with a marketplace fee.
- `NFTStaking.sol` – stake NFTs to earn ETH rewards over time.
- `VTV.sol` – basic ERC‑20 utility token.
- `VCHAN.sol` – governance token.
- `VPOINT.sol` – soulbound loyalty points that cannot be transferred.
- `CompliantSubscription.sol` – monthly subscription contract that checks the `ComplianceRegistry` and pays affiliate commissions.
- `CompliantNFT.sol` – minimal `.tv` style NFT with geo and tax metadata enforced through the `ComplianceRegistry`.
- `SubscriptionVault.sol` – legacy example of a simple subscription mechanism.
- `AffiliateRouter.sol` – records and pays out referral commissions.
- `ComplianceRegistry.sol` – on-chain registry of KYC-approved addresses.

## Development

1. Install dependencies:
   ```bash
   npm install
   ```
2. Compile contracts:
   ```bash
   npx hardhat compile
   ```
3. Deploy in order:
   ```bash
   npx hardhat run scripts/deploy-registry.js --network yourNetwork
   npx hardhat run scripts/deploy-tokens.js --network yourNetwork
   npx hardhat run scripts/deploy-nfts.js --network yourNetwork
   npx hardhat run scripts/deploy-subscriptions.js --network yourNetwork
   ```

Copy `.env.template` to `.env` and fill in your RPC URL, deployer private key, and the addresses output from each deployment.

## Compliance

Token transfers are gated by the `ComplianceRegistry`. Before minting or transferring tokens, approve participant addresses via the registry contract:

```bash
npx hardhat console --network yourNetwork
> const reg = await ethers.getContractAt("ComplianceRegistry", process.env.COMPLIANCE_REGISTRY)
> await reg.setKYCed("0xYourAddress", true)
```

Screen subscription addresses against OFAC lists via the Chainalysis API:

```bash
CHAINALYSIS_API_KEY=yourKey node scripts/subscription-report.js <address>
# or override the API endpoint
CHAINALYSIS_API_KEY=yourKey CHAINALYSIS_API_URL=https://public.chainalysis.com/api/v1/address node scripts/subscription-report.js <address>
```
