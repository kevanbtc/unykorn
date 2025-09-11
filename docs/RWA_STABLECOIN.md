# RWA-Backed Stablecoin System

## Overview

This module implements a stablecoin framework backed by real-world assets (RWAs) such as treasuries, bonds, commodities, or real estate. It includes:

- **Stablecoin Contract** – ERC-20 with role-based mint/burn and compliance checks.
- **ComplianceManager** – admin-controlled whitelist enforcing KYC/AML.
- **RWARegistry** – records proofs and collateral ratios for on-chain linkage to off-chain assets.
- **OracleConnector** – simple price feed storage with update tracking.
- **GovernanceTimelock** – timelock controller for DAO/multisig governance.
- **EmergencyPause** – circuit breaker to halt system operations.

## Repo Structure

```
contracts/
  Stablecoin.sol
  ComplianceManager.sol
  RWARegistry.sol
  OracleConnector.sol
  GovernanceTimelock.sol
  EmergencyPause.sol
deploy/
  01_deploy.js
test/
  Stablecoin.test.js
  RWARegistry.test.js
  ComplianceManager.test.js
  Integration.test.js
```

## Deployment

Install dependencies and deploy using Hardhat:

```bash
npm install
npx hardhat run deploy/01_deploy.js --network <network>
```

## Testing

Run the test suite:

```bash
npx hardhat test
```

The tests cover compliance gating, registry updates, and end-to-end mint/burn flows.

## Compliance & Governance

- All mint/burn events include an RWA reference.
- Whitelisting enforces KYC at the smart-contract layer.
- Governance actions can be executed through `GovernanceTimelock` with a configurable delay.
- `EmergencyPause` allows pausing the system during incidents.

