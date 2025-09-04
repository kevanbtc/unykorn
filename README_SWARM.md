# Mel AI Law – AI Swarm System

This repository describes a multi-agent legal assistant for Melanie Vaughn. It
coordinates independent agents that research law, draft filings, suggest
strategies, and generate cross-examination questions.

## Codex Build Prompt

**Mission**

Build a full-stack AI-powered law firm system for Melanie Vaughn’s paternity
and custody litigation in Florida. The system must act like an AI swarm of
agents working together to intake client data, research Florida law, draft
petitions/motions, suggest custody strategy, and generate trial preparation
questions.

**System Requirements**

- **Backend**: FastAPI with routers `/intake`, `/research`, `/draft`,
  `/strategy`, and `/trial`.
- **Agents**: Python classes in `backend/agents` (`IntakeAgent`,
  `ResearchAgent`, `DraftingAgent`, `StrategyAgent`, `CrossExamAgent`) that
  lazily initialize external dependencies and return safe fallbacks when
  missing.
- **Swarm Orchestrator**: `orchestrator.py` routes tasks between agents and logs
  JSON results.
- **Frontend**: Next.js + Tailwind UI with pages `/intake`, `/research`,
  `/documents`, `/strategy`, and `/trial` that call backend endpoints.
- **Database**: SQLite for development and Postgres for production to store
  case data and drafts.
- **Deployment**: Backend deployed to Railway or Render, frontend to Vercel or
  Netlify, with GitHub Actions handling lint, test, and deploy pipelines.

**Deliverables**

1. Backend scaffold (FastAPI app, routers, agents, orchestrator).
2. Frontend scaffold (Next.js pages with Tailwind styling).
3. `requirements.txt` and `package.json` listing all dependencies, including
   FastAPI, transformers, lexnlp, spacy/blackstone, docassemble, and requests.
4. `DEPLOY.md` with run and deployment instructions.
5. `README.md` explaining the system for contributors.

**Codex Instructions**

- Start by scaffolding the backend routers and agents with safe stubs.
- Each agent should use `try/except` blocks so missing libraries return a
  fallback JSON response instead of crashing.
- Ensure every endpoint responds with JSON for easy frontend consumption.
- Scaffold frontend pages that call the corresponding backend routes.
- Add TODO comments in agents for future feature expansion and integrate
  Tailwind for a simple professional interface.

## Repo Structure

```
mel-ai-law/
├── backend/            # FastAPI + agents
│   ├── main.py
│   ├── routers/
│   │   ├── intake.py
│   │   ├── research.py
│   │   ├── draft.py
│   │   ├── strategy.py
│   │   └── trial.py
│   ├── agents/
│   │   ├── intake_agent.py
│   │   ├── research_agent.py
│   │   ├── drafting_agent.py
│   │   ├── strategy_agent.py
│   │   └── cross_exam_agent.py
│   └── requirements.txt
├── frontend/           # Next.js + Tailwind UI
│   ├── pages/
│   │   ├── index.tsx
│   │   ├── intake.tsx
│   │   ├── research.tsx
│   │   ├── documents.tsx
│   │   ├── strategy.tsx
│   │   └── trial.tsx
│   └── package.json
├── swarm/              # Agent orchestration
│   ├── orchestrator.py
│   ├── task_queue.py
│   └── registry.json
├── README.md
└── DEPLOY.md
```

## Orchestrator Example

```python
import json
from agents.intake_agent import IntakeAgent
from agents.research_agent import ResearchAgent
from agents.drafting_agent import DraftingAgent
from agents.strategy_agent import StrategyAgent
from agents.cross_exam_agent import CrossExamAgent

class Orchestrator:
    def __init__(self):
        self.agents = {
            "intake": IntakeAgent(),
            "research": ResearchAgent(),
            "draft": DraftingAgent(),
            "strategy": StrategyAgent(),
            "cross": CrossExamAgent(),
        }

    def run(self, task: str, payload: dict):
        if task not in self.agents:
            return {"error": "Unknown task"}
        agent = self.agents[task]
        result = agent.run(payload)
        return {"task": task, "result": result}

if __name__ == "__main__":
    orch = Orchestrator()
    print(json.dumps(orch.run("research", {"query": "Florida timesharing law"}), indent=2))
```

## Deployment Targets

* **Codespaces** → development environment
* **Vercel/Netlify** → frontend hosting
* **Railway/Render** → backend API hosting
* **GitHub Actions** → CI/CD for linting, tests, and deploys

## Copilot Usage

Seed the repository with these agent stubs and orchestrator. Then add TODOs
in each agent file so Copilot can expand the implementation step by step.
