import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import GIFT.Core

/-!
# Cosmological Parameters - Extended Observables

Cosmological parameters with GIFT derivations:
- Omega_DM/Omega_b = 43/8 (the 42 appears here!)
- Omega_c/Omega_Lambda = 65/168
- Omega_Lambda/Omega_m = 113/52
- h = 167/248
- Omega_b/Omega_m = 5/32
- sigma_8 = 17/21
- Y_p = 15/61
-/

namespace GIFT.Observables.Cosmology

open GIFT.Core

/-- Omega_DM/Omega_b = 43/8. Planck: 5.375. GIFT: 5.375. Deviation: 0.00% -/
def Omega_DM_over_Omega_b : ℚ := 43 / 8

theorem Omega_DM_over_Omega_b_value : Omega_DM_over_Omega_b = 43 / 8 := rfl

/-- Primary: (b0 + two_b2) / rank_E8 = 43/8. The 42 appears in the universe! -/
theorem Omega_DM_b_primary :
    ((b0 : ℚ) + two_b2) / rank_E8 = Omega_DM_over_Omega_b := by
  unfold Omega_DM_over_Omega_b
  norm_num [b0_certified, two_b2_certified, rank_E8_certified]

/-- Omega_c/Omega_Lambda = 65/168. Planck: 0.387. GIFT: 0.3869. Deviation: 0.01% -/
def Omega_c_over_Omega_Lambda : ℚ := 65 / 168

theorem Omega_c_over_Omega_Lambda_value : Omega_c_over_Omega_Lambda = 65 / 168 := rfl

/-- Primary: det_g_num / PSL27 = 65/168 -/
theorem Omega_c_Lambda_primary :
    (det_g_num : ℚ) / PSL27 = Omega_c_over_Omega_Lambda := by
  unfold Omega_c_over_Omega_Lambda
  norm_num [det_g_num_certified, PSL27_certified]

/-- Omega_Lambda/Omega_m = 113/52. Planck: 2.175. GIFT: 2.173. Deviation: 0.07% -/
def Omega_Lambda_over_Omega_m : ℚ := 113 / 52

theorem Omega_Lambda_over_Omega_m_value : Omega_Lambda_over_Omega_m = 113 / 52 := rfl

/-- Primary: (dim_G2 + H_star) / dim_F4 = 113/52 -/
theorem Omega_Lambda_m_primary :
    ((dim_G2 : ℚ) + H_star) / dim_F4 = Omega_Lambda_over_Omega_m := by
  unfold Omega_Lambda_over_Omega_m
  norm_num [Algebraic.G2.dim_G2_eq, H_star_value, dim_F4_certified]

/-- h = 167/248 = (PSL27 - b0) / dim_E8. Planck: 0.674. GIFT: 0.6734. Deviation: 0.09% -/
def hubble_h : ℚ := 167 / 248

theorem hubble_h_value : hubble_h = 167 / 248 := rfl

/-- Primary: (PSL27 - b0) / dim_E8 = 167/248 -/
theorem hubble_h_primary :
    ((PSL27 : ℚ) - b0) / dim_E8 = hubble_h := by
  unfold hubble_h
  norm_num [PSL27_certified, b0_certified, dim_E8_certified]

/-- Omega_b/Omega_m = 5/32 = Weyl/det_g_den. Planck: 0.156. GIFT: 0.1562. Deviation: 0.16% -/
def Omega_b_over_Omega_m : ℚ := 5 / 32

theorem Omega_b_over_Omega_m_value : Omega_b_over_Omega_m = 5 / 32 := rfl

/-- Primary: Weyl / det_g_den = 5/32 -/
theorem Omega_b_m_primary :
    (Weyl_factor : ℚ) / det_g_den = Omega_b_over_Omega_m := by
  unfold Omega_b_over_Omega_m
  norm_num [Weyl_factor_certified, det_g_den_certified]

/-- sigma_8 = 17/21. Planck: 0.811. GIFT: 0.8095. Deviation: 0.18% -/
def sigma_8 : ℚ := 17 / 21

theorem sigma_8_value : sigma_8 = 17 / 21 := rfl

/-- Primary: (p2 + det_g_den) / two_b2 = 34/42 = 17/21 -/
theorem sigma_8_primary :
    ((p2 : ℚ) + det_g_den) / two_b2 = sigma_8 := by
  unfold sigma_8
  norm_num [p2_certified, det_g_den_certified, two_b2_certified]

/-- Y_p = 15/61. Experimental: 0.245. GIFT: 0.2459. Deviation: 0.37% -/
def Y_p : ℚ := 15 / 61

theorem Y_p_value : Y_p = 15 / 61 := rfl

/-- Primary: (b0 + dim_G2) / kappa_T_den = 15/61 -/
theorem Y_p_primary :
    ((b0 : ℚ) + dim_G2) / kappa_T_den = Y_p := by
  unfold Y_p
  norm_num [b0_certified, Algebraic.G2.dim_G2_eq, kappa_T_den_certified]

end GIFT.Observables.Cosmology
