from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

try:
    from jinja2 import Template
except Exception:
    Template = None

TEMPLATE_STR = (
    "Petition to Establish Paternity\n\n"
    "Petitioner: {{ petitioner }}\n"
    "Respondent: {{ respondent }}\n"
    "Child: {{ child }} born on {{ child_dob }}\n"
    "County: {{ county }}\n"
)


class DraftRequest(BaseModel):
    petitioner: str
    respondent: str
    child: str
    county: str
    child_dob: str


@router.post("/")
async def create_draft(req: DraftRequest):
    if not Template:
        return {"status": "degraded", "draft": "Jinja2 not installed"}

    template = Template(TEMPLATE_STR)
    draft = template.render(**req.dict())
    return {"status": "ok", "draft": draft}
