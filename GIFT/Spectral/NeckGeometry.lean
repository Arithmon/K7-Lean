/-
GIFT Spectral: TCS Neck Geometry
================================

Hypotheses for Twisted Connected Sum manifolds with cylindrical neck.

This module formalizes the geometric setup for TCS manifolds K = M₁ ∪_N M₂:
- Cylindrical neck N with cross-section Y and length L
- Volume normalization (H1)
- Bounded neck volume (H2)
- Product metric on neck (H3)
- Block Cheeger bounds (H4)
- Balanced blocks (H5)
- Neck minimality (H6)

These hypotheses are sufficient for the spectral bounds:
  c₁/L² ≤ λ₁(K) ≤ c₂/L²

## Axiom Classification

| Axiom | Category | Status |
|-------|----------|--------|
| `ProductNeckMetric` | C: Geometric structure | Metric hypothesis |
| `NeckMinimality` | C: Geometric structure | Isoperimetric hypothesis |
| `L₀_ge_one` | — | **ELIMINATED v3.3.39** (structure field) |
| `K7_is_TCS` | [REMOVED v4.0.12] Dead axiom, never used | Was: Existence (Kovalev 2003) |

References:
- Kovalev, A. (2003). Twisted connected sums and special Riemannian holonomy.
  Journal of Differential Geometry 64(2):169-238.
- Corti, A., Haskins, M., et al. (2015). G₂-manifolds and associative submanifolds.
  Duke Mathematical Journal 164(10):1971-2092.
- Cheeger, J. (1970). A lower bound for the smallest eigenvalue of the Laplacian.
  Proceedings of the Symposium in Pure Mathematics 36:195-199.

Version: 1.1.0 (v3.3.15: axiom classification)
-/

import GIFT.Core
import GIFT.Spectral.SpectralTheory

namespace GIFT.Spectral.NeckGeometry

open GIFT.Core
open GIFT.Spectral.SpectralTheory

/-!
## TCS Manifold Structure

A Twisted Connected Sum (TCS) manifold K = M₁ ∪_N M₂ is constructed by:
1. Two asymptotically cylindrical manifolds M₁, M₂ (the "building blocks")
2. A cylindrical neck N ≅ Y × [0, L] connecting them
3. Gluing with a twist (for G₂ holonomy)

The neck length L is the key parameter: as L → ∞, the spectral gap λ₁ → 0.
-/

-- ============================================================================
-- TCS MANIFOLD STRUCTURE
-- ============================================================================

/-- A TCS manifold structure: K = M₁ ∪_N M₂ with cylindrical neck.

The underlying CompactManifold is stored as a field, not via `extends`,
because CompactManifold is axiomatized (CLAUDE.md guideline 37).
-/
structure TCSManifold where
  /-- The underlying compact manifold -/
  toCompactManifold : CompactManifold
  /-- Neck length parameter L > 0 -/
  neckLength : ℝ
  /-- Neck length is positive -/
  neckLength_pos : neckLength > 0
  /-- Cross-section area A(Y) -/
  crossSectionArea : ℝ
  /-- Cross-section area is positive -/
  crossSectionArea_pos : crossSectionArea > 0
  /-- (H1) Volume normalization: Vol(K) = 1 -/
  volume_eq_one : toCompactManifold.volume = 1

-- ============================================================================
-- HYPOTHESIS (H2): BOUNDED NECK VOLUME
-- ============================================================================

/-- (H2) Bounded neck volume: Vol(N) ∈ [v₀, v₁] for fixed 0 < v₀ < v₁ < 1.

This ensures the neck is neither negligible nor dominant.
Physically: the throat has controlled size relative to the total volume.
-/
structure BoundedNeckVolume (K : TCSManifold) where
  /-- Lower bound on neck volume fraction -/
  v₀ : ℝ
  /-- Upper bound on neck volume fraction -/
  v₁ : ℝ
  /-- v₀ > 0 -/
  v₀_pos : 0 < v₀
  /-- v₁ < 1 (neck doesn't dominate) -/
  v₁_lt_one : v₁ < 1
  /-- v₀ < v₁ (non-trivial interval) -/
  v₀_lt_v₁ : v₀ < v₁
  /-- Actual neck volume -/
  neckVolume : ℝ
  /-- Vol(N) ≥ v₀ -/
  lower_bound : v₀ ≤ neckVolume
  /-- Vol(N) ≤ v₁ -/
  upper_bound : neckVolume ≤ v₁

-- ============================================================================
-- HYPOTHESIS (H3): PRODUCT NECK METRIC
-- ============================================================================

/-- (H3) Product metric on the neck: g|_N = dt² + g_Y.

This means the neck is geometrically a cylinder Y × [0, L].
The metric is the product of the line metric and the cross-section metric.

Axiomatized: requires differential geometry formalization.

**Former axiom, now opaque** (opaque refactoring 2026-02-09).
-/
opaque ProductNeckMetric (K : TCSManifold) : Prop

-- ============================================================================
-- HYPOTHESIS (H4): BLOCK CHEEGER BOUND
-- ============================================================================

/-- (H4) Block Cheeger bound: h(Mᵢ \ N) ≥ h₀ > 0.

This ensures each building block (without the neck) has a positive
isoperimetric constant. The blocks are "geometrically non-degenerate".
-/
structure BlockCheegerBound (K : TCSManifold) where
  /-- Minimal Cheeger constant for blocks -/
  h₀ : ℝ
  /-- h₀ is positive -/
  h₀_pos : h₀ > 0
  /-- Cheeger constant of M₁ \ N -/
  cheeger_block1 : ℝ
  /-- Cheeger constant of M₂ \ N -/
  cheeger_block2 : ℝ
  /-- h(M₁ \ N) ≥ h₀ -/
  block1_bound : cheeger_block1 ≥ h₀
  /-- h(M₂ \ N) ≥ h₀ -/
  block2_bound : cheeger_block2 ≥ h₀

-- ============================================================================
-- HYPOTHESIS (H5): BALANCED BLOCKS
-- ============================================================================

/-- (H5) Balanced blocks: Vol(Mᵢ) ∈ [1/4, 3/4].

This ensures neither block is too small or too large.
Combined with (H2), this bounds the orthogonalization correction
in the Rayleigh quotient argument.
-/
structure BalancedBlocks (K : TCSManifold) where
  /-- Volume of block M₁ (normalized) -/
  vol_M1 : ℝ
  /-- Volume of block M₂ (normalized) -/
  vol_M2 : ℝ
  /-- Vol(M₁) ≥ 1/4 -/
  M1_lower : 1/4 ≤ vol_M1
  /-- Vol(M₁) ≤ 3/4 -/
  M1_upper : vol_M1 ≤ 3/4
  /-- Vol(M₂) ≥ 1/4 -/
  M2_lower : 1/4 ≤ vol_M2
  /-- Vol(M₂) ≤ 3/4 -/
  M2_upper : vol_M2 ≤ 3/4
  /-- Volumes sum to 1 (with overlap correction) -/
  volume_sum : vol_M1 + vol_M2 ≥ 1

-- ============================================================================
-- HYPOTHESIS (H6): NECK MINIMALITY
-- ============================================================================

/-- (H6) Neck minimality: Area(Γ) ≥ Area(Y) for any separating Γ ⊂ N.

Any hypersurface in the neck that separates the two ends has area
at least as large as the cross-section Y. This follows from the
projection argument: π_Y : N → Y is 1-Lipschitz.

Axiomatized: requires measure theory on manifolds.

**Former axiom, now opaque** (opaque refactoring 2026-02-09).
-/
opaque NeckMinimality (K : TCSManifold) : Prop

-- ============================================================================
-- FULL HYPOTHESIS BUNDLE
-- ============================================================================

/-- Complete hypothesis bundle for TCS spectral bounds.

Combines all six hypotheses (H1)-(H6) into a single structure.
Note: (H1) is built into TCSManifold.volume_eq_one.
-/
structure TCSHypotheses (K : TCSManifold) where
  /-- (H2) Bounded neck volume -/
  neckVol : BoundedNeckVolume K
  /-- (H3) Product metric on neck -/
  productMetric : ProductNeckMetric K
  /-- (H4) Block Cheeger bound -/
  blockCheeger : BlockCheegerBound K
  /-- (H5) Balanced blocks -/
  balanced : BalancedBlocks K
  /-- (H6) Neck minimality -/
  neckMinimal : NeckMinimality K
  /-- (H7) Physical constraint: L₀ = 2v₀/h₀ ≥ 1.
  For typical TCS parameters (v₀ = 1/2, h₀ = 1), L₀ = 1.
  This ensures the neck is long enough for the spectral analysis to apply. -/
  neckLengthBound : 2 * neckVol.v₀ / blockCheeger.h₀ ≥ 1

-- ============================================================================
-- DERIVED QUANTITIES
-- ============================================================================

/-- Threshold neck length L₀ = 2v₀/h₀.

For L > L₀, the neck dominates the Cheeger constant:
  h(K) ≈ 2v₀/L (rather than h₀)

This is the transition point between "block-dominated" and "neck-dominated" regimes.
-/
noncomputable def L₀ (K : TCSManifold) (hyp : TCSHypotheses K) : ℝ :=
  2 * hyp.neckVol.v₀ / hyp.blockCheeger.h₀

/-- L₀ is positive -/
theorem L₀_pos (K : TCSManifold) (hyp : TCSHypotheses K) : L₀ K hyp > 0 := by
  unfold L₀
  apply div_pos
  · apply mul_pos
    · norm_num
    · exact hyp.neckVol.v₀_pos
  · exact hyp.blockCheeger.h₀_pos

/-- L₀ ≥ 1 for physical TCS manifolds.

For typical parameters (v₀ = 1/2, h₀ = 1), we have L₀ = 2v₀/h₀ = 1.

**Formerly axiom**, now theorem via TCSHypotheses.neckLengthBound field (v3.3.39). -/
theorem L₀_ge_one (K : TCSManifold) (hyp : TCSHypotheses K) : L₀ K hyp ≥ 1 := by
  unfold L₀
  exact hyp.neckLengthBound

-- ============================================================================
-- TYPICAL TCS PARAMETERS
-- ============================================================================

/-- Typical TCS parameters: v₀ = v₁ = 1/2, h₀ = 1.

For symmetric TCS constructions, this gives:
- c₁ = v₀² = 1/4
- c₂ = 16v₁/(1-v₁) = 16
- L₀ = 2v₀/h₀ = 1
-/
theorem typical_parameters :
    -- c₁ = (1/2)² = 1/4
    ((1 : ℚ) / 2) ^ 2 = 1 / 4 ∧
    -- c₂_robust = 16·(1/2)/(1-1/2) = 16
    (16 : ℚ) * (1 / 2) / (1 - 1 / 2) = 16 ∧
    -- L₀ = 2·(1/2)/1 = 1
    (2 : ℚ) * (1 / 2) / 1 = 1 := by
  native_decide

/-- For symmetric blocks, c₂ is smaller: 4v₁/(1-2v₁/3) = 3 when v₁ = 1/2 -/
theorem symmetric_block_constant :
    (4 : ℚ) * (1 / 2) / (1 - 2 * (1 / 2) / 3) = 3 := by
  native_decide

-- ============================================================================
-- CONNECTION TO K7
-- ============================================================================

-- **REMOVED v4.0.12**: `K7_is_TCS` was a dead axiom (never used in any proof).
-- It asserted `∃ (K : TCSManifold), K.toCompactManifold.dim = 7` without
-- connecting to K7. The TCS structure is already used via universally-quantified
-- axioms (spectral_upper_bound, neck_dominates, literature_package).
-- If a K7-specific TCS instance is needed later, it should be properly typed
-- as `K7_TCS : TCSManifold` with `K7_TCS.toCompactManifold = K7.g2base.base`.

-- ============================================================================
-- CERTIFICATE
-- ============================================================================

/-- NeckGeometry module certificate -/
theorem neck_geometry_certificate :
    -- Typical c₁
    ((1 : ℚ) / 2) ^ 2 = 1 / 4 ∧
    -- Typical c₂
    (16 : ℚ) * (1 / 2) / (1 - 1 / 2) = 16 ∧
    -- Typical L₀
    (2 : ℚ) * (1 / 2) / 1 = 1 ∧
    -- Symmetric c₂
    (4 : ℚ) * (1 / 2) / (1 - 2 * (1 / 2) / 3) = 3 := by
  native_decide

end GIFT.Spectral.NeckGeometry
