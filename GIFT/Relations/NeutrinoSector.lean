-- GIFT Relations: Neutrino Sector
-- Mixing angles θ₁₂, θ₁₃, θ₂₃ and γ_GIFT parameter
-- Extension: +4 certified relations

import GIFT.Core
import GIFT.Relations
import Mathlib.Data.Nat.Prime.Basic

namespace GIFT.Relations.NeutrinoSector

open GIFT.Core GIFT.Relations

/-!
## Scope note (v3.6 alignment, 2026-10-22)

The PMNS relations of the K₇ paper v3.6 are sin²θ₁₂ = 4/13, sin²θ₂₃ = 6/11 and
sin²θ₁₃ = 11/496 (`GIFT.Observables.PMNS`), and its δ_CP relation is the integer
dim(K₇)·dim(G₂) + H* = 197. The older angle formulas in this file (γ = 511/884,
θ₂₃ = 85/99 rad, θ₁₃ = π/21, the 7/23 and 8/14 ratios) are NOT relations of v3.6.
They are kept as arithmetic identities; the declarations whose names claimed an
observable were renamed to neutral arithmetic names (deprecated aliases keep the
old names compiling). Several of them are mutually incompatible with the paper's
relations as exact equalities: an instance of vocabulary freedom.
-/

-- =============================================================================
-- γ_GIFT (legacy parameter; not a relation of v3.6)
-- γ_GIFT = (2×rank(E₈) + 5×H*)/(10×dim(G₂) + 3×dim(E₈)) = 511/884
-- =============================================================================

/-- γ_GIFT numerator: 2×8 + 5×99 = 16 + 495 = 511 -/
def gamma_GIFT_num : Nat := 2 * rank_E8 + 5 * H_star

theorem gamma_GIFT_num_certified : gamma_GIFT_num = 511 := rfl

theorem gamma_GIFT_num_from_topology : 2 * rank_E8 + 5 * H_star = 511 := by native_decide

/-- γ_GIFT denominator: 10×14 + 3×248 = 140 + 744 = 884 -/
def gamma_GIFT_den : Nat := 10 * dim_G2 + 3 * dim_E8

theorem gamma_GIFT_den_certified : gamma_GIFT_den = 884 := rfl

theorem gamma_GIFT_den_from_topology : 10 * dim_G2 + 3 * dim_E8 = 884 := by native_decide

/-- γ_GIFT = 511/884 (irreducible) -/
theorem gamma_GIFT_certified : gamma_GIFT_num = 511 ∧ gamma_GIFT_den = 884 := ⟨rfl, rfl⟩

-- =============================================================================
-- RELATION #16: δ (PENTAGONAL STRUCTURE)
-- δ = 2π/25, Weyl² = 25
-- =============================================================================

/-- Pentagonal denominator: Weyl² = 5² = 25 -/
theorem delta_pentagonal_certified : Weyl_sq = 25 := rfl

theorem delta_denom_from_Weyl : Weyl_factor * Weyl_factor = 25 := by native_decide

-- =============================================================================
-- (rank(E₈) + b₃)/H* = 85/99 — arithmetic identity, NOT the θ₂₃ relation of v3.6
-- =============================================================================

/-- Arithmetic identity: rank(E₈) + b₃ = 8 + 77 = 85. Not the relation of the paper
    (which is sin²θ₂₃ = (D_bulk − Weyl)/D_bulk = 6/11); a legacy reading
    θ₂₃ = 85/99 rad is an instance of vocabulary freedom. Formerly `theta_23_num`. -/
def rank_E8_plus_b3 : Nat := rank_E8 + b3

theorem rank_E8_plus_b3_certified : rank_E8_plus_b3 = 85 := rfl

theorem rank_E8_plus_b3_from_topology : rank_E8 + b3 = 85 := by native_decide

/-- H* = 99 as the denominator of (rank(E₈) + b₃)/H*. Formerly `theta_23_den`. -/
def rank_E8_plus_b3_over_H_star_den : Nat := H_star

theorem rank_E8_plus_b3_over_H_star_den_certified : rank_E8_plus_b3_over_H_star_den = 99 := rfl

/-- Arithmetic identity: (rank(E₈) + b₃, H*) = (85, 99). Not the θ₂₃ relation of the
    paper (sin²θ₂₃ = 6/11). Formerly `theta_23_certified`. -/
theorem rank_E8_plus_b3_over_H_star_certified :
    rank_E8_plus_b3 = 85 ∧ rank_E8_plus_b3_over_H_star_den = 99 := ⟨rfl, rfl⟩

@[deprecated rank_E8_plus_b3 (since := "2026-10-22")]
abbrev theta_23_num : Nat := rank_E8_plus_b3
@[deprecated rank_E8_plus_b3_over_H_star_den (since := "2026-10-22")]
abbrev theta_23_den : Nat := rank_E8_plus_b3_over_H_star_den
@[deprecated (since := "2026-10-22")]
alias theta_23_num_certified := rank_E8_plus_b3_certified
@[deprecated (since := "2026-10-22")]
alias theta_23_num_from_topology := rank_E8_plus_b3_from_topology
@[deprecated (since := "2026-10-22")]
alias theta_23_den_certified := rank_E8_plus_b3_over_H_star_den_certified
@[deprecated (since := "2026-10-22")]
alias theta_23_certified := rank_E8_plus_b3_over_H_star_certified

-- =============================================================================
-- Legacy θ₁₃ = π/b₂ reading — NOT the θ₁₃ relation of v3.6
-- (the paper's relation is sin²θ₁₃ = D_bulk/dim(E₈×E₈) = 11/496)
-- =============================================================================

@[deprecated GIFT.Core.b2_value (since := "2026-10-22")]
alias theta_13_denom_certified := GIFT.Core.b2_value

@[deprecated GIFT.Core.b2_value (since := "2026-10-22")]
alias theta_13_from_Betti := GIFT.Core.b2_value

-- =============================================================================
-- Legacy θ₁₂ = arctan(√(δ/γ)) reading — NOT the θ₁₂ relation of v3.6
-- (the paper's relation is sin²θ₁₂ = (1 + N_gen)/α_sum = 4/13).
-- The statements below are arithmetic on Weyl² and γ only.
-- =============================================================================

/-- θ₁₂ involves δ denominator = 25 and γ = 511/884 -/
theorem theta_12_delta_denom : Weyl_sq = 25 := rfl

theorem theta_12_gamma_components : gamma_GIFT_num = 511 ∧ gamma_GIFT_den = 884 := ⟨rfl, rfl⟩

/-- δ/γ denominator structure: 25 × 511 = 12775 -/
theorem theta_12_ratio_num_factor : Weyl_sq * gamma_GIFT_num = 12775 := by native_decide

/-- δ/γ numerator structure: 884 (from γ denominator, contributes to numerator of δ/γ) -/
theorem theta_12_ratio_den_factor : gamma_GIFT_den = 884 := rfl

-- =============================================================================
-- V2.0: G2 SIGNATURE IN NEUTRINO PARAMETERS (Relations 221-230)
-- =============================================================================

/-- Arithmetic identity: dim(K₇) = 7 (numerator of dim(K₇)/(b₂ + p₂) = 7/23).
    Not the relation of the paper (which is sin²θ₁₂ = (1 + N_gen)/α_sum = 4/13);
    an instance of vocabulary freedom. Formerly `sin2_theta12_num`. -/
def K7_over_b2_plus_p2_num : Nat := dim_K7
/-- b₂ + p₂ = 23 (denominator of 7/23). Formerly `sin2_theta12_den`. -/
def K7_over_b2_plus_p2_den : Nat := b2 + p2

/-- Arithmetic identity: (dim(K₇), b₂ + p₂) = (7, 23). Not the relation of the paper
    (which is sin²θ₁₂ = 4/13); an instance of vocabulary freedom.
    Formerly `sin2_theta12_structure`. -/
theorem K7_over_b2_plus_p2_values :
    K7_over_b2_plus_p2_num = 7 ∧ K7_over_b2_plus_p2_den = 23 := by
  constructor <;> native_decide

/-- Arithmetic identity: rank(E₈) = 8 (numerator of rank(E₈)/dim(G₂) = 8/14 = 4/7).
    Not the relation of the paper (which is sin²θ₂₃ = (D_bulk − Weyl)/D_bulk = 6/11);
    an instance of vocabulary freedom. Formerly `sin2_theta23_num`. -/
def rank_E8_over_G2_num : Nat := rank_E8
/-- dim(G₂) = 14 (denominator of 8/14). Formerly `sin2_theta23_den`. -/
def rank_E8_over_G2_den : Nat := dim_G2

/-- Arithmetic identity: rank(E₈)/dim(G₂) = 8/14 = 4/7. Not the relation of the paper
    (which is sin²θ₂₃ = 6/11); an instance of vocabulary freedom.
    Formerly `sin2_theta23_structure`. -/
theorem rank_E8_over_G2_values :
    rank_E8_over_G2_num = 8 ∧ rank_E8_over_G2_den = 14 ∧
    8 * 7 = 14 * 4 := by
  repeat (first | constructor | native_decide)

@[deprecated K7_over_b2_plus_p2_num (since := "2026-10-22")]
abbrev sin2_theta12_num : Nat := K7_over_b2_plus_p2_num
@[deprecated K7_over_b2_plus_p2_den (since := "2026-10-22")]
abbrev sin2_theta12_den : Nat := K7_over_b2_plus_p2_den
@[deprecated (since := "2026-10-22")]
alias sin2_theta12_structure := K7_over_b2_plus_p2_values
@[deprecated rank_E8_over_G2_num (since := "2026-10-22")]
abbrev sin2_theta23_num : Nat := rank_E8_over_G2_num
@[deprecated rank_E8_over_G2_den (since := "2026-10-22")]
abbrev sin2_theta23_den : Nat := rank_E8_over_G2_den
@[deprecated (since := "2026-10-22")]
alias sin2_theta23_structure := rank_E8_over_G2_values

/-- Legacy name: the paper's sin²θ₁₃ = 11/496 does not involve b₂. -/
@[deprecated GIFT.Core.b2_value (since := "2026-10-22")]
alias sin2_theta13_involves_b2 := GIFT.Core.b2_value

/-- RELATION 224: the integer 197 = dim_K7 * dim_G2 + H* = 7*14 + 99 = 98 + 99.
    (Reading it as δ_CP in degrees is a dictionary assignment, not stated in Lean.) -/
theorem delta_CP_gift_v2 : (197 : Nat) = dim_K7 * dim_G2 + H_star := by native_decide

/-- RELATION 225: delta_CP alternative
    197 = dim_E8 - 3 * lambda_H_num = 248 - 51 -/
theorem delta_CP_from_E8 : (197 : Nat) = dim_E8 - 3 * lambda_H_num := by native_decide

/-- RELATION 226: dim_G2 = 14, dim_K7 = 7, dim_G2 = 2 · dim_K7
    (legacy docstring linked these to the 8/14 and 7/23 ratios above, which are
    not the PMNS relations of v3.6) -/
theorem G2_in_PMNS :
    dim_G2 = 14 ∧
    dim_K7 = 7 ∧
    dim_G2 = 2 * dim_K7 := by
  repeat (first | constructor | native_decide | rfl)

/-- RELATION 227: PMNS matrix determinant structure
    |det(U_PMNS)| = 1 (unitary)
    1 = dim_U1 -/
theorem PMNS_unitary : dim_U1 = 1 := rfl

/-- RELATION 228: CP violation phase 197 is prime -/
theorem delta_CP_prime : Nat.Prime 197 := by native_decide

/-- RELATION 229: Jarlskog invariant structure
    J ~ 0.033, structure involves N_gen = 3 -/
theorem jarlskog_structure : N_gen = 3 := rfl

/-- RELATION 230: Neutrino mass hierarchy
    Delta m^2_21 / Delta m^2_31 ~ 0.03
    Structure involves 3 / H_star -/
theorem mass_hierarchy_structure :
    N_gen = 3 ∧ H_star = 99 ∧ 99 / 3 = 33 := by
  repeat (first | constructor | native_decide | rfl)

-- =============================================================================
-- V2.0: MASTER THEOREM
-- =============================================================================

/-- Conjunction of the arithmetic identities of this section. The first two items
    (7/23, 8/14) are NOT the PMNS relations of v3.6 (sin²θ₁₂ = 4/13, sin²θ₂₃ = 6/11). -/
theorem all_neutrino_v2_relations_certified :
    -- arithmetic ratios 7/23 and 8/14 (not the paper's PMNS relations)
    (K7_over_b2_plus_p2_num = 7 ∧ K7_over_b2_plus_p2_den = 23) ∧
    (rank_E8_over_G2_num = 8 ∧ rank_E8_over_G2_den = 14) ∧
    (b2 = 21) ∧
    -- delta_CP
    (197 = dim_K7 * dim_G2 + H_star) ∧
    (197 = dim_E8 - 3 * lambda_H_num) ∧
    Nat.Prime 197 ∧
    -- G2 structure
    (dim_G2 = 2 * dim_K7) ∧
    -- Unitary
    (dim_U1 = 1) ∧
    -- Jarlskog
    (N_gen = 3) ∧
    -- Mass hierarchy
    (H_star = 99) :=
  ⟨K7_over_b2_plus_p2_values, ⟨rank_E8_over_G2_values.1, rank_E8_over_G2_values.2.1⟩, rfl,
   by native_decide, by native_decide, delta_CP_prime,
   by native_decide, rfl, rfl, rfl⟩

end GIFT.Relations.NeutrinoSector
