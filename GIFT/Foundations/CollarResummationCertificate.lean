import Mathlib

/-!
# Collar re-summation certificate (generalized binomial series)

This file machine-checks, fully rigorously, two self-contained identities that
underpin the collar estimate in the adiabatic G_2 / closed-form K3 construction.

* **Absolute re-summation identity.** The closed form
  `∑_{k≥0} |C(3/2, k)| = 3`, where `C(3/2, k)` is the generalized binomial
  coefficient. The collar bound erodes the bulk bound by exactly this constant
  factor `3`, independently of the adiabatic parameter.

  It is proved by an *elementary* route that does **not** rely on Abel's
  theorem: a telescoping identity for the alternating partial sums,
  `∑_{k=0}^{n} (-1)^k C(3/2,k) = (-1)^n C(1/2,n)`, combined with the explicit
  decay bound `|C(1/2,n)| ≤ 1/(2n-1)`. As a free corollary this also yields the
  alternating-series value `∑_{k≥0} (-1)^k C(3/2,k) = 0` (the binomial series of
  `(1+x)^{3/2}` evaluated at `x = -1`), obtained here without any
  boundary-limit theorem.

* **Indicial parity.** The indicial polynomial `P_m(β) = β² − m²` is even in
  `β`, so the indicial constant `K_ind(β) = 1/|P_{1/2}(β)|` satisfies
  `K_ind(-1) = K_ind(+1) = 4/3`. This is the symmetry that carries the weighted
  Schauder constant verbatim across the `β = +1` and `β = -1` weights.

All proofs are complete (no incomplete goals) and rely only on the standard
axioms `[propext, Classical.choice, Quot.sound]`.
-/

namespace GIFT.Foundations.CollarResummation

open Finset Filter Topology

/-! ## Generalized binomial coefficients `C(3/2, k)` and `C(1/2, k)` -/

/-- The generalized binomial coefficient `C(3/2, k) = (3/2)(3/2-1)⋯(3/2-k+1)/k!`. -/
noncomputable def C32 (k : ℕ) : ℝ := (∏ i ∈ range k, ((3 : ℝ) / 2 - i)) / (k.factorial : ℝ)

/-- The generalized binomial coefficient `C(1/2, k) = (1/2)(1/2-1)⋯(1/2-k+1)/k!`. -/
noncomputable def C12 (k : ℕ) : ℝ := (∏ i ∈ range k, ((1 : ℝ) / 2 - i)) / (k.factorial : ℝ)

@[simp] lemma C32_zero : C32 0 = 1 := by
  unfold C32; norm_num;

@[simp] lemma C12_zero : C12 0 = 1 := by
  simp [C12]

lemma C32_one : C32 1 = 3 / 2 := by
  unfold C32; norm_num;

lemma C32_two : C32 2 = 3 / 8 := by
  unfold C32; norm_num [ Finset.prod_range_succ ] ;

lemma C32_three : C32 3 = -1 / 16 := by
  unfold C32; norm_num [ Finset.prod_range_succ ] ;

lemma C12_one : C12 1 = 1 / 2 := by
  unfold C12; norm_num

/-
Recurrence for `C(3/2, ·)`.
-/
lemma C32_succ (k : ℕ) : C32 (k + 1) = C32 k * (((3 : ℝ) / 2 - k) / (k + 1)) := by
  unfold C32
  rw [Finset.prod_range_succ, Nat.factorial_succ]
  push_cast
  field_simp

/-
Recurrence for `C(1/2, ·)`.
-/
lemma C12_succ (k : ℕ) : C12 (k + 1) = C12 k * (((1 : ℝ) / 2 - k) / (k + 1)) := by
  unfold C12
  rw [Finset.prod_range_succ, Nat.factorial_succ]
  push_cast
  field_simp

/-
Pascal's rule for generalized binomial coefficients:
`C(3/2, k+1) = C(1/2, k+1) + C(1/2, k)`.
-/
lemma pascal (k : ℕ) : C32 (k + 1) = C12 (k + 1) + C12 k := by
  induction' k with k ih <;> norm_num [ C32_one, C12_one, C32_succ, C12_succ ] at *;
  grind

/-! ## Telescoping identity for the alternating partial sums -/

/-
`∑_{k=0}^{n} (-1)^k C(3/2,k) = (-1)^n C(1/2,n)`. Proven by induction using `pascal`.
-/
lemma telescope (n : ℕ) :
    ∑ k ∈ range (n + 1), (-1 : ℝ) ^ k * C32 k = (-1 : ℝ) ^ n * C12 n := by
      induction n <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ];
      rw [ pascal ] ; ring

/-! ## Sign analysis: `|C(3/2,k)| = (-1)^k C(3/2,k)` for `k ≥ 3` -/

/-
For `k ≥ 3`, `(-1)^k C(3/2,k) ≥ 0`.
-/
lemma sign_C32 (k : ℕ) (hk : 3 ≤ k) : 0 ≤ (-1 : ℝ) ^ k * C32 k := by
  induction' hk with k hk ih <;> norm_num [ pow_succ', C32_succ ] at *;
  rw [ ← mul_assoc ] ; exact mul_nonpos_of_nonneg_of_nonpos ih ( div_nonpos_of_nonpos_of_nonneg ( by linarith [ show ( k : ℝ ) ≥ 3 by norm_cast ] ) ( by positivity ) ) ;

/-
For `k ≥ 3`, `|C(3/2,k)| = (-1)^k C(3/2,k)`.
-/
lemma abs_C32 (k : ℕ) (hk : 3 ≤ k) : |C32 k| = (-1 : ℝ) ^ k * C32 k := by
  have h := abs_of_nonneg (sign_C32 k hk)
  rwa [abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul] at h

/-! ## Decay of `C(1/2, n)` -/

/-
The explicit decay bound `|C(1/2, n)| ≤ 1/(2n-1)` for `n ≥ 1`.
-/
lemma C12_abs_bound (n : ℕ) (hn : 1 ≤ n) : |C12 n| ≤ 1 / (2 * (n : ℝ) - 1) := by
  induction hn <;> simp_all +decide [ C12_succ ];
  · norm_num;
  · rw [ abs_div ];
    refine le_trans ( mul_le_mul_of_nonneg_right ‹_› <| by positivity ) ?_;
    rw [ inv_mul_eq_div, div_le_iff₀ ];
    · rw [ inv_mul_eq_div, div_le_div_iff₀ ] <;> cases abs_cases ( 2⁻¹ - ( ↑‹ℕ› : ℝ ) ) <;> cases abs_cases ( ( ↑‹ℕ› : ℝ ) + 1 ) <;> push_cast [ * ] <;> nlinarith [ show ( 1 : ℝ ) ≤ ↑‹ℕ› by norm_cast ];
    · linarith [ show ( ↑‹ℕ› : ℝ ) ≥ 1 by norm_cast ]

/-
`C(1/2, n) → 0`.
-/
lemma C12_tendsto_zero : Tendsto C12 atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ _;
  exacts [ fun n => 1 / ( 2 * ( n : ℝ ) - 1 ), by filter_upwards [ Filter.eventually_ge_atTop 1 ] with n hn using by simpa using C12_abs_bound n hn, tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ <| tendsto_natCast_atTop_atTop.const_mul_atTop zero_lt_two ]

/-! ## Partial sums of the absolute series -/

/-
For `n ≥ 3`, `∑_{k=0}^{n} |C(3/2,k)| = 3 + (-1)^n C(1/2,n)`.
-/
lemma abs_partial (n : ℕ) (hn : 3 ≤ n) :
    ∑ k ∈ range (n + 1), |C32 k| = 3 + (-1 : ℝ) ^ n * C12 n := by
      -- Using the identity from the provided solution, we can rewrite the absolute sum as a telescoping sum.
      have h_telescope : ∑ k ∈ Finset.range (n + 1), |C32 k| = ∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * C32 k + ∑ k ∈ Finset.range (n + 1), (|C32 k| - (-1 : ℝ) ^ k * C32 k) := by
        rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => add_sub_cancel _ _ ];
      -- The second sum is zero for $k \geq 3$.
      have h_zero : ∑ k ∈ Finset.range (n + 1), (|C32 k| - (-1 : ℝ) ^ k * C32 k) = ∑ k ∈ Finset.range 3, (|C32 k| - (-1 : ℝ) ^ k * C32 k) := by
        rw [ ← Finset.sum_range_add_sum_Ico _ ( by linarith : 3 ≤ n + 1 ) ];
        simp;
        rw [ ← Finset.sum_sub_distrib, Finset.sum_eq_zero ] ; intros ; rw [ abs_C32 ] ; linarith [ Finset.mem_Ico.mp ‹_› ];
        linarith [ Finset.mem_Ico.mp ‹_› ];
      rw [ h_telescope, h_zero, telescope ] ; norm_num [ Finset.sum_range_succ, C32_zero, C32_one, C32_two, C32_three, C12_zero, C12_one, C12_succ ] ; ring;

/-
The partial sums of `∑ |C(3/2,k)|` converge to `3`.
-/
lemma tendsto_abs_partial :
    Tendsto (fun n => ∑ k ∈ range n, |C32 k|) atTop (𝓝 3) := by
      -- By `abs_partial`, for n ≥ 3 this equals 3 + (-1)^n * C12 n.
      have h_eq : ∀ n ≥ 3, (∑ k ∈ Finset.range (n + 1), abs (C32 k)) = 3 + (-1 : ℝ) ^ n * C12 n :=
        fun n hn => abs_partial n hn
      -- Taking the limit as n approaches infinity, we have $3 + (-1)^n * C12 n \to 3$.
      have h_lim : Filter.Tendsto (fun n => 3 + (-1 : ℝ) ^ n * C12 n) Filter.atTop (nhds 3) := by
        exact le_trans ( tendsto_const_nhds.add ( tendsto_zero_iff_norm_tendsto_zero.mpr <| by simpa using C12_tendsto_zero.norm ) ) ( by norm_num );
      rw [ ← Filter.tendsto_add_atTop_iff_nat 1 ] ; exact h_lim.congr' ( by filter_upwards [ Filter.eventually_ge_atTop 3 ] with n hn; aesop ) ;

/-! ## Main results -/

/-
**Collar re-summation centerpiece.** The absolute generalized-binomial series sums to
`3` exactly.
-/
theorem collar_resummation : HasSum (fun k => |C32 k|) 3 := by
  convert Summable.hasSum _;
  · exact tendsto_nhds_unique ( tendsto_abs_partial ) ( Summable.hasSum ( show Summable _ from by by_contra h; exact not_tendsto_atTop_of_tendsto_nhds ( tendsto_abs_partial ) <| by exact not_summable_iff_tendsto_nat_atTop_of_nonneg ( fun _ => abs_nonneg _ ) |>.1 h |> Filter.Tendsto.comp <| Filter.tendsto_id ) |> HasSum.tendsto_sum_nat );
  · exact ( summable_iff_not_tendsto_nat_atTop_of_nonneg ( fun _ => abs_nonneg _ ) ) |>.2 fun h => not_tendsto_atTop_of_tendsto_nhds ( tendsto_abs_partial ) h

/-- The total absolute sum is `3`. -/
theorem tsum_abs_C32 : ∑' k, |C32 k| = 3 := collar_resummation.tsum_eq

/-
**Alternating-series value** obtained without Abel's theorem:
`∑_{k≥0} (-1)^k C(3/2,k) = 0`, i.e. the binomial series of `(1+x)^{3/2}` evaluated at `x = -1`.
-/
theorem alternating_binomial_at_neg_one :
    HasSum (fun k => (-1 : ℝ) ^ k * C32 k) 0 := by
      convert Summable.hasSum _ using 1;
      · convert tendsto_nhds_unique _ ( Summable.hasSum _ |> HasSum.tendsto_sum_nat ) using 1;
        · infer_instance;
        · have h_abs_sum : Filter.Tendsto (fun n => ∑ k ∈ Finset.range (n + 1), (-1 : ℝ) ^ k * C32 k) Filter.atTop (nhds 0) := by
            simp_rw [telescope];
            exact tendsto_zero_iff_norm_tendsto_zero.mpr ( by simpa using C12_tendsto_zero.norm );
          rwa [ ← Filter.tendsto_add_atTop_iff_nat ];
        · exact Summable.of_norm <| by simpa using collar_resummation.summable;
      · exact Summable.of_norm <| by simpa using collar_resummation.summable;

/-! ## Indicial parity -/

/-- The indicial polynomial `P_m(β) = β² − m²`. -/
def Pind (m β : ℝ) : ℝ := β ^ 2 - m ^ 2

/-
`P_m` is even in `β`.
-/
lemma Pind_even (m β : ℝ) : Pind m (-β) = Pind m β := by
  unfold Pind; ring;

/-
The minimizing indicial root `m = 1/2` gives `|P_{1/2}(±1)| = 3/4`.
-/
lemma Pind_half_one : |Pind (1 / 2) 1| = 3 / 4 := by
  unfold Pind; norm_num;

lemma Pind_half_neg_one : |Pind (1 / 2) (-1)| = 3 / 4 := by
  unfold Pind; norm_num;

/-
The indicial constant `K_ind = 1/|P_{1/2}(β)|` is identical at `β = -1` and `β = +1`,
both equal to `4/3`.
-/
theorem K_ind_neg_one_eq :
    1 / |Pind (1 / 2) (-1)| = 4 / 3 ∧ 1 / |Pind (1 / 2) (-1)| = 1 / |Pind (1 / 2) 1| := by
      norm_num [ Pind ]

end GIFT.Foundations.CollarResummation
