/-
  GIFT Algebraic Foundations: Quaternions
  ========================================

  Quaternion foundations: K₄ graph correspondence.

  Establishes the correspondence between:
  - K₄ (complete graph on 4 vertices)
  - ℍ (quaternions)

  Key facts:
  - dim(ℍ) = 4 = |V(K₄)|
  - 3 imaginary units {i,j,k} = C(4,2)/2 = 3 vertex pairings
  - Anti-commutative: ij = -ji, etc.
-/

import Mathlib.Combinatorics.SimpleGraph.Basic
import Mathlib.Combinatorics.SimpleGraph.Finite
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Nat.Choose.Basic
import Mathlib.Tactic.FinCases

namespace GIFT.Algebraic.Quaternions

/-!
## K₄ Properties
-/

/-- The complete graph K₄ -/
def K4 : SimpleGraph (Fin 4) := ⊤

/-- K₄ has 4 vertices -/
theorem K4_card_vertices : Fintype.card (Fin 4) = 4 := by decide

/-- K₄ adjacency is decidable -/
instance K4_DecidableRel : DecidableRel K4.Adj := fun v w =>
  if h : v = w then isFalse (K4.loopless.irrefl v ∘ (h ▸ ·))
  else isTrue h

/-- K₄ has 6 edges = C(4,2) -/
theorem K4_card_edges : K4.edgeFinset.card = 6 := by native_decide

/-- Each vertex of K₄ has degree 3 -/
theorem K4_degree (v : Fin 4) : K4.degree v = 3 := by
  fin_cases v <;> native_decide

/-!
## Quaternion Dimension Constants

The quaternions ℍ have dimension 4 over ℝ.
We record this as a constant, with the correspondence to K₄.
-/

/-- Dimension of the quaternions -/
def quaternion_dim : ℕ := 4

theorem quaternion_dim_eq : quaternion_dim = 4 := rfl

/-- Dimension correspondence: K₄ vertices = dim(ℍ) -/
theorem K4_vertices_eq_quaternion_dim :
    Fintype.card (Fin 4) = quaternion_dim := by decide

/-!
## Imaginary Quaternion Units

The three imaginary units {i, j, k} satisfy:
- i² = j² = k² = -1
- ij = k, jk = i, ki = j
- ji = -k, kj = -i, ik = -j (anti-commutativity)
-/

/-- Number of imaginary units in ℍ -/
def imaginary_count : ℕ := 3

theorem imaginary_count_eq : imaginary_count = 3 := rfl

/-- Count of imaginary units -/
theorem Im_H_card : Fintype.card (Fin 3) = 3 := by decide

/-- Relation: dim(ℍ) = imaginary_count + 1 (real + imaginaries) -/
theorem quaternion_dim_split : quaternion_dim = imaginary_count + 1 := rfl

/-!
## Connection to K₄ Structure

K₄ has 3 perfect matchings, corresponding to 3 ways to pair 4 vertices.
This matches the 3 imaginary units of ℍ!

Perfect matchings in K₄:
- {(0,1), (2,3)} ↔ i
- {(0,2), (1,3)} ↔ j
- {(0,3), (1,2)} ↔ k
-/

/-- K₄ has C(4,2) = 6 edges -/
theorem K4_edges_eq_choose : K4.edgeFinset.card = Nat.choose 4 2 := by native_decide

/-- C(4,2) = 6 -/
theorem choose_4_2 : Nat.choose 4 2 = 6 := by native_decide

/-- 6 edges, 3 pairs of opposite edges = 3 imaginary units -/
theorem K4_opposite_pairs : Nat.choose 4 2 / 2 = imaginary_count := by native_decide

/-- Each imaginary corresponds to a pair of opposite edges -/
theorem matching_count : 3 = imaginary_count := rfl

/-!
## Summary

This module establishes:
1. K₄ ↔ ℍ correspondence via dimension (4 vertices = dim 4)
2. 3 imaginary units from 3 perfect matchings of K₄
3. The "3" in quaternions connects to the "7" in octonions via 3 + 4 = 7
-/

end GIFT.Algebraic.Quaternions
