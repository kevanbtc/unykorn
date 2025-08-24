# API Epics

## Auth
- `POST /api/auth/login` – returns tenant scoped JWT.

## Estimating
- `POST /api/estimating/estimate` – compute line totals and grand total.
- `GET /api/estimating/export/xml` – return carrier XML for an estimate.

## Incentives
- `POST /api/incentives/stack` – apply incentive rules to a project.
- `POST /api/incentives/finance` – return IRR, NPV and LCOE metrics.

