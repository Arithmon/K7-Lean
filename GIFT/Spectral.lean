/-
GIFT Spectral Module
====================

Spectral theory foundations for the Yang-Mills mass gap.

## Overview

This module formalizes the spectral gap result:
  ev₁(K7) = (dim(G₂) − h) / H* = 13/99

The key insight: the mass gap is determined by TOPOLOGY, not dynamics.

## Contents (v3.3.16)

### Spectral Theory Foundation
- `SpectralTheory`: Laplacian, spectral theorem, mass gap definition

### G₂ Holonomy Manifolds
- `G2Manifold`: G₂ holonomy, K7 construction, TCS connection, parallel spinors

### Universal Spectral Law
- `UniversalLaw`: ev₁ × H* = dim(G₂) − h, the universal identity
- `MassGapRatio`: The 14/99 bare ratio (algebraic)
- `PhysicalSpectralGap`: dim(G₂)−h=13 algebraic identities (zero axioms)

### TCS Spectral Bounds (v3.3.12)
- `NeckGeometry`: TCS manifold structure and hypotheses (H1)-(H6)
- `TCSBounds`: Model Theorem - ev₁ ~ 1/L² for TCS manifolds

### Selection Principle (v3.3.14)
- `SelectionPrinciple`: kappa = pi^2/14, building blocks, L^2 = kappa*H*
- `RefinedSpectralBounds`: Refined bounds with H7 hypothesis, pi^2 coefficient

### Literature Axioms (Langlais 2024, CGN 2024)
- `LiteratureAxioms`: Spectral density formula, no small eigenvalues

### Applications
- `CheegerInequality`: Cheeger-Buser bounds
- `YangMills`: Connection to Clay Millennium Prize

## References

- Joyce, D.D. (2000). Compact Manifolds with Special Holonomy
- Cheeger, J. (1970). A lower bound for the smallest eigenvalue of the Laplacian
- Jaffe, A. & Witten, E. (2000). Yang-Mills Existence and Mass Gap
- Kovalev, A. (2003). Twisted connected sums and special Riemannian holonomy
- Selberg, A. (1956). Harmonic analysis and discontinuous groups
- Duistermaat, J.J. & Guillemin, V. (1975). Invent. Math. 29:39-79

Version: 2.3.0
-/

-- Spectral theory foundations
import GIFT.Spectral.SpectralTheory

-- G₂ holonomy manifolds
import GIFT.Spectral.G2Manifold

-- Universal law, mass gap ratio, physical spectral gap
import GIFT.Spectral.UniversalLaw
import GIFT.Spectral.MassGapRatio
import GIFT.Spectral.PhysicalSpectralGap

-- TCS Spectral Bounds
import GIFT.Spectral.NeckGeometry
import GIFT.Spectral.TCSBounds

-- Selection Principle (NEW in v3.3.14)
import GIFT.Spectral.SelectionPrinciple
import GIFT.Spectral.RefinedSpectralBounds

-- Literature Axioms (Langlais 2024, CGN 2024)
import GIFT.Spectral.LiteratureAxioms

-- Computed Spectrum (Spectral Physics paper results, v3.3.29)
import GIFT.Spectral.ComputedSpectrum

-- Spectral Democracy (generation universality, v3.3.30)
import GIFT.Spectral.SpectralDemocracy

-- Computed Yukawa (Wilson line mass ratios, v3.3.31)
import GIFT.Spectral.ComputedYukawa

-- Computed 7D Weyl Law (unified spectrum, v3.3.35)
import GIFT.Spectral.ComputedWeylLaw

-- Spectral Invariants (heat kernel, zeta, bounds, b₁=0, v3.3.39)
import GIFT.Spectral.SpectralInvariants

-- Applications
import GIFT.Spectral.CheegerInequality
import GIFT.Spectral.YangMills

namespace GIFT.Spectral

-- ============================================================================
-- RE-EXPORTS: SPECTRAL THEORY
-- ============================================================================

export SpectralTheory (
  CompactManifold
  LaplaceBeltrami
  Eigenvalue
  Spectrum
  MassGap
  mass_gap_positive
)

-- ============================================================================
-- RE-EXPORTS: G₂ MANIFOLD
-- ============================================================================

export G2Manifold (
  G2HolonomyManifold
  K7_Manifold
  K7
  K7_betti_2
  K7_betti_3
  K7_H_star
  G2_manifold_certificate
)

-- ============================================================================
-- RE-EXPORTS: UNIVERSAL LAW
-- ============================================================================

export UniversalLaw (
  K7_mass_gap_eq_gift_ratio
  product_formula
  ratio_irreducible
  ratio_coprime
  physical_mass_gap_MeV
  universal_law_certificate
)

-- ============================================================================
-- RE-EXPORTS: MASS GAP RATIO
-- ============================================================================

export MassGapRatio (
  -- Core definitions
  mass_gap_ratio
  mass_gap_ratio_num
  mass_gap_ratio_den
  cheeger_lower_bound
  -- Key theorems
  mass_gap_ratio_value
  mass_gap_ratio_irreducible
  mass_gap_coprime
  mass_gap_from_holonomy_cohomology
  mass_gap_tight_bound
  cheeger_bound_value
  cheeger_bound_positive
  -- Yang-Mills connection
  GIFT_mass_gap_MeV
  mass_gap_prediction
  mass_gap_exact
  -- Master certificate
  mass_gap_ratio_certified
)

-- ============================================================================
-- RE-EXPORTS: NECK GEOMETRY (TCS)
-- ============================================================================

export NeckGeometry (
  TCSManifold
  BoundedNeckVolume
  ProductNeckMetric
  BlockCheegerBound
  BalancedBlocks
  NeckMinimality
  TCSHypotheses
  L₀
  L₀_pos
  typical_parameters
  neck_geometry_certificate
)

-- ============================================================================
-- RE-EXPORTS: TCS BOUNDS
-- ============================================================================

export TCSBounds (
  c₁
  c₁_pos
  c₂_robust
  c₂_robust_pos
  c₂_symmetric
  spectral_upper_bound
  spectral_lower_bound
  tcs_spectral_bounds
  spectral_gap_scales_as_inverse_L_squared
  typical_tcs_bounds_algebraic
  tcs_bounds_certificate
)

-- ============================================================================
-- RE-EXPORTS: SELECTION PRINCIPLE (NEW in v3.3.14)
-- ============================================================================

export SelectionPrinciple (
  -- Pi bounds (documented numerical axioms - see PiBounds.lean)
  -- Selection constant
  pi_squared
  pi_squared_pos
  pi_squared_gt_9
  pi_squared_lt_10
  kappa
  kappa_pos
  kappa_rough_bounds
  -- Building blocks
  QuinticBlock
  CIBlock
  M1
  M2
  -- Mayer-Vietoris
  mayer_vietoris_b2
  mayer_vietoris_b3
  building_blocks_match_K7
  building_blocks_sum
  -- Neck length
  L_squared_canonical
  L_squared_canonical_pos
  L_canonical
  L_canonical_pos
  L_canonical_rough_bounds
  -- Spectral gap
  lambda1_gift
  lambda1_gift_eq
  spectral_gap_from_selection
  -- Spectral-Holonomy Principle
  spectral_holonomy_principle
  spectral_holonomy_alt
  spectral_holonomy_numerical
  spectral_geometric_identity
  -- Axioms
  selection_principle_holds
  universality_conjecture
  -- Certificate
  selection_principle_certificate
)

-- ============================================================================
-- RE-EXPORTS: REFINED SPECTRAL BOUNDS (NEW in v3.3.14)
-- ============================================================================

export RefinedSpectralBounds (
  -- H7 hypothesis
  CrossSectionGap
  TCSHypothesesExt
  -- Decay parameter
  decayParameter
  decayParameter_pos
  -- Spectral coefficient
  spectralCoefficient
  spectralCoefficient_pos
  spectralCoefficient_approx
  -- Main theorem
  refined_spectral_bounds
  spectral_gap_vanishes_at_rate
  coefficient_is_pi_squared
  -- GIFT connection
  gift_connection_algebraic
  gift_neck_length_algebraic
  refined_bounds_certificate
  -- Backwards compatibility
  tier1_spectral_bounds
  tier1_bounds_certificate
)

-- ============================================================================
-- RE-EXPORTS: LITERATURE AXIOMS (Langlais 2024, CGN 2024)
-- ============================================================================

export LiteratureAxioms (
  CrossSection
  K3_betti
  K3_S1
  K3_S1_dim
  density_coefficient_K3S1
  K3_S1_density_coeff_2
  K3_S1_density_coeff_3
  LiteraturePackage
  literature_package
  cgn_no_small_eigenvalues
  cgn_cheeger_lower_bound
  torsion_free_correction
  -- canonical_neck_length_conjecture  -- [REMOVED v3.3.19]
  gift_prediction_structure
  gift_prediction_in_range
  literature_axioms_certificate
)

-- ============================================================================
-- RE-EXPORTS: PHYSICAL SPECTRAL GAP (v3.3.16, zero axioms)
-- ============================================================================

export PhysicalSpectralGap (
  -- Core definitions
  physical_gap_num
  physical_gap_den
  physical_gap_ratio
  -- Derivation from topology
  physical_gap_num_eq
  physical_gap_den_eq
  physical_gap_ratio_value
  physical_gap_from_topology
  -- Algebraic properties
  physical_gap_irreducible
  physical_gap_coprime
  numerator_prime
  -- Spectral-holonomy identity
  spectral_holonomy_corrected
  spectral_holonomy_from_topology
  -- Bare vs physical
  bare_minus_physical
  correction_from_spinors
  -- Cross-holonomy
  SU3_spectral_product
  cross_holonomy_integers
  -- Pell connection
  pell_equation
  -- Certificate
  physical_spectral_gap_certificate
)

-- ============================================================================
-- RE-EXPORTS: COMPUTED SPECTRUM (v3.3.29, Spectral Physics paper)
-- ============================================================================

export ComputedSpectrum (
  -- Q22 intersection form
  Q22_pos
  Q22_neg
  Q22_total
  Q22_signature_sum
  SD_eq_N_gen
  Q22_total_eq_b2_plus_1
  Q22_neg_structural
  -- SD/ASD eigenvalue gap
  min_SD_num
  min_SD_den
  max_ASD_num
  max_ASD_den
  sd_asd_gap_large
  sd_eigenvalue_order
  asd_eigenvalue_small
  -- Gauge coupling B-test
  B_test_num
  B_test_den
  B_above_7_5
  B_close_to_7_5
  B_deviation_exact
  -- Coupling deviation bounds
  sin2w_exp_num
  sin2w_exp_den
  sin2w_theory_below_exp
  sin2w_deviation_small
  alpha_s_exp_num
  alpha_s_exp_den
  alpha_s_theory_below_exp
  alpha_s_deviation_small
  -- Neumann spectral gap
  lambda1_neumann_num
  lambda1_neumann_den
  lambda1_above_cheeger
  lambda1_below_bare
  lambda1_near_physical
  -- Master certificate
  computed_spectrum_certificate
)

-- ============================================================================
-- RE-EXPORTS: COMPUTED YUKAWA (v3.3.31, Wilson line mass ratios)
-- ============================================================================

export ComputedYukawa (
  -- Predicted mass ratios
  yukawa_tau_mu_num
  yukawa_tau_mu_den
  yukawa_tau_e
  yukawa_mu_e_num
  yukawa_mu_e_den
  -- Experimental values
  exp_tau_mu_num
  exp_tau_mu_den
  exp_tau_e_num
  exp_tau_e_den
  exp_mu_e_num
  exp_mu_e_den
  -- Deviation bounds
  tau_mu_below_exp
  tau_mu_deviation_small
  tau_e_deviation_small
  mu_e_deviation_small
  -- Master certificate
  yukawa_mass_ratio_certificate
)

-- ============================================================================
-- RE-EXPORTS: SPECTRAL DEMOCRACY (v3.3.30, generation universality)
-- ============================================================================

export SpectralDemocracy (
  -- SD eigenvalue data
  sd_ev_1_num
  sd_ev_2_num
  sd_ev_3_num
  sd_ev_den
  -- Democracy bounds
  sd_spread
  sd_spread_value
  sd_sum
  sd_sum_value
  sd_mean_exact
  sd_spread_small
  sd_all_above_threshold
  sd_mean_near_five
  -- Generation universality
  sd_coupling_ratio_near_unity
  sd_count_eq_N_gen
  -- Master certificate
  spectral_democracy_certificate
)

-- ============================================================================
-- RE-EXPORTS: COMPUTED WEYL LAW (v3.3.35, 7D Weyl law)
-- ============================================================================

export ComputedWeylLaw (
  -- Weyl exponent
  weyl_exponent_num
  weyl_exponent_den
  weyl_exponent_expected_num
  weyl_exponent_expected_den
  weyl_exponent_close
  weyl_exponent_above_3
  weyl_exponent_below_4
  -- KK state count
  n_kk_states_below_20
  n_fiber_channels
  n_states_large
  n_states_very_large
  n_channels_large
  -- Effective volume
  vol_effective_num
  vol_effective_den
  vol_positive
  vol_gt_one
  -- Master certificate
  computed_weyl_law_certificate
)

-- ============================================================================
-- RE-EXPORTS: SPECTRAL INVARIANTS (v3.3.39, heat kernel, zeta, bounds)
-- ============================================================================

export SpectralInvariants (
  -- Heat kernel coefficients
  a0_1d_num
  a0_1d_den
  a1_1d
  a0_positive
  a1_exceeds_a0
  -- Spectral zeta function
  zeta_prime_0_num
  zeta_prime_0_den
  log_det_order
  zeta_prime_large
  det_order_large
  -- Spectral bounds
  zhong_yang_D_num
  zhong_yang_D_den
  cheeger_h_num
  cheeger_h_den
  ratio_K7_circle_num
  ratio_K7_circle_den
  cheeger_sub_unit
  K7_eigenvalue_below_flat
  -- b₁ = 0 spectral confirmation
  b1_max_gap_scaled
  b1_gap_scale_exp
  b1_spectral_confirmed
  b1_channels_tested
  -- Spectrum size
  n_eigenvalues_distinct
  n_states_total
  n_states_eq_K7_cubed
  -- Master certificate
  spectral_invariants_certificate
)

-- ============================================================================
-- RE-EXPORTS: CHEEGER INEQUALITY
-- ============================================================================

export CheegerInequality (
  CheegerConstant
  K7_cheeger_lower_bound
  mass_gap_exceeds_cheeger
  cheeger_certificate
)

-- ============================================================================
-- RE-EXPORTS: YANG-MILLS
-- ============================================================================

export YangMills (
  CompactSimpleGroup
  YangMillsAction
  YangMillsMassGap
  GIFT_prediction
  mass_gap_in_MeV
  mass_gap_exact_MeV
  ClayMillenniumStatement
  GIFT_provides_candidate
  topological_origin
  yang_mills_certificate
)

/-!
## Quick Reference

| Quantity | Value | GIFT Origin |
|----------|-------|-------------|
| Bare ratio | 14/99 | dim(G₂) / H* |
| Physical ratio (algebraic) | 13/99 | (dim(G₂) − h) / H* |
| Spinor correction | 1/99 | h / H* (Berger) |
| Denominator | 99 | H* = b₂ + b₃ + 1 |
| Cheeger bound | 49/9801 | (14/99)²/4 |
| Graph Laplacian (N=50K) | 0.1313 | Numerical confirmation |
| Algebraic scale (13/99)×200 | 26.26 MeV | Superseded by analytical: √(6π²/475)×200 ≈ 70.7 MeV |

## Module Hierarchy

```
Spectral/
├── SpectralTheory.lean          # Laplacian, spectral theorem
├── G2Manifold.lean              # G₂ holonomy, K7, parallel spinors
├── UniversalLaw.lean            # ev₁ x H* = dim(G₂) - h
├── MassGapRatio.lean            # 14/99 bare algebraic
├── PhysicalSpectralGap.lean     # dim(G₂)−h=13 algebraic (zero axioms)
├── ComputedSpectrum.lean        # Q22 sig, SD/ASD gap, B-test, couplings [v3.3.29]
├── SpectralDemocracy.lean      # Generation universality, SD spread [v3.3.30]
├── ComputedYukawa.lean         # Wilson line mass ratios [v3.3.31]
├── ComputedWeylLaw.lean        # 7D Weyl law verification [v3.3.35]
├── NeckGeometry.lean            # TCS structure, hypotheses (H1)-(H6)
├── TCSBounds.lean               # Model Theorem: ev₁ ~ 1/L^2
├── SelectionPrinciple.lean      # kappa = pi^2/14, building blocks
├── RefinedSpectralBounds.lean   # H7 hypothesis, pi^2 coefficient
├── LiteratureAxioms.lean        # Literature axioms (Langlais, CGN)
├── SpectralInvariants.lean      # Heat kernel, zeta, bounds, b₁=0 [v3.3.39]
├── CheegerInequality.lean       # Cheeger-Buser bounds
└── YangMills.lean               # Clay Prize connection
```

## Axiom Summary

**DOCUMENTED NUMERICAL AXIOMS (v3.3.15):**
These bounds are computationally trivial but Mathlib 4.27 doesn't export them directly.
- `pi_gt_three` → π > 3 (needs sqrtTwoAddSeries or future Mathlib)
- `pi_lt_four` → π < 4 (needs sqrtTwoAddSeries or future Mathlib)
- `pi_lt_sqrt_ten` → π < √10 (needs π < 3.16 bound)

See `GIFT/Foundations/PiBounds.lean` for full documentation and elimination paths.

| Axiom | Purpose | Elimination Path |
|-------|---------|------------------|
| `spectral_theorem_discrete` | Discrete spectrum | Full Mathlib Riemannian geometry |
| `K7_spectral_law` | λ₁ × 99 = 14 | Heat kernel + trace formula |
| `K7_cheeger_constant` | h(K7) = 14/99 | Isoperimetric analysis |
| `GIFT_mass_gap_relation` | Δ = λ₁ × Λ_QCD | M-theory compactification |
| `ProductNeckMetric` | Product metric on TCS neck | Differential geometry |
| `NeckMinimality` | Isoperimetric bound on neck | Coarea formula |
| `spectral_upper_bound` | Rayleigh quotient bound | L² space formalization |
| `neck_dominates` | Neck controls Cheeger | Cut classification |
| `langlais_spectral_density` | [REMOVED v4.0] Superseded by S1-S5 |
| `cgn_no_small_eigenvalues` | No small eigenvalues | CGN 2024 |
| `cgn_cheeger_lower_bound` | Cheeger lower bound | CGN 2024 |
| `canonical_neck_length_conjecture` | L² ~ H* conjecture | GIFT conjecture |
| `selection_principle_holds` | L² = κ·H* selection | Variational proof |
| `universality_conjecture` | λ₁·H* = dim(G₂) for all TCS | Geometric analysis |
| `localization_lemma` | Eigenfunction localization | Mazzeo-Melrose |
| `spectral_lower_bound_refined` | pi^2/L^2 - exp correction | Poincare + localization |
| `trace_formula` | [MOVED v4.0] → Exploratory/Spectral/SelbergBridge |
| `weil_positivity_equiv_RH` | [MOVED v4.0] → Exploratory/Spectral/ConnesBridge |
-/

end GIFT.Spectral
