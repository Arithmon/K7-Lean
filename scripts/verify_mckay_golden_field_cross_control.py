#!/usr/bin/env python3
"""Check the frozen external McKay crossover fixture against Arithmon receipts.

This verifier does not import OPH. The pinned OPH producer was executed only
after the Arithmon reconstruction was committed; its extracted invariant
summary is preserved in the crossover JSON.
"""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FIXTURE = ROOT / "certificates" / "oph_mckay_golden_field_cross_control.json"

def verify() -> dict:
    x = json.loads(FIXTURE.read_text())
    raw = json.loads((ROOT / "certificates" / "mckay_golden_field_certificate.json").read_text())
    ref = json.loads((ROOT / "certificates" / "mckay_golden_field_reference.json").read_text())
    checks = {
        "raw_group_order": raw["source_group"]["order"] == 120,
        "verified_group_order": ref["independent_verifier"]["group_order"] == 120,
        "class_count": raw["conjugacy_classes"]["count"] == 9,
        "dimensions": sorted(raw["irreducibles"]["dimensions"]) == x["compared_invariants"]["irreducible_dimension_multiset"]["arithmon"],
        "sum_squares": raw["irreducibles"]["sum_squared_dimensions"] == 120,
        "affine_e8": ref["affine_e8"]["isomorphic"] is True,
        "galois_affine_e8": ref["galois"]["same_affine_e8_graph_type"] is True,
        "oph_commit_pin": x["oph"]["commit"] == "4ae2148a26ce15591adaac78ff408fb2cc32d3a2",
        "oph_blob_pin": x["oph"]["producer_blob_sha"] == "2938db085477737cab6eb09a3a87f7330c37f473",
        "no_oph_derivation_input": x["derivation_firewall"]["oph_used_as_derivation_input"] is False,
        "no_koide": x["derivation_firewall"]["koide_used"] is False,
    }
    if not all(checks.values()):
        raise ValueError("McKay crossover fixture failed: " + str([k for k,v in checks.items() if not v]))
    if x["comparison_result"] != "INDEPENDENT_EXACT_AGREEMENT":
        raise ValueError("unexpected cross-control result")
    return {"schema": x["schema"], "comparison_result": x["comparison_result"], "checks": checks}

if __name__ == "__main__":
    print(json.dumps(verify(), indent=2, sort_keys=True))
