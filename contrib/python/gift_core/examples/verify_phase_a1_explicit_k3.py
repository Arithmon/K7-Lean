"""Lightweight verification for the Phase A.1 explicit K3 workbench.

Checks the JK Betti predictor, Nikulin (r,a,δ) → (g,k) formula, and the
predictions of the candidate explicit K3 models (generic sextic, reducible
sextic, Kummer skeleton).

Returns a dict of named bool checks. Prints PASS / FAIL per check and exits
non-zero if any check fails.
"""

from __future__ import annotations

from gift_core.geometry.k3_explicit import (
    AtiyahBottLefschetzCalculator,
    EllipticK3WeierstrassFull2Torsion,
    EquivariantK3TorelliPackage,
    GIFT15_7_1WeierstrassRealisation,
    GIFTCandidateProfile,
    GInvariantPolarisationScanner,
    MukaiLinearisationFramework,
    ProjectiveModelRouteSelector,
    gift_15_7_1_AB_coefficients,
    IterSeventeenMobiusOneOverTAblation,
    JKBettiPredictor,
    K3CM_15_7_1_D4_9A1,
    K3GenusTwoSymmetricDoubleCover,
    K3Lattice,
    K3ReducibleSexticDoubleCover,
    K3SexticDoubleCover,
    KummerK3Model,
    PhaseA1MasterAudit,
    TwoElementaryLatticeRAD,
    TauCompatibleABSearch,
    TauMobiusNormalizerSearch,
    TauNaiveAntiSymplecticCandidate,
    TauNaiveLatticeClassDiagnostic,
    TauV4CosetSearch,
    V4Z2TorsionTranslations,
    Z2CubedExplicit15x15Matrices,
    Z2CubedLatticeAction,
    audit_phase_a1_master,
    branch_a_quick_kill_diagnostic,
    enumerate_branch_singularity_patterns_with_delta_8,
    L_11_7_1_gram,
    L_11_9_1_gram,
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

    # Iter #9: σ_A lattice candidate.
    L_11_9_inv = verify_lattice_invariants(L_11_9_1_gram())
    embed_11_9_into_15 = nikulin_primitive_embedding_M_into_L(
        (11, 9, 1), (15, 7, 1)
    )
    sigma_recipe = cm_157.sigma_A_lattice_candidate_recipe()

    # Iter #10: σ_B lattice candidate completing Z_2^3.
    sigma_b_recipe = cm_157.sigma_B_lattice_candidate_recipe()
    cm_157_profile_iter10 = cm_157.candidate_profile()
    cm_157_match_iter10 = (
        cm_157_profile_iter10.matches(target) if cm_157_profile_iter10 else None
    )

    # Iter #11: explicit 15×15 integer matrices.
    iter11 = Z2CubedExplicit15x15Matrices().audit()
    iter11_fixed = iter11["anti_symplectic_fixed_sublattices"]

    # Iter #12: explicit Weierstrass A(t), B(t) for the D_4 + 9 A_1 fiber
    # configuration of the (15, 7, 1) profile.
    iter12 = GIFT15_7_1WeierstrassRealisation().audit()
    iter12_config = iter12["configuration_summary"]

    # Iter #13: V_4 = ⟨T_A, T_B⟩ symplectic via 2-torsion translations.
    A_c, B_c = gift_15_7_1_AB_coefficients()
    iter13 = V4Z2TorsionTranslations(A_coeffs=A_c, B_coeffs=B_c).audit()

    # Iter #14: τ_naive anti-symplectic candidate framework.
    iter14 = TauNaiveAntiSymplecticCandidate(
        A_coeffs=A_c, B_coeffs=B_c
    ).audit()

    # Iter #15A: τ_naive lattice-class diagnostic (per GPT council #9).
    iter15A = TauNaiveLatticeClassDiagnostic(
        A_coeffs=A_c, B_coeffs=B_c
    ).audit()

    # Iter #15B: V_4-coset enumeration of τ candidates.
    iter15B = TauV4CosetSearch(A_coeffs=A_c, B_coeffs=B_c).audit()

    # Iter #15C: fibrewise Möbius normalizer + base involution search.
    iter15C = TauMobiusNormalizerSearch(A_coeffs=A_c, B_coeffs=B_c).audit()

    # Iter #16: search for (A, B) admitting compatible base involution.
    iter16 = TauCompatibleABSearch().audit()

    # Iter #17: σ(t) = 1/t Möbius palindromic ablation (P1 closure).
    iter17 = IterSeventeenMobiusOneOverTAblation().audit()

    # Iter #18A (per GPT council #11): equivariant Torelli package
    # baseline. Pivot to P2 — lattice triple (Λ_K3, NS = (15, 7, 1),
    # T_X = (7, 7, 1)) with prescribed Z_2^3 extension; Torelli step
    # 1 + 2 + 3 (at signature level) verified.
    iter18 = EquivariantK3TorelliPackage().audit()

    # Iter #18B (per GPT council #11): G-invariant polarisation scanner.
    # Enumerate primitive h ∈ NS^G, classify by h², recommend route via
    # canonical witness + GPT priority h²=8 > 4 > 2 > 6 > 10.
    iter18B = GInvariantPolarisationScanner().audit()

    # Iter #18C (per GPT council #11): projective model route selector.
    # Riemann-Roch + Mukai genus-5 → CI(2,2,2) in P^5 for h = 4e + f;
    # wall screen against D + Q + P-α; predicted singularity D_4 + 9 A_1
    # matches iter #12 Weierstrass.
    iter18C = ProjectiveModelRouteSelector().audit()

    # Iter #18D (per GPT council #11): Mukai linearisation framework.
    # Z_2^3 character theory on V = C^6, Sym²(V) = C^21 decomposition,
    # G-stable 3-dim subspace identification, default template
    # reducibility, irreducible alternatives.
    iter18D = MukaiLinearisationFramework().audit()

    # Iter #18E (per GPT council #11 finale): Atiyah-Bott Lefschetz
    # calculator. Direct H^2 trace from iter #11 matrices reveals
    # σ_B / σ_Aσ_B Mukai anomaly (Lefschetz χ=16 vs 8 expected).
    iter18E = AtiyahBottLefschetzCalculator().audit()

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
        # iter #10: master Bool flipped to TRUE at the lattice-counting level.
        "iter10_master_bool_flipped_at_lattice_counting_level": master[
            "lean_bool_certificates"
        ]["phase_a1_explicit_model_realizes_gift_betti"]
        is True,
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
        # iter #10: all anti-syms have GIFT-correct profiles (lattice level).
        "iter10_all_anti_syms_match_gift_at_lattice_level": master[
            "lean_bool_certificates"
        ]["phase_a1_explicit_model_has_correct_all_anti_syms"]
        is True,
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
        # iter #10: K3CM candidate_profile now returns the GIFT-matching profile.
        "iter10_cm_157_candidate_profile_emitted": cm_157.candidate_profile()
        is not None,
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
        # iter #8 said s_i_tau pending; iter #9 resolved 1 of 3 (σ_A side).
        "iter9_s_i_tau_lattice_invariants_partially_computed": cm_partial[
            "s_i_tau_lattice_invariants_computed"
        ]
        is True,
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
        # Iter #9: σ_A and τσ_A → (11, 9, 1).
        "iter9_L_11_9_1_rank_11_sig_1_10": (
            L_11_9_inv["rank"] == 11 and L_11_9_inv["signature"] == (1, 10)
        ),
        "iter9_L_11_9_1_abs_det_2_to_9": L_11_9_inv["abs_det"] == 512,
        "iter9_L_11_9_1_even": L_11_9_inv["even"] is True,
        "iter9_11_9_1_into_15_7_1_embeds_primitively": embed_11_9_into_15[
            "embeds_primitively"
        ]
        is True,
        "iter9_sigma_A_fixed_rank_7": sigma_recipe["sigma_A_definition"][
            "total_sigma_A_fixed_rank"
        ]
        == 7,
        "iter9_sigma_A_minus_eigenspace_rank_8_mukai_v4": sigma_recipe[
            "sigma_A_definition"
        ]["matches_mukai_v4_generator_rank_8"]
        is True,
        "iter9_tau_sigma_A_invariant_lattice_rank_11": sigma_recipe[
            "tau_sigma_A_invariant_lattice_verified"
        ]["rank"]
        == 11,
        "iter9_tau_sigma_A_invariant_lattice_a_9": sigma_recipe[
            "tau_sigma_A_invariant_lattice_verified"
        ]["a"]
        == 9,
        "iter9_tau_sigma_A_invariant_lattice_delta_1": sigma_recipe[
            "tau_sigma_A_invariant_lattice_verified"
        ]["delta"]
        == 1,
        "iter9_tau_sigma_A_matches_11_9_1": sigma_recipe[
            "tau_sigma_A_invariant_lattice_verified"
        ]["matches_gift_s_i_tau_profile"]
        is True,
        "iter9_tau_sigma_A_g_k_matches_1_1": sigma_recipe[
            "matches_gift_s_i_tau_g_k_1_1"
        ]
        is True,
        "master_audit_iter9_11_9_1_embeds": master["lean_bool_certificates"][
            "phase_a1_iter9_11_9_1_primitively_embeds_into_15_7_1"
        ]
        is True,
        "master_audit_iter9_L_11_9_1_gram_verified": master[
            "lean_bool_certificates"
        ]["phase_a1_iter9_L_11_9_1_gram_matrix_verified"]
        is True,
        "master_audit_iter9_tau_sigma_A_is_11_9_1": master[
            "lean_bool_certificates"
        ]["phase_a1_iter9_tau_sigma_A_invariant_lattice_is_11_9_1"]
        is True,
        "master_audit_iter9_tau_sigma_A_g_k_1_1": master[
            "lean_bool_certificates"
        ]["phase_a1_iter9_tau_sigma_A_g_k_is_1_1"]
        is True,
        # Iter #10: σ_B + complete Z_2^3 lattice action.
        "iter10_sigma_B_definition_x_y_2_2": sigma_b_recipe["sigma_B_definition"][
            "x_y_choice"
        ]
        == (2, 2),
        "iter10_sigma_B_distinct_from_sigma_A": sigma_b_recipe["sigma_B_definition"][
            "distinct_from_sigma_A"
        ]
        is True,
        "iter10_sigma_B_mukai_v4_rank_8_eigenspace": sigma_b_recipe[
            "sigma_B_definition"
        ]["matches_mukai_v4_generator_rank_8"]
        is True,
        "iter10_tau_sigma_B_invariant_lattice_is_11_9_1": sigma_b_recipe[
            "tau_sigma_B_invariant_lattice_verified"
        ]["matches_gift_s_i_tau_profile"]
        is True,
        "iter10_tau_sigma_A_sigma_B_invariant_lattice_is_11_9_1": sigma_b_recipe[
            "tau_sigma_A_sigma_B_invariant_lattice_verified"
        ]["matches_gift_s_i_tau_profile"]
        is True,
        "iter10_all_4_anti_syms_match_gift": sigma_b_recipe[
            "all_4_anti_symplectic_profiles_match_gift"
        ]
        is True,
        "iter10_z2_cubed_lattice_action_complete": sigma_b_recipe[
            "z2_cubed_lattice_action_complete_at_algebraic_level"
        ]
        is True,
        "iter10_cm_157_match_all_components_with_gift_target": cm_157_match_iter10[
            "all_match"
        ]
        is True,
        "master_audit_iter10_sigma_B_identified": master["lean_bool_certificates"][
            "phase_a1_iter10_sigma_B_lattice_candidate_identified"
        ]
        is True,
        "master_audit_iter10_tau_sigma_B_11_9_1": master["lean_bool_certificates"][
            "phase_a1_iter10_tau_sigma_B_invariant_lattice_is_11_9_1"
        ]
        is True,
        "master_audit_iter10_tau_sigma_A_sigma_B_11_9_1": master[
            "lean_bool_certificates"
        ]["phase_a1_iter10_tau_sigma_A_sigma_B_invariant_lattice_is_11_9_1"]
        is True,
        "master_audit_iter10_all_4_anti_syms_match": master["lean_bool_certificates"][
            "phase_a1_iter10_all_4_anti_symplectic_profiles_match_gift"
        ]
        is True,
        "master_audit_iter10_z2_cubed_complete": master["lean_bool_certificates"][
            "phase_a1_iter10_z2_cubed_lattice_action_complete"
        ]
        is True,
        # Iter #11: explicit 15×15 integer matrices.
        "iter11_matrices_constructed": iter11["matrices_constructed"] is True,
        "iter11_tau_squared_eq_I": iter11["involutivity"]["tau_squared_eq_I"]
        is True,
        "iter11_sigma_A_squared_eq_I": iter11["involutivity"][
            "sigma_A_squared_eq_I"
        ]
        is True,
        "iter11_sigma_B_squared_eq_I": iter11["involutivity"][
            "sigma_B_squared_eq_I"
        ]
        is True,
        "iter11_all_involutions_squared_to_I": iter11[
            "all_involutions_squared_to_I"
        ]
        is True,
        "iter11_tau_sigma_A_commute": iter11["commutativity"][
            "tau_sigma_A_commute"
        ]
        is True,
        "iter11_tau_sigma_B_commute": iter11["commutativity"][
            "tau_sigma_B_commute"
        ]
        is True,
        "iter11_sigma_A_sigma_B_commute": iter11["commutativity"][
            "sigma_A_sigma_B_commute"
        ]
        is True,
        "iter11_all_pairs_commute": iter11["all_pairs_commute"] is True,
        "iter11_tau_preserves_gram": iter11["isometry"]["tau_preserves_gram"]
        is True,
        "iter11_sigma_A_preserves_gram": iter11["isometry"][
            "sigma_A_preserves_gram"
        ]
        is True,
        "iter11_sigma_B_preserves_gram": iter11["isometry"][
            "sigma_B_preserves_gram"
        ]
        is True,
        "iter11_all_generators_preserve_gram": iter11[
            "all_generators_preserve_gram"
        ]
        is True,
        "iter11_tau_fixed_rank_11": iter11_fixed["tau"]["rank"] == 11,
        "iter11_tau_fixed_a_eq_7": iter11_fixed["tau"]["a"] == 7,
        "iter11_tau_fixed_log2_det_eq_7": iter11_fixed["tau"]["log2_abs_det"]
        == 7,
        "iter11_tau_fixed_2_elementary": iter11_fixed["tau"]["is_2_elementary"]
        is True,
        "iter11_tau_fixed_even": iter11_fixed["tau"]["is_even"] is True,
        "iter11_tau_sigma_A_fixed_rank_11": iter11_fixed["tau_sigma_A"]["rank"]
        == 11,
        "iter11_tau_sigma_A_fixed_a_eq_9": iter11_fixed["tau_sigma_A"]["a"]
        == 9,
        "iter11_tau_sigma_A_fixed_log2_det_eq_9": iter11_fixed["tau_sigma_A"][
            "log2_abs_det"
        ]
        == 9,
        "iter11_tau_sigma_A_fixed_2_elementary": iter11_fixed["tau_sigma_A"][
            "is_2_elementary"
        ]
        is True,
        "iter11_tau_sigma_A_fixed_even": iter11_fixed["tau_sigma_A"][
            "is_even"
        ]
        is True,
        "iter11_tau_sigma_B_fixed_rank_11": iter11_fixed["tau_sigma_B"]["rank"]
        == 11,
        "iter11_tau_sigma_B_fixed_a_eq_9": iter11_fixed["tau_sigma_B"]["a"]
        == 9,
        "iter11_tau_sigma_B_fixed_log2_det_eq_9": iter11_fixed["tau_sigma_B"][
            "log2_abs_det"
        ]
        == 9,
        "iter11_tau_sigma_B_fixed_2_elementary": iter11_fixed["tau_sigma_B"][
            "is_2_elementary"
        ]
        is True,
        "iter11_tau_sigma_B_fixed_even": iter11_fixed["tau_sigma_B"][
            "is_even"
        ]
        is True,
        "iter11_tau_sigma_A_sigma_B_fixed_rank_11": iter11_fixed[
            "tau_sigma_A_sigma_B"
        ]["rank"]
        == 11,
        "iter11_tau_sigma_A_sigma_B_fixed_a_eq_9": iter11_fixed[
            "tau_sigma_A_sigma_B"
        ]["a"]
        == 9,
        "iter11_tau_sigma_A_sigma_B_fixed_log2_det_eq_9": iter11_fixed[
            "tau_sigma_A_sigma_B"
        ]["log2_abs_det"]
        == 9,
        "iter11_tau_sigma_A_sigma_B_fixed_2_elementary": iter11_fixed[
            "tau_sigma_A_sigma_B"
        ]["is_2_elementary"]
        is True,
        "iter11_tau_sigma_A_sigma_B_fixed_even": iter11_fixed[
            "tau_sigma_A_sigma_B"
        ]["is_even"]
        is True,
        "iter11_all_anti_sym_match_target_a": iter11[
            "all_anti_sym_fixed_sublattices_match_target_a"
        ]
        is True,
        "iter11_all_anti_sym_2_elementary": iter11[
            "all_anti_sym_fixed_sublattices_are_2_elementary"
        ]
        is True,
        "iter11_all_anti_sym_even": iter11[
            "all_anti_sym_fixed_sublattices_are_even"
        ]
        is True,
        "iter11_complete_master_bool": iter11["iter_11_complete"] is True,
        "master_audit_iter11_matrices_constructed": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_matrices_constructed"]
        is True,
        "master_audit_iter11_all_involutions_squared_to_I": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_involutions_squared_to_I"]
        is True,
        "master_audit_iter11_all_pairs_commute": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_pairs_commute"]
        is True,
        "master_audit_iter11_all_generators_preserve_gram": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_generators_preserve_gram"]
        is True,
        "master_audit_iter11_all_anti_sym_target_a_match": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_anti_sym_fixed_sublattices_match_target_a"]
        is True,
        "master_audit_iter11_all_anti_sym_2_elementary": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_anti_sym_fixed_sublattices_are_2_elementary"]
        is True,
        "master_audit_iter11_all_anti_sym_even": master[
            "lean_bool_certificates"
        ]["phase_a1_iter11_all_anti_sym_fixed_sublattices_are_even"]
        is True,
        "master_audit_iter11_complete": master["lean_bool_certificates"][
            "phase_a1_iter11_complete"
        ]
        is True,
        # Iter #12 (Phase A.2): explicit Weierstrass D_4 + 9 A_1.
        "iter12_discriminant_degree_eq_24": iter12["discriminant_degree_24"]
        is True,
        "iter12_one_I_0_star_fiber": iter12_config["I_0_star_count"] == 1,
        "iter12_nine_I_2_fibers": iter12_config["I_2_count"] == 9,
        "iter12_no_unsupported_fiber_pattern": iter12_config[
            "unsupported_pattern_count"
        ]
        == 0,
        "iter12_total_root_lattice_rank_eq_13": iter12_config[
            "total_root_lattice_rank_from_singular_fibers"
        ]
        == 13,
        "iter12_total_disc_order_eq_24": iter12_config[
            "total_discriminant_order"
        ]
        == 24,
        "iter12_matches_15_7_1_target": iter12_config["matches_15_7_1_target"]
        is True,
        "iter12_picard_rank_from_singular_fibers_eq_15": iter12[
            "picard_rank_from_singular_fibers_eq_15"
        ]
        is True,
        "master_audit_iter12_weierstrass_AB_explicit": master[
            "lean_bool_certificates"
        ]["phase_a2_iter12_weierstrass_AB_explicit"]
        is True,
        "master_audit_iter12_discriminant_degree_24": master[
            "lean_bool_certificates"
        ]["phase_a2_iter12_discriminant_degree_24"]
        is True,
        "master_audit_iter12_singular_fibers_match": master[
            "lean_bool_certificates"
        ]["phase_a2_iter12_singular_fibers_match_D4_plus_9A1"]
        is True,
        "master_audit_iter12_total_root_lattice_rank_13": master[
            "lean_bool_certificates"
        ]["phase_a2_iter12_total_root_lattice_rank_eq_13"]
        is True,
        "master_audit_iter12_picard_rank_15": master["lean_bool_certificates"][
            "phase_a2_iter12_picard_rank_from_singular_fibers_eq_15"
        ]
        is True,
        # Iter #13 (Phase A.2): V_4 symplectic action via 2-torsion.
        "iter13_T_1_squared_eq_id": iter13["involutivity"][
            "T_1_squared_eq_id_x"
        ]
        is True
        and iter13["involutivity"]["T_1_squared_eq_id_y"] is True,
        "iter13_T_A_squared_eq_id": iter13["involutivity"][
            "T_A_squared_eq_id_x"
        ]
        is True
        and iter13["involutivity"]["T_A_squared_eq_id_y"] is True,
        "iter13_T_B_squared_eq_id": iter13["involutivity"][
            "T_B_squared_eq_id_x"
        ]
        is True
        and iter13["involutivity"]["T_B_squared_eq_id_y"] is True,
        "iter13_all_three_translations_are_involutions": iter13[
            "all_three_translations_are_involutions"
        ]
        is True,
        "iter13_T_A_after_T_B_eq_T_1": iter13["v4_closure"][
            "T_A_after_T_B_eq_T_1_x"
        ]
        is True
        and iter13["v4_closure"]["T_A_after_T_B_eq_T_1_y"] is True,
        "iter13_T_B_after_T_A_eq_T_1": iter13["v4_closure"][
            "T_B_after_T_A_eq_T_1_x"
        ]
        is True
        and iter13["v4_closure"]["T_B_after_T_A_eq_T_1_y"] is True,
        "iter13_T_A_T_B_commute": iter13["v4_closure"]["T_A_T_B_commute_x"]
        is True
        and iter13["v4_closure"]["T_A_T_B_commute_y"] is True,
        "iter13_v4_closure_holds": iter13["v4_closure_holds"] is True,
        "iter13_v4_commutative": iter13["v4_commutative"] is True,
        "iter13_v4_isomorphic_to_z2_squared": iter13[
            "v4_group_isomorphic_to_Z2_squared"
        ]
        is True,
        "iter13_T_1_preserves_dx_over_y": iter13["symplectic"][
            "T_1_preserves_dx_over_y"
        ]
        is True,
        "iter13_T_A_preserves_dx_over_y": iter13["symplectic"][
            "T_A_preserves_dx_over_y"
        ]
        is True,
        "iter13_T_B_preserves_dx_over_y": iter13["symplectic"][
            "T_B_preserves_dx_over_y"
        ]
        is True,
        "iter13_all_three_translations_are_symplectic": iter13[
            "all_three_translations_are_symplectic"
        ]
        is True,
        "iter13_complete_master_bool": iter13["iter_13_complete"] is True,
        "master_audit_iter13_three_involutions": master[
            "lean_bool_certificates"
        ]["phase_a2_iter13_three_translations_are_involutions"]
        is True,
        "master_audit_iter13_v4_closure": master["lean_bool_certificates"][
            "phase_a2_iter13_v4_closure_holds"
        ]
        is True,
        "master_audit_iter13_v4_commutative": master["lean_bool_certificates"][
            "phase_a2_iter13_v4_commutative"
        ]
        is True,
        "master_audit_iter13_v4_z2_squared": master["lean_bool_certificates"][
            "phase_a2_iter13_v4_isomorphic_to_z2_squared"
        ]
        is True,
        "master_audit_iter13_three_symplectic": master[
            "lean_bool_certificates"
        ]["phase_a2_iter13_three_translations_are_symplectic"]
        is True,
        "master_audit_iter13_complete": master["lean_bool_certificates"][
            "phase_a2_iter13_complete"
        ]
        is True,
        # Iter #14 (Phase A.2): τ_naive framework + honest diagnostic.
        "iter14_tau_naive_squared_eq_id": iter14["involutivity"][
            "tau_naive_squared_eq_id_x"
        ]
        is True
        and iter14["involutivity"]["tau_naive_squared_eq_id_y"] is True
        and iter14["involutivity"]["tau_naive_squared_eq_id_t"] is True,
        "iter14_tau_naive_is_involution": iter14["tau_naive_is_involution"]
        is True,
        "iter14_tau_naive_commutes_with_T_1": iter14[
            "commutativity_with_V_4"
        ]["tau_naive_commutes_with_T_1_x"]
        is True
        and iter14["commutativity_with_V_4"]["tau_naive_commutes_with_T_1_y"]
        is True,
        "iter14_tau_naive_commutes_with_T_A": iter14[
            "commutativity_with_V_4"
        ]["tau_naive_commutes_with_T_A_x"]
        is True
        and iter14["commutativity_with_V_4"]["tau_naive_commutes_with_T_A_y"]
        is True,
        "iter14_tau_naive_commutes_with_T_B": iter14[
            "commutativity_with_V_4"
        ]["tau_naive_commutes_with_T_B_x"]
        is True
        and iter14["commutativity_with_V_4"]["tau_naive_commutes_with_T_B_y"]
        is True,
        "iter14_tau_naive_commutes_with_V_4": iter14[
            "tau_naive_commutes_with_V_4"
        ]
        is True,
        "iter14_tau_naive_is_anti_symplectic": iter14[
            "tau_naive_is_anti_symplectic"
        ]
        is True,
        "iter14_z2_cubed_abelian_extension_holds": iter14[
            "Z_2_cubed_abelian_extension_of_V_4_holds"
        ]
        is True,
        "iter14_framework_complete": iter14["iter_14_framework_complete"]
        is True,
        "iter14_geometric_match_pending_honest_no_go": iter14[
            "iter_14_geometric_match_pending"
        ]
        is True,
        "master_audit_iter14_tau_naive_involution": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_tau_naive_is_involution"]
        is True,
        "master_audit_iter14_tau_naive_commutes_v4": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_tau_naive_commutes_with_V_4"]
        is True,
        "master_audit_iter14_tau_naive_anti_symplectic": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_tau_naive_is_anti_symplectic"]
        is True,
        "master_audit_iter14_z2_cubed_abelian_holds": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_z2_cubed_abelian_extension_holds"]
        is True,
        "master_audit_iter14_framework_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_framework_complete"]
        is True,
        "master_audit_iter14_geometric_pending_honest": master[
            "lean_bool_certificates"
        ]["phase_a2_iter14_tau_naive_geometric_match_pending_honest"]
        is True,
        # Iter #15A (Phase A.2, GPT council #9): τ_naive lattice-class
        # diagnostic.
        "iter15A_tau_naive_acts_as_plus_I_on_NS": iter15A[
            "tau_naive_action_on_NS"
        ]["tau_naive_acts_as_plus_I_on_NS"]
        is True,
        "iter15A_tau_naive_invariant_NS_rank_eq_15": iter15A[
            "lattice_class"
        ]["tau_naive_invariant_NS_rank"]
        == 15,
        "iter15A_tau_naive_anti_invariant_NS_rank_eq_0": iter15A[
            "lattice_class"
        ]["tau_naive_anti_invariant_NS_rank"]
        == 0,
        "iter15A_lattice_classes_do_NOT_match_iter11": iter15A[
            "lattice_class"
        ]["matches_iter11_tau_class"]
        is False,
        "iter15A_belongs_to_trivial_NS_class": iter15A[
            "tau_naive_belongs_to_trivial_NS_class"
        ]
        is True,
        "iter15A_NOT_iter11_geometric_representative": iter15A[
            "tau_naive_is_NOT_iter11_tau_geometric_representative"
        ]
        is True,
        "iter15A_moduli_tuning_route_ruled_out": iter15A[
            "moduli_tuning_route_ruled_out"
        ]
        is True,
        "iter15A_diagnostic_complete": iter15A["iter_15A_diagnostic_complete"]
        is True,
        "master_audit_iter15A_plus_I_on_NS": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15A_tau_naive_acts_as_plus_I_on_NS"]
        is True,
        "master_audit_iter15A_trivial_NS_class": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15A_tau_naive_belongs_to_trivial_NS_class"]
        is True,
        "master_audit_iter15A_NOT_iter11_geometric_rep": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15A_tau_naive_is_NOT_iter11_geometric_rep"]
        is True,
        "master_audit_iter15A_moduli_tuning_ruled_out": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15A_moduli_tuning_route_ruled_out_honest"]
        is True,
        "master_audit_iter15A_diagnostic_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15A_diagnostic_complete"]
        is True,
        # Iter #15B (Phase A.2): V_4-coset enumeration.
        "iter15B_all_4_coset_elements_are_involutions": iter15B[
            "all_4_coset_elements_are_involutions"
        ]
        is True,
        "iter15B_all_4_coset_elements_commute_with_V_4": iter15B[
            "all_4_coset_elements_commute_with_V_4"
        ]
        is True,
        "iter15B_all_4_coset_elements_are_anti_symplectic": iter15B[
            "all_4_coset_elements_are_anti_symplectic"
        ]
        is True,
        "iter15B_v4_coset_does_NOT_contain_iter11_rep_honest": (
            not iter15B["v4_coset_contains_iter11_geometric_rep"]
        ),
        "iter15B_search_complete": iter15B["iter_15B_search_complete"]
        is True,
        "master_audit_iter15B_4_involutions": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15B_all_4_coset_elements_are_involutions"]
        is True,
        "master_audit_iter15B_4_commute_v4": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15B_all_4_coset_elements_commute_with_V_4"]
        is True,
        "master_audit_iter15B_4_anti_symplectic": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15B_all_4_coset_elements_are_anti_symplectic"]
        is True,
        "master_audit_iter15B_no_iter11_rep_honest": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15B_v4_coset_contains_iter11_rep_FALSE_honest"]
        is True,
        "master_audit_iter15B_complete": master["lean_bool_certificates"][
            "phase_a2_iter15B_search_complete"
        ]
        is True,
        # Iter #15C (Phase A.2): fibrewise Möbius normalizer.
        "iter15C_fibrewise_mobius_eq_V4_coset": iter15C[
            "fibrewise_mobius_match_V4_coset"
        ]
        is True,
        "iter15C_iter12_AB_admits_NO_base_involution_honest": (
            not iter15C["iter12_AB_admits_compatible_base_involution"]
        ),
        "iter15C_search_complete": iter15C["iter_15C_search_complete"]
        is True,
        "master_audit_iter15C_mobius_eq_v4": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15C_fibrewise_mobius_match_V4_coset"]
        is True,
        "master_audit_iter15C_no_base_involution_honest": master[
            "lean_bool_certificates"
        ]["phase_a2_iter15C_iter12_admits_no_base_involution_honest"]
        is True,
        "master_audit_iter15C_complete": master["lean_bool_certificates"][
            "phase_a2_iter15C_search_complete"
        ]
        is True,
        # Iter #16 (Phase A.2): search for (A, B) compatible with base involution.
        "iter16_sigma_minus_t_RULED_OUT": iter16[
            "sigma_minus_t_RULED_OUT"
        ]
        is True,
        "iter16_sigma_c_minus_t_open_for_iter17": iter16[
            "sigma_c_minus_t_open_for_iter_17"
        ]
        is True,
        "iter16_sigma_c_over_t_open_for_iter17": iter16[
            "sigma_c_over_t_open_for_iter_17"
        ]
        is True,
        "iter16_matrix_certificate_iter11_remains_master": iter16[
            "matrix_certificate_iter_11_remains_master"
        ]
        is True,
        "iter16_search_complete": iter16["iter_16_search_complete"]
        is True,
        "master_audit_iter16_sigma_minus_t_ruled_out": master[
            "lean_bool_certificates"
        ]["phase_a2_iter16_sigma_minus_t_RULED_OUT"]
        is True,
        "master_audit_iter16_sigma_c_minus_t_open": master[
            "lean_bool_certificates"
        ]["phase_a2_iter16_sigma_c_minus_t_open_for_iter17"]
        is True,
        "master_audit_iter16_sigma_c_over_t_open": master[
            "lean_bool_certificates"
        ]["phase_a2_iter16_sigma_c_over_t_open_for_iter17"]
        is True,
        "master_audit_iter16_iter11_master": master[
            "lean_bool_certificates"
        ]["phase_a2_iter16_matrix_cert_iter11_remains_master"]
        is True,
        "master_audit_iter16_complete": master["lean_bool_certificates"][
            "phase_a2_iter16_search_complete"
        ]
        is True,
        # Per GPT council #10: explicit-scope Bool split to remove
        # ambiguity between matrix-level and geometric-Weierstrass
        # certifications.
        "matrix_level_realizes_gift_betti_TRUE": master[
            "lean_bool_certificates"
        ]["phase_a1_matrix_level_realizes_gift_betti"]
        is True,
        "geometric_weierstrass_realizes_gift_fixed_loci_FALSE_honest": master[
            "lean_bool_certificates"
        ]["phase_a2_geometric_weierstrass_realizes_gift_fixed_loci"]
        is False,
        # Iter #17 (Phase A.2): σ(t) = 1/t ablation closing P1 search.
        "iter17_case_1_palindromic_antiinv_RULED_OUT": iter17[
            "case_1_palindromic_antiinvariant_AB"
        ]["case_1_RULED_OUT"]
        is True,
        "iter17_case_2_swap_yields_D4_dihedral": iter17[
            "case_2_sigma_swaps_A_and_B"
        ]["case_2_RULED_OUT"]
        is True,
        "iter17_case_2_fiber_pattern_correct_D4_plus_9A1": iter17[
            "case_2_sigma_swaps_A_and_B"
        ]["fiber_count_correct_D4_plus_9A1"]
        is True,
        "iter17_case_2_group_NOT_abelian_Z2_cubed": iter17[
            "case_2_sigma_swaps_A_and_B"
        ]["group_generated_is_D4_dihedral_not_Z2_cubed"]
        is True,
        "iter17_case_3_individual_invariance_RULED_OUT": iter17[
            "case_3_individual_invariance"
        ]["case_3_RULED_OUT"]
        is True,
        "iter17_all_3_cases_ruled_out": iter17["all_3_cases_ruled_out"]
        is True,
        "iter17_sigma_one_over_t_RULED_OUT": iter17[
            "sigma_one_over_t_search_RULED_OUT"
        ]
        is True,
        "iter17_pivot_to_P2_recommended": iter17[
            "pivot_to_P2_recommended"
        ]
        is True,
        "iter17_P1_search_complete": iter17["iter_17_P1_search_complete"]
        is True,
        "master_audit_iter17_case_1_ruled_out": master[
            "lean_bool_certificates"
        ]["phase_a2_iter17_case_1_palindromic_antiinvariant_RULED_OUT"]
        is True,
        "master_audit_iter17_case_2_dihedral": master[
            "lean_bool_certificates"
        ]["phase_a2_iter17_case_2_swap_yields_D4_dihedral_not_Z2_cubed"]
        is True,
        "master_audit_iter17_case_3_ruled_out": master[
            "lean_bool_certificates"
        ]["phase_a2_iter17_case_3_individual_invariance_RULED_OUT"]
        is True,
        "master_audit_iter17_sigma_1_over_t_ruled_out": master[
            "lean_bool_certificates"
        ]["phase_a2_iter17_sigma_one_over_t_search_RULED_OUT"]
        is True,
        "master_audit_iter17_pivot_P2": master["lean_bool_certificates"][
            "phase_a2_iter17_pivot_to_P2_recommended"
        ]
        is True,
        "master_audit_iter17_P1_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter17_P1_search_complete"]
        is True,
        # Iter #18A: equivariant Torelli package baseline.
        "iter18_NS_lattice_rank_15": iter18["NS_lattice_invariants"]["rank_15"]
        is True,
        "iter18_NS_abs_det_eq_2_to_7": iter18["NS_lattice_invariants"][
            "abs_det_eq_2_to_7"
        ]
        is True,
        "iter18_NS_signature_1_14": iter18["NS_lattice_invariants"][
            "signature_1_14"
        ]
        is True,
        "iter18_NS_even": iter18["NS_lattice_invariants"]["even"] is True,
        "iter18_K3_lattice_rank_22": iter18["K3_lattice_invariants"]["rank_22"]
        is True,
        "iter18_K3_lattice_signature_3_19": iter18["K3_lattice_invariants"][
            "signature_3_19"
        ]
        is True,
        "iter18_K3_lattice_unimodular": iter18["K3_lattice_invariants"][
            "unimodular"
        ]
        is True,
        "iter18_K3_lattice_even": iter18["K3_lattice_invariants"]["even"]
        is True,
        "iter18_T_X_triple_eq_7_7_1": iter18["discriminant_gluing"]["T_X_triple"]
        == (7, 7, 1),
        "iter18_T_X_signature_eq_2_5": iter18["discriminant_gluing"][
            "signature_T_X_eq_2_5"
        ]
        is True,
        "iter18_NS_primitive_embedding_certified": iter18["discriminant_gluing"][
            "NS_admits_primitive_embedding_into_Lambda_K3"
        ]
        is True,
        "iter18_discriminant_gluing_via_Nikulin": iter18["discriminant_gluing"][
            "gluing_certified_by_Nikulin_1980_Cor_1_6_2"
        ]
        is True,
        "iter18_22x22_all_squared_to_I": iter18["Lambda_K3_extension"][
            "all_three_squared_to_I_22"
        ]
        is True,
        "iter18_22x22_all_pairs_commute": iter18["Lambda_K3_extension"][
            "all_pairs_commute_on_22_dim"
        ]
        is True,
        "iter18_tau_acts_as_minus_I_on_T_X_block": iter18["Lambda_K3_extension"][
            "tau_T_X_block_eq_minus_I_7"
        ]
        is True,
        "iter18_sigma_A_acts_as_plus_I_on_T_X_block": iter18[
            "Lambda_K3_extension"
        ]["sigma_A_T_X_block_eq_plus_I_7"]
        is True,
        "iter18_sigma_B_acts_as_plus_I_on_T_X_block": iter18[
            "Lambda_K3_extension"
        ]["sigma_B_T_X_block_eq_plus_I_7"]
        is True,
        "iter18_Z2_cubed_action_on_22_dim_direct_sum_certified": iter18[
            "Lambda_K3_extension"
        ]["Z_2_cubed_action_on_direct_sum_certified"]
        is True,
        "iter18_NS_G_rank_eq_7": iter18["NS_G_invariant_sublattice"][
            "NS_G_eq_P_rank_7"
        ]
        is True,
        "iter18_NS_G_signature_eq_1_6": iter18["NS_G_invariant_sublattice"][
            "NS_G_signature_eq_1_6"
        ]
        is True,
        "iter18_NS_G_abs_det_eq_2_to_5": iter18["NS_G_invariant_sublattice"][
            "NS_G_abs_det_eq_2_to_5"
        ]
        is True,
        "iter18_NS_G_contains_positive_class": iter18[
            "NS_G_invariant_sublattice"
        ]["NS_G_contains_positive_class"]
        is True,
        "iter18_period_domain_nonempty": iter18["period_eigenconditions"][
            "period_domain_non_empty"
        ]
        is True,
        "iter18_period_eigenconditions_automatic": iter18[
            "period_eigenconditions"
        ]["period_eigenconditions_automatic_under_prescribed_extension"]
        is True,
        "iter18_hodge_riemann_positivity_realisable": iter18[
            "period_eigenconditions"
        ]["hodge_riemann_positivity_realisable"]
        is True,
        "iter18_torelli_step_1_lattice_isometry": iter18["torelli_applicability"][
            "torelli_step_1_abstract_lattice_isometry"
        ]
        is True,
        "iter18_torelli_step_2_hodge_eigenconditions": iter18[
            "torelli_applicability"
        ]["torelli_step_2_hodge_eigenconditions"]
        is True,
        "iter18_torelli_step_3_ample_chamber_at_signature_level": iter18[
            "torelli_applicability"
        ]["torelli_step_3_ample_chamber_preservation_at_signature_level"]
        is True,
        "iter18_baseline_complete": iter18["iter_18A_baseline_complete"] is True,
        # iter #18 honesty: specific polarisation + explicit equations
        # must remain UNCERTIFIED for now (per GPT council #11).
        "iter18_specific_polarisation_pending_honest": iter18[
            "ample_chamber_preservation"
        ]["iter_18B_specific_polarisation_scan_pending"]
        is True,
        "iter18_projective_model_route_pending_honest": iter18[
            "ample_chamber_preservation"
        ]["iter_18C_projective_model_route_pending"]
        is True,
        # Master audit cross-checks.
        "master_audit_iter18_NS_15_7_1_invariants_match": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_NS_15_7_1_invariants_match"]
        is True,
        "master_audit_iter18_K3_unimodular_3_19": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_K3_lattice_unimodular_even_sig_3_19"]
        is True,
        "master_audit_iter18_T_X_eq_7_7_1": master["lean_bool_certificates"][
            "phase_a2_iter18_T_X_invariants_eq_7_7_1"
        ]
        is True,
        "master_audit_iter18_discriminant_gluing": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_discriminant_gluing_verified"]
        is True,
        "master_audit_iter18_full_action_constructed": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_full_LambdaK3_direct_sum_action_constructed"]
        is True,
        "master_audit_iter18_NS_G_rank_7": master["lean_bool_certificates"][
            "phase_a2_iter18_NS_G_rank_eq_7"
        ]
        is True,
        "master_audit_iter18_period_nonempty": master["lean_bool_certificates"][
            "phase_a2_iter18_period_domain_nonempty"
        ]
        is True,
        "master_audit_iter18_torelli_step_1": master["lean_bool_certificates"][
            "phase_a2_iter18_torelli_step_1_lattice_isometry"
        ]
        is True,
        "master_audit_iter18_torelli_step_2": master["lean_bool_certificates"][
            "phase_a2_iter18_torelli_step_2_hodge_eigenconditions"
        ]
        is True,
        "master_audit_iter18_torelli_step_3": master["lean_bool_certificates"][
            "phase_a2_iter18_torelli_step_3_ample_chamber_at_signature_level"
        ]
        is True,
        "master_audit_iter18_weierstrass_demoted": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_weierstrass_demoted_to_derived_structure"]
        is True,
        "master_audit_iter18_explicit_equations_FALSE_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18_explicit_equations_found_FALSE_HONEST"]
        is False,
        "master_audit_iter18_baseline_complete": master["lean_bool_certificates"][
            "phase_a2_iter18_baseline_complete"
        ]
        is True,
        # Iter #18B: G-invariant polarisation scanner.
        "iter18B_NS_G_gram_is_H_plus_A1_5_canonical": iter18B[
            "ns_g_gram_is_H_plus_A1_minus_1_times_5"
        ]
        is True,
        "iter18B_positive_classes_count_geq_100": iter18B[
            "positive_classes_count"
        ]
        >= 100,
        "iter18B_minus_2_roots_count_positive": iter18B["minus_2_roots_count"] > 0,
        "iter18B_isotropic_classes_count_positive": iter18B[
            "isotropic_classes_count"
        ]
        > 0,
        "iter18B_h_double_sextic_witness_h2_eq_2": iter18B["witnesses"][
            "h_double_sextic_witness_h2"
        ]
        == 2,
        "iter18B_h_quartic_witness_h2_eq_4": iter18B["witnesses"][
            "h_quartic_witness_h2"
        ]
        == 4,
        "iter18B_h_CI222_witness_h2_eq_8": iter18B["witnesses"][
            "h_CI222_witness_h2"
        ]
        == 8,
        "iter18B_h_isotropic_e_h2_eq_0": iter18B["witnesses"][
            "h_isotropic_e_h2"
        ]
        == 0,
        "iter18B_h_isotropic_f_h2_eq_0": iter18B["witnesses"][
            "h_isotropic_f_h2"
        ]
        == 0,
        "iter18B_U_summand_present_in_NS_G": iter18B[
            "isotropic_present_indicates_U_summand_in_NS_G"
        ]
        is True,
        "iter18B_elliptic_fibration_derived_route_available": iter18B[
            "elliptic_fibration_derived_route_available"
        ]
        is True,
        "iter18B_recommended_h_square_eq_8": iter18B["recommendation"][
            "recommended_h_square"
        ]
        == 8,
        "iter18B_recommended_route_is_CI222": (
            "CI(2,2,2)"
            in (
                iter18B["recommendation"]["recommended_projective_model_route"]
                or ""
            )
        ),
        "iter18B_recommended_example_h_eq_4e_plus_f": iter18B["recommendation"][
            "recommended_example_h_coords"
        ]
        == [4, 1, 0, 0, 0, 0, 0],
        "iter18B_open_chamber_full_analysis_deferred_iter18C": iter18B[
            "recommendation"
        ]["open_chamber_full_analysis_deferred_to_iter_18C"]
        is True,
        "iter18B_scanner_complete": iter18B["iter_18B_scanner_complete"] is True,
        # Master audit cross-checks for iter #18B.
        "master_audit_iter18B_NS_G_canonical_form": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18B_NS_G_gram_is_H_plus_A1_5"]
        is True,
        "master_audit_iter18B_positive_classes_exist": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18B_positive_h_classes_exist"]
        is True,
        "master_audit_iter18B_CI222_witness_h2_8": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18B_h_CI222_witness_h2_eq_8"]
        is True,
        "master_audit_iter18B_recommended_CI222": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18B_route_recommended_h2_eq_8_CI222"]
        is True,
        "master_audit_iter18B_witness_4e_plus_f": master["lean_bool_certificates"][
            "phase_a2_iter18B_witness_h_eq_4e_plus_f_recommended"
        ]
        is True,
        "master_audit_iter18B_scanner_complete": master["lean_bool_certificates"][
            "phase_a2_iter18B_scanner_complete"
        ]
        is True,
        # Iter #18C: projective model route selector.
        "iter18C_h_square_eq_8": iter18C["h_square_in_NS_G"] == 8,
        "iter18C_h_lift_purely_in_P_block": (
            iter18C["h_lift_to_M_oplus_M_perp"][7:] == [0] * 8
        ),
        "iter18C_riemann_roch_h0_eq_6": iter18C["riemann_roch"][
            "h0_via_riemann_roch"
        ]
        == 6,
        "iter18C_projective_embedding_dim_eq_5": iter18C["riemann_roch"][
            "projective_embedding_dimension"
        ]
        == 5,
        "iter18C_mukai_genus_5_applies": iter18C["mukai_genus_5_recognition"][
            "applies"
        ]
        is True,
        "iter18C_mukai_route_CI222_in_P5": iter18C[
            "mukai_genus_5_recognition"
        ].get("projective_model_type", "")
        == "complete intersection (2, 2, 2) in P^5",
        "iter18C_24_D4_roots_tested": iter18C["D_block_screen"][
            "num_D_4_roots_tested"
        ]
        == 24,
        "iter18C_all_D4_roots_are_minus_2": iter18C["D_block_screen"][
            "all_roots_are_minus_2_classes"
        ]
        is True,
        "iter18C_h_orthogonal_to_all_D4_roots": iter18C["D_block_screen"][
            "all_orthogonal_to_h"
        ]
        is True,
        "iter18C_8_Q_block_roots_tested": iter18C["Q_block_screen"][
            "num_Q_block_roots_tested"
        ]
        == 8,
        "iter18C_h_orthogonal_to_all_Q_block_A1_roots": iter18C["Q_block_screen"][
            "all_orthogonal_to_h"
        ]
        is True,
        "iter18C_h_orthogonal_to_all_5_P_alpha_walls": iter18C[
            "P_alpha_walls_screen"
        ]["all_orthogonal_to_h"]
        is True,
        "iter18C_h_NOT_orthogonal_to_H_wall": iter18C["H_wall_screen"][
            "h_orthogonal_to_H_wall"
        ]
        is False,
        "iter18C_h_on_positive_side_of_H_wall": iter18C["H_wall_screen"][
            "h_on_positive_side_of_oriented_wall"
        ]
        is True,
        "iter18C_all_walls_consistent_with_singular_CI222": iter18C[
            "all_walls_consistent_with_singular_CI222"
        ]
        is True,
        "iter18C_predicted_ADE_eq_D4_plus_9_A1": iter18C[
            "predicted_singularity_type"
        ]["ADE_type_summary"]
        == "D_4 + 9 A_1",
        "iter18C_predicted_singularity_matches_NS_rank_15": iter18C[
            "predicted_singularity_type"
        ]["matches_NS_rank_15"]
        is True,
        "iter18C_picard_after_resolution_eq_15": iter18C[
            "predicted_singularity_type"
        ]["total_picard_rank_after_resolution"]
        == 15,
        "iter18C_V_dim_eq_6": iter18C["G_representation_framework"]["V_dim"]
        == 6,
        "iter18C_G_chars_count_eq_8": iter18C["G_representation_framework"][
            "G_dual_size"
        ]
        == 8,
        "iter18C_Sym2_V_dim_eq_21": iter18C["G_representation_framework"][
            "sym2_V_dim"
        ]
        == 21,
        "iter18C_Q_triple_dim_eq_3": iter18C["G_representation_framework"][
            "quadric_space_dim_eq_3"
        ]
        is True,
        "iter18C_character_multiplicities_pending_iter18D": iter18C[
            "G_representation_framework"
        ]["character_multiplicities_pending_iter_18D"]
        is True,
        "iter18C_route_structure_complete": iter18C[
            "iter_18C_route_structure_complete"
        ]
        is True,
        "iter18C_explicit_equations_pending_iter18D_HONEST": iter18C[
            "iter_18D_explicit_equations_pending"
        ]
        is True,
        # Master audit cross-checks for iter #18C.
        "master_audit_iter18C_h_square_8": master["lean_bool_certificates"][
            "phase_a2_iter18C_h_square_eq_8"
        ]
        is True,
        "master_audit_iter18C_RR_h0_6": master["lean_bool_certificates"][
            "phase_a2_iter18C_riemann_roch_h0_eq_6"
        ]
        is True,
        "master_audit_iter18C_mukai_genus_5_applies": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18C_mukai_genus_5_applies"]
        is True,
        "master_audit_iter18C_h_perp_24_D4": master["lean_bool_certificates"][
            "phase_a2_iter18C_h_orthogonal_to_all_D4_roots"
        ]
        is True,
        "master_audit_iter18C_h_perp_Q_roots": master["lean_bool_certificates"][
            "phase_a2_iter18C_h_orthogonal_to_all_Q_block_A1_roots"
        ]
        is True,
        "master_audit_iter18C_h_not_perp_H_wall": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18C_h_NOT_orthogonal_to_H_wall"]
        is True,
        "master_audit_iter18C_singularity_D4_plus_9A1": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18C_predicted_ADE_eq_D4_plus_9_A1"]
        is True,
        "master_audit_iter18C_cross_validates_iter12": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18C_cross_validates_iter12_weierstrass_D4_9A1"]
        is True,
        "master_audit_iter18C_route_structure_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18C_route_structure_complete"]
        is True,
        "master_audit_iter18D_pending_HONEST": master["lean_bool_certificates"][
            "phase_a2_iter18D_explicit_equations_pending_HONEST"
        ]
        is True,
        # Iter #18D: Mukai linearisation framework.
        "iter18D_V_dim_eq_6": iter18D["V_dim_eq_6_required_for_h_squared_8"]
        is True,
        "iter18D_Sym2_V_dim_eq_21": iter18D["Sym2_V_dim_eq_21"] is True,
        "iter18D_Sym2_V_decomposition_sums_to_21": iter18D[
            "Sym2_V_decomposition_sums_to_21"
        ]
        is True,
        "iter18D_default_canonical_isotype_chi_tau_dim_3": (
            iter18D["default_canonical_3_dim_isotype"] is not None
            and iter18D["default_canonical_3_dim_isotype"]["characters"]
            == ["τ"]
        ),
        "iter18D_default_canonical_monomials_3_count": (
            len(iter18D["default_canonical_quadric_monomial_basis"]) == 3
        ),
        "iter18D_default_template_reducible_K3_HONEST": iter18D[
            "default_template_predicts_reducible_K3"
        ]
        is True,
        "iter18D_alternative_irreducible_templates_exist": (
            len(iter18D["templates_predicting_irreducible_K3"]) > 0
        ),
        "iter18D_T4_trivial_mult_2_irreducible": any(
            "T4" in t for t in iter18D["templates_predicting_irreducible_K3"]
        ),
        "iter18D_T5_tau_mult_2_irreducible": any(
            "T5" in t for t in iter18D["templates_predicting_irreducible_K3"]
        ),
        "iter18D_framework_complete": iter18D["framework_complete"] is True,
        "iter18D_lefschetz_choice_pending_HONEST": iter18D[
            "iter_18D_explicit_equations_pending_lefschetz_or_moduli_choice"
        ]
        is True,
        # Master audit cross-checks for iter #18D.
        "master_audit_iter18D_V_dim_eq_6": master["lean_bool_certificates"][
            "phase_a2_iter18D_V_dim_eq_6"
        ]
        is True,
        "master_audit_iter18D_Sym2_V_dim_21": master["lean_bool_certificates"][
            "phase_a2_iter18D_Sym2_V_dim_eq_21"
        ]
        is True,
        "master_audit_iter18D_default_canonical_chi_tau": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18D_default_canonical_isotype_chi_tau_dim_3"]
        is True,
        "master_audit_iter18D_default_reducible_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18D_default_template_reducible_K3_HONEST"]
        is True,
        "master_audit_iter18D_irreducible_templates_exist": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18D_alternative_irreducible_templates_exist"]
        is True,
        "master_audit_iter18D_framework_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18D_framework_complete"]
        is True,
        "master_audit_iter18D_lefschetz_pending_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18D_lefschetz_template_choice_pending_HONEST"]
        is True,
        # Iter #18E: Atiyah-Bott Lefschetz calculator.
        "iter18E_id_lefschetz_eq_24_chi_K3": iter18E[
            "id_lefschetz_eq_24_chi_K3"
        ]
        is True,
        "iter18E_sigma_A_lefschetz_eq_8_mukai_compatible": iter18E[
            "sigma_A_lefschetz_eq_8_mukai_compatible"
        ]
        is True,
        "iter18E_sigma_B_lefschetz_eq_16_anomaly_HONEST": iter18E[
            "sigma_B_lefschetz_eq_16_mukai_ANOMALY"
        ]
        is True,
        "iter18E_sigma_A_sigma_B_lefschetz_eq_16_anomaly_HONEST": iter18E[
            "sigma_A_sigma_B_lefschetz_eq_16_mukai_ANOMALY"
        ]
        is True,
        "iter18E_all_4_tau_cosets_chi_eq_2": iter18E[
            "all_4_tau_cosets_lefschetz_eq_2"
        ]
        is True,
        "iter18E_inverse_char_transform_self_consistent_T4": iter18E[
            "candidate_trace_exploration"
        ]["transform_is_self_consistent_for_T4"]
        is True,
        "iter18E_framework_complete": iter18E[
            "iter_18E_lefschetz_framework_complete"
        ]
        is True,
        "iter18E_revealed_structural_anomaly_HONEST": iter18E[
            "iter_18E_revealed_sigma_B_mukai_anomaly_HONEST"
        ]
        is True,
        "iter18E_explicit_m_chi_blocked_HONEST": iter18E[
            "iter_18E_explicit_m_chi_blocked_by_structural_issue_HONEST"
        ]
        is True,
        # Master audit cross-checks for iter #18E.
        "master_audit_iter18E_id_lefschetz_24": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_id_lefschetz_eq_24_chi_K3"]
        is True,
        "master_audit_iter18E_sigma_A_mukai_8": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_sigma_A_lefschetz_eq_8_mukai_compatible"]
        is True,
        "master_audit_iter18E_sigma_B_anomaly_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_sigma_B_lefschetz_eq_16_mukai_ANOMALY_HONEST"]
        is True,
        "master_audit_iter18E_tau_cosets_chi_2": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_all_4_tau_cosets_lefschetz_eq_2_consistent"]
        is True,
        "master_audit_iter18E_framework_complete": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_framework_complete"]
        is True,
        "master_audit_iter18E_anomaly_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_revealed_structural_anomaly_HONEST"]
        is True,
        "master_audit_iter18E_explicit_blocked_HONEST": master[
            "lean_bool_certificates"
        ]["phase_a2_iter18E_explicit_m_chi_blocked_HONEST"]
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
