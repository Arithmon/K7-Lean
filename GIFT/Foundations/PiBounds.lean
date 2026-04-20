/-
GIFT Foundations: Pi Bounds
===========================

Bounds on π used in the Selection Principle.

All bounds are PROVEN using Mathlib's `Mathlib.Analysis.Real.Pi.Bounds` module,
which provides `pi_gt_three`, `pi_lt_four`, and tighter bounds via the
sqrtTwoAddSeries method.

**opaque refactoring (2026-02-09)**: 3 axioms → 0 axioms.
Previously these were numerical axioms because the project notes
incorrectly stated Mathlib 4.27 did not export them. In fact,
`Mathlib.Analysis.Real.Pi.Bounds` provides `pi_gt_three`, `pi_lt_four`,
`pi_lt_d2` (π < 3.15), and much tighter bounds up to 20 decimal places.

Version: 2.0.0 (zero axioms)
-/

import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.Real.Pi.Bounds
import Mathlib.Data.Real.Sqrt
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

namespace GIFT.Foundations.PiBounds

open Real

/-!
## Section 1: Core π bounds (all from Mathlib)
-/

/-- π > 0 (from Mathlib) -/
theorem pi_pos' : Real.pi > 0 := Real.pi_pos

/-- π ≥ 2 (from Mathlib) -/
theorem two_le_pi' : 2 ≤ Real.pi := Real.two_le_pi

/-- π ≤ 4 (from Mathlib, non-strict) -/
theorem pi_le_four' : Real.pi ≤ 4 := Real.pi_le_four

/-- π ≠ 0 (from Mathlib) -/
theorem pi_ne_zero' : Real.pi ≠ 0 := Real.pi_ne_zero

/-!
## Section 2: Strict bounds (proven via Mathlib.Analysis.Real.Pi.Bounds)

Previously axiomatized as numerical bounds. Now fully proven.
-/

/-- π > 3. PROVEN via Mathlib's `pi_gt_three`.

**Former axiom, now theorem** (opaque refactoring 2026-02-09).
Uses `pi_lower_bound` tactic with witness `[23/16]` internally. -/
theorem pi_gt_three : Real.pi > 3 := Real.pi_gt_three

/-- π < 4. PROVEN via Mathlib's `pi_lt_four`.

**Former axiom, now theorem** (opaque refactoring 2026-02-09).
Uses `pi_upper_bound` tactic with witness `[4/3]` internally. -/
theorem pi_lt_four : Real.pi < 4 := Real.pi_lt_four

/-- π < √10. PROVEN from π < 3.15 (Mathlib's `pi_lt_d2`) and 3.15² < 10.

**Former axiom, now theorem** (opaque refactoring 2026-02-09).
Chain: π < 3.15 < √10 (since 3.15² = 9.9225 < 10). -/
theorem pi_lt_sqrt_ten : Real.pi < Real.sqrt 10 := by
  have h_pi_lt : Real.pi < 3.15 := Real.pi_lt_d2
  have h_sqrt : 3.15 < Real.sqrt 10 := by
    rw [show (3.15 : ℝ) = 315 / 100 from by norm_num]
    rw [Real.lt_sqrt (by norm_num : (315 : ℝ) / 100 ≥ 0)]
    norm_num
  linarith

/-!
## Section 3: Derived bounds on π²

These are derived from the axioms above.
-/

/-- π² > 9 (from π > 3) -/
theorem pi_squared_gt_9 : Real.pi ^ 2 > 9 := by
  have h : Real.pi > 3 := pi_gt_three
  have h3 : (3 : ℝ)^2 = 9 := by norm_num
  rw [← h3]
  exact sq_lt_sq' (by linarith) h

/-- π² < 10 (from π < √10) -/
theorem pi_squared_lt_10 : Real.pi ^ 2 < 10 := by
  have h : Real.pi < Real.sqrt 10 := pi_lt_sqrt_ten
  have hpi_pos : 0 ≤ Real.pi := le_of_lt Real.pi_pos
  have h10_pos : (0 : ℝ) ≤ 10 := by norm_num
  calc Real.pi ^ 2
      < (Real.sqrt 10) ^ 2 := sq_lt_sq' (by linarith [Real.pi_pos]) h
    _ = 10 := Real.sq_sqrt h10_pos

/-- π² < 16 (from π < 4) - looser bound -/
theorem pi_squared_lt_16 : Real.pi ^ 2 < 16 := by
  have h : Real.pi < 4 := pi_lt_four
  have hpi_pos : 0 ≤ Real.pi := le_of_lt Real.pi_pos
  have h4 : (4 : ℝ)^2 = 16 := by norm_num
  rw [← h4]
  exact sq_lt_sq' (by linarith [Real.pi_pos]) h

/-!
## Section 4: Additional useful bounds
-/

/-- π is strictly between 3 and 4 -/
theorem pi_between_3_and_4 : 3 < Real.pi ∧ Real.pi < 4 :=
  ⟨pi_gt_three, pi_lt_four⟩

/-- π² is strictly between 9 and 10 -/
theorem pi_squared_between_9_and_10 : 9 < Real.pi ^ 2 ∧ Real.pi ^ 2 < 10 :=
  ⟨pi_squared_gt_9, pi_squared_lt_10⟩

end GIFT.Foundations.PiBounds
