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
-- Result proven here (machine-checked, no sorry):
--   * `koide_lt_iff` — the exact algebraic reduction: with a = sqrt m_mu,
--     b = sqrt m_tau, Q < 2/3  <->  a^2 + b^2 + 1 < 4a + 4b + 4ab.
--   * `koideQ_gift_enclosure` — a rigorous enclosure of the assembled Koide
--     value: 0.665 < Q_gift < 0.668, from the existing 206 < 27^phi < 209 bound
--     and rational sqrt bounds.
--
-- HONEST SCOPE / open follow-on. The enclosure CONTAINS 2/3: it does not resolve
-- the sign of the gap. Numerically Q_gift = 0.66655, i.e. 0.018% BELOW 2/3 (the
-- GIFT muon 27^phi = 207.01 is 0.12% above the real 206.77; the Koide-consistent
-- muon is 206.74). Proving the strict `Q_gift < 2/3` reduces to `27^phi > 206.74`,
-- i.e. `log 3 > 1.0986` (with phi > 1.618). The inequality margin is only ~2.0 in
-- 3685 (0.054%), so a strict certificate needs 27^phi to ~5 significant figures
-- on both sides — a dedicated transcendental-bounds development. Until then the
-- honest statement is the enclosure plus the documented numerical gap.
-- See private note koide_q_assembly_verdict_2026_06_16.md.

import Mathlib
import GIFT.Foundations.GoldenRatioPowers

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

end GIFT.Relations.KoideAssembly
