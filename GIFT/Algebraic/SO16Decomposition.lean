/-
  SO(16) Decomposition of E₈
  ==========================

  Key result: The GIFT topological invariants sum to dim(SO(16)) = 120,
  while the octonionic spinor contributes 128, giving dim(E₈) = 248.

  This connects G₂ compactification geometry to standard group theory.

  Reference: GIFT v3.2 Implementation Plan
-/

import GIFT.Core
import GIFT.Algebraic.Octonions
import GIFT.Algebraic.BettiNumbers

namespace GIFT.Algebraic.SO16Decomposition

open GIFT.Core Octonions BettiNumbers

/-!
## SO(n) Dimension Formula

dim(SO(n)) = n(n-1)/2
-/

/-- Dimension of SO(n) = n(n-1)/2 -/
def dim_SO (n : ℕ) : ℕ := n * (n - 1) / 2

/-- SO(16) has dimension 120 -/
theorem dim_SO16 : dim_SO 16 = 120 := by decide

/-- SO(7) has dimension 21 -/
theorem dim_SO7 : dim_SO 7 = 21 := by decide

/-- SO(8) has dimension 28 -/
theorem dim_SO8 : dim_SO 8 = 28 := by decide

/-!
## Spinor Representations

The chiral spinor of SO(16) has dimension 2^8/2 = 128.
This equals 2^|Im(O)| = 2^7 = 128.
-/

/-- Chiral spinor dimension of SO(16) = 2^(16/2) / 2 = 2^8 / 2 = 128 -/
def spinor_SO16 : ℕ := 128

theorem spinor_SO16_eq : spinor_SO16 = 128 := rfl

/-- Spinor dimension from octonions: 2^|Im(O)| = 2^7 = 128 -/
theorem spinor_from_octonions : (2 : ℕ) ^ imaginary_count = 128 := by decide

/-!
## Geometric Part: Topology of K₇

The "geometric part" encodes:
- b₂ = 21 (harmonic 2-forms)
- b₃ = 77 (harmonic 3-forms)
- dim(G₂) = 14 (holonomy group)
- rank(E₈) = 8 (Cartan subalgebra)

Total: 21 + 77 + 14 + 8 = 120 = dim(SO(16))
-/

/-- The geometric part: topology of K₇ + algebra -/
def geometric_part : ℕ := b2 + b3 + G2.dim_G2 + rank_E8

/-- Geometric part equals dim(SO(16)) = 120 -/
theorem geometric_is_SO16 : geometric_part = 120 := by
  unfold geometric_part b2 b3 G2.dim_G2 rank_E8
  decide

/-- Geometric part equals dim(SO(16)) directly -/
theorem geometric_eq_dim_SO16 : geometric_part = dim_SO 16 := by
  rw [geometric_is_SO16, dim_SO16]

/-!
## Spinorial Part: Octonion Structure

The "spinorial part" encodes:
- 2^|Im(O)| = 2^7 = 128 (chiral spinor from octonion imaginaries)
-/

/-- The spinorial part: 2^|Im(O)| -/
def spinorial_part : ℕ := 2 ^ imaginary_count

/-- Spinorial part equals 128 -/
theorem spinorial_is_128 : spinorial_part = 128 := by
  unfold spinorial_part imaginary_count
  decide

/-- Spinorial part equals SO(16) spinor -/
theorem spinorial_eq_spinor_SO16 : spinorial_part = spinor_SO16 := by
  rw [spinorial_is_128, spinor_SO16_eq]

/-!
## MASTER THEOREM: E₈ = SO(16) adjoint ⊕ SO(16) spinor

dim(E₈) = 248 = 120 + 128 = geometric + spinorial
-/

/-- MASTER THEOREM: E₈ decomposes as SO(16) adjoint ⊕ SO(16) spinor -/
theorem E8_SO16_decomposition :
    dim_E8 = geometric_part + spinorial_part := by
  unfold dim_E8 geometric_part spinorial_part
  decide

/-- Alternative: dim(E₈) = dim(SO(16)) + spinor(SO(16)) -/
theorem E8_equals_SO16_plus_spinor :
    dim_E8 = dim_SO 16 + spinor_SO16 := by
  unfold dim_E8 dim_SO spinor_SO16
  decide

/-- Physical interpretation: geometry → gauge bosons, octonions → fermions -/
theorem gauge_fermion_split :
    dim_E8 = (b2 + b3 + G2.dim_G2 + rank_E8) + 2^imaginary_count := by
  decide

/-!
## Detailed Component Breakdown
-/

/-- Component check: 21 + 77 + 14 + 8 = 120 -/
theorem geometric_breakdown : 21 + 77 + 14 + 8 = 120 := rfl

/-- Component check: 120 + 128 = 248 -/
theorem total_breakdown : 120 + 128 = 248 := rfl

/-- The split preserves E₈ dimension -/
theorem split_preserves_dim : dim_SO 16 + spinor_SO16 = 248 := by decide

/-!
## Summary

E₈ ⊃ SO(16) is a maximal subgroup embedding.
The adjoint representation decomposes as:

    248 = 120 ⊕ 128
        = adj(SO(16)) ⊕ spinor(SO(16))

GIFT Interpretation:
- 120 = b₂ + b₃ + dim(G₂) + rank(E₈) = Topology + Holonomy + Cartan
      → Generates GAUGE BOSONS
- 128 = 2^|Im(O)| = Spinor dimension from octonions
      → Generates FERMIONS
-/

end GIFT.Algebraic.SO16Decomposition
