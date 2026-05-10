"""Lightweight verification for the Phase A.1 explicit K3 workbench.

Checks the JK Betti predictor, Nikulin (r,a,δ) → (g,k) formula, and the
predictions of the candidate explicit K3 models (generic sextic, reducible
sextic, Kummer skeleton).

Returns a dict of named bool checks. Prints PASS / FAIL per check and exits
non-zero if any check fails.
"""

from __future__ import annotations

from gift_core.geometry.k3_explicit import (
    EllipticK3WeierstrassFull2Torsion,
    GIFTCandidateProfile,
    JKBettiPredictor,
    K3CM_15_7_1_D4_9A1,
    K3GenusTwoSymmetricDoubleCover,
    K3Lattice,
    K3ReducibleSexticDoubleCover,
    K3SexticDoubleCover,
    KummerK3Model,
    PhaseA1MasterAudit,
    TwoElementaryLatticeRAD,
    Z2CubedLatticeAction,
    audit_phase_a1_master,
    branch_a_quick_kill_diagnostic,
    enumerate_branch_singularity_patterns_with_delta_8,
    L_11_7_1_gram,
    L_15_7_1_gram,
    nikulin_admits_primitive_embedding_in_K3,
    nikulin_g_k_from_rad,
    nikulin_primitive_embedding_M_into_L,
    verify_lattice_invariants,
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

    # GIFT candidate gate.
    target = GIFTCandidateProfile.gift_target()
    sextic_profile = K3SexticDoubleCover().candidate_profile()
    sextic_match = sextic_profile.matches(target)
    reducible_profile = reducible.candidate_profile()
    reducible_match = reducible_profile.matches(target)
    kummer_profile = kummer.candidate_profile()
    kummer_match = kummer_profile.matches(target)

    # Weierstrass elliptic K3 skeleton.
    weierstrass = EllipticK3WeierstrassFull2Torsion()
    weierstrass_report = weierstrass.predicted_full_betti()

    # Lattice-Torelli safety net (per GPT council #7, piste 5).
    k3_lattice = K3Lattice()
    lattice_action = Z2CubedLatticeAction()
    lattice_check = lattice_action.consistency_check()
    lattice_derived_profile = lattice_action.derived_candidate_profile()
    lattice_match = lattice_derived_profile.matches(target)

    # Garbagnati-Salgado Prop 7.3 explicit genus-2 construction.
    gs_genus2 = K3GenusTwoSymmetricDoubleCover()
    gs_profile = gs_genus2.candidate_profile_partial()

    # Iter #6: σ'-symmetric Z_2^3 audit.
    gs_z2cubed_profiles = gs_genus2.z2_cubed_anti_symplectic_profiles()
    gs_iter6_candidate = gs_genus2.candidate_profile()
    gs_iter6_match = (
        gs_iter6_candidate.matches(target) if gs_iter6_candidate else None
    )

    # Iter #7 Branch A: τ = α singularity pattern enumeration.
    branch_a_diag = branch_a_quick_kill_diagnostic()
    branch_a_patterns = enumerate_branch_singularity_patterns_with_delta_8()

    # Iter #7 Branch B: Clingher-Malmendier (15, 7, 1) skeleton.
    cm_157 = K3CM_15_7_1_D4_9A1()
    cm_partial = cm_157.partial_profile_status()
    cm_tau = cm_157.tau_search_problem()

    # Iter #8: τ lattice candidate.
    L_11_inv = verify_lattice_invariants(L_11_7_1_gram())
    L_15_inv = verify_lattice_invariants(L_15_7_1_gram())
    embed_11_15 = nikulin_primitive_embedding_M_into_L((11, 7, 1), (15, 7, 1))
    cm_recipe = cm_157.tau_lattice_candidate_recipe()

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
        "candidate_gate_target_yields_b2_b3_21_77": target.JK_b2 == 21
        and target.JK_b3 == 77,
        "candidate_gate_target_tau_is_2_2_and_11_7_1": (
            target.tau.g == 2
            and target.tau.k == 2
            and target.tau.rad == (11, 7, 1)
        ),
        "candidate_gate_target_s1_tau_is_1_1_and_11_9_1": (
            target.s1_tau.g == 1
            and target.s1_tau.k == 1
            and target.s1_tau.rad == (11, 9, 1)
        ),
        "candidate_gate_generic_sextic_does_not_match": sextic_match["all_match"]
        is False,
        "candidate_gate_reducible_sextic_tau_matches": reducible_match["tau_matches"]
        is True,
        "candidate_gate_reducible_sextic_does_not_match_full": reducible_match[
            "all_match"
        ]
        is False,
        "candidate_gate_kummer_does_not_match": kummer_match["all_match"] is False,
        "weierstrass_is_k3_elliptic_surface": weierstrass.is_k3_elliptic_surface()
        is True,
        "weierstrass_discriminant_degree_24": weierstrass_report["discriminant_degree"]
        == 24,
        "weierstrass_mw_torsion_z2_squared": weierstrass_report[
            "mw_torsion_contains_z2_squared"
        ]
        is True,
        "weierstrass_picard_rank_geq_11": weierstrass_report["picard_rank_lower_bound"]
        >= 11,
        "weierstrass_naive_profile_returns_none_pending_moduli_tuning": weierstrass.candidate_profile()
        is None,
        "master_audit_weierstrass_skeleton_in_place": master["lean_bool_certificates"][
            "phase_a1_weierstrass_full_2_torsion_skeleton_in_place"
        ]
        is True,
        "master_audit_weierstrass_picard_geq_11": master["lean_bool_certificates"][
            "phase_a1_weierstrass_picard_rank_geq_11"
        ]
        is True,
        "master_audit_candidate_profile_implemented": master["lean_bool_certificates"][
            "phase_a1_gift_candidate_profile_implemented"
        ]
        is True,
        # Lattice-Torelli safety net checks.
        "k3_lattice_rank_22": k3_lattice.rank == 22,
        "k3_lattice_signature_3_19": k3_lattice.signature == (3, 19),
        "k3_lattice_unimodular": k3_lattice.is_unimodular is True,
        "k3_lattice_even": k3_lattice.is_even is True,
        "k3_lattice_determinant_minus_one": k3_lattice.determinant == -1,
        "nikulin_11_7_1_primitive_embed_in_K3": nikulin_admits_primitive_embedding_in_K3(
            11, 7, 1
        )
        is True,
        "nikulin_11_9_1_primitive_embed_in_K3": nikulin_admits_primitive_embedding_in_K3(
            11, 9, 1
        )
        is True,
        "nikulin_22_0_0_excluded_above_rank_21": nikulin_admits_primitive_embedding_in_K3(
            22, 0, 0
        )
        is False,
        "two_elementary_11_7_1_g_k_is_2_2": TwoElementaryLatticeRAD(
            11, 7, 1
        ).fixed_locus_g_k
        == (2, 2),
        "two_elementary_11_9_1_g_k_is_1_1": TwoElementaryLatticeRAD(
            11, 9, 1
        ).fixed_locus_g_k
        == (1, 1),
        "lattice_action_all_primitive_embeddings_exist": lattice_check[
            "all_primitive_embeddings_exist"
        ]
        is True,
        "lattice_action_v4_mukai_compatible": lattice_check[
            "V4_symplectic_mukai_compatible"
        ]
        is True,
        "lattice_action_predicted_jk_betti_21_77": lattice_check["predicted_jk_betti"]
        == (21, 77),
        "lattice_action_matches_gift_target_full": lattice_match["all_match"] is True,
        "lattice_level_existence_certified_TRUE": lattice_check[
            "lattice_level_existence_certified"
        ]
        is True,
        "master_audit_lattice_level_existence_certified": master[
            "lean_bool_certificates"
        ]["phase_a1_lattice_level_existence_certified"]
        is True,
        "master_audit_k3_lattice_gram_unimodular_even": master["lean_bool_certificates"][
            "phase_a1_k3_lattice_explicit_gram_matrix_unimodular_even"
        ]
        is True,
        "master_audit_nikulin_11_7_1_certified": master["lean_bool_certificates"][
            "phase_a1_nikulin_primitive_embedding_11_7_1_certified"
        ]
        is True,
        "master_audit_nikulin_11_9_1_certified": master["lean_bool_certificates"][
            "phase_a1_nikulin_primitive_embedding_11_9_1_certified"
        ]
        is True,
        # Garbagnati-Salgado Prop 7.3 genus-2 construction checks.
        "gs_prop_7_3_iota_g_k_is_2_2": gs_genus2.fixed_locus_g_k_for_iota() == (2, 2),
        "gs_prop_7_3_iota_matches_11_7_1": gs_profile["iota_matches_11_7_1_profile"]
        is True,
        "gs_prop_7_3_sigma_via_2_torsion": gs_profile[
            "sigma_symplectic_via_2_torsion_translation"
        ]
        is True,
        "gs_prop_7_3_picard_rank_geq_11": gs_profile["picard_rank_lower_bound"] >= 11,
        "gs_prop_7_3_candidate_profile_not_yet_complete": gs_profile[
            "candidate_profile_complete"
        ]
        is False,
        "master_audit_gs_prop_7_3_construction_implemented": master[
            "lean_bool_certificates"
        ]["phase_a1_gs_prop_7_3_genus2_construction_implemented"]
        is True,
        "master_audit_gs_prop_7_3_iota_matches_11_7_1": master[
            "lean_bool_certificates"
        ]["phase_a1_gs_prop_7_3_iota_matches_11_7_1"]
        is True,
        "master_audit_gs_prop_7_3_sigma_via_2_torsion": master[
            "lean_bool_certificates"
        ]["phase_a1_gs_prop_7_3_sigma_via_2_torsion_translation"]
        is True,
        # Iteration #6: σ'-symmetric Z_2^3 audit.
        "iter6_default_branch_sextic_is_sigma_prime_symmetric": gs_genus2.is_sigma_prime_symmetric
        is True,
        "iter6_iota_g_k_matches_gift_2_2": gs_z2cubed_profiles["iota"]["g_k"]
        == (2, 2),
        "iter6_alpha_g_k_is_8_3_does_not_match_1_1": gs_z2cubed_profiles[
            "alpha_eq_sigma_iota"
        ]["g_k"]
        == (8, 3),
        "iter6_sigma_sigma_prime_fixed_locus_empty": gs_z2cubed_profiles[
            "sigma_sigma_prime"
        ]["g_k"]
        == (-1, 0),
        "iter6_summary_matches_gift_full_is_false_honest_no_go": gs_z2cubed_profiles[
            "summary"
        ]["matches_gift_target_full"]
        is False,
        "iter6_candidate_profile_emitted": gs_iter6_candidate is not None,
        "iter6_candidate_does_not_match_gift": gs_iter6_match["all_match"]
        is False,
        "master_audit_iter6_z2_cubed_profiles_computed": master[
            "lean_bool_certificates"
        ]["phase_a1_iter6_z2_cubed_anti_symplectic_profiles_computed"]
        is True,
        "master_audit_iter6_naive_sigma_prime_no_go": master["lean_bool_certificates"][
            "phase_a1_iter6_naive_sigma_prime_does_not_match_gift"
        ]
        is True,
        # Iter #7: 3 sub-Bools refactor.
        "iter7_subbool_correct_V4_present": master["lean_bool_certificates"][
            "phase_a1_explicit_model_has_correct_V4"
        ]
        is True,
        "iter7_subbool_correct_tau_present": master["lean_bool_certificates"][
            "phase_a1_explicit_model_has_correct_tau"
        ]
        is True,
        "iter7_subbool_all_anti_syms_still_pending": master["lean_bool_certificates"][
            "phase_a1_explicit_model_has_correct_all_anti_syms"
        ]
        is False,
        # Iter #7 Branch A: quick kill on τ = α.
        "iter7_branch_a_408_patterns_enumerated": len(branch_a_patterns) == 408,
        "iter7_branch_a_no_patterns_match_k_2": branch_a_diag[
            "n_patterns_matching_k_eq_2"
        ]
        == 0,
        "iter7_branch_a_min_exc_count_is_8": branch_a_diag[
            "minimum_exceptional_count_across_all_patterns"
        ]
        == 8,
        "iter7_branch_a_killed_for_plane_sextic": branch_a_diag["branch_a_killed"]
        is True,
        "master_audit_branch_a_killed": master["lean_bool_certificates"][
            "phase_a1_iter7_branch_a_killed_for_plane_sextic"
        ]
        is True,
        # Iter #7 Branch B: CM (15, 7, 1) skeleton.
        "iter7_branch_b_cm_NS_invariants_15_7_1": cm_157.NS_invariants
        == (15, 7, 1),
        "iter7_branch_b_cm_K_root_D4_9A1": cm_157.K_root_lattice == "D_4 + 9*A_1",
        "iter7_branch_b_cm_MW_torsion_full_2": cm_157.MW_torsion == "(Z/2)^2",
        "iter7_branch_b_cm_v4_implemented": cm_partial[
            "V_4_via_2_torsion_translations_implemented"
        ]
        is True,
        # iter #7 said τ search was pending; iter #8 resolved it at lattice level.
        "iter8_tau_search_resolved_at_lattice_level": cm_partial["tau_searched"]
        is True,
        "iter7_branch_b_cm_no_candidate_profile_yet": cm_157.candidate_profile()
        is None,
        "master_audit_iter7_branch_b_skeleton_implemented": master[
            "lean_bool_certificates"
        ]["phase_a1_iter7_branch_b_cm_15_7_1_skeleton_implemented"]
        is True,
        "master_audit_iter7_branch_b_v4_via_2_torsion": master[
            "lean_bool_certificates"
        ]["phase_a1_iter7_branch_b_v4_via_2_torsion_translations"]
        is True,
        # Iter #8: τ lattice candidate.
        "iter8_L_11_7_1_rank_11_sig_1_10": (
            L_11_inv["rank"] == 11 and L_11_inv["signature"] == (1, 10)
        ),
        "iter8_L_11_7_1_abs_det_2_to_7": L_11_inv["abs_det"] == 128,
        "iter8_L_11_7_1_even": L_11_inv["even"] is True,
        "iter8_L_15_7_1_rank_15_sig_1_14": (
            L_15_inv["rank"] == 15 and L_15_inv["signature"] == (1, 14)
        ),
        "iter8_L_15_7_1_abs_det_2_to_7": L_15_inv["abs_det"] == 128,
        "iter8_L_15_7_1_even": L_15_inv["even"] is True,
        "iter8_11_7_1_into_15_7_1_embeds_primitively": embed_11_15[
            "embeds_primitively"
        ]
        is True,
        "iter8_11_7_1_into_15_7_1_has_4_valid_complement_options": len(
            embed_11_15["valid_orthogonal_complement_invariants"]
        )
        == 4,
        "iter8_tau_lattice_candidate_via_recipe": cm_recipe[
            "primitive_embedding_M_into_L"
        ]
        is True,
        "iter8_tau_g_k_is_2_2_via_nikulin": cm_recipe[
            "tau_matches_gift_2_2_profile"
        ]
        is True,
        "iter8_s_i_tau_lattice_invariants_pending_iter_9": cm_partial[
            "s_i_tau_lattice_invariants_computed"
        ]
        is False,
        "master_audit_iter8_11_7_1_embeds_in_15_7_1": master[
            "lean_bool_certificates"
        ]["phase_a1_iter8_11_7_1_primitively_embeds_into_15_7_1"]
        is True,
        "master_audit_iter8_L_11_7_1_gram_verified": master[
            "lean_bool_certificates"
        ]["phase_a1_iter8_L_11_7_1_gram_matrix_verified"]
        is True,
        "master_audit_iter8_L_15_7_1_gram_verified": master[
            "lean_bool_certificates"
        ]["phase_a1_iter8_L_15_7_1_gram_matrix_verified"]
        is True,
        "master_audit_iter8_tau_lattice_candidate_identified": master[
            "lean_bool_certificates"
        ]["phase_a1_iter8_tau_lattice_candidate_identified"]
        is True,
        "master_audit_iter8_tau_g_k_2_2": master["lean_bool_certificates"][
            "phase_a1_iter8_tau_invariant_lattice_g_k_is_2_2"
        ]
        is True,
    }


def main() -> None:
    results = verify()
    for name, passed in results.items():
        print(f"{name}: {'PASS' if passed else 'FAIL'}")
    if not all(results.values()):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
