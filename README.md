# 🦄 Unykorn Contracts & Banking Backend

This repository provides a modular, banking-grade stack for **stablecoin issuance, real-world asset (RWA) tokenization, and institutional compliance**.  
It is designed to demonstrate how a next-generation financial infrastructure can be built with **Solidity smart contracts, regulated banking adapters, a compliance-first backend, and a unified frontend dashboard**.

---

## 📂 Structure

- **contracts/**
  - `USDxEnterprise.sol` – USD-pegged ERC-20 stablecoin with mint/burn control.
  - `EnterpriseTreasury.sol` – Treasury contract enforcing Basel III ratio gates before mint.
  - `RWAVault.sol` – Vault for tokenized real-world assets (real estate, carbon credits, bonds).
  - `BaselIIICompliance.sol` – Capital adequacy calculations (Tier 1 vs RWA).
  - `ISO20022Processor.sol` – Event logs for ISO 20022 PACS/PAIN/CAMT messages.
  - `TravelRuleCompliance.sol` – FATF Travel Rule notifications for large transfers.

- **backend/**
  - Node.js + Express API for **KYC, compliance, reporting**, with middleware for rate-limiting and monitoring.
  - Example routes: `/api/compliance/report`, `/api/kyc/check`.

- **adapters/**
  - Connectivity modules to plug into **traditional rails**:
    - `swift-adapter/` – MT103/199 message simulation.
    - `fedwire-adapter/` – RTGS wire transfer stub.
    - `cbdc-bridge/` – demo CBDC bridge adapter.
  - Shared services: `services/TreasuryService.js` for minting through the treasury.

- **infra/**
  - `docker-compose.yml` – Postgres, Redis, Kafka services.
  - `k8s/` – placeholders for Kubernetes manifests.
  - `monitoring/` – Prometheus/Grafana scaffolds.

- **frontend/**
  - Next.js dashboard skeleton with hooks for wallet connection and reporting.
  - Example homepage: `Unykorn Dashboard`.

- **scripts/**
  - `fullDeployment.sh` – compiles contracts, runs deployment, launches infra, backend, frontend.
  - `deployContracts.js` – Hardhat deployment stub.

---

## 🔒 Compliance Features

- **Basel III** capital ratio enforcement inside Treasury.
- **ISO 20022** logging for settlement events.
- **FATF Travel Rule** notifications for transfers with encrypted metadata.
- **GDPR/Privacy** – No raw PII on-chain, only hashed or off-chain references.

---

## 🚀 Development

1. **Install dependencies**

   ```bash
   npm install
   ```

2. **Compile contracts**

   ```bash
   npx hardhat compile
   ```

3. **Deploy (example)**

   ```bash
   npx hardhat run scripts/deployContracts.js --network sepolia
   ```

4. **Run backend**

   ```bash
   cd backend && npm start
   ```

5. **Run frontend**

   ```bash
   cd frontend && npm run dev
   ```

---

## ✅ Testing

* **Contracts**

  ```bash
  npx hardhat compile
  npx hardhat test
  slither .
  ```

* **Backend**

  ```bash
  cd backend && npm test
  ```

* **Frontend**

  ```bash
  cd frontend && npm test
  ```

---

## 📊 Roadmap

* [ ] Integrate Chainlink Proof-of-Reserves for USDx backing.
* [ ] Expand RWA Vault for fractionalized ERC-1400 security tokens.
* [ ] ISO 20022 XML ↔ Solidity event bridge.
* [ ] MiCA monthly disclosure generator.
* [ ] Fedwire/SWIFT sandbox integration.

---

## ⚠️ Disclaimer

This repository is a **technical scaffold and research prototype**.
It is **not production code**, nor is it licensed for financial issuance without regulator approval.

