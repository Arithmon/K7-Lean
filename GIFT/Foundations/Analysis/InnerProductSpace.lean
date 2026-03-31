/-
GIFT Foundations: Inner Product Space
=====================================

Establishes ℝⁿ with standard inner product using Mathlib.
This is the foundation for E8 lattice and differential forms.

Version: 3.2.0

NOTE ON NAMESPACE CONFLICTS:
  R7 and R8 are also defined in domain-specific modules:
  - R8: GIFT.Foundations.E8Lattice.R8 (canonical for E8 work)
  - R7: GIFT.Foundations.G2CrossProduct.R7 (canonical for G2 work)

  When importing multiple modules, use qualified names to avoid ambiguity:
    open GIFT.Foundations.E8Lattice (R8)
    open GIFT.Foundations.G2CrossProduct (R7)

  The definitions here are equivalent (all are EuclideanSpace ℝ (Fin n))
  but exist for standalone use of this utility module.
-/

import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Data.Int.Basic

namespace GIFT.Foundations.Analysis.InnerProductSpace

/-!
## Standard Euclidean Spaces
-/

/-- ℝ⁷ as Euclidean space -/
abbrev R7 := EuclideanSpace ℝ (Fin 7)

/-- ℝ⁸ as Euclidean space -/
abbrev R8 := EuclideanSpace ℝ (Fin 8)

/-!
## Inner Product Properties
-/

/-- Inner product on ℝⁿ -/
noncomputable def innerRn {n : ℕ} (v w : EuclideanSpace ℝ (Fin n)) : ℝ :=
  @inner ℝ _ _ v w

/-- Squared norm -/
noncomputable def normSq {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) : ℝ :=
  ‖v‖^2

/-- Norm squared is non-negative -/
theorem normSq_nonneg {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) :
    normSq v ≥ 0 := by
  unfold normSq
  exact sq_nonneg _

/-- Norm squared zero iff vector is zero -/
theorem normSq_eq_zero_iff {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) :
    normSq v = 0 ↔ v = 0 := by
  unfold normSq
  rw [sq_eq_zero_iff, norm_eq_zero]

/-- Cauchy-Schwarz inequality -/
theorem cauchy_schwarz {n : ℕ} (v w : EuclideanSpace ℝ (Fin n)) :
    |innerRn v w| ≤ ‖v‖ * ‖w‖ := by
  unfold innerRn
  exact abs_real_inner_le_norm v w

/-!
## Standard Basis
-/

/-- Standard basis vector eᵢ -/
noncomputable def stdBasis {n : ℕ} (i : Fin n) : EuclideanSpace ℝ (Fin n) :=
  EuclideanSpace.single i 1

/-- Basis vectors are orthonormal -/
theorem stdBasis_orthonormal {n : ℕ} (i j : Fin n) :
    innerRn (stdBasis i) (stdBasis j) = if i = j then 1 else 0 := by
  unfold innerRn stdBasis
  simp [PiLp.single_apply, inner, mul_comm, @eq_comm _ i j]

/-- Basis vectors have norm 1 -/
theorem stdBasis_norm {n : ℕ} (i : Fin n) :
    ‖stdBasis (n := n) i‖ = 1 := by
  unfold stdBasis
  rw [PiLp.norm_single, norm_one]

/-!
## Integer and Half-Integer Predicates (for E8)
-/

/-- x is an integer -/
def IsInteger (x : ℝ) : Prop := ∃ n : ℤ, x = n

/-- x is a half-integer (n + 1/2) -/
def IsHalfInteger (x : ℝ) : Prop := ∃ n : ℤ, x = n + 1/2

/-- All coordinates are integers -/
def AllInteger {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) : Prop :=
  ∀ i, IsInteger (v i)

/-- All coordinates are half-integers -/
def AllHalfInteger {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) : Prop :=
  ∀ i, IsHalfInteger (v i)

/-- Integer + integer = integer -/
theorem IsInteger.add {x y : ℝ} (hx : IsInteger x) (hy : IsInteger y) :
    IsInteger (x + y) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨n, rfl⟩ := hy
  exact ⟨m + n, by push_cast; ring⟩

/-- Integer × integer = integer -/
theorem IsInteger.mul {x y : ℝ} (hx : IsInteger x) (hy : IsInteger y) :
    IsInteger (x * y) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨n, rfl⟩ := hy
  exact ⟨m * n, by push_cast; ring⟩

/-- Half-integer + half-integer = integer -/
theorem IsHalfInteger.add_self {x y : ℝ}
    (hx : IsHalfInteger x) (hy : IsHalfInteger y) :
    IsInteger (x + y) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨n, rfl⟩ := hy
  exact ⟨m + n + 1, by push_cast; ring⟩

/-- Negation of integer is integer -/
theorem IsInteger.neg {x : ℝ} (hx : IsInteger x) : IsInteger (-x) := by
  obtain ⟨n, rfl⟩ := hx
  exact ⟨-n, by push_cast; ring⟩

/-- Negation of half-integer is half-integer -/
theorem IsHalfInteger.neg {x : ℝ} (hx : IsHalfInteger x) : IsHalfInteger (-x) := by
  obtain ⟨n, rfl⟩ := hx
  exact ⟨-n - 1, by push_cast; ring⟩

/-- Integer + half-integer = half-integer -/
theorem IsInteger.add_half {x y : ℝ} (hx : IsInteger x) (hy : IsHalfInteger y) :
    IsHalfInteger (x + y) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨n, rfl⟩ := hy
  exact ⟨m + n, by push_cast; ring⟩

/-- Half-integer + integer = half-integer -/
theorem IsHalfInteger.add_int {x y : ℝ} (hx : IsHalfInteger x) (hy : IsInteger y) :
    IsHalfInteger (x + y) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨n, rfl⟩ := hy
  exact ⟨m + n, by push_cast; ring⟩

/-- Integer scalar multiple of integer is integer -/
theorem IsInteger.zsmul {x : ℝ} (n : ℤ) (hx : IsInteger x) : IsInteger (n * x) := by
  obtain ⟨m, rfl⟩ := hx
  exact ⟨n * m, by push_cast; ring⟩

/-- Integer scalar multiple of half-integer is half-integer when n is odd -/
theorem IsHalfInteger.zsmul_odd {x : ℝ} {n : ℤ} (hn : Odd n) (hx : IsHalfInteger x) :
    IsHalfInteger (n * x) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨k, hk⟩ := hn
  rw [hk]
  exact ⟨(2*k + 1) * m + k, by push_cast; ring⟩

/-- Integer scalar multiple of half-integer is integer when n is even -/
theorem IsHalfInteger.zsmul_even {x : ℝ} {n : ℤ} (hn : Even n) (hx : IsHalfInteger x) :
    IsInteger (n * x) := by
  obtain ⟨m, rfl⟩ := hx
  obtain ⟨k, hk⟩ := hn
  rw [hk]
  exact ⟨2 * k * m + k, by push_cast; ring⟩

/-!
## AllInteger and AllHalfInteger closure lemmas
-/

/-- Negation preserves AllInteger -/
theorem AllInteger.neg {d : ℕ} {v : EuclideanSpace ℝ (Fin d)} (hv : AllInteger v) :
    AllInteger (-v) := fun i => (hv i).neg

/-- Negation preserves AllHalfInteger -/
theorem AllHalfInteger.neg {d : ℕ} {v : EuclideanSpace ℝ (Fin d)} (hv : AllHalfInteger v) :
    AllHalfInteger (-v) := fun i => (hv i).neg

/-- AllInteger + AllInteger = AllInteger -/
theorem AllInteger.add {d : ℕ} {v w : EuclideanSpace ℝ (Fin d)}
    (hv : AllInteger v) (hw : AllInteger w) : AllInteger (v + w) :=
  fun i => (hv i).add (hw i)

/-- AllHalfInteger + AllHalfInteger = AllInteger -/
theorem AllHalfInteger.add_self {d : ℕ} {v w : EuclideanSpace ℝ (Fin d)}
    (hv : AllHalfInteger v) (hw : AllHalfInteger w) : AllInteger (v + w) :=
  fun i => (hv i).add_self (hw i)

/-- AllInteger + AllHalfInteger = AllHalfInteger -/
theorem AllInteger.add_half {d : ℕ} {v w : EuclideanSpace ℝ (Fin d)}
    (hv : AllInteger v) (hw : AllHalfInteger w) : AllHalfInteger (v + w) :=
  fun i => (hv i).add_half (hw i)

/-- AllHalfInteger + AllInteger = AllHalfInteger -/
theorem AllHalfInteger.add_int {d : ℕ} {v w : EuclideanSpace ℝ (Fin d)}
    (hv : AllHalfInteger v) (hw : AllInteger w) : AllHalfInteger (v + w) :=
  fun i => (hv i).add_int (hw i)

/-!
## Norm Squared Formulas
-/

/-- Norm squared as sum of squares -/
theorem normSq_eq_sum {n : ℕ} (v : EuclideanSpace ℝ (Fin n)) :
    normSq v = ∑ i, (v i)^2 := by
  unfold normSq
  rw [EuclideanSpace.norm_eq]
  rw [Real.sq_sqrt (Finset.sum_nonneg (fun i _ => sq_nonneg _))]
  congr 1
  funext i
  rw [Real.norm_eq_abs, sq_abs]

/-- Inner product as sum of products -/
theorem inner_eq_sum {n : ℕ} (v w : EuclideanSpace ℝ (Fin n)) :
    innerRn v w = ∑ i, (v i) * (w i) := by
  unfold innerRn
  rw [PiLp.inner_apply]
  congr 1
  funext i
  simp [inner, mul_comm]

end GIFT.Foundations.Analysis.InnerProductSpace
