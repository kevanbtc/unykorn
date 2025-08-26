# Unykorn ESG + IP Sovereignty Scaffold

This repository is a pre-scaffolded skeleton for rebuilding the Unykorn ESG tokenization and IP Sovereignty platform. Core smart contracts include reference implementations that Codex or other AI systems can extend into full production logic.

## Structure

- `contracts/` – Reference implementations grouped by domain (vaults, stablecoin, oracle, compliance, IP, bridge) plus interfaces and shared libraries.
- `scripts/` – Deployment, setup, and IPFS helper scripts.
- `frontend/` – Next.js dashboard scaffold (components, hooks, utilities).
- `docs/` – Legal, compliance, audit, appraisal templates, and Codex prompts.
- `test/` – Baseline unit tests for key contracts (vault deposits/withdrawals, stablecoin mint/burn, compliance whitelisting).
- `.github/workflows/` – Continuous integration pipeline.
- `.eslintrc.js` / `.prettierrc` – Linting and formatting config.
- `.npmrc` – npm settings for offline/CI environments.
- `.env.example` – Sample environment variables for local development.

## Repository Tree

```
.eslintrc.js
.env.example
.env.template
.github/
  workflows/
    ci.yml
.npmrc
.prettierrc
hardhat.config.js
package.json
package-lock.json
contracts/
  interfaces/
    IERC20Vault.sol
    ILicenseNFT.sol
    IOracle.sol
    ISovereigntyRegistry.sol
  libraries/
    ComplianceLib.sol
    FeeSplitter.sol
    SafeCollateralMath.sol
    SovereigntyUtils.sol
  bridge/
    CBDCBridge.sol
  compliance/
    ComplianceRegistry.sol
  ip/
    UnykornESGProof.sol
    UnykornLicenseNFT.sol
    UnykornSovereigntyRegistry.sol
  mocks/
    MockERC20.sol
  oracle/
    ESGOracle.sol
  stablecoin/
    ESGStablecoin.sol
  vaults/
    CarbonVault.sol
    EnergyVault.sol
    WaterVault.sol
scripts/
  deploy/
    create-subscriptions.js
    deploy-esg.js
    deploy-ip-protection.js
    mint-ip-proof.js
  ipfs/
    generate-manifest.js
    upload-archive.js
  setup/
    init-dev.js
frontend/
  components/
    ESGExplorer.tsx
    SubscriptionManager.tsx
    VaultDashboard.tsx
    WalletConnector.tsx
  hooks/
    .gitkeep
  lib/
    .gitkeep
  app/
    page.tsx
  next.config.js
  tailwind.config.js
  tsconfig.json
docs/
  COMPLIANCE_REPORT.md
  LEGAL_IP_PROTECTION_NOTICE.md
  UNYKORN_AUDIT_MASTER_PROMPT.md
  UNYKORN_APPRAISAL_REPORT_TEMPLATE.md
  UNYKORN_ESG_COMPLETE_SUMMARY.md
  UNYKORN_PROJECT_IDENTITY.md
  UNYKORN_SYSTEM_REBUILD_PROMPT.md
test/
  complianceregistry.test.js
  esgstablecoin.test.js
  licensenft.test.js
  sovereignty.test.js
  bridge.test.js
  oracle.test.js
  vaults.test.js
```

## Codex Rebuild Plan

**Phase 1 – Contracts**
- Implement vaults, stablecoin, CBDC bridge, and IP protection contracts with UUPS upgrades, circuit breakers, and compliance stubs.

**Phase 2 – Scripts**
- Complete deployment and setup scripts, plus IPFS utilities.

**Phase 3 – Frontend**
- Build dashboard for vault balances, stablecoin supply, IP proofs, and subscriptions.

**Phase 4 – Documentation**
- Populate legal notices, compliance reports, audit prompts, and appraisal templates.

**Phase 5 – Testing & CI**
- Write unit/integration tests, configure multi-chain Hardhat networks, and add automated reports.

## Development

1. Install dependencies:
   ```bash
   npm install
   ```
2. Lint code:
   ```bash
   npm run lint
   ```
3. Run tests (compiles contracts):
   ```bash
   npm test
   ```
4. Use the Codex rebuild master prompt to generate full implementations for each placeholder file.
   The prompt is stored in `docs/UNYKORN_SYSTEM_REBUILD_PROMPT.md`.
