import yaml


def load_rules(path: str):
    with open(path) as f:
        return yaml.safe_load(f)


def stack_incentives(project: dict, rules: list):
    total = 0
    applied = []
    for rule in rules:
        if project.get("type") not in rule.get("applies_to", []):
            continue
        amount = rule["amount"]["value"] * project["capex"]
        applied.append({"id": rule["id"], "amount": amount})
        total += amount
    return {"applied": applied, "total": total}


def finance_metrics(project: dict, incentives: dict):
    net_capex = project["capex"] - incentives.get("total", 0)
    irr = 0.1  # placeholder
    npv = -net_capex
    lcoe = net_capex / project.get("capacity_kw", 1)
    return {"irr": irr, "npv": npv, "lcoe": lcoe}

