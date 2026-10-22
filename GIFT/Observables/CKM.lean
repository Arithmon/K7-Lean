import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import GIFT.Core

/-!
# CKM Matrix Parameters - Extended Observables

CKM (Cabibbo-Kobayashi-Maskawa) quark mixing matrix parameters:
- sin(theta_12)_CKM = 56/248 = 7/31 (16 expressions)
- lambda_Wolfenstein = 56/248 (16 expressions)
- A_Wolfenstein = 83/99 (7 expressions)
- sin(theta_23)_CKM = 7/168 (4 expressions)

The CKM entries are compared as sin θ₁₂ = λ and sin θ₂₃ = Aλ² (sines, not
squared sines). The declarations were renamed on 2026-10-22 from
`sin2_theta12_CKM` / `sin2_theta23_CKM` (which suggested sin²) to
`sin_theta12_CKM` / `sin_theta23_CKM`; the old names remain as deprecated aliases
at the end of this file.
-/

namespace GIFT.Observables.CKM

open GIFT.Core

-- =============================================================================
-- sin(theta_12)_CKM = 56/248 = 7/31 - Cabibbo angle
-- =============================================================================

/-- sin(theta_12)_CKM = 56/248 = 7/31 = fund_E7 / dim_E8
    Experimental: 0.2250 (error 0.0006)
    GIFT: 56/248 = 0.2258
    Deviation: 0.36% -/
def sin_theta12_CKM : ℚ := 56 / 248

theorem sin_theta12_CKM_value : sin_theta12_CKM = 56 / 248 := rfl

/-- Reduced form: 56/248 = 7/31 -/
theorem sin_theta12_CKM_reduced : sin_theta12_CKM = 7 / 31 := by
  unfold sin_theta12_CKM
  norm_num

/-- Primary: fund_E7 / dim_E8 = 56/248 -/
theorem sin_theta12_CKM_primary :
    (dim_fund_E7 : ℚ) / dim_E8 = sin_theta12_CKM := by
  unfold sin_theta12_CKM
  norm_num [dim_fund_E7_certified, dim_E8_certified]

/-- Expression 2: (b3 - b2) / dim_E8 = 56/248 -/
theorem sin_theta12_CKM_expr2 :
    ((b3 : ℚ) - b2) / dim_E8 = sin_theta12_CKM := by
  unfold sin_theta12_CKM
  norm_num [b3_value, b2_value, dim_E8_certified]

/-- Expression 3: (2 * b2 + dim_G2) / dim_E8 = 56/248 -/
theorem sin_theta12_CKM_expr3 :
    ((2 : ℚ) * b2 + dim_G2) / dim_E8 = sin_theta12_CKM := by
  unfold sin_theta12_CKM
  norm_num [b2_value, Algebraic.G2.dim_G2_eq, dim_E8_certified]

/-- Expression 4: dim_K7 / (alpha_sum + b2 - N_gen) = 7/31 -/
theorem sin_theta12_CKM_expr4 :
    (dim_K7 : ℚ) / (alpha_sum + b2 - N_gen) = sin_theta12_CKM := by
  unfold sin_theta12_CKM
  norm_num [dim_K7_certified, alpha_sum_certified, b2_value, N_gen_certified]

-- =============================================================================
-- lambda_Wolfenstein = 56/248 - Wolfenstein parameter
-- =============================================================================

/-- lambda_Wolfenstein = sin(theta_Cabibbo) approx 56/248
    Experimental: 0.22453 (error 0.00044)
    GIFT: 56/248 = 0.2258
    Deviation: 0.57% -/
def lambda_Wolf : ℚ := 56 / 248

theorem lambda_Wolf_value : lambda_Wolf = 56 / 248 := rfl

theorem lambda_Wolf_equals_sin_theta12 :
    lambda_Wolf = sin_theta12_CKM := rfl

-- =============================================================================
-- A_Wolfenstein = 83/99 - Wolfenstein A parameter
-- =============================================================================

/-- A_Wolfenstein = 83/99 = (Weyl + dim_E6) / H_star
    Experimental: 0.836 (error 0.015)
    GIFT: 83/99 = 0.838
    Deviation: 0.29% -/
def A_Wolf : ℚ := 83 / 99

theorem A_Wolf_value : A_Wolf = 83 / 99 := rfl

/-- Primary: (Weyl + dim_E6) / H_star = 83/99 -/
theorem A_Wolf_primary :
    ((Weyl_factor : ℚ) + dim_E6) / H_star = A_Wolf := by
  unfold A_Wolf
  norm_num [Weyl_factor_certified, dim_E6_certified, H_star_value]

/-- Expression 2: (dim_E6 + rank_E8 - N_gen) / H_star = 83/99 -/
theorem A_Wolf_expr2 :
    ((dim_E6 : ℚ) + rank_E8 - N_gen) / H_star = A_Wolf := by
  unfold A_Wolf
  norm_num [dim_E6_certified, rank_E8_certified, N_gen_certified, H_star_value]

/-- Expression 3: (b3 + p2 * N_gen) / H_star = 83/99 -/
theorem A_Wolf_expr3 :
    ((b3 : ℚ) + p2 * N_gen) / H_star = A_Wolf := by
  unfold A_Wolf
  norm_num [b3_value, p2_certified, N_gen_certified, H_star_value]

-- =============================================================================
-- sin(theta_23)_CKM = 7/168 - CKM 23 mixing
-- =============================================================================

/-- sin(theta_23)_CKM = 7/168 = dim_K7 / PSL27
    Experimental: 0.0412 (error 0.0008)
    GIFT: 7/168 = 0.0417
    Deviation: 1.13% (worst in catalog) -/
def sin_theta23_CKM : ℚ := 7 / 168

theorem sin_theta23_CKM_value : sin_theta23_CKM = 7 / 168 := rfl

/-- Reduced: 7/168 = 1/24 -/
theorem sin_theta23_CKM_reduced : sin_theta23_CKM = 1 / 24 := by
  unfold sin_theta23_CKM
  norm_num

/-- Primary: dim_K7 / PSL27 = 7/168 -/
theorem sin_theta23_CKM_primary :
    (dim_K7 : ℚ) / PSL27 = sin_theta23_CKM := by
  unfold sin_theta23_CKM
  norm_num [dim_K7_certified, PSL27_certified]

/-- Expression 2: dim_K7 / (rank_E8 * b2) = 7/168 -/
theorem sin_theta23_CKM_expr2 :
    (dim_K7 : ℚ) / (rank_E8 * b2) = sin_theta23_CKM := by
  unfold sin_theta23_CKM
  norm_num [dim_K7_certified, rank_E8_certified, b2_value]

/-- Expression 3: imaginary_count / PSL27 = 7/168 -/
theorem sin_theta23_CKM_expr3 :
    (Algebraic.Octonions.imaginary_count : ℚ) / PSL27 = sin_theta23_CKM := by
  unfold sin_theta23_CKM
  norm_num [Algebraic.Octonions.imaginary_count_eq, PSL27_certified]

-- =============================================================================
-- STRUCTURAL THEOREMS
-- =============================================================================

/-- CKM and PMNS share structural elements -/
theorem ckm_pmns_structural_connection :
    sin_theta12_CKM = (dim_fund_E7 : ℚ) / dim_E8 ∧
    sin_theta23_CKM = (dim_K7 : ℚ) / PSL27 := by
  constructor
  · exact sin_theta12_CKM_primary
  · exact sin_theta23_CKM_primary

/-- The E7 fundamental appears in CKM -/
theorem E7_in_ckm :
    dim_fund_E7 = 56 ∧
    sin_theta12_CKM = (56 : ℚ) / 248 := by
  constructor
  · exact dim_fund_E7_certified
  · rfl

-- =============================================================================
-- DEPRECATED ALIASES (renamed 2026-10-22: these quantities are sines, not sin²)
-- =============================================================================

@[deprecated sin_theta12_CKM (since := "2026-10-22")]
abbrev sin2_theta12_CKM : ℚ := sin_theta12_CKM
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_value := sin_theta12_CKM_value
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_reduced := sin_theta12_CKM_reduced
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_primary := sin_theta12_CKM_primary
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_expr2 := sin_theta12_CKM_expr2
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_expr3 := sin_theta12_CKM_expr3
@[deprecated (since := "2026-10-22")] alias sin2_theta12_CKM_expr4 := sin_theta12_CKM_expr4
@[deprecated (since := "2026-10-22")]
alias lambda_Wolf_equals_sin2_theta12 := lambda_Wolf_equals_sin_theta12

@[deprecated sin_theta23_CKM (since := "2026-10-22")]
abbrev sin2_theta23_CKM : ℚ := sin_theta23_CKM
@[deprecated (since := "2026-10-22")] alias sin2_theta23_CKM_value := sin_theta23_CKM_value
@[deprecated (since := "2026-10-22")] alias sin2_theta23_CKM_reduced := sin_theta23_CKM_reduced
@[deprecated (since := "2026-10-22")] alias sin2_theta23_CKM_primary := sin_theta23_CKM_primary
@[deprecated (since := "2026-10-22")] alias sin2_theta23_CKM_expr2 := sin_theta23_CKM_expr2
@[deprecated (since := "2026-10-22")] alias sin2_theta23_CKM_expr3 := sin_theta23_CKM_expr3

end GIFT.Observables.CKM
