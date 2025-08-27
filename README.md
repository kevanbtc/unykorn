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

---

## Appendix A: Affiliate Onboarding (KYC) Requirements

- One-time registration fee: $100 (USDC or USDT).
- Wallet must be ERC-20 compatible (MetaMask, TrustWallet, Coinbase Wallet, Ledger/Trezor).
- Do not use exchange deposit addresses or non-EVM wallets.
- Reward: 1000 SGE tokens after successful KYC and fee payment.

Affiliates must provide:
- Full name, billing address, and contact information.
- Role (residential, renter, or homeowner).
- Recent utility bill (≤ 3 months old) or utility contract with expiration date.
- Confirmation of interest in energy conservation initiatives.
- Explicit agreement to pay the $100 onboarding fee in USDC or USDT (non-refundable).
- Checkbox acknowledgment confirming fee payment and wallet compatibility.

**Non-negotiable conditions**
- $100 onboarding fee is non-refundable.
- Only compliant ERC-20 wallets are eligible.
- Without valid KYC information and a recent utility bill, or if an incompatible wallet is used, the reward is forfeited.

## Appendix B: SGE Claim Instructions

1. **Step 1 – Compile Contract**
   - Open Remix and load `SGEClaim.sol`.
   - Contract address: `0x4BFeF695a5f85a65E1Aa6015439f317494477D09`.
2. **Step 2 – Approve Stablecoin**
   - USDC: `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`.
   - USDT: `0xdAC17F958D2ee523a2206206994597C13D831ec7`.
   - Approve **spender** = SGEClaim contract address.
   - Amount = `100 * 10^6` (100 tokens, 6 decimals).
3. **Step 3 – Claim SGE**
   - Call `claimWithUSDC` or `claimWithUSDT`.
   - Receive **1000 SGE** tokens instantly.

**Important**
- Each wallet can claim only once.
- Sending USDC/USDT directly to the contract will not trigger a claim.

## Appendix C: SGE Affiliate Claim – Exact Flow

1. **Wallet Requirement**
   - Supported wallets: MetaMask, Trust Wallet, Coinbase Wallet (not Coinbase Exchange), Ledger, or Trezor.
   - Do not use exchange deposit addresses or non-EVM wallets such as Bitcoin, XRP, or Solana.

2. **KYC / Affiliate Onboarding**
   - Provide full name, billing address, contact details, and role (residential, renter, or homeowner).
   - Upload a recent utility bill (within the last 3 months) or utility contract details.
   - Confirm interest in green/energy conservation initiatives and agree to pay the onboarding fee.

3. **$100 Payment**
   - Pay the non-refundable $100 fee in USDC or USDT via Coinbase Commerce.
   - Only after KYC approval and fee payment are affiliates eligible for the 1000 SGE reward.

4. **Contract Interaction**
   - Compile and load `SGEClaim.sol` in Remix at `0x4BFeF695a5f85a65E1Aa6015439f317494477D09`.
   - Approve USDC or USDT to the contract (`100 * 10^6` units) then call `claimWithUSDC` or `claimWithUSDT`.
   - Contract transfers 1000 SGE tokens directly to the wallet.

5. **Compliance Summary**
   - Fee is mandatory and non-refundable.
   - Only compliant ERC-20 wallets may claim; exchange or non-EVM addresses will lose funds.
   - Each wallet may claim only once, and failure to complete KYC forfeits the reward.

