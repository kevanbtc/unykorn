# unykorn

This repository contains a minimal prototype for the `.HYDRO` protocol. It
includes example smart contracts, tests, and an automation script that runs a
simple audit.

## Hydro Audit Script

`hydro_audit.py` performs the following actions:

1. Checks the git repository and pulls the latest changes if an `origin`
   remote is configured.
2. Runs the test suite with `pytest`.
3. Ensures Node dependencies are installed with `npm install` if needed.
4. Compiles all Solidity contracts using `solcjs`.
5. Outputs a short JSON report.

## Smart Contracts

- `HydroCoin.sol` – a basic ERC20 token.
- `WaterVaultNFT.sol` – an ERC721 NFT used to represent water vaults.

Contracts are located in the `contracts/` directory. The tests compile these
contracts with a local solcjs compiler to avoid external network access.

## Setup

Before running the tests or the audit script, install the Node.js dependencies:

```bash
npm install
```

This installs the `solc` compiler used by the tests and audit script.
