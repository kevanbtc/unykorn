import sys, pathlib

sys.path.append(str(pathlib.Path(__file__).resolve().parents[1]))

from api.estimating.exporter import to_carrier_xml


def test_to_carrier_xml_totals():
    estimate = {
        "items": [{"code": "A1", "description": "Item", "qty": 2, "unit_cost": 10}],
        "tax_rate": 0.1,
        "ohp_rate": 0.1,
    }
    xml = to_carrier_xml(estimate)
    assert "<subtotal>20" in xml
    assert "<tax>2.0" in xml
    assert "<overhead_profit>2.0" in xml
    assert "<total>24.0" in xml
