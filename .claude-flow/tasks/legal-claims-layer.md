You are a swarm of specialized AI engineers working inside the monorepo `power-drs-platform`
for Unykorn Global Finance (Eagle Eye Construction). All work is CONFIDENTIAL & PROPRIETARY.

## Goal
Embed a legal and compliance layer into the claims workflow so the platform can parse
insurance policies, map losses to coverage, enforce jurisdictional regulations and
produce litigation-ready binders.

## Context
- Backend: FastAPI, Postgres + pgVector, object storage for documents
- Frontend: Next.js 14 partner dashboards
- All documents and policies are stored as PDFs/Word with embeddings for semantic search
- Swarm orchestrator: Claude Flow

---

## Deliverables

### 1. Policy Parsing & Legal Normalization
- Endpoint `POST /api/policy/parse` to ingest policy PDFs/Word docs
- Extract coverage types, exclusions, deductibles, riders, endorsements
- Store structured data in `policies` and `policy_clauses` tables
- Index clauses with pgVector for semantic search and citation
- UI: policy viewer with searchable clauses
- Tests: policy parser correctly extracts key fields

### 2. Loss & Coverage Mapping
- Endpoint `POST /api/policy/map_loss` to associate estimate line items with policy sections
- Tag estimator results to coverage buckets (e.g. Dwelling A, Contents C)
- Flag ambiguous or excluded items before submission
- UI: loss-to-coverage mapping view inside partner dashboards
- Tests: mapping function assigns correct coverage based on sample policy

### 3. Compliance & Litigation Guardrails
- Rules engine for state DOI timelines and required notices
- Immutable audit trail of communications, estimates, and exports
- Automated letter templates: reservation of rights, proof of loss, appraisal demand, bad faith notice
- UI: generate and send legal notices
- Tests: rules engine triggers deadlines and generates letters with sample data

### 4. Dispute / Ambiguity Resolution
- `PolicyAgent` generates interpretation reports citing policy pages and state regs
- Endpoint `POST /api/policy/legal_report` returning memo-style summary
- Store reports in object storage with hash for integrity
- Tests: report includes citations and is reproducible from same inputs

### 5. Litigation-Readiness Package
- Endpoint `POST /api/policy/litigation_bundle` assembling:
  - Policy excerpts
  - Loss mapping
  - Estimates and notices
  - Communication audit trail
- Export as PDF/JSON with immutable hash
- UI: "Download Litigation Package" button on claim view
- Tests: bundle includes all referenced artifacts and hash matches contents

---

## General Requirements
- Open PR titled `feat(legal): policy compliance layer`
- Include DB migrations, routers, frontend components, docs, and tests
- Ensure `/docs` updated with new endpoints and examples
- Run CI (`pytest`, `npm test`, docker healthcheck`) before merging

---

## Task Assignment
- **Planner**: break deliverables into subtasks and assign to agents
- **PolicyAgent**: parse policies and extract structured clauses
- **CoverageAgent**: map losses and flag ambiguities
- **LegalAgent**: generate interpretation reports and notices
- **Backend Engineer**: implement endpoints and migrations
- **Frontend Engineer**: build policy viewer, mapping UI, notice generator
- **Compliance Officer**: verify rules engine against state DOI guidance
- **Tech Writer**: document workflows and legal notices in `/docs`

---

## Acceptance Criteria
- Policies can be parsed and searched with citations back to source documents
- Estimates are mapped to coverage sections with exclusions flagged
- System tracks regulatory deadlines and can issue standard legal notices
- Legal reports and litigation bundles are generated with immutable proofs
- All new endpoints and UIs are tested and documented
