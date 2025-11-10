from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routers import draft, research, strategy, trial

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(research.router, prefix="/research")
app.include_router(draft.router, prefix="/draft")
app.include_router(strategy.router, prefix="/strategy")
app.include_router(trial.router, prefix="/trial")
