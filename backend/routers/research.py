from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

try:
    import requests
except Exception:
    requests = None

try:
    from transformers import pipeline
except Exception:
    pipeline = None


class ResearchRequest(BaseModel):
    query: str


@router.post("/")
async def research(req: ResearchRequest):
    cases = []
    status = "ok"

    if requests:
        try:
            resp = requests.get(
                "https://www.courtlistener.com/api/rest/v3/opinions/",
                params={"search": req.query},
                timeout=5,
            )
            resp.raise_for_status()
            data = resp.json()
            cases = data.get("results", [])[:3]
        except Exception:
            status = "degraded"
    else:
        status = "degraded"

    answer = ""
    if pipeline:
        try:
            qa = pipeline("question-answering")
            context = " ".join([c.get("plain_text", "") for c in cases])
            result = qa(question=req.query, context=context)
            answer = result.get("answer", "")
        except Exception:
            status = "degraded"
            answer = "Legal-BERT error"
    else:
        status = "degraded"
        answer = "Legal-BERT not installed"

    if not answer:
        answer = "No answer generated"

    return {"status": status, "cases": cases, "answer": answer}
