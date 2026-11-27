#!/usr/bin/env python3
"""Check contrib/python/gift_core/relations_v36.py against the Lean certificate.

The statements of the 33 theorems A01 ... A33 are parsed from
GIFT/Certificate/RelationsV36.lean. For each one this script checks that the
Python package has an entry with the same id and theorem name, and that the
value the package computes from its own constants equals the right-hand side
of the Lean statement. A change of the Lean statements that the package does
not follow makes this script fail.

Usage: python3 scripts/test_relations_v36.py
"""
import math
import re
import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "contrib" / "python"))

from gift_core.relations_v36 import RELATIONS_V36  # noqa: E402

LEAN = ROOT / "GIFT" / "Certificate" / "RelationsV36.lean"

THEOREM = re.compile(r"^theorem (A(\d\d)_\w+)\s*:(.*?):=", re.S | re.M)
RATIONAL_RHS = re.compile(r"=\s*(\d+)\s*/\s*(\d+)\s*$")
INTEGER_RHS = re.compile(r"=\s*(\d+)\s*$")

# Right-hand sides that are not a rational or an integer: the evaluated form
# the Lean statement must contain, and the float it stands for.
SPECIAL = {
    "A02": ("Real.sqrt 2 / 12", math.sqrt(2) / 12),
    "A03": ("Real.sqrt 17 / 32", math.sqrt(17) / 32),
    "A23": ("Real.log 2 * (98 / 99)", math.log(2) * 98 / 99),
}


def main() -> int:
    text = LEAN.read_text(encoding="utf-8")
    lean = {}
    for name, num, stmt in THEOREM.findall(text):
        lean[f"A{num}"] = (name, " ".join(stmt.split()))

    errors = []
    expected_ids = [f"A{i:02d}" for i in range(1, 34)]
    if sorted(lean) != expected_ids:
        errors.append(f"Lean file: expected theorems A01..A33, found {sorted(lean)}")
    py_ids = [r.id for r in RELATIONS_V36]
    if py_ids != expected_ids:
        errors.append(f"package: expected entries A01..A33 in order, found {py_ids}")

    checked = 0
    for r in RELATIONS_V36:
        if r.id not in lean:
            continue
        name, stmt = lean[r.id]
        if name != r.lean_theorem:
            errors.append(f"{r.id}: theorem name {r.lean_theorem!r} vs Lean {name!r}")

        if r.id in SPECIAL:
            form, val = SPECIAL[r.id]
            if form not in stmt:
                errors.append(f"{r.id}: Lean statement no longer contains {form!r}")
            if not math.isclose(float(r.value), val, rel_tol=1e-14):
                errors.append(f"{r.id}: package {r.value!r} vs {val!r}")
        elif r.id == "A07":
            m = re.search(r"\((\d+) : ℝ\) <.*< (\d+)", stmt)
            if not m or "dim_J3O = 27" not in stmt:
                errors.append("A07: Lean statement not of the expected form")
            elif not int(m.group(1)) < float(r.value) < int(m.group(2)):
                errors.append(f"A07: package {r.value!r} outside Lean bounds {m.groups()}")
            elif r.stated != f"{m.group(1)} < 27^phi < {m.group(2)}":
                errors.append(f"A07: stated {r.stated!r} vs Lean bounds {m.groups()}")
        elif r.id == "A24":
            if not ("D_bulk = 11" in stmt and "Weyl_factor = 5" in stmt
                    and "riemannZeta 11 / riemannZeta 5" in stmt):
                errors.append("A24: Lean statement not of the expected form")
            # zeta(11)/zeta(5) to 12 digits, from the Euler products' known values
            if not math.isclose(float(r.value), 1.0004941886041194 / 1.0369277551433699,
                                rel_tol=1e-12):
                errors.append(f"A24: package {r.value!r} is not zeta(11)/zeta(5)")
        else:
            m = RATIONAL_RHS.search(stmt)
            if m:
                rhs = Fraction(int(m.group(1)), int(m.group(2)))
                stated = f"{m.group(1)}/{m.group(2)}"
            else:
                m = INTEGER_RHS.search(stmt)
                if not m:
                    errors.append(f"{r.id}: cannot read the Lean right-hand side: {stmt!r}")
                    continue
                rhs = int(m.group(1))
                stated = m.group(1)
            if r.value != rhs:
                errors.append(f"{r.id}: package {r.value} vs Lean {rhs}")
            if r.stated != stated:
                errors.append(f"{r.id}: stated {r.stated!r} vs Lean {stated!r}")
            if isinstance(rhs, int) != isinstance(r.value, int):
                errors.append(f"{r.id}: type {type(r.value).__name__} vs Lean {stated}")
        checked += 1

    if errors:
        for e in errors:
            print(f"FAIL  {e}")
        return 1
    print(f"OK  {checked} relations of gift_core.relations_v36 agree with {LEAN.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
