/-
GIFT Geometry: Hodge Star on ℝ⁷
================================

Concrete implementation of the Hodge star operator ⋆ : Ω³ ↔ Ω⁴ on ℝ⁷.

Key results:
- `psi_eq_star_phi`: ψ = ⋆φ proven by explicit coefficient comparison
- `standardG2Geom_torsionFree`: (dφ=0) ∧ (dψ=0) on flat ℝ⁷

Version: 3.3.4
-/

import GIFT.Geometry.HodgeStarCompute
import Mathlib.Data.Int.Basic

namespace GIFT.Geometry.HodgeStarR7

open GIFT.Geometry.Exterior
open GIFT.Geometry.DifferentialFormsR7
open GIFT.Geometry.HodgeStarCompute

/-!
## Part 1: Sign Analysis for n = 7
-/

/-- k(7-k) for k ∈ {0,...,7} -/
def starStarExponent (k : Fin 8) : ℕ := k.val * (7 - k.val)

/-- k(7-k) is always even for k ≤ 7 -/
theorem starStar_exp_even (k : Fin 8) : Even (starStarExponent k) := by
  unfold starStarExponent
  fin_cases k <;> decide

/-- Therefore ⋆⋆ = +1 on all forms in 7 dimensions -/
theorem starStar_sign_positive (k : Fin 8) :
    (-1 : ℤ) ^ starStarExponent k = 1 := by
  unfold starStarExponent
  fin_cases k <;> native_decide

/-!
## Part 2: Hodge Duality Dimensions
-/

/-- ⋆ : Ω³ → Ω⁴, both 35-dimensional -/
theorem hodge_3_to_4 : Nat.choose 7 3 = Nat.choose 7 4 := by native_decide

/-- ⋆ : Ω² → Ω⁵, both 21-dimensional -/
theorem hodge_2_to_5 : Nat.choose 7 2 = Nat.choose 7 5 := by native_decide

/-!
## Part 3: Hodge Star for G₂ Forms

Direct definitions of star3 and star4 for constant forms.
Note: These operators extract coefficients at position 0, so involutivity
(⋆⋆ = id) only holds for constant (position-independent) forms.
-/

/-- Hodge star for constant 3-forms → 4-forms -/
def star3 (ω : DiffForm 3) : DiffForm 4 :=
  constDiffForm 4 (hodgeStar3to4 (ω.coeffs 0))

/-- Hodge star for constant 4-forms → 3-forms -/
def star4 (η : DiffForm 4) : DiffForm 3 :=
  constDiffForm 3 (hodgeStar4to3 (η.coeffs 0))

/-- star3 is linear -/
theorem star3_linear (a : ℝ) (ω η : DiffForm 3) :
    star3 (a • ω + η) = a • star3 ω + star3 η := by
  ext p i
  show sign3 (complement4to3 i) * (a * ω.coeffs 0 (complement4to3 i) + η.coeffs 0 (complement4to3 i))
    = a * (sign3 (complement4to3 i) * ω.coeffs 0 (complement4to3 i))
      + sign3 (complement4to3 i) * η.coeffs 0 (complement4to3 i)
  ring

/-- star4 is linear -/
theorem star4_linear (a : ℝ) (ω η : DiffForm 4) :
    star4 (a • ω + η) = a • star4 ω + star4 η := by
  ext p i
  show sign4 (complement3to4 i) * (a * ω.coeffs 0 (complement3to4 i) + η.coeffs 0 (complement3to4 i))
    = a * (sign4 (complement3to4 i) * ω.coeffs 0 (complement3to4 i))
      + sign4 (complement3to4 i) * η.coeffs 0 (complement3to4 i)
  ring

/-- ⋆⋆ = id on constant 3-forms (coefficient level) -/
theorem star4_star3_const (c : FormCoeffs 3) :
    star4 (star3 (constDiffForm 3 c)) = constDiffForm 3 c := by
  unfold star4 star3 constDiffForm
  congr 1
  funext _
  exact hodgeStar_invol_3 c

/-- ⋆⋆ = id on constant 4-forms (coefficient level) -/
theorem star3_star4_const (c : FormCoeffs 4) :
    star3 (star4 (constDiffForm 4 c)) = constDiffForm 4 c := by
  unfold star3 star4 constDiffForm
  congr 1
  funext _
  exact hodgeStar_invol_4 c

/-!
## Part 4: G₂ Structure
-/

/-- Complete G₂ geometric structure -/
structure G2GeomData where
  /-- Exterior derivative -/
  extDeriv : ExteriorDerivative
  /-- The G₂ 3-form -/
  phi : DiffForm 3
  /-- The coassociative 4-form -/
  psi : DiffForm 4
  /-- ψ = ⋆φ -/
  psi_is_star_phi : psi = star3 phi

/-- Torsion-free: dφ = 0 and d(⋆φ) = 0 -/
def G2GeomData.TorsionFree (g : G2GeomData) : Prop :=
  IsClosed g.extDeriv 3 g.phi ∧ IsClosed g.extDeriv 4 g.psi

/-!
## Part 5: Standard G₂ on Flat ℝ⁷
-/

/-- For the standard G₂ structure, ψ = ⋆φ (proven by coefficient computation) -/
theorem psi_eq_star_phi : standardG2.psi = star3 standardG2.phi := by
  ext p i
  -- Goal: standardG2.psi.coeffs p i = (star3 standardG2.phi).coeffs p i
  unfold star3 standardG2 constDiffForm
  simp only
  unfold hodgeStar3to4 complement4to3 sign3
  fin_cases i <;> norm_num

/-- Standard G₂ geometric structure on flat ℝ⁷ -/
def standardG2Geom : G2GeomData where
  extDeriv := trivialExteriorDeriv
  phi := standardG2.phi
  psi := standardG2.psi
  psi_is_star_phi := psi_eq_star_phi

/-- Standard G₂ is torsion-free -/
theorem standardG2Geom_torsionFree : standardG2Geom.TorsionFree := by
  unfold G2GeomData.TorsionFree standardG2Geom
  constructor
  · exact constant_forms_closed 3 standardG2.phi
  · exact constant_forms_closed 4 standardG2.psi

/-!
## Part 6: Module Certificate
-/

/-- Hodge star infrastructure certificate (axiom-free version) -/
theorem hodge_infrastructure_complete :
    -- Dimensional identities
    (Nat.choose 7 3 = Nat.choose 7 4) ∧
    (Nat.choose 7 2 = Nat.choose 7 5) ∧
    -- Sign is always positive in 7 dimensions
    (∀ k : Fin 8, (-1 : ℤ) ^ starStarExponent k = 1) ∧
    -- ψ = ⋆φ (proven, not axiomatized)
    (standardG2.psi = star3 standardG2.phi) ∧
    -- ⋆⋆ = id on constant forms
    (∀ c : FormCoeffs 3, star4 (star3 (constDiffForm 3 c)) = constDiffForm 3 c) ∧
    -- Standard G₂ is torsion-free
    standardG2Geom.TorsionFree := by
  exact ⟨hodge_3_to_4, hodge_2_to_5, starStar_sign_positive,
         psi_eq_star_phi, star4_star3_const, standardG2Geom_torsionFree⟩

end GIFT.Geometry.HodgeStarR7
