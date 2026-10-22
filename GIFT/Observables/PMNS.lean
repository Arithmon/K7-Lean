import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import GIFT.Core

/-!
# PMNS Neutrino Mixing Matrix - Extended Observables

PMNS matrix mixing angles with GIFT derivations:
- sin^2(theta_12) = 4/13 (28 expressions)
- sin^2(theta_23) = 6/11 (15 expressions)
- sin^2(theta_13) = 11/496 (5 expressions)
-/

namespace GIFT.Observables.PMNS

open GIFT.Core

/-- sin^2(theta_12) PMNS = 4/13. Experimental: 0.307. GIFT: 0.3077. Deviation: 0.23% -/
def sin2_theta12 : ℚ := 4 / 13

theorem sin2_theta12_value : sin2_theta12 = 4 / 13 := rfl

/-- Primary: (b0 + N_gen) / alpha_sum = 4/13 -/
theorem sin2_theta12_primary :
    ((b0 : ℚ) + N_gen) / alpha_sum = sin2_theta12 := by
  unfold sin2_theta12
  norm_num [b0_certified, N_gen_certified, alpha_sum_certified]

/-- sin^2(theta_23) PMNS = 6/11. Experimental: 0.546. GIFT: 0.5455. Deviation: 0.10% -/
def sin2_theta23 : ℚ := 6 / 11

theorem sin2_theta23_value : sin2_theta23 = 6 / 11 := rfl

/-- Primary: (D_bulk - Weyl) / D_bulk = 6/11 -/
theorem sin2_theta23_primary :
    ((D_bulk : ℚ) - Weyl_factor) / D_bulk = sin2_theta23 := by
  unfold sin2_theta23
  norm_num [D_bulk_certified, Weyl_factor_certified]

/-- Expression 2: two_b2 / b3 = 42/77 = 6/11 -/
theorem sin2_theta23_expr2 :
    (two_b2 : ℚ) / b3 = sin2_theta23 := by
  unfold sin2_theta23
  norm_num [two_b2_certified, b3_value]

/-- sin^2(theta_13) PMNS = 11/496. Experimental: 0.0220. GIFT: 0.0222. Deviation: 0.81% -/
def sin2_theta13 : ℚ := 11 / 496

theorem sin2_theta13_value : sin2_theta13 = 11 / 496 := rfl

/-- Primary: D_bulk / dim_E8xE8 = 11/496 -/
theorem sin2_theta13_primary :
    (D_bulk : ℚ) / dim_E8xE8 = sin2_theta13 := by
  unfold sin2_theta13
  norm_num [D_bulk_certified, dim_E8xE8_certified]

/-- Sum of PMNS sin^2 angles is less than 1 -/
theorem pmns_sum_check :
    sin2_theta12 + sin2_theta23 + sin2_theta13 < 1 := by
  unfold sin2_theta12 sin2_theta23 sin2_theta13
  norm_num

end GIFT.Observables.PMNS
