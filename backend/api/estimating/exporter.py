from xml.etree.ElementTree import Element, SubElement, tostring


def to_carrier_xml(estimate: dict) -> str:
    """Create a tiny carrier XML with totals."""
    root = Element("estimate", xmlns="http://example.com/carrier")
    lines = SubElement(root, "lines")
    subtotal = 0.0
    for item in estimate.get("items", []):
        line = SubElement(lines, "line")
        for key in ["code", "description", "qty", "unit_cost"]:
            SubElement(line, key).text = str(item.get(key, ""))
        line_total = item.get("qty", 0) * item.get("unit_cost", 0)
        SubElement(line, "line_total").text = str(line_total)
        subtotal += line_total
    tax = subtotal * estimate.get("tax_rate", 0)
    ohp = subtotal * estimate.get("ohp_rate", 0)
    total = subtotal + tax + ohp
    totals = SubElement(root, "totals")
    SubElement(totals, "subtotal").text = str(subtotal)
    SubElement(totals, "tax").text = str(tax)
    SubElement(totals, "overhead_profit").text = str(ohp)
    SubElement(totals, "total").text = str(total)
    return tostring(root, encoding="unicode")
