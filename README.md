# 🦄 Digital Giant x MOG Sovereign Domains

Enterprise-ready domain registry and settlement stack built on Polygon.
Features compliance primitives, stablecoin settlement, and affiliate
program support.

## ✨ Features
- **DigitalGiantRegistry** – ERC-721 domain NFTs with resolution hooks
- **VaultProofNFT** – on-chain compliance certificates (EIN, articles)
- **AtomicSettlementBus** – stablecoin PvP/DvP engine with circuit breaker and affiliate hook
- **AffiliateRegistry** – tracks referrals and withdrawals with pause control
- **ComplianceMiddleware** – KYC enforcement and circuit breaker
- **ComplianceCouncil** – DAO-style address freezing
- Additional sample contracts: NFT marketplace, staking, token suite

## 🛠️ Quick Start
```bash
# Install dependencies
npm install

# Compile contracts
npm run build

# Run tests
npm test

# Deploy (example)
npx hardhat run scripts/deploy.js --network yourNetwork
```

## 🔧 Configuration
Copy `.env.example` to `.env` and populate the following values:

- `RPC_URL` – Polygon RPC endpoint
- `PRIVATE_KEY` – Deployer key
- `PINATA_JWT` – Pinata authentication token for IPFS
- `COUNCIL_ADDRESSES` – Comma-separated list of compliance council members
- `MULTISIG_SAFE` – Gnosis Safe that will assume contract ownership

## 📁 Structure
```
contracts/   Solidity sources
scripts/     Hardhat deployment and utility scripts
test/        Example tests
docs/        Audit and valuation reports
```

## 🤝 Contributing
Please open issues and pull requests. Critical contracts are `Ownable` so a
multi-sig can administer upgrades. See `CODEOWNERS` for the default maintainer.
Guidelines are provided in [CONTRIBUTING.md](./CONTRIBUTING.md).

## 🔐 Security
Automated static analysis runs in CI via [Slither](https://github.com/crytic/slither).
See [SECURITY.md](./SECURITY.md) for how to report vulnerabilities.

## 📄 License
MIT

## 📚 Documentation
Extended audit and valuation materials are available in the [docs](./docs) directory.
