# Unykorn NFT Marketplace

This repository contains example Solidity smart contracts for an NFT marketplace with staking functionality.

## Contracts

- `NFTMarketplace.sol` - listing and purchasing NFTs with a configurable fee.
- `NFTStaking.sol` - stake NFTs to earn ETH rewards over time.
- `VTVToken.sol` - ERC20 utility token with pausing and burn support.
- `VCHANToken.sol` - governance style token.
- `VPOINTToken.sol` - non-transferable loyalty points.
- `VChannelDomain.sol` - soulbound `.tv` domain NFTs.

## Development

Contracts are written for Hardhat. Install dependencies with `npm install` and compile using `npx hardhat compile`.

A sample deploy script is provided in `scripts/deploy.js` which deploys the tokens and domain contract.

Environment variables should be defined in `.env` based on `.env.template` for network deployments.
