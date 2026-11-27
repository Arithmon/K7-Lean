"""
GIFT Verification Module.

Functions to verify all certified relations and check consistency.
Useful for testing and demonstrations.
"""
from fractions import Fraction
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass

from .constants import (
    # Algebra
    DIM_E8, RANK_E8, DIM_G2, DIM_K7, DIM_J3O,
    WEYL_FACTOR, WEYL_E8_ORDER, DIM_F4, DIM_E6, DIM_E7,
    # Topology
    M1_B2, M1_B3, M2_B2, M2_B3,
    B2, B3, H_STAR, P2, D_BULK,
    # Structural
    N_GEN, PSL27_ORDER,
    # Physics
    SIN2_THETA_W, Q_KOIDE, M_TAU_M_E, KAPPA_T, KAPPA_T_INV,
    GAMMA_GIFT, ALPHA_INV_BASE, DET_G, TAU,
    # Cosmology
    OMEGA_DE_FRACTION,
)


@dataclass
class VerificationResult:
    """Result of a single verification check."""
    name: str
    passed: bool
    expected: str
    actual: str
    category: str


def verify_all() -> List[VerificationResult]:
    """
    Run all verification checks and return results.

    Returns a list of VerificationResult objects.
    """
    results = []

    # ==========================================================================
    # ARITHMETIC WITNESSES OF (21, 77) (v3.2 labels; not a TCS construction)
    # ==========================================================================

    results.append(VerificationResult(
        name="b2_derivation",
        passed=(M1_B2 + M2_B2 == B2),
        expected=f"M1_B2 + M2_B2 = {B2}",
        actual=f"{M1_B2} + {M2_B2} = {M1_B2 + M2_B2}",
        category="TCS"
    ))

    results.append(VerificationResult(
        name="b3_derivation",
        passed=(M1_B3 + M2_B3 == B3),
        expected=f"M1_B3 + M2_B3 = {B3}",
        actual=f"{M1_B3} + {M2_B3} = {M1_B3 + M2_B3}",
        category="TCS"
    ))

    results.append(VerificationResult(
        name="H_star_derivation",
        passed=(B2 + B3 + 1 == H_STAR),
        expected=f"B2 + B3 + 1 = {H_STAR}",
        actual=f"{B2} + {B3} + 1 = {B2 + B3 + 1}",
        category="TCS"
    ))

    # ==========================================================================
    # WEYL TRIPLE IDENTITY (v3.2)
    # ==========================================================================

    results.append(VerificationResult(
        name="weyl_path_1",
        passed=((DIM_G2 + 1) // N_GEN == WEYL_FACTOR),
        expected=f"(dim_G2 + 1) / N_gen = {WEYL_FACTOR}",
        actual=f"({DIM_G2} + 1) / {N_GEN} = {(DIM_G2 + 1) // N_GEN}",
        category="Structural"
    ))

    results.append(VerificationResult(
        name="weyl_path_2",
        passed=(B2 // N_GEN - P2 == WEYL_FACTOR),
        expected=f"b2 / N_gen - p2 = {WEYL_FACTOR}",
        actual=f"{B2} / {N_GEN} - {P2} = {B2 // N_GEN - P2}",
        category="Structural"
    ))

    results.append(VerificationResult(
        name="weyl_path_3",
        passed=(DIM_G2 - RANK_E8 - 1 == WEYL_FACTOR),
        expected=f"dim_G2 - rank_E8 - 1 = {WEYL_FACTOR}",
        actual=f"{DIM_G2} - {RANK_E8} - 1 = {DIM_G2 - RANK_E8 - 1}",
        category="Structural"
    ))

    # ==========================================================================
    # PSL(2,7) = 168 (v3.2)
    # ==========================================================================

    results.append(VerificationResult(
        name="psl27_path_1",
        passed=((B3 + DIM_G2) + B3 == PSL27_ORDER),
        expected=f"(b3 + dim_G2) + b3 = {PSL27_ORDER}",
        actual=f"({B3} + {DIM_G2}) + {B3} = {(B3 + DIM_G2) + B3}",
        category="Structural"
    ))

    results.append(VerificationResult(
        name="psl27_path_2",
        passed=(RANK_E8 * B2 == PSL27_ORDER),
        expected=f"rank_E8 * b2 = {PSL27_ORDER}",
        actual=f"{RANK_E8} * {B2} = {RANK_E8 * B2}",
        category="Structural"
    ))

    results.append(VerificationResult(
        name="psl27_path_3",
        passed=(N_GEN * (B3 - B2) == PSL27_ORDER),
        expected=f"N_gen * (b3 - b2) = {PSL27_ORDER}",
        actual=f"{N_GEN} * ({B3} - {B2}) = {N_GEN * (B3 - B2)}",
        category="Structural"
    ))

    # ==========================================================================
    # PHYSICAL RELATIONS
    # ==========================================================================

    sin2_computed = Fraction(B2, B3 + DIM_G2)
    results.append(VerificationResult(
        name="weinberg_angle",
        passed=(sin2_computed == SIN2_THETA_W),
        expected=f"sin²θ_W = {SIN2_THETA_W}",
        actual=f"b2/(b3+dim_G2) = {B2}/({B3}+{DIM_G2}) = {sin2_computed}",
        category="Physics"
    ))

    q_computed = Fraction(DIM_G2, B2)
    results.append(VerificationResult(
        name="koide_parameter",
        passed=(q_computed == Q_KOIDE),
        expected=f"Q = {Q_KOIDE}",
        actual=f"dim_G2/b2 = {DIM_G2}/{B2} = {q_computed}",
        category="Physics"
    ))

    kappa_computed = B3 - DIM_G2 - P2
    results.append(VerificationResult(
        name="kappa_T_inverse",
        passed=(kappa_computed == KAPPA_T_INV),
        expected=f"κ_T⁻¹ = {KAPPA_T_INV}",
        actual=f"b3 - dim_G2 - p2 = {B3} - {DIM_G2} - {P2} = {kappa_computed}",
        category="Physics"
    ))

    alpha_base = (DIM_E8 + RANK_E8) // 2 + H_STAR // D_BULK
    results.append(VerificationResult(
        name="alpha_inverse_base",
        passed=(alpha_base == ALPHA_INV_BASE),
        expected=f"α⁻¹ base = {ALPHA_INV_BASE}",
        actual=f"({DIM_E8}+{RANK_E8})/2 + {H_STAR}/{D_BULK} = {alpha_base}",
        category="Physics"
    ))

    # ==========================================================================
    # EXCEPTIONAL CHAIN
    # ==========================================================================

    results.append(VerificationResult(
        name="E6_chain",
        passed=(6 * 13 == DIM_E6),
        expected=f"6 × 13 = {DIM_E6}",
        actual=f"6 × 13 = {6 * 13}",
        category="Exceptional"
    ))

    results.append(VerificationResult(
        name="E7_chain",
        passed=(7 * 19 == DIM_E7),
        expected=f"7 × 19 = {DIM_E7}",
        actual=f"7 × 19 = {7 * 19}",
        category="Exceptional"
    ))

    results.append(VerificationResult(
        name="E8_chain",
        passed=(8 * 31 == DIM_E8),
        expected=f"8 × 31 = {DIM_E8}",
        actual=f"8 × 31 = {8 * 31}",
        category="Exceptional"
    ))

    # ==========================================================================
    # COSMOLOGY
    # ==========================================================================

    omega_computed = Fraction(B2 + B3, H_STAR)
    results.append(VerificationResult(
        name="dark_energy_fraction",
        passed=(omega_computed == OMEGA_DE_FRACTION),
        expected=f"Ω_DE = {OMEGA_DE_FRACTION}",
        actual=f"(b2+b3)/H* = ({B2}+{B3})/{H_STAR} = {omega_computed}",
        category="Cosmology"
    ))

    # ==========================================================================
    # ROOT SYSTEM
    # ==========================================================================

    e8_roots_count = 112 + 128
    results.append(VerificationResult(
        name="E8_root_count",
        passed=(e8_roots_count == 240),
        expected="240 roots",
        actual=f"D8({112}) + HalfInt({128}) = {e8_roots_count}",
        category="RootSystem"
    ))

    e8_dim = e8_roots_count + RANK_E8
    results.append(VerificationResult(
        name="E8_dimension",
        passed=(e8_dim == DIM_E8),
        expected=f"dim(E8) = {DIM_E8}",
        actual=f"roots + rank = {e8_roots_count} + {RANK_E8} = {e8_dim}",
        category="RootSystem"
    ))

    return results


def verify_summary() -> Dict[str, any]:
    """Run all verifications and return a summary."""
    results = verify_all()

    passed = sum(1 for r in results if r.passed)
    failed = sum(1 for r in results if not r.passed)

    by_category = {}
    for r in results:
        if r.category not in by_category:
            by_category[r.category] = {'passed': 0, 'failed': 0}
        if r.passed:
            by_category[r.category]['passed'] += 1
        else:
            by_category[r.category]['failed'] += 1

    return {
        'total': len(results),
        'passed': passed,
        'failed': failed,
        'success_rate': passed / len(results) if results else 0,
        'by_category': by_category,
        'all_passed': failed == 0,
    }


def print_verification_report():
    """Print a formatted verification report."""
    results = verify_all()
    summary = verify_summary()

    print("=" * 60)
    print("GIFT VERIFICATION REPORT")
    print("=" * 60)
    print()

    current_category = None
    for r in results:
        if r.category != current_category:
            print(f"\n[{r.category}]")
            current_category = r.category

        status = "✓" if r.passed else "✗"
        print(f"  {status} {r.name}")
        if not r.passed:
            print(f"      Expected: {r.expected}")
            print(f"      Actual:   {r.actual}")

    print()
    print("=" * 60)
    print(f"SUMMARY: {summary['passed']}/{summary['total']} passed")
    if summary['all_passed']:
        print("All verifications PASSED ✓")
    else:
        print(f"FAILED: {summary['failed']} verification(s)")
    print("=" * 60)


# Convenience function
def verify() -> bool:
    """Quick verification - returns True if all checks pass."""
    return verify_summary()['all_passed']
