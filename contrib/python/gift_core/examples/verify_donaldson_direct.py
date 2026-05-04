"""Lightweight verification for the Donaldson-direct workbench."""

from __future__ import annotations

from gift_core.geometry.donaldson import (
    DonaldsonG2Ansatz,
    DonaldsonTopology,
    FanoMeridianModel,
    solve_min_energy_radial_profile,
    solve_rotating_coframe_profile,
    solve_signed_radial_profile,
)


def verify() -> dict[str, bool]:
    meridians = FanoMeridianModel()
    topology = DonaldsonTopology(meridian_model=meridians)
    ansatz = DonaldsonG2Ansatz()
    ansatz_report = ansatz.report()
    radial = solve_min_energy_radial_profile()
    radial_report = radial.dense_report()
    signed = solve_signed_radial_profile()
    signed_report = signed.dense_report()
    rotating = solve_rotating_coframe_profile()
    rotating_report = rotating.dense_report()

    return {
        "fano_relation_rank_11": meridians.relation_rank == 11,
        "fano_quotient_rank_3": meridians.quotient_rank == 3,
        "fano_cokernel_primitive": meridians.maximal_minor_gcd == 1,
        "fano_nonzero_maximal_minors_232": meridians.nonzero_maximal_minor_count == 232,
        "topology_b2_21": topology.b2 == 21,
        "topology_twisted_h1_76": topology.twisted_h1_dimension == 76,
        "topology_b3_77": topology.b3 == 77,
        "topology_hstar_99": topology.h_star == 99,
        "ansatz_det_constraint": str(ansatz.determinant_constraint) == "Eq(a**6*b**8, 65/32)",
        "ansatz_phi_has_7_components": len(ansatz_report["phi_components"]) == 7,
        "ansatz_star_phi_has_7_components": len(ansatz_report["star_phi_components"]) == 7,
        "ansatz_connection_has_3_curvatures": set(ansatz_report["connection_curvature_forms"]) == {"F1", "F2", "F3"},
        "ansatz_coclosed_compensator_is_fiber_volume": ansatz_report["coclosed_compensator_form"] == {"4567": "lambda"},
        "radial_determinant_preserved": radial_report["max_abs_determinant_error"] < 1e-12,
        "radial_dphi_compensated": radial_report["max_abs_compensated_dphi"] < 1e-12,
        "radial_coclosed_compensated": radial_report["max_abs_compensated_coclosed"] < 1e-12,
        "radial_boundary_order_2": radial_report["boundary_order"] == 2,
        "radial_connection_samples_present": set(radial_report["connection_component_samples"]["curvature"]) == {
            "F1_23",
            "F2_31",
            "F3_12",
        },
        "so3_matrix_samples_present": "so3_connection" in radial_report,
        "so3_real_branch_exposes_signed_obstruction": radial_report["so3_connection"]["max_abs_signed_residual"] > 0.0,
        "so3_real_branch_has_negative_requested_sector": radial_report["so3_connection"]["negative_requested_fraction"] > 0.0,
        "hk_rotation_smoothness_C1": signed_report["hk_rotation"]["max_orthogonality_error"] < 1e-12,
        "signed_branch_resolves_negative_curvature": signed_report["signed_so3_connection"]["max_abs_signed_curvature_residual"] < 1e-12,
        "nu_profiles_vanish_at_boundary": signed_report["hk_rotation"]["max_abs_nu_boundary"] < 1e-12,
        "combined_dphi_compensated_to_machine_precision": signed_report["max_abs_compensated_dphi"] < 1e-12,
        "combined_coclosed_compensated": signed_report["max_abs_compensated_coclosed"] < 1e-12,
        "sign_pattern_consistent_with_rotation_path": signed_report["signed_so3_connection"]["negative_requested_coverage"] > 0.0,
        "no_indefinite_or_complex_metric_introduced": signed_report["positive_definite_metric"] is True,
        "active_hk_rotation_enabled": rotating_report["active_hk_rotation"] is True,
        "base_coframe_coefficients_vanish_at_boundary": rotating_report["base_coframe"]["max_abs_boundary_coefficient"] < 1e-12,
        "base_coframe_cancels_rotation_dphi": rotating_report["max_abs_combined_rotation_base_dphi"] < 1e-12,
        "base_coframe_bianchi_residual_zero": rotating_report["base_coframe"]["max_abs_ddtheta_residual"] < 1e-12,
        "rotating_branch_stays_so3": rotating_report["hk_rotation"]["max_abs_det_minus_one"] < 1e-12,
        "rotating_branch_keeps_real_metric": rotating_report["positive_definite_metric"] is True,
    }


def main() -> None:
    results = verify()
    for name, passed in results.items():
        print(f"{name}: {'PASS' if passed else 'FAIL'}")
    if not all(results.values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
