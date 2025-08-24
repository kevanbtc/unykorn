from fastapi import FastAPI
from backend.api.esg.router import router as esg_router

app = FastAPI()

app.include_router(esg_router, prefix="/api/esg", tags=["esg"])


@app.get("/health")
def health():
    return {"status": "ok"}

