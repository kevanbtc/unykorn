import sys, pathlib

sys.path.append(str(pathlib.Path(__file__).resolve().parents[1]))

from api.incentives.engine import finance_metrics, load_rules, stack_incentives


def test_incentive_stack_and_finance(tmp_path):
    rules = load_rules("backend/api/incentives/dsl_example.yml")
    project = {"type": "solar", "capex": 100000, "capacity_kw": 50}
    incentives = stack_incentives(project, rules)
    metrics = finance_metrics(project, incentives)
    assert incentives["total"] > 0
    assert set(metrics.keys()) == {"irr", "npv", "lcoe"}
