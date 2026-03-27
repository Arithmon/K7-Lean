-- Import all submodules
import GIFT.Algebraic.Quaternions
import GIFT.Algebraic.Octonions
import GIFT.Algebraic.CayleyDickson
import GIFT.Algebraic.G2
import GIFT.Algebraic.BettiNumbers
import GIFT.Algebraic.GIFTConstants
-- V3.2: SO(16) Decomposition
import GIFT.Algebraic.SO16Decomposition
import GIFT.Algebraic.GeometricSaturation
-- G₂ 3-form: explicit phi0 → G₂=Stab(phi0), toward Mathlib contribution
import GIFT.Algebraic.G2ThreeForm

/-!
# GIFT Algebraic Foundations (PREFERRED)

Module entry point for the octonion-based formalization.

## Status: CURRENT — Use this for new code

This module **derives** constants from mathematical structure rather than
defining them as arbitrary values. Prefer this over GIFT.Algebra/Topology.

## Comparison with Legacy Modules

| This Module | Legacy Module | Difference |
|-------------|---------------|------------|
| BettiNumbers.b2 = C(7,2) | Topology.b2 = 21 | Derived vs defined |
| G2.dim_G2 = 2 × imaginary_count | Algebra.dim_G2 = 14 | Derived vs defined |
| Octonions.imaginary_count = 7 | (none) | Foundational |

  This module formalizes the algebraic chain:
    ℍ → 𝕆 → G₂ → b₂, b₃ → GIFT constants

  The key insight is that GIFT's topological constants (b₂, b₃, H*)
  are NOT arbitrary inputs but DERIVE from the structure of octonions.

  ## Module Structure

  1. **Quaternions.lean**: K₄ ↔ ℍ correspondence
     - dim(ℍ) = 4 = |V(K₄)|
     - 3 imaginary units

  2. **Octonions.lean**: 𝕆 structure
     - dim(𝕆) = 8
     - 7 imaginary units (e₁, ..., e₇)
     - Fano plane multiplication structure

  3. **CayleyDickson.lean**: Doubling construction
     - ℝ → ℂ → ℍ → 𝕆 sequence
     - Dimension sequence 2ⁿ
     - Property loss at each level

  4. **G2.lean**: G₂ = Aut(𝕆)
     - dim(G₂) = 14 = 2 × 7
     - Connection to exceptional series

  5. **BettiNumbers.lean**: Topological invariants
     - b₂ = C(7,2) = 21 (from imaginary pairs)
     - b₃ = b₂ + fund(E₇) = 77
     - H* = b₂ + b₃ + 1 = 99

  6. **GIFTConstants.lean**: Physical predictions
     - sin²θ_W = 3/13
     - Q_Koide = 2/3
     - N_gen = 3

  ## Key Results

  The master theorem `gift_from_octonions` proves that all GIFT
  constants derive from:
  - The 7 imaginary units of 𝕆
  - The 14-dimensional automorphism group G₂

  This establishes GIFT on algebraic foundations rather than
  arbitrary topological inputs.

  ## Usage

  ```lean
  import GIFT.Algebraic

  -- Access all submodules
  open GIFT.Algebraic.Octonions
  open GIFT.Algebraic.BettiNumbers
  open GIFT.Algebraic.GIFTConstants

  -- Use the master theorem
  #check gift_from_octonions
  ```
-/

namespace GIFT.Algebraic

/-!
## Re-exports for Convenience
-/

-- Core octonion constants
export Octonions (imaginary_count octonion_dim)

-- G₂ dimension
export G2 (dim_G2 rank_G2)

-- Betti numbers (derived!)
export BettiNumbers (b2 b3 H_star fund_E7)

-- Physical constants (as integer numerator/denominator pairs)
export GIFTConstants (N_gen sin2_theta_W_num_simp sin2_theta_W_den_simp
                      Q_Koide_num_simp Q_Koide_den_simp magic_168)

-- SO(16) decomposition (V3.2)
export SO16Decomposition (dim_SO geometric_part spinorial_part
                          E8_SO16_decomposition geometric_is_SO16 spinorial_is_128)

-- Geometric saturation (V3.2)
export GeometricSaturation (tangent_rotation_dim b2_equals_dim_SO7 saturation_ratio)

/-!
## Summary Theorems
-/

/-- All Betti numbers derive from octonions -/
theorem betti_derivation :
    BettiNumbers.b2 = Nat.choose Octonions.imaginary_count 2 ∧
    BettiNumbers.b3 = BettiNumbers.b2 + BettiNumbers.fund_E7 ∧
    BettiNumbers.H_star = BettiNumbers.b2 + BettiNumbers.b3 + 1 :=
  ⟨rfl, rfl, rfl⟩

/-- Physical predictions from algebraic structure -/
theorem physical_predictions :
    -- sin²θ_W = 3/13 (as fraction)
    GIFTConstants.sin2_theta_W_num_simp = 3 ∧
    GIFTConstants.sin2_theta_W_den_simp = 13 ∧
    -- Q_Koide = 2/3 (as fraction)
    GIFTConstants.Q_Koide_num_simp = 2 ∧
    GIFTConstants.Q_Koide_den_simp = 3 ∧
    -- N_gen = 3
    GIFTConstants.N_gen = 3 :=
  ⟨rfl, rfl, rfl, rfl, rfl⟩

/-- Cross-multiplication verification for sin²θ_W = 3/13 -/
theorem sin2_theta_W_verified : 21 * 13 = 3 * 91 :=
  GIFTConstants.sin2_theta_W_simplified

/-- Cross-multiplication verification for Q_Koide = 2/3 -/
theorem Q_Koide_verified : 14 * 3 = 2 * 21 :=
  GIFTConstants.Q_Koide_simplified

end GIFT.Algebraic
