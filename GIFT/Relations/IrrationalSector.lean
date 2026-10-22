-- GIFT Relations: Irrational Sector
-- Relations involving irrational numbers (pi, phi)
-- Extension: Topological relations with certified rational parts
-- Version: 1.4.0

import GIFT.Core

namespace GIFT.Relations.IrrationalSector

open GIFT.Core

/-!
## Scope note (v3.6 alignment, 2026-10-22)

The legacy readings θ₁₃ = π/b₂ and θ₂₃ = 85/99 rad below are NOT relations of the
K₇ paper v3.6, whose PMNS relations are sin²θ₁₃ = D_bulk/dim(E₈×E₈) = 11/496 and
sin²θ₂₃ = (D_bulk − Weyl)/D_bulk = 6/11 (`GIFT.Observables.PMNS`). The statements
here are arithmetic identities (180/21 = 60/7, rank(E₈) + b₃ = 85, H* = 99); as
exact values of the same angles they are incompatible with the paper's relations:
an instance of vocabulary freedom. The declarations whose names claimed an angle
were renamed to neutral names (deprecated aliases keep the old names compiling).
-/

-- =============================================================================
-- 180/b2 = 180/21 = 60/7 (legacy θ₁₃ = π/21 reading; NOT the v3.6 relation)
-- =============================================================================

/-- 21 = b2(K7). Formerly `theta_13_divisor_is_b2`. -/
theorem twenty_one_is_b2 : (21 : Nat) = b2 := rfl

/-- 180/21 = 60/7 (rational part). Formerly `theta_13_degrees_num/_den`. -/
def deg180_over_b2_num : Nat := 180
def deg180_over_b2_den : Nat := 21

/-- Simplified: 180/21 = 60/7 -/
theorem deg180_over_b2_simplified :
    deg180_over_b2_num / 3 = 60 ∧ deg180_over_b2_den / 3 = 7 := by native_decide

/-- Rational bounds: 8 < 60/7 < 9 -/
theorem sixty_sevenths_bounds :
    8 * 7 < 60 ∧ 60 < 9 * 7 := by native_decide

@[deprecated (since := "2026-10-22")] alias theta_13_divisor_is_b2 := twenty_one_is_b2
@[deprecated deg180_over_b2_num (since := "2026-10-22")]
abbrev theta_13_degrees_num : Nat := deg180_over_b2_num
@[deprecated deg180_over_b2_den (since := "2026-10-22")]
abbrev theta_13_degrees_den : Nat := deg180_over_b2_den
@[deprecated (since := "2026-10-22")]
alias theta_13_degrees_simplified := deg180_over_b2_simplified
@[deprecated (since := "2026-10-22")] alias theta_13_rational_bounds := sixty_sevenths_bounds

-- =============================================================================
-- (rank(E8) + b3)/H* = 85/99 (legacy θ₂₃ = 85/99 rad reading; NOT the v3.6 relation)
-- =============================================================================

/-- 85 = rank(E8) + b3. Formerly `theta_23_rad_num`. -/
def ratio_85_99_num : Nat := 85

/-- 99 = H*. Formerly `theta_23_rad_den`. -/
def ratio_85_99_den : Nat := 99

/-- Arithmetic identity (rank(E8) + b3, H*) = (85, 99); not the θ₂₃ relation of the
    paper (which is sin²θ₂₃ = 6/11). Formerly `theta_23_from_topology`. -/
theorem ratio_85_99_values :
    rank_E8 + b3 = ratio_85_99_num ∧ H_star = ratio_85_99_den := by
  constructor <;> native_decide

/-- Degree conversion factor 180 (legacy). -/
def theta_23_degrees_factor : Nat := 180

@[deprecated ratio_85_99_num (since := "2026-10-22")]
abbrev theta_23_rad_num : Nat := ratio_85_99_num
@[deprecated ratio_85_99_den (since := "2026-10-22")]
abbrev theta_23_rad_den : Nat := ratio_85_99_den
@[deprecated (since := "2026-10-22")]
alias theta_23_from_topology := ratio_85_99_values

-- =============================================================================
-- alpha^-1 COMPLETE (EXACT RATIONAL!)
-- Defined in GaugeSector.lean - here we just reference it
-- alpha^-1 = 128 + 9 + (65/32)*(1/61) = 267489/1952
-- =============================================================================

/-- alpha^-1 torsion correction denominator (reference) -/
def alpha_inv_torsion_den_ref : Nat := 32 * 61

theorem alpha_inv_torsion_den_ref_value : alpha_inv_torsion_den_ref = 1952 := by native_decide

/-- Breakdown verification (reference) -/
theorem alpha_inv_breakdown_ref :
    (128 + 9) * 1952 + 65 = 267489 := by native_decide

-- =============================================================================
-- MASTER THEOREM
-- =============================================================================

/-- Conjunction of the arithmetic identities of this module (legacy θ₁₃ = π/21 and
    θ₂₃ = 85/99 readings, which are NOT relations of v3.6). -/
theorem irrational_sector_certified :
    -- 21 = b2 (legacy θ₁₃ = π/21 divisor)
    (21 : Nat) = b2 ∧
    8 * 7 < 60 ∧ 60 < 9 * 7 ∧
    -- 85 = rank(E8) + b3, 99 = H* (legacy θ₂₃ = 85/99 reading)
    rank_E8 + b3 = 85 ∧ H_star = 99 := by
  refine ⟨rfl, ?_, ?_, ?_, ?_⟩
  all_goals native_decide

end GIFT.Relations.IrrationalSector
