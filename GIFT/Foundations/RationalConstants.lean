-- GIFT Foundations: Rational Constants
-- Proper rational arithmetic using ℚ instead of Nat hacks
--
-- This module upgrades GIFT relations from integer cross-multiplication
-- to genuine rational number statements.
--
-- Old (hack): b2 * 13 = 3 * (b3 + dim_G2)
-- New (real): sin²θ_W = 21/91 = 3/13 as actual ℚ values

import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Batteries.Tactic.Alias

namespace GIFT.Foundations.RationalConstants

/-!
## Topological Constants as Rationals

These match the canonical ℕ sources in Algebraic.BettiNumbers and Algebraic.G2.
Defined as literals here for norm_num compatibility in ℚ proofs.
-/

/-- Second Betti number of K7 (= Algebraic.BettiNumbers.b2) -/
def b2 : ℚ := 21

/-- Third Betti number of K7 (= Algebraic.BettiNumbers.b3) -/
def b3 : ℚ := 77

/-- Effective degrees of freedom H* = b2 + b3 + 1 -/
def H_star : ℚ := b2 + b3 + 1

theorem H_star_value : H_star = 99 := by unfold H_star b2 b3; norm_num

/-- Dimension of G2 (= Algebraic.G2.dim_G2) -/
def dim_G2 : ℚ := 14

/-- Dimension of E8 (= Algebraic.G2.dim_E8) -/
def dim_E8 : ℚ := 248

/-- Rank of E8 -/
def rank_E8 : ℚ := 8

/-- p2 = binary ratio dim(G2)/dim(K7) (not a Pontryagin class) -/
def p2 : ℚ := 2

/-- Weyl factor -/
def Weyl_factor : ℚ := 5

/-- Dimension of K7 -/
def dim_K7 : ℚ := 7

/-- Dimension of J3(O) -/
def dim_J3O : ℚ := 27

/-!
## Weinberg Angle: sin²θ_W = 21/91 = 3/13

This is a REAL rational equality, not just cross-multiplication!
-/

/-- Weinberg angle: sin²θ_W = b2/(b3 + dim_G2) -/
def sin2_theta_W : ℚ := b2 / (b3 + dim_G2)

/-- The Weinberg angle equals 21/91 -/
theorem sin2_theta_W_value : sin2_theta_W = 21 / 91 := by
  unfold sin2_theta_W b2 b3 dim_G2
  norm_num

/-- 21/91 simplifies to 3/13 -/
theorem sin2_theta_W_simplified : sin2_theta_W = 3 / 13 := by
  unfold sin2_theta_W b2 b3 dim_G2
  norm_num

/-- Direct proof that 21/91 = 3/13 -/
theorem weinberg_simplification : (21 : ℚ) / 91 = 3 / 13 := by norm_num

/-!
## Koide Parameter: Q = dim_G2/b2 = 14/21 = 2/3

The Koide formula relates lepton masses.
-/

/-- Koide parameter Q = dim_G2/b2 -/
def koide_Q : ℚ := dim_G2 / b2

theorem koide_value : koide_Q = 14 / 21 := by
  unfold koide_Q dim_G2 b2
  norm_num

theorem koide_simplified : koide_Q = 2 / 3 := by
  unfold koide_Q dim_G2 b2
  norm_num

/-!
## Gamma GIFT: γ = 511/884

The master coupling constant.
-/

/-- γ_GIFT numerator: 2·rank(E8) + 5·H* = 2·8 + 5·99 = 511 -/
def gamma_num : ℚ := 2 * rank_E8 + 5 * H_star

/-- γ_GIFT denominator: 10·dim(G2) + 3·dim(E8) = 10·14 + 3·248 = 884 -/
def gamma_den : ℚ := 10 * dim_G2 + 3 * dim_E8

theorem gamma_num_value : gamma_num = 511 := by
  unfold gamma_num rank_E8 H_star b2 b3
  norm_num

theorem gamma_den_value : gamma_den = 884 := by
  unfold gamma_den dim_G2 dim_E8
  norm_num

/-- γ_GIFT = 511/884 -/
def gamma_GIFT : ℚ := gamma_num / gamma_den

theorem gamma_GIFT_value : gamma_GIFT = 511 / 884 := by
  unfold gamma_GIFT
  rw [gamma_num_value, gamma_den_value]

/-!
## Strong Coupling: rational factor 1/(dim_G2 - p2) = 1/12

The relation of the paper is α_s = √2/(dim(G₂) − p₂) = √2/12. The declaration below
is only its RATIONAL FACTOR 1/12 (it was named `alpha_s` before 2026-10-22, which
named one component as if it were the observable).
-/

/-- Strong coupling denominator -/
def alpha_s_den : ℚ := dim_G2 - p2

theorem alpha_s_den_value : alpha_s_den = 12 := by
  unfold alpha_s_den dim_G2 p2
  norm_num

/-- Rational factor of α_s = √2 × (1/12): the value 1/12 (NOT α_s itself). -/
def alpha_s_rational_factor : ℚ := 1 / alpha_s_den

theorem alpha_s_rational_factor_value : alpha_s_rational_factor = 1 / 12 := by
  unfold alpha_s_rational_factor
  rw [alpha_s_den_value]

/-- (1/12)² = 1/144 (so α_s² = 2/144). -/
theorem alpha_s_rational_factor_squared :
    alpha_s_rational_factor * alpha_s_rational_factor = 1 / 144 := by
  rw [alpha_s_rational_factor_value]
  norm_num

@[deprecated alpha_s_rational_factor (since := "2026-10-22")]
abbrev alpha_s : ℚ := alpha_s_rational_factor
@[deprecated (since := "2026-10-22")] alias alpha_s_value := alpha_s_rational_factor_value
@[deprecated (since := "2026-10-22")] alias alpha_s_squared := alpha_s_rational_factor_squared

/-!
## Torsion Coefficient: κ_T = 1/(b3 - dim_G2 - p2) = 1/61
-/

/-- κ_T denominator: b3 - dim_G2 - p2 = 77 - 14 - 2 = 61 -/
def kappa_T_den : ℚ := b3 - dim_G2 - p2

theorem kappa_T_den_value : kappa_T_den = 61 := by
  unfold kappa_T_den b3 dim_G2 p2
  norm_num

/-- κ_T = 1/61 -/
def kappa_T : ℚ := 1 / kappa_T_den

theorem kappa_T_value : kappa_T = 1 / 61 := by
  unfold kappa_T
  rw [kappa_T_den_value]

/-!
## Tau Hierarchy: τ = (dim_E8×E8 · b2)/(dim_J3O · H*) = 10416/2673
-/

/-- E8×E8 dimension -/
def dim_E8xE8 : ℚ := 2 * dim_E8

theorem dim_E8xE8_value : dim_E8xE8 = 496 := by
  unfold dim_E8xE8 dim_E8
  norm_num

/-- τ numerator: 496 × 21 = 10416 -/
def tau_num : ℚ := dim_E8xE8 * b2

/-- τ denominator: 27 × 99 = 2673 -/
def tau_den : ℚ := dim_J3O * H_star

theorem tau_num_value : tau_num = 10416 := by
  unfold tau_num dim_E8xE8 dim_E8 b2
  norm_num

theorem tau_den_value : tau_den = 2673 := by
  unfold tau_den dim_J3O H_star b2 b3
  norm_num

/-- τ = 10416/2673 -/
def tau_ratio : ℚ := tau_num / tau_den

theorem tau_ratio_value : tau_ratio = 10416 / 2673 := by
  unfold tau_ratio
  rw [tau_num_value, tau_den_value]

/-!
## Two legacy ratios (NOT mixing-angle relations of v3.6)

(rank_E8 + b3)/H* = 85/99 and 1/b2 = 1/21 are arithmetic identities. They were named
`theta_23` and `theta_13_base` before 2026-10-22. They are not the relations of the
paper, whose PMNS relations are sin²θ₂₃ = (D_bulk − Weyl)/D_bulk = 6/11 and
sin²θ₁₃ = D_bulk/dim(E₈×E₈) = 11/496: an instance of vocabulary freedom.
-/

/-- rank_E8 + b3 = 85 (formerly `theta_23_num`) -/
def rank_E8_plus_b3 : ℚ := rank_E8 + b3

theorem rank_E8_plus_b3_value : rank_E8_plus_b3 = 85 := by
  unfold rank_E8_plus_b3 rank_E8 b3
  norm_num

/-- Arithmetic identity (rank_E8 + b3)/H* = 85/99; not the θ₂₃ relation of the paper
    (sin²θ₂₃ = 6/11). Formerly `theta_23`. -/
def rank_E8_plus_b3_over_H_star : ℚ := rank_E8_plus_b3 / H_star

theorem rank_E8_plus_b3_over_H_star_value : rank_E8_plus_b3_over_H_star = 85 / 99 := by
  unfold rank_E8_plus_b3_over_H_star
  rw [rank_E8_plus_b3_value, H_star_value]

/-- 1/b2 = 1/21; not the θ₁₃ relation of the paper (sin²θ₁₃ = 11/496).
    Formerly `theta_13_base`. -/
def inv_b2 : ℚ := 1 / b2

theorem inv_b2_value : inv_b2 = 1 / 21 := by
  unfold inv_b2 b2
  norm_num

@[deprecated rank_E8_plus_b3 (since := "2026-10-22")]
abbrev theta_23_num : ℚ := rank_E8_plus_b3
@[deprecated (since := "2026-10-22")] alias theta_23_num_value := rank_E8_plus_b3_value
@[deprecated rank_E8_plus_b3_over_H_star (since := "2026-10-22")]
abbrev theta_23 : ℚ := rank_E8_plus_b3_over_H_star
@[deprecated (since := "2026-10-22")] alias theta_23_value := rank_E8_plus_b3_over_H_star_value
@[deprecated inv_b2 (since := "2026-10-22")]
abbrev theta_13_base : ℚ := inv_b2
@[deprecated (since := "2026-10-22")] alias theta_13_base_value := inv_b2_value

/-!
## Dark Energy: rational factor (H* - 1)/H* = 98/99

The relation of the paper is Ω_DE = ln 2 × (b₂ + b₃)/H* = ln 2 × 98/99. The
declaration below is only its RATIONAL FACTOR 98/99 (it was named `Omega_DE` before
2026-10-22, which named one component as if it were the observable).
-/

/-- Ω_DE numerator: H* - 1 = 98 -/
def Omega_DE_num : ℚ := H_star - 1

theorem Omega_DE_num_value : Omega_DE_num = 98 := by
  unfold Omega_DE_num H_star b2 b3
  norm_num

/-- Rational factor 98/99 of Ω_DE = ln 2 × 98/99 (NOT Ω_DE itself). -/
def Omega_DE_rational_factor : ℚ := Omega_DE_num / H_star

theorem Omega_DE_rational_factor_value : Omega_DE_rational_factor = 98 / 99 := by
  unfold Omega_DE_rational_factor
  rw [Omega_DE_num_value, H_star_value]

@[deprecated Omega_DE_rational_factor (since := "2026-10-22")]
abbrev Omega_DE : ℚ := Omega_DE_rational_factor
@[deprecated (since := "2026-10-22")] alias Omega_DE_value := Omega_DE_rational_factor_value

/-!
## Fine Structure Constant Components

Integer part of α⁻¹: α_algebraic + α_bulk = 128 + 9 = 137. The relation of the
paper is α⁻¹ = 128 + 9 + 65/(32 × 61) = 267489/1952; the declaration below is only
its integer part (it was named `alpha_inv_total` before 2026-10-22).
-/

/-- Algebraic part: 128 = 2^(rank_E8 - 1) -/
def alpha_inv_algebraic : ℚ := 128

/-- Bulk part: 9 = N_gen² -/
def alpha_inv_bulk : ℚ := 9

/-- Integer part of α⁻¹: 128 + 9 = 137 (NOT α⁻¹ = 267489/1952 itself). -/
def alpha_inv_integer_part : ℚ := alpha_inv_algebraic + alpha_inv_bulk

theorem alpha_inv_integer_part_value : alpha_inv_integer_part = 137 := by
  unfold alpha_inv_integer_part alpha_inv_algebraic alpha_inv_bulk
  norm_num

@[deprecated alpha_inv_integer_part (since := "2026-10-22")]
abbrev alpha_inv_total : ℚ := alpha_inv_integer_part
@[deprecated (since := "2026-10-22")] alias alpha_inv_total_value := alpha_inv_integer_part_value

/-!
## Conjunction of the rational values above

Arithmetic identities on local ℚ copies of the constants. Several conjuncts are
components of a relation (rational factor of α_s or Ω_DE, integer part of α⁻¹) or
legacy ratios that are not relations of the paper (γ, 85/99, 1/21). The certificate
of the paper's 33 relations is `GIFT.Certificate.RelationsV36.relations_v36_certified`.
-/

theorem all_rational_relations_certified :
    -- Weinberg angle
    sin2_theta_W = 3 / 13 ∧
    -- Koide parameter
    koide_Q = 2 / 3 ∧
    -- Gamma GIFT (legacy parameter, not a relation of v3.6)
    gamma_GIFT = 511 / 884 ∧
    -- Strong coupling: rational factor 1/12 of α_s = √2/12
    alpha_s_rational_factor = 1 / 12 ∧
    -- Torsion coefficient
    kappa_T = 1 / 61 ∧
    -- Tau ratio
    tau_ratio = 10416 / 2673 ∧
    -- Legacy ratios (not mixing-angle relations of v3.6)
    rank_E8_plus_b3_over_H_star = 85 / 99 ∧
    inv_b2 = 1 / 21 ∧
    -- Dark energy: rational factor 98/99 of Ω_DE = ln 2 × 98/99
    Omega_DE_rational_factor = 98 / 99 ∧
    -- Fine structure: integer part 137 of α⁻¹ = 267489/1952
    alpha_inv_integer_part = 137 :=
  ⟨sin2_theta_W_simplified, koide_simplified, gamma_GIFT_value,
   alpha_s_rational_factor_value, kappa_T_value, tau_ratio_value,
   rank_E8_plus_b3_over_H_star_value, inv_b2_value,
   Omega_DE_rational_factor_value, alpha_inv_integer_part_value⟩

/-!
## Why This Matters

Old approach (in GIFT.Relations):
```
theorem weinberg_angle_certified : b2 * 13 = 3 * (b3 + dim_G2) := by native_decide
```
This proves: 21 × 13 = 3 × (77 + 14), which is just integer arithmetic.

New approach (here):
```
theorem sin2_theta_W_simplified : sin2_theta_W = 3 / 13 := by norm_num
```
This proves: The actual rational number 21/91 equals 3/13.

The new approach is mathematically proper because:
1. We work with actual rational numbers, not cross-multiplication hacks
2. We can perform further algebraic manipulations
3. The statements are what physicists actually mean
-/

end GIFT.Foundations.RationalConstants
