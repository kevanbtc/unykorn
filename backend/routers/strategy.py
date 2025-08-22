from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

try:
    from transformers import pipeline
except Exception:
    pipeline = None


class StrategyRequest(BaseModel):
    query: str


@router.post("/")
async def suggest_strategy(req: StrategyRequest):
    if pipeline:
        try:
            generator = pipeline("text-generation")
            result = generator(req.query, max_length=100, num_return_sequences=1)
            suggestion = result[0].get("generated_text", "")
            return {"status": "ok", "strategy": suggestion}
        except Exception:
            pass
    return {
        "status": "degraded",
        "strategy": "Strategy model unavailable",
    }
