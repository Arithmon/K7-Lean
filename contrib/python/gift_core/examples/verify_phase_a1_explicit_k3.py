"""Lightweight verification for the Phase A.1 explicit K3 workbench.

Checks the JK Betti predictor, Nikulin (r,a,δ) → (g,k) formula, and the
predictions of the candidate explicit K3 models (generic sextic, reducible
sextic, Kummer skeleton).

Returns a dict of named bool checks. Prints PASS / FAIL per check and exits
non-zero if any check fails.
"""

from __future__ import annotations

from gift_core.geometry.k3_explicit import (
    JKBettiPredictor,
    K3ReducibleSexticDoubleCover,
    KummerK3Model,
    PhaseA1MasterAudit,
    audit_phase_a1_master,
    nikulin_g_k_from_rad,
)


def verify() -> dict[str, bool]:
    # Nikulin formula sanity.
    nikulin_11_7_1 = nikulin_g_k_from_rad(11, 7, 1)
    nikulin_11_9_1 = nikulin_g_k_from_rad(11, 9, 1)
    nikulin_10_10_0 = nikulin_g_k_from_rad(10, 10, 0)

    # JK Betti predictor sanity.
    gift_profile = JKBettiPredictor.gift_target_profile()
    gift_b2_b3 = JKBettiPredictor().predict(gift_profile)

    sextic_profile = JKBettiPredictor.generic_sextic_v4_s3_profile()
    sextic_b2_b3 = JKBettiPredictor().predict(sextic_profile)

    # Reducible sextic predictions.
    reducible = K3ReducibleSexticDoubleCover()
    reducible_report = reducible.predicted_full_betti()

    # Kummer skeleton predictions.
    kummer = KummerK3Model()
    kummer_report = kummer.predicted_full_betti()

    # Master audit.
    master = audit_phase_a1_master()

    return {
        "nikulin_11_7_1_yields_g_k_2_2": nikulin_11_7_1 == (2, 2),
        "nikulin_11_9_1_yields_g_k_1_1": nikulin_11_9_1 == (1, 1),
        "nikulin_10_10_0_empty_sentinel": nikulin_10_10_0 == (-1, 0),
        "jk_predictor_gift_profile_21_components": len(gift_profile) == 21,
        "jk_predictor_gift_profile_yields_21_77": gift_b2_b3 == (21, 77),
        "jk_predictor_failed_sextic_yields_16_94": sextic_b2_b3 == (16, 94),
        "reducible_sextic_total_nodes_of_B_is_10": reducible.count_branch_curve_nodes()[
            "total_nodes_of_B"
        ]
        == 10,
        "reducible_sextic_picard_rank_geq_11": reducible.predicted_picard_rank_lower_bound()
        >= 11,
        "reducible_sextic_iota_matches_11_7_1": reducible_report["iota_matches_11_7_1"]
        is True,
        "reducible_sextic_does_not_match_full_gift": reducible_report[
            "matches_gift_target"
        ]
        is False,
        "reducible_sextic_predicted_b2_b3_is_17_67": (
            reducible_report["predicted_b2"],
            reducible_report["predicted_b3"],
        )
        == (17, 67),
        "kummer_picard_rank_at_least_17": kummer.picard_rank_lower_bound >= 17,
        "kummer_naive_tau_does_not_match_11_7_1": kummer_report[
            "matches_gift_tau_11_7_1"
        ]
        is False,
        "master_audit_predictor_implemented": master["lean_bool_certificates"][
            "phase_a1_jk_betti_predictor_implemented"
        ]
        is True,
        "master_audit_gift_target_sanity": master["lean_bool_certificates"][
            "phase_a1_gift_target_profile_yields_21_77"
        ]
        is True,
        "master_audit_reducible_iota_partial_positive": master["lean_bool_certificates"][
            "phase_a1_reducible_sextic_iota_matches_11_7_1"
        ]
        is True,
        "master_audit_reducible_picard_partial_positive": master[
            "lean_bool_certificates"
        ]["phase_a1_reducible_sextic_picard_rank_geq_11"]
        is True,
        "master_audit_no_full_explicit_model_yet_honest_no_go": master[
            "lean_bool_certificates"
        ]["phase_a1_explicit_model_realizes_gift_betti"]
        is False,
    }


def main() -> None:
    results = verify()
    for name, passed in results.items():
        print(f"{name}: {'PASS' if passed else 'FAIL'}")
    if not all(results.values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
