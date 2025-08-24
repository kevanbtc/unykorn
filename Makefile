.PHONY: api dev test seed

api:
	uvicorn backend.app.main:app --reload --port 8000
dev:
	( cd frontend/apps/public-site && npm ci && npm run dev ) & \
	( cd frontend/apps/partner-dashboards && npm ci && npm run dev ) & \
	( cd frontend/apps/investor-dash && npm ci && npm run dev )
test:
	pytest -q && npm test --silent
seed:
	python -m backend.db.seed
