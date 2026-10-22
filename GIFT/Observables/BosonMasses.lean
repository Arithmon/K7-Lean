import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import GIFT.Core

/-!
# Boson Mass Ratios - Extended Observables

Boson mass ratios with GIFT derivations:
- m_H/m_W = 81/52 (3 expressions)
- m_H/m_t = 8/11 (19 expressions)
- m_t/m_W = 139/65 (5 expressions)
-/

namespace GIFT.Observables.BosonMasses

open GIFT.Core

/-- m_H/m_W = 81/52. Experimental: 1.558. GIFT: 1.5577. Deviation: 0.02% -/
def m_H_over_m_W : ℚ := 81 / 52

theorem m_H_over_m_W_value : m_H_over_m_W = 81 / 52 := rfl

/-- Primary: (N_gen + dim_E6) / dim_F4 = 81/52 -/
theorem m_H_over_m_W_primary :
    ((N_gen : ℚ) + dim_E6) / dim_F4 = m_H_over_m_W := by
  unfold m_H_over_m_W
  norm_num [N_gen_certified, dim_E6_certified, dim_F4_certified]

/-- m_H/m_t = 8/11 = rank_E8/D_bulk. Experimental: 0.725. GIFT: 0.7273. Deviation: 0.31% -/
def m_H_over_m_t : ℚ := 8 / 11

theorem m_H_over_m_t_value : m_H_over_m_t = 8 / 11 := rfl

/-- Primary: rank_E8 / D_bulk = 8/11 -/
theorem m_H_over_m_t_primary :
    (rank_E8 : ℚ) / D_bulk = m_H_over_m_t := by
  unfold m_H_over_m_t
  norm_num [rank_E8_certified, D_bulk_certified]

/-- Expression 2: fund_E7 / b3 = 56/77 = 8/11 -/
theorem m_H_over_m_t_expr2 :
    (dim_fund_E7 : ℚ) / b3 = m_H_over_m_t := by
  unfold m_H_over_m_t
  norm_num [dim_fund_E7_certified, b3_value]

/-- m_t/m_W = 139/65. Experimental: 2.14. GIFT: 2.138. Deviation: 0.07% -/
def m_t_over_m_W : ℚ := 139 / 65

theorem m_t_over_m_W_value : m_t_over_m_W = 139 / 65 := rfl

/-- Primary: (kappa_T_den + dim_E6) / det_g_num = 139/65 -/
theorem m_t_over_m_W_primary :
    ((kappa_T_den : ℚ) + dim_E6) / det_g_num = m_t_over_m_W := by
  unfold m_t_over_m_W
  norm_num [kappa_T_den_certified, dim_E6_certified, det_g_num_certified]

-- =============================================================================
-- m_W/m_Z = 37/42 (NEW - from Selection Rules Analysis)
-- =============================================================================

/-!
## W/Z Mass Ratio

The W/Z mass ratio was previously poorly predicted (8.7% deviation).
The corrected formula uses the Fano selection principle:

  m_W/m_Z = (2b₂ - Weyl) / (2b₂) = (42 - 5) / 42 = 37/42

Physical interpretation: The ratio involves 2b₂ = 42 (a structural invariant)
minus the Weyl factor, divided by the structural invariant.

Note: 2b₂ = two_b2 = 42 (the "42" appearing in multiple contexts).
-/

/-- m_W/m_Z = 37/42. Experimental: 0.8815. GIFT: 0.8810. Deviation: 0.06% -/
def m_W_over_m_Z : ℚ := 37 / 42

theorem m_W_over_m_Z_value : m_W_over_m_Z = 37 / 42 := rfl

/-- Primary: (2b₂ - Weyl) / (2b₂) = 37/42 -/
theorem m_W_over_m_Z_primary :
    ((2 * b2 : ℚ) - Weyl_factor) / (2 * b2) = m_W_over_m_Z := by
  unfold m_W_over_m_Z
  norm_num [b2_value, Weyl_factor_certified]

/-- Expression 2: (two_b2 - Weyl) / two_b2 = 37/42 -/
theorem m_W_over_m_Z_expr2 :
    ((two_b2 : ℚ) - Weyl_factor) / two_b2 = m_W_over_m_Z := by
  unfold m_W_over_m_Z
  norm_num [two_b2_certified, Weyl_factor_certified]

/-- Expression 3: Using structural invariant 42 = 2 × 21 -/
theorem m_W_over_m_Z_expr3 :
    (42 - (Weyl_factor : ℚ)) / 42 = m_W_over_m_Z := by
  unfold m_W_over_m_Z
  norm_num [Weyl_factor_certified]

/-- Structural identity: 2b₂ = two_b2 (the constant formerly named `chi_K7`; not χ(K₇), which is 0) -/
theorem two_b2_eq_chi : 2 * b2 = two_b2 := by native_decide

/-- The 37 in numerator: two_b2 - Weyl = 42 - 5 = 37 -/
theorem m_W_over_m_Z_numerator : two_b2 - Weyl_factor = 37 := by native_decide

end GIFT.Observables.BosonMasses
