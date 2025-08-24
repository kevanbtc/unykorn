# ESG & Sustainability Layer

## Goal
Implement ESG rules engine, incentive mapping, Energy Star evaluation, and report generation to make projects sustainability-ready.

## Deliverables
- Database tables for ESG rules, assessments, and reports.
- FastAPI endpoints:
  - `POST /api/esg/assess` – build ESG scorecard for a project.
  - `POST /api/esg/credits` – map project to federal/state/local ESG incentives.
  - `POST /api/esg/energystar` – evaluate Energy Star readiness.
  - `GET /api/esg/report` – generate ESG binder (PDF/JSON).
- ESG Scorecard agent and Energy Star evaluator stubs.
- Frontend dashboard tab showing ESG scorecard, matched credits, and report download.
- Tests and documentation.

## Acceptance Criteria
- Rules DB seeded with sample programs (48E bonus, PTC, 179D, CA SGIP, NYSERDA, NYC LL97).
- API endpoints return deterministic placeholder data with proper routing.
- Docs describe ESG endpoints and data model.
- `pytest` and `npm test` remain green.
