from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

try:
    from lexnlp.extract.en.entities.persons import get_persons
except Exception:
    get_persons = None


class TrialRequest(BaseModel):
    prep_text: str


@router.post("/")
async def trial_prep(req: TrialRequest):
    if not get_persons:
        return {
            "status": "degraded",
            "entities": [],
            "questions": ["LexNLP not installed"],
        }

    try:
        entities = list(get_persons(req.prep_text))
    except Exception:
        entities = []

    questions = [f"Isn't it true that {e}?" for e in entities] if entities else ["No entities found"]
    status = "ok" if entities else "degraded"
    return {"status": status, "entities": entities, "questions": questions}
