/-
  GIFT Foundations: Lean certificate for the closed-form K3 Calabi-Yau
  residual on the Z_2^3-equivariant K3 surface X = V(Q_1, Q_2, Q_3) ⊂ P^5.

  The surface carries an explicit closed-form Kähler ansatz

      K = log ρ + φ_2 + φ_3 ,   667 real parameters
          (10 ρ-block  +  97 deg-2  +  560 deg-3),

  frozen as the reproducible witness `k3_closedform_witness_v1.npz`.
  The quality functional is

      R = detG · |Ω|² ,

  where detG is the determinant of the induced 2×2 tangent metric and |Ω|²
  the holomorphic-volume normalisation; a perfect Ricci-flat metric gives
  log R constant on X, so Var(log R) measures the residual deviation.

  CERTIFIED BOUNDS (ℕ num/den, all `native_decide`):

      box-local order-3 (r=10⁻⁸, full witness) : ε₃' = 1321/10⁷ ≈ 1.321·10⁻⁴
      order-2 (φ₃ ≡ 0)                          : ε₂   = 3842771/10⁷ ≈ 0.384

  on n_valid = 4000 Krawczyk-certified boxes B_n of radius r = 10⁻⁸ on the
  QR-free coordinates.  The target ε < 10⁻³ is met with safety ×7.57.

  Box-local interpretation.
  -------------------------
  The certificate is stated on a frozen family of Krawczyk-certified boxes
  of radius r = 10⁻⁸ (six orders above float-double precision and four
  orders above the previous pointwise baseline at r = 10⁻¹²). The forward
  enclosure of log R on each B_n is the interval [L_n^lo, L_n^hi]; the
  certified variance bound holds uniformly in the enclosure :
  Var_{1 ≤ n ≤ 4000}(ℓ_n) ≤ ε₃' for any choice ℓ_n ∈ [L_n^lo, L_n^hi],
  including ℓ_n = log R(z) at any z ∈ B_n ⊂ X (a uniform bound on log R
  over an explicit union of 4000 open boxes of X, not a point-sample
  statistic).

  Lean-recomputed variance aggregate.
  -----------------------------------
  Rather than trusting a pre-digested scalar bound emitted by Python's
  interval-arithmetic variance routine, the auto-generated companion
  module `K3ClosedFormBoxEnclosures` carries the 4000 per-box rational
  enclosures `(L_n^lo, L_n^hi)` as `Int` literals (common denominator
  D = 10¹⁰, outward-rounded from the `mpmath.iv` enclosure) together
  with a single rational centring constant c, and proves the envelope
  inequality

      Var(ℓ) ≤ (1/(N-1)) Σ_n max((L_n^lo - c)², (L_n^hi - c)²) ≤ ε₃'

  by `native_decide` on the integer aggregate (minimiser inequality, no
  interval-arithmetic library to formalise — see
  `K3ClosedFormBoxEnclosures.variance_envelope_bound`).  The Lean-
  recomputed envelope bound is ε₃' = 1321/10⁷ ≈ 1.321·10⁻⁴, slightly
  TIGHTER than the 1331/10⁷ obtained from Python's interval-mean
  propagation (the envelope chooses an optimal c close to the mean of
  midpoints and avoids the interval-mean dependency overhead).  Safety
  factor ×7.57 under the 10⁻³ target (vs ×7.51 for the Python-emitted
  bound).  Trust boundary : Python is consulted only for the per-box
  `mpmath.iv` interval enclosures of log R; all variance aggregation is
  Lean-`native_decide` on rationals.

  Scope.  ε₃' < 10⁻³ does NOT promote to a bound over the whole compact
  K3 (the 4000 boxes cover ≪ 1 of the K3 volume); that promotion is a
  global-positivity (Positivstellensatz/SOS) problem mapped in §9 of the
  companion paper.

  **Numerically verified** — private/canonical/results/
    phase_iii3_interval_metric_box_local_r1e-8.json   (box-local
       production at r = 10⁻⁸, N=4000, 4000/4000 certified, all float-in,
       var ∈ [1.288e-4, 1.331e-4])
    phase_iii3_interval_metric_pilot.json             (pointwise baseline
       at r=10⁻¹², 1309/10⁷ — superseded by box-local)
    phase_iii3_interval_residual.json                 (δ-bracketed
       baseline, historical)
  **Why bracketed**: ε₃'/ε₂ are the interval-rigorous Var upper endpoints
  at the frozen explicit 667-param witness on the fixed Krawczyk boxes.

  All theorems are ℕ arithmetic, verifiable by `native_decide`; no new axiom.
  Pattern: GIFT.Foundations.NewtonKantorovich.
-/

import GIFT.Core
import GIFT.Foundations.K3ClosedFormBoxEnclosures

namespace GIFT.Foundations.K3ClosedFormWitness

/-! ### Frozen witness scalars -/

/-- Number of closed-form parameters: 10 ρ-block + 97 deg-2 + 560 deg-3. -/
def n_params : ℕ := 667

/-- ρ-block / φ₂ / φ₃ split. -/
def n_rho : ℕ := 10
def n_phi2 : ℕ := 97
def n_phi3 : ℕ := 560

theorem n_params_split : n_rho + n_phi2 + n_phi3 = n_params := by native_decide

/-- Valid test points in the frozen (seed-fixed) independent sample. -/
def n_valid : ℕ := 4000

/-! ### Certified residual bounds (interval-rigorous, δ-eliminated) -/

/-- Box-local order-3 closed-form CY residual upper bound numerator
    (Lean-recomputed envelope bound).
    Var_{1≤n≤4000}(ℓ_n) ≤ ε₃' = 1321 / 10⁷ ≈ 1.321·10⁻⁴,
    uniformly in the choice ℓ_n ∈ [L_n^lo, L_n^hi] of the forward-interval
    enclosure of log R over each Krawczyk-certified box B_n of radius 10⁻⁸,
    recomputed in Lean from the 4000 per-box rational endpoints by
    `K3ClosedFormBoxEnclosures.variance_envelope_bound`.

**Numerically verified**
Verified: phase_iii3_emit_lean_box_enclosures.py (box-local production at
r=10⁻⁸, N=4000, 4000/4000 Krawczyk-certified, all float-in,
envelope bound S/((N-1)D²) ≈ 1.320·10⁻⁴ tidied to 1321/10⁷).
**Why bracketed**: interval-rigorous Var upper endpoint, recomputed in
Lean from the 4000 per-box rational enclosures (no scalar dependency on
Python's interval-mean propagation).
**Elimination path**: whole-K3 global bound (constraint-aware
Positivstellensatz/SOS), research-level, mapped. -/
def eps3_num : ℕ := 1321

/-- order-3 residual bound denominator = 10⁷. -/
def eps3_den : ℕ := 10000000

/-- Krawczyk box radius numerator (r = 1 / 10⁸). -/
def krawczyk_radius_num : ℕ := 1

/-- Krawczyk box radius denominator. The 4000 boxes B_n have half-width
    10⁻⁸ on each QR-free real coordinate (5 frozen by QR-pivot), six orders
    above float-double precision and four orders above the previous
    pointwise baseline r = 10⁻¹². -/
def krawczyk_radius_den : ℕ := 100000000

/-- order-2 truncation (φ₃ ≡ 0) residual numerator.
    ε₂ = 3842771 / 10⁷ ≈ 0.384.  Truncating φ₃ from a ρ+φ₂+φ₃ co-optimised
    fit pushes the residual ~3 orders worse — φ₃ is structurally required,
    not cosmetic (honest contrast, NOT a standalone order-2 quality bound).

**Numerically verified**
Verified: phase_iii3_interval_residual.py (same interval aggregation). -/
def eps2_num : ℕ := 3842771

/-- order-2 truncation residual denominator = 10⁷. -/
def eps2_den : ℕ := 10000000

/-- Completeness target II.1: residual < 10⁻³. -/
def target_num : ℕ := 1
def target_den : ℕ := 1000

/-! ### Theorems (all `native_decide`) -/

/-- II.1 achieved: ε₃ < 10⁻³  (cross-multiplied: ε₃_num·target_den
    < target_num·ε₃_den). -/
theorem cy_order3_below_target :
    eps3_num * target_den < target_num * eps3_den := by native_decide

/-- Tighter: ε₃ < 2·10⁻⁴. -/
theorem cy_order3_margin : eps3_num * 10000 < 2 * eps3_den := by native_decide

/-- Safety margin: target / ε₃ > 7  (cross-multiplied to avoid integer
    division; the true ratio is ≈ 7.64). -/
theorem cy_order3_safety_margin :
    target_num * eps3_den > 7 * eps3_num * target_den := by native_decide

/-- Sharper safety: target / ε₃' > 7.5  (×10 cross-multiplied; Lean-
    recomputed envelope ratio ≈ 7.57 at r = 10⁻⁸; the Python-emitted
    bound 1331/10⁷ gives ≈ 7.51, the pointwise baseline 1309/10⁷ at
    r = 10⁻¹² gives ≈ 7.64). -/
theorem cy_order3_safety_margin_sharp :
    10 * target_num * eps3_den > 75 * eps3_num * target_den := by native_decide

/-- Krawczyk radius is well-formed (0 < 1/10⁸ < 1). -/
theorem krawczyk_radius_positive :
    0 < krawczyk_radius_num ∧ krawczyk_radius_num < krawczyk_radius_den := by
  native_decide

/-- The ε₃' exposed here is exactly the β bound proved by the Lean-
    recomputed envelope variance
    (`K3ClosedFormBoxEnclosures.variance_envelope_bound`). -/
theorem eps3_agrees_with_variance_envelope :
    (eps3_num : Int) = GIFT.Foundations.K3ClosedFormBoxEnclosures.beta_num ∧
    (eps3_den : Int) = GIFT.Foundations.K3ClosedFormBoxEnclosures.beta_den := by
  refine ⟨?_, ?_⟩ <;> rfl

/-- φ₃ is essential: the order-3 bound is far tighter than the order-2
    truncation (ε₃ ≪ ε₂, fraction comparison, same denominator). -/
theorem cy_order3_tighter_than_order2 :
    eps3_num * eps2_den < eps2_num * eps3_den := by native_decide

/-- φ₃ essential, quantified: the order-2 truncation sits above 100× the
    target (ε₂ > 100·10⁻³ = 0.1). -/
theorem cy_order2_trunc_far_above_target :
    eps2_num * target_den > 100 * target_num * eps2_den := by native_decide

/-! ### Aggregate certificate -/

/-- Bundled witness certificate. -/
structure ClosedFormCertificate where
  /-- closed-form parameter count -/
  params : ℕ
  /-- valid test points -/
  valid : ℕ
  /-- order-3 residual numerator -/
  e3_num : ℕ
  /-- order-3 residual denominator -/
  e3_den : ℕ
  /-- order-2 truncation residual numerator -/
  e2_num : ℕ
  /-- order-2 truncation residual denominator -/
  e2_den : ℕ
  /-- II.1 target met: ε₃ < 10⁻³ -/
  below_target : e3_num * 1000 < e3_den
  /-- φ₃ essential: ε₃ ≪ ε₂ -/
  phi3_essential : e3_num * e2_den < e2_num * e3_den

/-- The GIFT closed-form K3 witness certificate (Lean-recomputed
    envelope, r = 10⁻⁸). -/
def k3_closed_form_witness : ClosedFormCertificate where
  params := 667
  valid := 4000
  e3_num := 1321
  e3_den := 10000000
  e2_num := 3842771
  e2_den := 10000000
  below_target := by native_decide
  phi3_essential := by native_decide

theorem k3_closed_form_witness_params :
    k3_closed_form_witness.params = 667 := rfl

theorem k3_closed_form_witness_valid :
    k3_closed_form_witness.valid = 4000 := rfl

/-- Master certificate: every structural fact at once (box-local r = 10⁻⁸). -/
theorem k3_closed_form_witness_certificate :
    (n_rho + n_phi2 + n_phi3 = n_params) ∧
    (eps3_num * target_den < target_num * eps3_den) ∧
    (eps3_num * 10000 < 2 * eps3_den) ∧
    (target_num * eps3_den > 7 * eps3_num * target_den) ∧
    (eps3_num * eps2_den < eps2_num * eps3_den) ∧
    (eps2_num * target_den > 100 * target_num * eps2_den) ∧
    (0 < krawczyk_radius_num ∧ krawczyk_radius_num < krawczyk_radius_den) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  all_goals native_decide

/-- Human-readable status. -/
def k3ClosedFormWitnessStatus : String :=
  "Closed-form K3 CY residual (D.9b order-3, 667 params, N=4000 boxes): " ++
  "Var(ℓ_n) ≤ ε₃' = 1321/10⁷ ≈ 1.321e-4 < 1e-3 (II.1 met, safety ×7.57) " ++
  "uniformly in ℓ_n ∈ [L_n^lo, L_n^hi] (forward-interval enclosure of " ++
  "log R on each Krawczyk-certified box B_n of radius r = 10⁻⁸); " ++
  "Box-local at r = 10⁻⁸ with Lean-recomputed envelope " ++
  "aggregate from the 4000 per-box rational endpoints (see " ++
  "K3ClosedFormBoxEnclosures.variance_envelope_bound); order-2 trunc " ++
  "ε₂ ≈ 0.384 (φ₃ essential)."

theorem k3ClosedFormWitnessStatus_nonempty :
    k3ClosedFormWitnessStatus.length > 0 := by native_decide

end GIFT.Foundations.K3ClosedFormWitness
