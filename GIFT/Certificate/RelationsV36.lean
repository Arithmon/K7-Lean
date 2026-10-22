import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.NumberTheory.LSeries.RiemannZeta
import GIFT.Core
import GIFT.Observables
import GIFT.Relations.OverDetermination
import GIFT.Foundations.GoldenRatio
import GIFT.Foundations.GoldenRatioPowers

/-!
# Certificate: the 33 relations of the K₇ paper, v3.6 (A01–A33)

`relations_v36_certified` is a conjunction of 33 statements, in the order A01 … A33.
Each statement ties the paper's closed form, written in the framework's structural
constants (`b2`, `b3`, `dim_G2`, `dim_E8`, `rank_E8`, `H_star`, `D_bulk`,
`Weyl_factor`, `PSL27`, `dim_E6`, `dim_F4`, `dim_fund_E7`, `dim_J3O`, `N_gen`, `p2`,
`det_g_num`/`det_g_den`, `kappa_T_den` = κ_T⁻¹ = 61, …), to its value. No conjunct
is a definitional literal of the form `X = v` with `X := v`.

Form of each statement:
* rational relations: exact equality in ℚ (closed form = stated fraction, unreduced);
* A02, A03, A23: equality in ℝ of the closed form with the value, integers evaluated
  (√2/12, √17/32, log 2 · 98/99);
* A24 (n_s = ζ(11)/ζ(5)): the indices (D_bulk, Weyl) = (11, 5) and the equality
  ζ(D_bulk)/ζ(Weyl) = ζ(11)/ζ(5) in ℂ (Mathlib's `riemannZeta`); no numerical bound;
* A07 (m_μ/m_e = 27^φ): dim(J₃(𝕆)) = 27 and the bounds 206 < 27^φ < 209 only;
* A15 (δ_CP): the integer dim(K₇)·dim(G₂) + H* = 197 only; the unit (degrees) is a
  dictionary assignment of the paper and is not stated in Lean;
* A06, A08: integer identities in ℕ.

**Scope.** These are arithmetic identities. They do not establish a physical
identification of any quantity, the choice of a formula among the many with the same
value, or the mutual consistency of the relations: several of the relations are
mutually incompatible as exact equalities (in the lepton, CKM and cosmological
sectors), which nothing here addresses.

The CKM relations A16 and A18 are read as sin θ₁₂ = λ and sin θ₂₃ = Aλ² (sines, not
squared sines). In A10, A21, A25 and A31, `2 * b2` is the structural constant 2b₂ = 42,
which is not the Euler characteristic of K₇ (χ(K₇) = 0).
-/

namespace GIFT.Certificate.RelationsV36

open GIFT.Core

/-! ## The 33 relations, one theorem each -/

/-- A01 sin²θ_W = b₂/(b₃ + dim G₂) = 3/13 -/
theorem A01_sin2_theta_W : (b2 : ℚ) / (b3 + dim_G2) = 3 / 13 :=
  GIFT.Observables.WeakMixingAngle.sin2_theta_W_primary.trans
    GIFT.Observables.WeakMixingAngle.sin2_theta_W_value

/-- A02 α_s(M_Z) = √2/(dim G₂ − p₂) = √2/12 -/
theorem A02_alpha_s : Real.sqrt 2 / ((dim_G2 : ℝ) - p2) = Real.sqrt 2 / 12 := by
  rw [Algebraic.G2.dim_G2_eq, p2_certified]; norm_num

/-- A03 λ_H = √(dim G₂ + N_gen)/det_den = √17/32 -/
theorem A03_lambda_H :
    Real.sqrt ((dim_G2 : ℝ) + N_gen) / det_g_den = Real.sqrt 17 / 32 := by
  rw [Algebraic.G2.dim_G2_eq, N_gen_certified, det_g_den_certified]; norm_num

/-- A04 α⁻¹(0) = (dim E₈ + rank E₈)/2 + H*/D_bulk + det_num/(det_den · κ_T⁻¹)
    = 128 + 9 + 65/(32 × 61) = 267489/1952 -/
theorem A04_alpha_inv :
    ((dim_E8 : ℚ) + rank_E8) / 2 + (H_star : ℚ) / D_bulk +
      (det_g_num : ℚ) / (det_g_den * kappa_T_den) = 267489 / 1952 := by
  rw [dim_E8_certified, rank_E8_certified, H_star_value, D_bulk_certified,
    det_g_num_certified, det_g_den_certified, kappa_T_den_certified]
  norm_num

/-- A05 Q_Koide = dim G₂/b₂ = 2/3 -/
theorem A05_Q_Koide : (dim_G2 : ℚ) / b2 = 2 / 3 :=
  GIFT.Relations.OverDetermination.Q_koide_G2_b2

/-- A06 m_τ/m_e = dim K₇ + 10 · dim E₈ + 10 · H* = 3477 -/
theorem A06_m_tau_m_e : dim_K7 + 10 * dim_E8 + 10 * H_star = 3477 := by
  rw [dim_K7_certified, dim_E8_certified, H_star_value]

/-- A07 m_μ/m_e = 27^φ with 27 = dim J₃(𝕆): the base and the bounds 206 < 27^φ < 209 -/
theorem A07_m_mu_m_e :
    dim_J3O = 27 ∧
    (206 : ℝ) < (dim_J3O : ℝ) ^ GIFT.Foundations.GoldenRatio.phi ∧
    (dim_J3O : ℝ) ^ GIFT.Foundations.GoldenRatio.phi < 209 := by
  have h : ((dim_J3O : ℕ) : ℝ) = 27 := by rw [dim_J3O_certified]; norm_num
  refine ⟨dim_J3O_certified, ?_, ?_⟩ <;> rw [h]
  · exact GIFT.Foundations.GoldenRatioPowers.jordan_power_phi_bounds.1
  · exact GIFT.Foundations.GoldenRatioPowers.jordan_power_phi_bounds.2

/-- A08 m_s/m_d = p₂² × Weyl = 20 -/
theorem A08_m_s_m_d : p2 * p2 * Weyl_factor = 20 := by
  rw [p2_certified, Weyl_factor_certified]

/-- A09 m_c/m_s = (dim E₈ − p₂)/b₂ = 246/21 -/
theorem A09_m_c_m_s : ((dim_E8 : ℚ) - p2) / b2 = 246 / 21 :=
  GIFT.Observables.QuarkMasses.m_c_over_m_s_primary.trans
    GIFT.Observables.QuarkMasses.m_c_over_m_s_value

/-- A10 m_b/m_t = 1/(2b₂) = 1/42 -/
theorem A10_m_b_m_t : (1 : ℚ) / (2 * b2) = 1 / 42 :=
  GIFT.Relations.OverDetermination.mb_mt_2b2

/-- A11 m_u/m_d = (1 + dim E₆)/PSL(2,7) = 79/168 -/
theorem A11_m_u_m_d : ((b0 : ℚ) + dim_E6) / PSL27 = 79 / 168 :=
  GIFT.Observables.QuarkMasses.m_u_over_m_d_primary.trans
    GIFT.Observables.QuarkMasses.m_u_over_m_d_value

/-- A12 sin²θ₁₂ (PMNS) = (1 + N_gen)/α_sum = 4/13 -/
theorem A12_sin2_theta12_PMNS : ((b0 : ℚ) + N_gen) / alpha_sum = 4 / 13 :=
  GIFT.Observables.PMNS.sin2_theta12_primary.trans GIFT.Observables.PMNS.sin2_theta12_value

/-- A13 sin²θ₂₃ (PMNS) = (D_bulk − Weyl)/D_bulk = 6/11 -/
theorem A13_sin2_theta23_PMNS : ((D_bulk : ℚ) - Weyl_factor) / D_bulk = 6 / 11 :=
  GIFT.Observables.PMNS.sin2_theta23_primary.trans GIFT.Observables.PMNS.sin2_theta23_value

/-- A14 sin²θ₁₃ (PMNS) = D_bulk/dim(E₈ × E₈) = 11/496 -/
theorem A14_sin2_theta13_PMNS : (D_bulk : ℚ) / dim_E8xE8 = 11 / 496 :=
  GIFT.Observables.PMNS.sin2_theta13_primary.trans GIFT.Observables.PMNS.sin2_theta13_value

/-- A15 δ_CP: the integer dim K₇ × dim G₂ + H* = 197 (the unit is a dictionary
    assignment of the paper, not stated here) -/
theorem A15_delta_CP : dim_K7 * dim_G2 + H_star = 197 := by
  rw [dim_K7_certified, Algebraic.G2.dim_G2_eq, H_star_value]

/-- A16 sin θ₁₂ (CKM) = fund(E₇)/dim E₈ = 56/248 -/
theorem A16_sin_theta12_CKM : (dim_fund_E7 : ℚ) / dim_E8 = 56 / 248 :=
  GIFT.Observables.CKM.sin_theta12_CKM_primary.trans
    GIFT.Observables.CKM.sin_theta12_CKM_value

/-- A17 A (Wolfenstein) = (Weyl + dim E₆)/H* = 83/99 -/
theorem A17_A_Wolf : ((Weyl_factor : ℚ) + dim_E6) / H_star = 83 / 99 :=
  GIFT.Observables.CKM.A_Wolf_primary.trans GIFT.Observables.CKM.A_Wolf_value

/-- A18 sin θ₂₃ (CKM) = dim K₇/PSL(2,7) = 7/168 -/
theorem A18_sin_theta23_CKM : (dim_K7 : ℚ) / PSL27 = 7 / 168 :=
  GIFT.Observables.CKM.sin_theta23_CKM_primary.trans
    GIFT.Observables.CKM.sin_theta23_CKM_value

/-- A19 m_H/m_t = fund(E₇)/b₃ = 56/77 -/
theorem A19_m_H_m_t : (dim_fund_E7 : ℚ) / b3 = 56 / 77 :=
  GIFT.Observables.BosonMasses.m_H_over_m_t_expr2.trans
    (GIFT.Observables.BosonMasses.m_H_over_m_t_value.trans (by norm_num))

/-- A20 m_H/m_W = (N_gen + dim E₆)/dim F₄ = 81/52 -/
theorem A20_m_H_m_W : ((N_gen : ℚ) + dim_E6) / dim_F4 = 81 / 52 :=
  GIFT.Observables.BosonMasses.m_H_over_m_W_primary.trans
    GIFT.Observables.BosonMasses.m_H_over_m_W_value

/-- A21 m_W/m_Z = (2b₂ − Weyl)/(2b₂) = 37/42 -/
theorem A21_m_W_m_Z : ((2 * b2 : ℚ) - Weyl_factor) / (2 * b2) = 37 / 42 :=
  GIFT.Observables.BosonMasses.m_W_over_m_Z_primary.trans
    GIFT.Observables.BosonMasses.m_W_over_m_Z_value

/-- A22 m_μ/m_τ = (b₂ − D_bulk)/PSL(2,7) = 10/168 -/
theorem A22_m_mu_m_tau : ((b2 : ℚ) - D_bulk) / PSL27 = 10 / 168 := by
  rw [b2_value, D_bulk_certified, PSL27_certified]; norm_num

/-- A23 Ω_DE = log 2 × (b₂ + b₃)/H* = log 2 × 98/99 -/
theorem A23_Omega_DE :
    Real.log 2 * (((b2 : ℝ) + b3) / H_star) = Real.log 2 * (98 / 99) := by
  rw [b2_value, b3_value, H_star_value]; norm_num

/-- A24 n_s = ζ(D_bulk)/ζ(Weyl) = ζ(11)/ζ(5): the indices, and the equality of the
    quotients of Mathlib's `riemannZeta` (no numerical bound) -/
theorem A24_n_s :
    D_bulk = 11 ∧ Weyl_factor = 5 ∧
    riemannZeta (D_bulk : ℂ) / riemannZeta (Weyl_factor : ℂ) =
      riemannZeta 11 / riemannZeta 5 := by
  refine ⟨D_bulk_certified, Weyl_factor_certified, ?_⟩
  rw [D_bulk_certified, Weyl_factor_certified]; norm_num

/-- A25 Ω_DM/Ω_b = (1 + 2b₂)/rank E₈ = 43/8 -/
theorem A25_Omega_DM_b : ((b0 : ℚ) + 2 * b2) / rank_E8 = 43 / 8 := by
  rw [b0_certified, b2_value, rank_E8_certified]; norm_num

/-- A26 Ω_c/Ω_Λ = det_num/PSL(2,7) = 65/168 -/
theorem A26_Omega_c_Lambda : (det_g_num : ℚ) / PSL27 = 65 / 168 :=
  GIFT.Observables.Cosmology.Omega_c_Lambda_primary.trans
    GIFT.Observables.Cosmology.Omega_c_over_Omega_Lambda_value

/-- A27 Ω_Λ/Ω_m = (dim G₂ + H*)/dim F₄ = 113/52 -/
theorem A27_Omega_Lambda_m : ((dim_G2 : ℚ) + H_star) / dim_F4 = 113 / 52 :=
  GIFT.Observables.Cosmology.Omega_Lambda_m_primary.trans
    GIFT.Observables.Cosmology.Omega_Lambda_over_Omega_m_value

/-- A28 h = (PSL(2,7) − 1)/dim E₈ = 167/248 -/
theorem A28_hubble_h : ((PSL27 : ℚ) - b0) / dim_E8 = 167 / 248 :=
  GIFT.Observables.Cosmology.hubble_h_primary.trans GIFT.Observables.Cosmology.hubble_h_value

/-- A29 Ω_b/Ω_m = Weyl/det_den = 5/32 -/
theorem A29_Omega_b_m : (Weyl_factor : ℚ) / det_g_den = 5 / 32 :=
  GIFT.Observables.Cosmology.Omega_b_m_primary.trans
    GIFT.Observables.Cosmology.Omega_b_over_Omega_m_value

/-- A30 Ω_c/Ω_m = (det_den − Weyl)/det_den = 27/32 -/
theorem A30_Omega_c_m : ((det_g_den : ℚ) - Weyl_factor) / det_g_den = 27 / 32 := by
  rw [det_g_den_certified, Weyl_factor_certified]; norm_num

/-- A31 σ₈ = (p₂ + det_den)/(2b₂) = 34/42 -/
theorem A31_sigma_8 : ((p2 : ℚ) + det_g_den) / (2 * b2) = 34 / 42 := by
  rw [p2_certified, det_g_den_certified, b2_value]; norm_num

/-- A32 Y_p = (1 + dim G₂)/κ_T⁻¹ = 15/61 -/
theorem A32_Y_p : ((b0 : ℚ) + dim_G2) / kappa_T_den = 15 / 61 :=
  GIFT.Observables.Cosmology.Y_p_primary.trans GIFT.Observables.Cosmology.Y_p_value

/-- A33 Ω_m/Ω_Λ = (1 + dim J₃(𝕆))/κ_T⁻¹ = 28/61 -/
theorem A33_Omega_m_Lambda : ((b0 : ℚ) + dim_J3O) / kappa_T_den = 28 / 61 := by
  rw [b0_certified, dim_J3O_certified, kappa_T_den_certified]; norm_num

/-! ## The aggregate certificate -/

/-- The 33 relations of the K₇ paper v3.6, A01 … A33, each tying its closed form in
the structural constants to its value.

These are arithmetic identities. They do not establish physical identification,
formula choice, or the mutual consistency of the relations (several are mutually
incompatible as exact equalities in the lepton, CKM and cosmological sectors). -/
theorem relations_v36_certified :
    -- A01 sin²θ_W
    ((b2 : ℚ) / (b3 + dim_G2) = 3 / 13) ∧
    -- A02 α_s(M_Z)
    (Real.sqrt 2 / ((dim_G2 : ℝ) - p2) = Real.sqrt 2 / 12) ∧
    -- A03 λ_H
    (Real.sqrt ((dim_G2 : ℝ) + N_gen) / det_g_den = Real.sqrt 17 / 32) ∧
    -- A04 α⁻¹(0)
    (((dim_E8 : ℚ) + rank_E8) / 2 + (H_star : ℚ) / D_bulk +
      (det_g_num : ℚ) / (det_g_den * kappa_T_den) = 267489 / 1952) ∧
    -- A05 Q_Koide
    ((dim_G2 : ℚ) / b2 = 2 / 3) ∧
    -- A06 m_τ/m_e
    (dim_K7 + 10 * dim_E8 + 10 * H_star = 3477) ∧
    -- A07 m_μ/m_e (base and bounds only)
    (dim_J3O = 27 ∧
      (206 : ℝ) < (dim_J3O : ℝ) ^ GIFT.Foundations.GoldenRatio.phi ∧
      (dim_J3O : ℝ) ^ GIFT.Foundations.GoldenRatio.phi < 209) ∧
    -- A08 m_s/m_d
    (p2 * p2 * Weyl_factor = 20) ∧
    -- A09 m_c/m_s
    (((dim_E8 : ℚ) - p2) / b2 = 246 / 21) ∧
    -- A10 m_b/m_t
    ((1 : ℚ) / (2 * b2) = 1 / 42) ∧
    -- A11 m_u/m_d
    (((b0 : ℚ) + dim_E6) / PSL27 = 79 / 168) ∧
    -- A12 sin²θ₁₂ (PMNS)
    (((b0 : ℚ) + N_gen) / alpha_sum = 4 / 13) ∧
    -- A13 sin²θ₂₃ (PMNS)
    (((D_bulk : ℚ) - Weyl_factor) / D_bulk = 6 / 11) ∧
    -- A14 sin²θ₁₃ (PMNS)
    ((D_bulk : ℚ) / dim_E8xE8 = 11 / 496) ∧
    -- A15 δ_CP (integer only)
    (dim_K7 * dim_G2 + H_star = 197) ∧
    -- A16 sin θ₁₂ (CKM)
    ((dim_fund_E7 : ℚ) / dim_E8 = 56 / 248) ∧
    -- A17 A (Wolfenstein)
    (((Weyl_factor : ℚ) + dim_E6) / H_star = 83 / 99) ∧
    -- A18 sin θ₂₃ (CKM)
    ((dim_K7 : ℚ) / PSL27 = 7 / 168) ∧
    -- A19 m_H/m_t
    ((dim_fund_E7 : ℚ) / b3 = 56 / 77) ∧
    -- A20 m_H/m_W
    (((N_gen : ℚ) + dim_E6) / dim_F4 = 81 / 52) ∧
    -- A21 m_W/m_Z
    (((2 * b2 : ℚ) - Weyl_factor) / (2 * b2) = 37 / 42) ∧
    -- A22 m_μ/m_τ
    (((b2 : ℚ) - D_bulk) / PSL27 = 10 / 168) ∧
    -- A23 Ω_DE
    (Real.log 2 * (((b2 : ℝ) + b3) / H_star) = Real.log 2 * (98 / 99)) ∧
    -- A24 n_s (indices and ζ-quotient)
    (D_bulk = 11 ∧ Weyl_factor = 5 ∧
      riemannZeta (D_bulk : ℂ) / riemannZeta (Weyl_factor : ℂ) =
        riemannZeta 11 / riemannZeta 5) ∧
    -- A25 Ω_DM/Ω_b
    (((b0 : ℚ) + 2 * b2) / rank_E8 = 43 / 8) ∧
    -- A26 Ω_c/Ω_Λ
    ((det_g_num : ℚ) / PSL27 = 65 / 168) ∧
    -- A27 Ω_Λ/Ω_m
    (((dim_G2 : ℚ) + H_star) / dim_F4 = 113 / 52) ∧
    -- A28 h
    (((PSL27 : ℚ) - b0) / dim_E8 = 167 / 248) ∧
    -- A29 Ω_b/Ω_m
    ((Weyl_factor : ℚ) / det_g_den = 5 / 32) ∧
    -- A30 Ω_c/Ω_m
    (((det_g_den : ℚ) - Weyl_factor) / det_g_den = 27 / 32) ∧
    -- A31 σ₈
    (((p2 : ℚ) + det_g_den) / (2 * b2) = 34 / 42) ∧
    -- A32 Y_p
    (((b0 : ℚ) + dim_G2) / kappa_T_den = 15 / 61) ∧
    -- A33 Ω_m/Ω_Λ
    (((b0 : ℚ) + dim_J3O) / kappa_T_den = 28 / 61) :=
  ⟨A01_sin2_theta_W, A02_alpha_s, A03_lambda_H, A04_alpha_inv, A05_Q_Koide,
   A06_m_tau_m_e, A07_m_mu_m_e, A08_m_s_m_d, A09_m_c_m_s, A10_m_b_m_t,
   A11_m_u_m_d, A12_sin2_theta12_PMNS, A13_sin2_theta23_PMNS, A14_sin2_theta13_PMNS,
   A15_delta_CP, A16_sin_theta12_CKM, A17_A_Wolf, A18_sin_theta23_CKM, A19_m_H_m_t,
   A20_m_H_m_W, A21_m_W_m_Z, A22_m_mu_m_tau, A23_Omega_DE, A24_n_s,
   A25_Omega_DM_b, A26_Omega_c_Lambda, A27_Omega_Lambda_m, A28_hubble_h,
   A29_Omega_b_m, A30_Omega_c_m, A31_sigma_8, A32_Y_p, A33_Omega_m_Lambda⟩

/-- The proposition certified by `relations_v36_certified` (for aggregation in
`GIFT.Certificate.gift_master_certificate`). -/
def statement : Prop := type_of% relations_v36_certified

theorem certified : statement := relations_v36_certified

end GIFT.Certificate.RelationsV36
