# Unykorn DAO Governance System

This project contains example smart contracts and a Hardhat setup for a simple DAO governance system.

## Contracts

- `GovernanceToken.sol` – an ERC-20 token used for governance voting.
- `DAO.sol` – allows token holders to create proposals, vote, and execute approved proposals.

## Development

Install dependencies with `npm install` and run Hardhat commands:

```bash
npx hardhat compile
npx hardhat test
```

The Hardhat network will attempt to download the Solidity compiler from the internet. If this environment restricts network access, compilation will fail. You may need to configure an offline compiler.

To deploy locally:

```bash
npx hardhat run scripts/deploy.js
```

## Structure

- `contracts/` – Solidity contracts
- `scripts/` – deployment scripts
- `test/` – example Hardhat tests

This is a starting point for building a DAO governance application.
