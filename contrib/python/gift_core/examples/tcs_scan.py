#!/usr/bin/env python3
"""TCS Betti-pair scan — arithmetic exercise across building-block labels.

Scans all pairwise sums of the Betti data of some CHNP building blocks and
compares three of the resulting arithmetic values to experiment.

This is an arithmetic scan of pairs (b2, b3), not a geometric statement:
no twisted connected sum realising (21, 77) is known, orthogonal TCS being
excluded for that pair by parity (GIFT/Foundations/TCSConstruction.lean;
K7 paper v3.6, S1 section 8). The labels "Quintic + CI(2,2,2)" name the
splitting 11 + 10, 40 + 37, kept from version 3.2.

Usage:
    python -m gift_core.examples.tcs_scan

Results:
    Among the scanned pairs, (21, 77) is the only one with:
        - N_gen = 3 (b₂ = 21 = 3 × 7)
        - sin²θ_W = 3/13 ≈ 0.2308 (0.17% from exp)
        - Q_Koide = 14/21 = 2/3 (exact)
"""

from fractions import Fraction
from gift_core.geometry.tcs import TCSManifold, list_building_blocks


# Experimental values (PDG 2024)
EXP_SIN2 = 0.2312
EXP_KOIDE = 0.6667
EXP_N_GEN = 3


def scan_all_pairs():
    """Scan all unique pairs of building blocks."""
    blocks = list_building_blocks()
    results = []

    for i, b1 in enumerate(blocks):
        for b2 in blocks[i:]:
            m = TCSManifold(m1=b1, m2=b2)
            sin2 = float(Fraction(m.b2, m.b3 + 14))
            n_gen = m.b2 // 7 if m.b2 % 7 == 0 else None
            koide = float(Fraction(14, m.b2)) if m.b2 > 0 else 99.0

            d_sin2 = abs(sin2 - EXP_SIN2) / EXP_SIN2 * 100
            d_koide = abs(koide - EXP_KOIDE) / EXP_KOIDE * 100
            n_gen_ok = n_gen == EXP_N_GEN
            score = d_sin2 + d_koide + (0 if n_gen_ok else 50)

            results.append({
                "m1": b1.name, "m2": b2.name,
                "b2": m.b2, "b3": m.b3, "h_star": m.h_star,
                "sin2_theta_w": sin2, "n_gen": n_gen, "koide": koide,
                "d_sin2": d_sin2, "d_koide": d_koide,
                "n_gen_ok": n_gen_ok, "score": score,
            })

    results.sort(key=lambda r: r["score"])
    return results


def print_report(results):
    """Print the full scan report."""
    print("=" * 80)
    print("TCS MANIFOLD SCAN — Topological predictions vs experiment")
    print("=" * 80)

    header = (f"{'Manifold':<32} {'b2':>3} {'b3':>3} {'H*':>3}"
              f" {'sin²θ_W':>9} {'N_gen':>5} {'Q_Koide':>8} {'Score':>7}")
    print(f"\n{header}")
    print("-" * 80)

    for r in results:
        label = f"{r['m1']} + {r['m2']}"
        n_str = str(r["n_gen"]) if r["n_gen"] is not None else "-"
        marker = " <--" if r["score"] < 1.0 else ""
        print(f"{label:<32} {r['b2']:>3} {r['b3']:>3} {r['h_star']:>3}"
              f" {r['sin2_theta_w']:>9.5f} {n_str:>5} {r['koide']:>8.4f}"
              f" {r['score']:>7.1f}{marker}")

    print("-" * 80)
    print(f"{'Experiment':<32} {'':>3} {'':>3} {'':>3}"
          f" {EXP_SIN2:>9.5f} {EXP_N_GEN:>5} {EXP_KOIDE:>8.4f}")

    # Summary
    winner = results[0]
    runner_up = next((r for r in results if r["score"] > 1.0), results[-1])

    print(f"\n{'=' * 80}")
    print(f"WINNER: {winner['m1']} + {winner['m2']}"
          f" (score={winner['score']:.1f})")
    print(f"Runner-up: {runner_up['m1']} + {runner_up['m2']}"
          f" (score={runner_up['score']:.1f})")
    print(f"Advantage: {runner_up['score'] / max(winner['score'], 0.01):.0f}x")
    print(f"\nTotal manifolds scanned: {len(results)}")
    n_gen3 = sum(1 for r in results if r["n_gen_ok"])
    print(f"With N_gen = 3: {n_gen3}")
    print(f"With sin²θ_W within 1%: "
          f"{sum(1 for r in results if r['d_sin2'] < 1)}")
    print(f"With Q_Koide within 1%: "
          f"{sum(1 for r in results if r['d_koide'] < 1)}")


if __name__ == "__main__":
    results = scan_all_pairs()
    print_report(results)
