-- GIFT Relations: Koide assembly from the lepton mass formulas
--
-- Core proves the topological identity dim_G2/b2 = 2/3 and *asserts* it is the
-- Koide parameter (see Relations.koide_certified, AbsoluteMasses.koide_from_G2_b2).
-- It never assembles the *physical* Koide combination
--
--     Q = (m_e + m_mu + m_tau) / (sqrt m_e + sqrt m_mu + sqrt m_tau)^2
--
-- from the GIFT mass ratios. This module does. Normalising m_e = 1 (Koide is
-- scale-invariant), the two GIFT ratios are
--     m_mu/m_e = 27^phi   (jordan_power_phi, GoldenRatioPowers)
--     m_tau/m_e = 3477     (AbsoluteMasses.m_tau_m_e_formula)
--
-- Results proven here (machine-checked, no sorry):
--   * `koide_lt_iff` — the exact algebraic reduction: with a = sqrt m_mu,
--     b = sqrt m_tau, Q < 2/3  <->  a^2 + b^2 + 1 < 4a + 4b + 4ab.
--   * `koideQ_gift_enclosure` — a rigorous enclosure of the assembled Koide
--     value: 0.665 < Q_gift < 0.668, from the existing 206 < 27^phi < 209 bound
--     and rational sqrt bounds.
--   * `koideQ_gift_lt_two_thirds` — the STRICT sign of the gap: Q_gift < 2/3.
--
-- HONEST READING. Numerically Q_gift = 0.66655, i.e. 0.018% BELOW 2/3 (the GIFT
-- muon 27^phi = 207.01 is 0.12% above the real 206.77; the Koide-consistent muon
-- is 206.74). The strict bound is genuine but DEFLATIONARY: it certifies that
-- GIFT's own mass formulas do NOT close Koide at 2/3 — the topological value 2/3
-- holds for the REAL masses, not for GIFT's predictions. Earning the rebate
-- sub-claim R1c would require Q_gift = 2/3, which is false. The inequality margin
-- is only ~0.96 in 3686 (0.026%), so the strict proof pins 27^phi from below to
-- ~5 significant figures (log 3 > 1.0986, from exp(1.0986) < 3 via a degree-6
-- Taylor bound) in the `Strict separation` section below.
-- See private note koide_q_assembly_verdict_2026_06_16.md.

import Mathlib
import GIFT.Foundations.GoldenRatioPowers
import GIFT.Foundations.NumericalBounds

namespace GIFT.Relations.KoideAssembly

open Real GIFT.Foundations.GoldenRatioPowers

/-- Physical Koide ratio with m_e = 1 (scale-invariant). -/
noncomputable def koideQ (mmu mtau : ℝ) : ℝ :=
  (1 + mmu + mtau) / (1 + Real.sqrt mmu + Real.sqrt mtau) ^ 2

/-- Exact algebraic reduction. With a = sqrt(m_mu), b = sqrt(m_tau) (so the
    masses are a^2, b^2), Koide Q < 2/3 iff a^2 + b^2 + 1 < 4a + 4b + 4ab. -/
theorem koide_lt_iff (a b : ℝ) (hden : 0 < 1 + a + b) :
    (1 + a ^ 2 + b ^ 2) / (1 + a + b) ^ 2 < 2 / 3
      ↔ a ^ 2 + b ^ 2 + 1 < 4 * a + 4 * b + 4 * a * b := by
  rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
  constructor <;> intro h <;> nlinarith [h]

/-- sqrt(3477) enclosure: 58.96 < sqrt 3477 < 58.97. -/
theorem sqrt_3477_bounds :
    (5896 : ℝ) / 100 < Real.sqrt 3477 ∧ Real.sqrt 3477 < (5897 : ℝ) / 100 := by
  constructor
  · rw [show (5896 : ℝ) / 100 = Real.sqrt (((5896 : ℝ) / 100) ^ 2) from
        (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_lt_sqrt (by positivity) (by norm_num)
  · rw [show (5897 : ℝ) / 100 = Real.sqrt (((5897 : ℝ) / 100) ^ 2) from
        (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)

/-- sqrt(27^phi) enclosure from 206 < 27^phi < 209: 14.35 < sqrt(27^phi) < 14.46. -/
theorem sqrt_jordan_bounds :
    (1435 : ℝ) / 100 < Real.sqrt jordan_power_phi
      ∧ Real.sqrt jordan_power_phi < (1446 : ℝ) / 100 := by
  have ⟨hlo, hhi⟩ := jordan_power_phi_bounds
  constructor
  · rw [show (1435 : ℝ) / 100 = Real.sqrt (((1435 : ℝ) / 100) ^ 2) from
        (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_lt_sqrt (by positivity) (by nlinarith)
  · rw [show (1446 : ℝ) / 100 = Real.sqrt (((1446 : ℝ) / 100) ^ 2) from
        (Real.sqrt_sq (by norm_num)).symm]
    exact Real.sqrt_lt_sqrt (le_of_lt jordan_power_phi_pos) (by nlinarith)

/-- Rigorous enclosure of the assembled GIFT Koide value:
    0.665 < koideQ(27^phi, 3477) < 0.668.

    NOTE: this band contains 2/3 = 0.6667. It establishes the formal assembly but
    does not resolve the 0.018% gap (Q_gift = 0.66655 < 2/3). See module header. -/
theorem koideQ_gift_enclosure :
    (665 : ℝ) / 1000 < koideQ jordan_power_phi 3477
      ∧ koideQ jordan_power_phi 3477 < (668 : ℝ) / 1000 := by
  unfold koideQ
  have ⟨hmlo, hmhi⟩ := jordan_power_phi_bounds          -- 206 < 27^phi < 209
  have ⟨hslo, hshi⟩ := sqrt_jordan_bounds               -- 14.35 < sqrt(27^phi) < 14.46
  have ⟨htlo, hthi⟩ := sqrt_3477_bounds                 -- 58.96 < sqrt 3477 < 58.97
  have hsnn : 0 ≤ Real.sqrt jordan_power_phi := Real.sqrt_nonneg _
  have htnn : 0 ≤ Real.sqrt 3477 := Real.sqrt_nonneg _
  -- denominator base D0 = 1 + sqrt(27^phi) + sqrt 3477 ∈ (74.31, 74.43)
  set D0 := 1 + Real.sqrt jordan_power_phi + Real.sqrt 3477 with hD0
  have hD0lo : (7431 : ℝ) / 100 < D0 := by rw [hD0]; linarith
  have hD0hi : D0 < (7443 : ℝ) / 100 := by rw [hD0]; linarith
  have hD0pos : 0 < D0 := by linarith
  have hDsq_pos : 0 < D0 ^ 2 := by positivity
  constructor
  · -- lower: N / D^2 > 0.665, i.e. N > 0.665 * D^2
    rw [lt_div_iff₀ hDsq_pos]
    have hDsq_hi : D0 ^ 2 < ((7443 : ℝ) / 100) ^ 2 := by nlinarith
    nlinarith [hmlo, hDsq_hi]
  · -- upper: N / D^2 < 0.668, i.e. N < 0.668 * D^2
    rw [div_lt_iff₀ hDsq_pos]
    have hDsq_lo : ((7431 : ℝ) / 100) ^ 2 < D0 ^ 2 := by nlinarith
    nlinarith [hmhi, hDsq_lo]

/-!
## Strict separation: koideQ_gift < 2/3 (machine-checked)

The enclosure above contains 2/3. This section proves the SIGN of the gap:
the GIFT-assembled Koide value is strictly below 2/3. Via `koide_lt_iff` with
a = sqrt(27^phi), b = sqrt(3477), the goal reduces to a^2 + b^2 + 1 < 4a+4b+4ab,
which (since the inequality margin is only ~0.96 in ~3686) needs 27^phi pinned
from below to ~5 significant figures: 27^phi > 206.9. That in turn needs
log 3 > 1.0986 (tighter than the 1.098 in NumericalBounds), obtained from
exp(1.0986) < 3 via a degree-6 Taylor bound. All constants verified exactly.
-/

/-- Degree-6 Taylor upper bound: exp(0.5493) < 1.73205. -/
theorem exp_05493_lt : Real.exp ((5493 : ℝ) / 10000) < (173205 : ℝ) / 100000 := by
  have hx : |((5493 : ℝ) / 10000)| ≤ 1 := by norm_num
  have hn : (0 : ℕ) < 6 := by norm_num
  have hbound := Real.exp_bound hx hn
  have hsum : (Finset.range 6).sum (fun m => ((5493 : ℝ)/10000)^m / ↑(m.factorial))
      = 1 + 5493/10000 + (5493/10000)^2/2 + (5493/10000)^3/6
        + (5493/10000)^4/24 + (5493/10000)^5/120 := by
    simp only [Finset.sum_range_succ, Finset.range_zero, Finset.sum_empty,
               Nat.factorial, Nat.cast_one, pow_zero, pow_one]
    ring
  have herr_eq : |((5493 : ℝ)/10000)|^6 * (↑(Nat.succ 6) / (↑(Nat.factorial 6) * 6))
      = (5493/10000)^6 * (7 / 4320) := by
    simp only [Nat.factorial, Nat.succ_eq_add_one]; norm_num
  have hval : 1 + 5493/10000 + (5493/10000)^2/2 + (5493/10000)^3/6
      + (5493/10000)^4/24 + (5493/10000)^5/120 + (5493/10000)^6 * (7/4320)
      < (173205 : ℝ) / 100000 := by norm_num
  have h := abs_sub_le_iff.mp hbound
  have hupper : Real.exp (5493/10000)
      ≤ (Finset.range 6).sum (fun m => ((5493 : ℝ)/10000)^m / ↑(m.factorial))
        + |((5493 : ℝ)/10000)|^6 * (↑(Nat.succ 6) / (↑(Nat.factorial 6) * 6)) := by
    linarith [h.1]
  calc Real.exp (5493/10000)
      ≤ (Finset.range 6).sum (fun m => ((5493 : ℝ)/10000)^m / ↑(m.factorial))
        + |((5493 : ℝ)/10000)|^6 * (↑(Nat.succ 6) / (↑(Nat.factorial 6) * 6)) := hupper
    _ = 1 + 5493/10000 + (5493/10000)^2/2 + (5493/10000)^3/6
        + (5493/10000)^4/24 + (5493/10000)^5/120 + (5493/10000)^6 * (7/4320) := by
        rw [hsum, herr_eq]
    _ < 173205/100000 := hval

/-- exp(1.0986) < 3 (square of the previous bound). -/
theorem exp_10986_lt_3 : Real.exp ((10986 : ℝ) / 10000) < 3 := by
  have h := exp_05493_lt
  have hsq : (173205 : ℝ)/100000 * (173205/100000) < 3 := by norm_num
  calc Real.exp (10986/10000)
      = Real.exp (5493/10000 + 5493/10000) := by ring_nf
    _ = Real.exp (5493/10000) * Real.exp (5493/10000) := by rw [Real.exp_add]
    _ < (173205/100000) * (173205/100000) := by
        nlinarith [Real.exp_pos (5493/10000 : ℝ), h]
    _ < 3 := hsq

/-- log 3 > 1.0986. -/
theorem log_three_gt_10986 : (10986 : ℝ) / 10000 < Real.log 3 := by
  rw [← Real.exp_lt_exp, Real.exp_log (by norm_num : (0 : ℝ) < 3)]
  exact exp_10986_lt_3

/-- log 27 = 3 log 3 > 3.2958. -/
theorem log_27_gt_32958 : (32958 : ℝ) / 10000 < Real.log 27 := by
  rw [GIFT.Foundations.NumericalBounds.log_27_eq]
  have := log_three_gt_10986
  linarith

/-- exp(5.3326044) > 206.9, via exp(5) * exp(0.3326044). -/
theorem exp_arg_gt_2069 :
    (2069 : ℝ) / 10 < Real.exp ((53326044 : ℝ) / 10000000) := by
  have he := Real.exp_one_gt_d9
  have he_bound : (271828 : ℝ)/100000 < Real.exp 1 := by linarith
  -- exp(0.3326044) > 1.39459 by Taylor lower bound (range 6)
  have hr : (139459 : ℝ)/100000 < Real.exp ((3326044 : ℝ)/10000000) := by
    have hpos : (0 : ℝ) ≤ 3326044/10000000 := by norm_num
    have hsum : (Finset.range 6).sum (fun m => ((3326044 : ℝ)/10000000)^m / ↑(m.factorial))
        = 1 + 3326044/10000000 + (3326044/10000000)^2/2 + (3326044/10000000)^3/6
          + (3326044/10000000)^4/24 + (3326044/10000000)^5/120 := by
      simp only [Finset.sum_range_succ, Finset.range_zero, Finset.sum_empty,
                 Nat.factorial, Nat.cast_one, pow_zero, pow_one]
      ring
    have hval : (139459 : ℝ)/100000 < 1 + 3326044/10000000 + (3326044/10000000)^2/2
        + (3326044/10000000)^3/6 + (3326044/10000000)^4/24 + (3326044/10000000)^5/120 := by
      norm_num
    calc (139459 : ℝ)/100000
        < 1 + 3326044/10000000 + (3326044/10000000)^2/2 + (3326044/10000000)^3/6
          + (3326044/10000000)^4/24 + (3326044/10000000)^5/120 := hval
      _ = (Finset.range 6).sum (fun m => ((3326044 : ℝ)/10000000)^m / ↑(m.factorial)) := hsum.symm
      _ ≤ Real.exp (3326044/10000000) := Real.sum_le_exp_of_nonneg hpos 6
  -- exp(5) = exp(1)^5 > 2.71828^5
  have hexp5 : ((271828 : ℝ)/100000)^5 < Real.exp 5 := by
    have h1 : (Real.exp 1)^5 = Real.exp 5 := by rw [← Real.exp_nat_mul]; norm_num
    calc ((271828 : ℝ)/100000)^5
        < (Real.exp 1)^5 := by gcongr
      _ = Real.exp 5 := h1
  have hprod : (2069 : ℝ)/10 < ((271828 : ℝ)/100000)^5 * (139459/100000) := by norm_num
  have hmul : ((271828 : ℝ)/100000)^5 * (139459/100000)
      < Real.exp 5 * Real.exp (3326044/10000000) :=
    mul_lt_mul hexp5 (le_of_lt hr) (by positivity) (le_of_lt (Real.exp_pos 5))
  calc (2069 : ℝ)/10
      < ((271828 : ℝ)/100000)^5 * (139459/100000) := hprod
    _ < Real.exp 5 * Real.exp (3326044/10000000) := hmul
    _ = Real.exp (5 + 3326044/10000000) := by rw [← Real.exp_add]
    _ = Real.exp (53326044/10000000) := by norm_num

/-- The binding bound: 27^phi > 206.9. -/
theorem jordan_power_phi_gt_2069 : (2069 : ℝ) / 10 < jordan_power_phi := by
  have hphi_lo := GIFT.Foundations.NumericalBounds.phi_gt_1618
  have h27 : (1 : ℝ) < 27 := by norm_num
  have h1618 : (2069 : ℝ)/10 < (27 : ℝ) ^ ((1618 : ℝ)/1000) := by
    rw [Real.rpow_def_of_pos (by norm_num : (0 : ℝ) < 27)]
    have harg : (53326044 : ℝ)/10000000 < Real.log 27 * ((1618 : ℝ)/1000) := by
      nlinarith [log_27_gt_32958]
    calc (2069 : ℝ)/10
        < Real.exp (53326044/10000000) := exp_arg_gt_2069
      _ ≤ Real.exp (Real.log 27 * (1618/1000)) := by
          apply Real.exp_le_exp.mpr; linarith [harg]
  unfold jordan_power_phi
  calc (2069 : ℝ)/10
      < (27 : ℝ) ^ ((1618 : ℝ)/1000) := h1618
    _ < (27 : ℝ) ^ GIFT.Foundations.GoldenRatio.phi :=
        Real.rpow_lt_rpow_of_exponent_lt h27 hphi_lo

/-- sqrt(27^phi) > 14.384 (from 27^phi > 206.9). -/
theorem sqrt_jordan_gt_14384 : (14384 : ℝ)/1000 < Real.sqrt jordan_power_phi := by
  rw [show (14384 : ℝ)/1000 = Real.sqrt (((14384 : ℝ)/1000)^2) from
      (Real.sqrt_sq (by norm_num)).symm]
  exact Real.sqrt_lt_sqrt (by positivity) (by nlinarith [jordan_power_phi_gt_2069])

/-- STRICT RESULT: the GIFT-assembled Koide value is below 2/3.

    Q_gift = koideQ(27^phi, 3477) < 2/3. Numerically 0.66655 < 0.66667 (0.018%
    below). This is the machine-checked sign of the gap the enclosure left open. -/
theorem koideQ_gift_lt_two_thirds : koideQ jordan_power_phi 3477 < 2 / 3 := by
  have hmu_nn : 0 ≤ jordan_power_phi := le_of_lt jordan_power_phi_pos
  have ha2 : Real.sqrt jordan_power_phi ^ 2 = jordan_power_phi := Real.sq_sqrt hmu_nn
  have hb2 : Real.sqrt 3477 ^ 2 = (3477 : ℝ) := Real.sq_sqrt (by norm_num)
  have hann : 0 ≤ Real.sqrt jordan_power_phi := Real.sqrt_nonneg _
  have hbnn : 0 ≤ Real.sqrt 3477 := Real.sqrt_nonneg _
  have hco : koideQ jordan_power_phi 3477
      = (1 + Real.sqrt jordan_power_phi ^ 2 + Real.sqrt 3477 ^ 2)
        / (1 + Real.sqrt jordan_power_phi + Real.sqrt 3477) ^ 2 := by
    rw [koideQ, ha2, hb2]
  rw [hco, koide_lt_iff _ _ (by positivity)]
  -- goal: a^2 + b^2 + 1 < 4a + 4b + 4ab, with a = sqrt(27^phi), b = sqrt 3477
  have ha_lo := sqrt_jordan_gt_14384
  have ha_hi := sqrt_jordan_bounds.2
  have hb_lo := sqrt_3477_bounds.1
  have hb_hi := sqrt_3477_bounds.2
  nlinarith [ha_lo, ha_hi, hb_lo, hb_hi, hann, hbnn,
             mul_pos (sub_pos.mpr ha_lo) (sub_pos.mpr hb_lo),
             mul_pos (sub_pos.mpr ha_lo) (sub_pos.mpr ha_hi),
             mul_pos (sub_pos.mpr hb_lo) (sub_pos.mpr hb_hi)]

end GIFT.Relations.KoideAssembly
