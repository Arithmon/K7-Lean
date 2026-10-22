import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import GIFT.Core

/-!
# Quark Mass Ratios - Extended Observables

Quark mass ratios with GIFT derivations:
- m_s/m_d = 20 (14 expressions)
- m_c/m_s = 246/21 (5 expressions)
- m_b/m_t = 1/42 (21 expressions) - THE MAGIC 42!
- m_u/m_d = 79/168 (4 expressions)
-/

namespace GIFT.Observables.QuarkMasses

open GIFT.Core

/-- m_s/m_d = 20. Experimental: 20.0. GIFT: 20. Deviation: 0.00% -/
def m_s_over_m_d : ℚ := 20

theorem m_s_over_m_d_value : m_s_over_m_d = 20 := rfl

/-- Primary: (alpha_sum + dim_J3O) / p2 = 40/2 = 20 -/
theorem m_s_over_m_d_primary :
    ((alpha_sum : ℚ) + dim_J3O) / p2 = m_s_over_m_d := by
  unfold m_s_over_m_d
  norm_num [alpha_sum_certified, dim_J3O_certified, p2_certified]

/-- m_c/m_s = 246/21. Experimental: 11.7. GIFT: 11.714. Deviation: 0.12% -/
def m_c_over_m_s : ℚ := 246 / 21

theorem m_c_over_m_s_value : m_c_over_m_s = 246 / 21 := rfl

/-- Primary: (dim_E8 - p2) / b2 = 246/21 -/
theorem m_c_over_m_s_primary :
    ((dim_E8 : ℚ) - p2) / b2 = m_c_over_m_s := by
  unfold m_c_over_m_s
  norm_num [dim_E8_certified, p2_certified, b2_value]

/-- m_b/m_t = 1/42 = 1/(2b₂). Experimental: 0.024. GIFT: 0.0238. Deviation: 0.79% -/
def m_b_over_m_t : ℚ := 1 / 42

theorem m_b_over_m_t_value : m_b_over_m_t = 1 / 42 := rfl

/-- Primary: b0 / two_b2 = 1/42 -/
theorem m_b_over_m_t_primary :
    (b0 : ℚ) / two_b2 = m_b_over_m_t := by
  unfold m_b_over_m_t
  norm_num [b0_certified, two_b2_certified]

/-- Expression 2: (b0 + N_gen) / PSL27 = 4/168 = 1/42 -/
theorem m_b_over_m_t_expr2 :
    ((b0 : ℚ) + N_gen) / PSL27 = m_b_over_m_t := by
  unfold m_b_over_m_t
  norm_num [b0_certified, N_gen_certified, PSL27_certified]

/-- m_u/m_d = 79/168. Experimental: 0.47. GIFT: 0.470. Deviation: 0.05% -/
def m_u_over_m_d : ℚ := 79 / 168

theorem m_u_over_m_d_value : m_u_over_m_d = 79 / 168 := rfl

/-- Primary: (b0 + dim_E6) / PSL27 = 79/168 -/
theorem m_u_over_m_d_primary :
    ((b0 : ℚ) + dim_E6) / PSL27 = m_u_over_m_d := by
  unfold m_u_over_m_d
  norm_num [b0_certified, dim_E6_certified, PSL27_certified]

/-- The 42 connection: two_b2 = 2b₂ = 42 (not an Euler characteristic; χ(K₇) = 0) -/
theorem two_b2_is_42 : two_b2 = 42 := two_b2_certified
@[deprecated two_b2_is_42 (since := "2026-10-22")]
alias chi_K7_is_42 := two_b2_is_42

end GIFT.Observables.QuarkMasses
