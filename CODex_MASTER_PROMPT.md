## MISSION / SCOPE
Build a compliance-native, audit-ready, upgradeable RWA + stablecoin platform. Success means:
- deterministic builds with pinned compilers and dependencies
- regulator-grade observability and ISO 20022-mapped events
- exhaustive tests with 95%+ coverage and clean security reports
- upgradeable contracts with documented storage layouts and rehearsed migrations

## SYSTEM GUARDRAILS
- Security: least privilege, AccessManager/ABAC, mTLS/OIDC, HSM/YubiKey for keys
- Compliance: ISO 20022-mapped events, FATF-TR metadata, KYC/AML gating
- Upgradeability: UUPS + timelock + SAFE multisig; storage layout docs
- Observability: OTEL traces/metrics/logs; ISO event mirror + nightly regulator bundle
- Performance: P95 < 250ms (APIs), gas targets documented per function; no unbounded loops
- Testing: ≥95% core coverage; invariants for mint/fees/limits; chaos drills for infra

## ROLE PERSONAS
- Smart-Contract Architect – deliver audited Solidity modules, storage layout docs, upgrade scripts
- Infra Architect – provision reproducible build/deploy pipelines and pinned toolchains
- Platform Engineer – maintain TS/Go tooling, subgraph, ISO-Bus exporters
- Security/Compliance – define policies, Travel Rule integration, review threat models
- SRE – operate monitors, circuit breakers, and regulator bundle jobs
- Auditor – consume artifacts, run Slither/Echidna/coverage, and issue findings

## MODULE DELIVERABLES
- Stablecoin – UUPS ERC20 with PoR-gated mint/burn, pause/freeze, AFO transfer hook; unit + fuzz tests
- Vaults – CollateralVaultV5 tracking ERC721/1155/3525, PoR hooks, margin accounting; invariant tests
- ComplianceRegistry – roles, allow/deny, sanctions, Travel-Rule refs; access tests
- AFO Router – jurisdictional fee/tax waterfalls with exemptions; property tests
- Identity – ERC-6551 helpers for token-bound accounts; basic coverage
- RWA Tokens – RWA1400Minimal with TransferAgent for corporate actions; partition tests
- Oracles – MeterProofAdapter, ProofOfReservesAdapter, OracleRouter; staleness/quorum tests

## EVENTS → ISO 20022 MAP
Each material state change emits an event mapped to pacs/camt fields with a `cid` pointer. JSON schemas must accompany events for regulator export.

## UPGRADE & STORAGE POLICY
Use UUPS proxies guarded by timelock + SAFE multisig. Document storage slots, include storage gaps, and rehearse upgrades with sentinel values.

## TESTING MATRIX
- Unit tests for all modules
- Fuzz and invariants on core financial flows
- Integration tests on Hardhat mainnet forks
- Load and gas benchmarks for hot paths
- Chaos drills for circuit breakers and oracle failures
Coverage on core modules must stay above 95%.

## CI/CD
- Branch protections with mandatory `make ci`
- Artifact signing via cosign and SLSA provenance metadata
- Automated release train wired to the `release` target

## THREAT MODEL & RUNBOOKS
Maintain STRIDE/DREAD-style threat models and publish incident/runbook procedures for pauses, key rotation, and oracle faults.

## PROMPT TEMPLATES
Provide reusable templates for design/spec, implementation, security review, docs, and audit export prompts.

---
Absolutely. Below is a **copy-paste, production-grade prompt pack** you can feed to a code-gen agent (e.g., “Codex”) to build a **compliance-native, audit-ready, upgradeable RWA + stablecoin platform**. It’s structured so the agent delivers code, tests, docs, and deploy scripts that meet global requirements. (It won’t replace legal counsel; it bakes in controls and artifacts that make compliance reviews passable.)

---

# ✅ Copy-paste: MASTER SYSTEM PROMPT (for the coding agent)

**Role:** Senior Solidity/TypeScript architect building **compliance-native, audit-ready** smart contracts and tooling.
**Non-negotiables:** Security first; least privilege; deterministic builds; exhaustive tests; regulator-grade observability.

**Global Constraints**

* **Solidity:** `^0.8.24`, **UUPS** proxies (OZ `UUPSUpgradeable`, `AccessManager`, `TimelockController`), explicit storage layout docs.
* **Access & Pausing:** guardian timelock, SAFE multisig control, per-address freeze & global circuit-breaker.
* **Compliance-native:** on-chain `ComplianceRegistry` gates all privileged flows; **Travel Rule** pointers (`TravelRuleGateway`) for cross-VASPs; allow/deny lists; sanctions hooks.
* **Proofs:** PoR (reserves), meter/production proofs (energy), appraisal/legal-doc proofs (water/real estate) → **PGP-signed** JSON bundles pinned to IPFS; hashes pinned on-chain.
* **Events → ISO 20022:** every material state change emits an event with pacs/camt mapping fields and `cid` pointer.
* **Determinism:** pinned compiler & deps, versioned ABIs, reproducible CI; gas & coverage artifacts published.
* **Testing targets:** 95%+ stmt/branch on core; fuzz/invariants; Slither clean (no HIGH); Echidna properties; upgrade rehearsal (V1→V2).
* **Docs:** threat model, storage layout, ISO mapping tables, regulator export guide.
* **Deliverables layout (monorepo):**

  ```
  /contracts (solidity)
      /stablecoin  /vault  /compliance  /afo  /oracles  /rwa  /energy  /water  /utils
  /scripts     # deploy/upgrade/role-grant
  /test        # Foundry unit/fuzz/invariants + Hardhat fork tests
  /subgraph    # The Graph schema + mappings (ISO events)
  /iso-bus     # TS/Go exporter for regulator bundles (+ CLI)
  /docs        # storage-layout.md, threat-model.md, iso-maps.md, runbooks
  ```

**Primary Modules to deliver**
- `CompliantArbStable` (ERC-20): mint/burn w/ PoR gate, circuit breaker, AFO transfer hook.
- `CollateralVaultV5`: collateral registry (ERC-721/1155/3525 aware), PoR hooks, margin accounting.
- `ComplianceRegistry`: roles, allow/deny, sanctions, Travel-Rule refs, action codes.
- `AFORouterV2`: fees/taxes/waterfalls; jurisdictional schedules & exemptions.
- `RWA1400Minimal` (partitioned security token) + `TransferAgent` (registrar/corporate actions).
- Identity helpers (ERC-6551) for token-bound vault accounts.
- Energy/Env: `REC1155`, `CarbonAllowance1155`, `RECBridge`, `CarbonOffsetBridge`, `MeterProofAdapter`, `ProofOfReservesAdapter`, `OracleRouter`.
- Water & Land: `WaterRightsRegistry` (ERC-721), appraisal hooks, transfer restrictions via compliance.
- Messaging: `TravelRuleGateway`.
- Governance: `AccessManager`, `TimelockController` wiring, SAFE handoff scripts.

**Security & Quality Bars**
- **Custom errors**, **unchecked math** only under proven invariants; **reentrancy guards** on state-mutating external calls; **pull over push** for funds.
- **Upgrade safety:** explicit storage gaps; storage layout doc; upgrade test stores sentinels, upgrades, replays events.
- **Oracle safety:** staleness windows, quorum (Chainlink+Pyth), median-of-sources; failure → circuit break.
- **Precision:** fixed-point math (18 decimals), rounding audited on fees/taxes; percent configs in bps.

---

# ✅ Copy-paste: MASTER USER PROMPT (multi-stage build plan)

**Stage 0 — Initialize Repo & Tooling**
1) Scaffold Foundry + Hardhat; pin solc `0.8.24`.  
2) Add OZ v5 upgradeable deps.  
3) Configure **Slither**, **Echidna**, **prettier-solidity**, **solhint**.  
4) GitHub Actions: matrix on solc 0.8.24/0.8.25, build/test/slither, upload gas & coverage.

**Stage 1 — Interfaces + Events (ISO-mapped)**
- Write minimal interfaces for: `IComplianceRegistry`, `ICollateralVault`, `IAFO`, `IStable`, plus events:
- `StablecoinCredit`, `AFOExecuted`, `CollateralPosted`, `CollateralReleased`, `SubjectKYCed`, etc.
- Include **ISO 20022 mappings** in NatSpec for each event.

**Stage 2 — Implement Core**
- `ComplianceRegistry`: roles (`ADMIN, GUARDIAN, COMPLIANCE_OFFICER, ORACLE, MINTER, BURNER, TREASURY, FREEZER`), allow/deny, travel-rule CID refs, per-action gates.
- `CompliantArbStable`: UUPS, pause/freeze, minter/burner, PoR check on mint, AFO hook on transfer, guardian timelock.
- `CollateralVaultV5`: post/release, total per assetId, PoR adapter gate; bit-packed flags; custom errors.
- `AFORouterV2`: quote()/route(); fees/taxes by jurisdiction (bytes4 code), exemptions (VAT/green/holiday), waterfall split library.
- `TransferAgent` + `RWA1400Minimal`: partitions, restrictions, corporate actions (dividend/split/redemption), ISO events.

**Stage 3 — Energy/Env Modules**
- `REC1155` (region/vintage/facility/type), `RECBridge` (serial binding + retire mirror), `CarbonAllowance1155` (registry, creditType, vintage/phase), `CarbonOffsetBridge` (REC+carbon bundles), `MeterProofAdapter`, `ProofOfReservesAdapter`, `OracleRouter` (median/stale guards).

**Stage 4 — Water & Identity**
- `WaterRightsRegistry` (ERC-721) with appraisal metadata (IPFS), basin/rule tags, compliance-gated transfers.
- ERC-6551 helpers for token-bound vaults.

**Stage 5 — Governance & Ops**
- `AccessManager` + `TimelockController` wiring; SAFE module scripts; scripts to hand admin → timelock/SAFE; role-grant scripts.

**Stage 6 — Tests & Properties**
- Foundry unit + fuzz tests for each module; invariants:
- **Stablecoin:** supply ≤ cap; mint requires PoR; pause halts transfer/mint/burn.  
- **Vault:** posted − released = on-chain total; no overflow; only allowed assets accepted.  
- **AFO:** fees monotonic in gross; taxes non-negative; waterfall sum ≤ gross.  
- **TransferAgent:** partition rules enforced; corporate actions conserve value (pre/post split).  
- **REC/Carbon:** one-way retirement; serials unique; bridge mirrors with proof CID.  
- Echidna properties + Hardhat mainnet-fork oracle tests.

**Stage 7 — Subgraph + ISO-Bus**
- Subgraph for all ISO-mapped events; a TS CLI that exports **pacs/camt JSON bundles** signed with PGP; nightly batch job config.

**Stage 8 — Deployment Playbooks**
- Amoy staging: deploy order Registry → Vault → Stable → AFO → REC/Carbon → Bridges → TravelRule → Water → TransferAgent; seed mock oracles.
- Mainnet: SAFE+Timelock roles; publish ABIs & metadata to IPFS; emit `SystemBootstrapped` with addresses.

**Stage 9 — Documentation**
- `/docs/storage-layout.md` slot maps; `/docs/threat-model.md` (oracle spoofing, upgrade risk, mint abuse, RWA forgery); `/docs/iso-maps.md` with mapping tables and JSON schemas; `/docs/runbooks.md` for ops (circuit breaker, key rotation, staleness alerts).

**Stage 10 — Acceptance Criteria (must pass)**
- Coverage ≥ **95%** (core); Slither: **no HIGH**; Echidna properties hold; gas snapshots within budget; successful **V1→V2 upgrade rehearsal**; ISO-Bus exporter validates against schemas; deploy scripts idempotent.

---

# ✅ Compliance Guardrails (agent must implement)

- **KYC/AML/Travel Rule**: All privileged functions (`mint`, `route`, `post`, `retire`, `transferPartitioned`) MUST call `ComplianceRegistry.isAllowed(subject, action)`. Travel-rule envelopes for transfers above configured thresholds must be CID-attached prior to settlement.
- **Sanctions & Freeze:** per-address `frozen[addr]` and global `paused` respected across modules; emergency 2-of-3 SAFE action to toggle.
- **Jurisdiction Policies:** `PolicyRegistry` holds CID to global policy pack (US/EU/UK/SG/AE/IN). `AFORouterV2` applies jurisdiction codes to fee/tax schedules; `TransferAgent` enforces legends (e.g., Reg D 144 lockups, Reg S Cat 3).
- **Proof Gates:** PoR required for stablecoin mint; `MeterProofAdapter.verify` required for REC issuance; appraisal/doc proofs required for water/real-estate transfers.
- **Oracle Safety:** quorum (≥2 feeds), max staleness, and bound checks; on breach → `CircuitBreakerToggled(true, cause)`.

---

# ✅ Security/Test Checklist (the agent should auto-generate)

- **Slither config** (suppress only known safe patterns), **Mythril/Manticore** optional.  
- **Echidna** properties: AFO monotonicity, liveness of circuit breaker (re-enable by guardian), serial uniqueness, upgrade safety invariants.  
- **Upgrade test:** Deploy V1, set sentinel values, upgrade to V2 (new var appended), assert invariants, replay events.  
- **Gas tests:** snapshots for hot paths (mint, route, post, retire, transferPartitioned).  
- **Mainnet-fork oracle tests** (Chainlink/Pyth adapters, staleness/equivocation cases).  

---

# ✅ Deliverable Artifacts (agent must output)

- Full Solidity source + Foundry/Hardhat tests.  
- `scripts/` for deploy/upgrade/roles (Amoy + mainnet).  
- `/subgraph/` schema + mappings; `/iso-bus/` exporter (TS) with CLI.  
- `/docs/` as listed above.  
- `README_DEPLOY.md` with exact commands and env vars.  
- **Coverage**, **Slither report**, **Echidna logs**, **gas reports** as build artifacts.

---

# 🧪 Bonus: Red-Team Scenarios (agent must include tests for)

- **Oracle staleness & price gap** → auto-pause.  
- **PoR signer rotation** → old signer rejected; new accepted.  
- **Sanctions hit mid-transfer** → revert before settlement.  
- **Policy change (jurisdiction exempt → non-exempt)** → AFO recalculates taxes/fees deterministically.  
- **Upgrade attempt by non-timelock** → revert.  
- **Serial double-bind** on REC/Carbon bridges → revert; cumulative retired monotonic.  

---

# 🧩 One-line “build this now” prompt (quick start)

> **Build a compliance-native, UUPS-upgradeable RWA stack (modules listed above) in Solidity `^0.8.24` with Foundry/Hardhat, Slither/Echidna, Subgraph + ISO-Bus exporter, and Amoy/mainnet deploy scripts. Enforce ComplianceRegistry gates, TravelRule pointers, PoR & oracle staleness quorums, ISO-mapped events, and pass the acceptance criteria (coverage ≥95%, Slither no HIGH, upgrade rehearsal green). Output code, tests, docs, scripts, and artifacts exactly per the repo layout.**

---
