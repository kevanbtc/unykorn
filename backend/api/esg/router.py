from fastapi import APIRouter
from .scorecard import build_scorecard
from .report import generate_report

router = APIRouter()

@router.post("/assess")
def assess(payload: dict):
    return {"scorecard": build_scorecard(payload)}

@router.post("/credits")
def credits(payload: dict):
    return {"credits": []}

@router.post("/energystar")
def energystar(payload: dict):
    return {"eligible": False}

@router.get("/report")
def report():
    return {"report": generate_report({})}
