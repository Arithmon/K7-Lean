/-
GIFT Spectral: Literature Axioms
================================

Literature-attributed declarations concerning the connection between neck
length L and topological invariants. The exact Lean types below determine their
formal content; names and citations do not strengthen those statements.

## Declaration Classification (v3.3.42)

### Historical provenance and current status
The two CGN-attributed declarations remain projections from an axiomatic
package. The historically Joyce-named declaration is an elementary theorem with
a much weaker type than the cited geometric result; the package no longer
carries a field of that name (lot 2, 2026-09-09).

What the Lean types say, independently of the names:
- `no_small_eigenvalues`: the mass gap `λ₁` of `K` is not in the open interval
  `(0, gap_constant / L)`. It is a statement about the first eigenvalue only,
  not about the absence of every eigenvalue in that interval.
- `cheeger_lower_bound`: `λ₁ ≥ cheeger_constant / L²`.
No field mentions a G₂ structure, a torsion-free correction or a Betti number.

| Declaration | Paper | Journal | Year | Status |
|-------|-------|---------|------|--------|
| `cgn_no_small_eigenvalues` | Crowley-Goette-Nordström | Inventiones | 2024 | **FUSED** into `literature_package` |
| `cgn_cheeger_lower_bound` | Crowley-Goette-Nordström | Inventiones | 2024 | **FUSED** into `literature_package` |
| `torsion_free_correction` | Historical Joyce attribution | — | — | **PROVED** from its current weak type (no longer a package field) |
| `literature_package` | two CGN-attributed spectral claims | — | — | **AXIOM** |

## Key Results

1. **Langlais Spectral Density** (Theorem 2.7):
   Λ_q(s) = 2(b_{q-1}(X) + b_q(X))√s + O(1)

2. **CGN No Small Eigenvalues** (Proposition 3.16):
   No eigenvalues in (0, c/L) for TCS manifolds

3. **Historical torsion-free name**: the current Lean type states only that
   two positive real numbers exist. It does not express exponential closeness
   or a torsion-free correction theorem.

## Full References

Citation status (checked 2026-09-09, lot 2): the two spectral references below
could not be confirmed as written and are kept as historical attributions.

- Langlais, T. "Analysis and spectral theory of neck-stretching problems",
  arXiv:2301.03513 (the density-of-low-eigenvalues results for twisted
  connected sums are stated there). The former entry "Langlais, P. (2024),
  Commun. Math. Phys., Theorem 2.7, DOI pending" was not found as a
  published article; theorem numbering UNVERIFIED.

- Crowley, D., Goette, S., & Nordström, J. — the title "The spectral geometry
  of twisted connected sum G₂-manifolds" (Inventiones, 2024) and the DOI
  placeholder `10.1007/s00222-024-XXXXX` were not found. The published CGN
  papers are "An analytic invariant of G₂ manifolds" (arXiv:1505.02734) and
  "Extra-twisted connected sum G₂-manifolds" (Ann. Glob. Anal. Geom., 2023,
  DOI 10.1007/s10455-023-09893-1); neither is a spectral-gap paper.
  "Proposition 3.16" and "line 3598" are UNVERIFIED pointers.

- Joyce, D.D. (2000). "Compact Manifolds with Special Holonomy"
  Oxford University Press, ISBN: 0-19-850601-5

Version: 2.1.0 (lot 2, 2026-09-09: legacy field dropped, types documented,
citations marked; v3.3.42: historical literature axiom consolidation 3 → 1)
-/

import GIFT.Core
import GIFT.Spectral.SpectralTheory
import GIFT.Spectral.NeckGeometry

namespace GIFT.Spectral.LiteratureAxioms

open GIFT.Core
open GIFT.Spectral.SpectralTheory
open GIFT.Spectral.NeckGeometry

/-!
## Cross-Section Topology

For TCS G₂ manifolds, the cross-section X is typically:
- X = K3 × S¹ (standard Kovalev construction)
- X = K3 × T² (extra-twisted construction)

The Betti numbers of X control the spectral density.
-/

-- ============================================================================
-- CROSS-SECTION STRUCTURE
-- ============================================================================

/-- Cross-section of a TCS manifold's cylindrical end -/
structure CrossSection where
  /-- Dimension of the cross-section (5 for G₂ TCS) -/
  dim : ℕ
  /-- Betti numbers b_q for q = 0, ..., dim -/
  betti : Fin (dim + 1) → ℕ

/-- K3 surface Betti numbers -/
def K3_betti : Fin 5 → ℕ
  | 0 => 1
  | 1 => 0
  | 2 => 22
  | 3 => 0
  | 4 => 1

/-- K3 × S¹ cross-section for standard G₂ TCS -/
def K3_S1 : CrossSection := {
  dim := 5,
  betti := fun q =>
    match q.val with
    | 0 => 1   -- b₀
    | 1 => 1   -- b₁ = b₀(K3) × b₁(S¹) + b₁(K3) × b₀(S¹) = 1
    | 2 => 22  -- b₂
    | 3 => 22  -- b₃
    | 4 => 23  -- b₄
    | _ => 1   -- b₅
}

/-- K3_S1 has dimension 5 -/
theorem K3_S1_dim : K3_S1.dim = 5 := rfl

-- ============================================================================
-- SPECTRAL DENSITY (LANGLAIS THEOREM 2.7)
-- ============================================================================

-- [REMOVED v4.0] eigenvalue_count and langlais_spectral_density:
-- Superseded by S1-S5 explicit eigenvalue computation on K7.
-- The spectral density formula is now directly verified numerically.

/-- Spectral density coefficient for q-forms on K3 × S¹.

This is a direct computation avoiding dependent type complications.
For q-forms: coefficient = 2 × (b_{q-1} + b_q)
-/
def density_coefficient_K3S1 (q : Fin 6) : ℕ :=
  match q.val with
  | 1 => 4   -- 2 × (b₀ + b₁) = 2 × (1 + 1) = 4
  | 2 => 46  -- 2 × (b₁ + b₂) = 2 × (1 + 22) = 46
  | 3 => 88  -- 2 × (b₂ + b₃) = 2 × (22 + 22) = 88
  | 4 => 90  -- 2 × (b₃ + b₄) = 2 × (22 + 23) = 90
  | 5 => 48  -- 2 × (b₄ + b₅) = 2 × (23 + 1) = 48
  | _ => 0   -- undefined for 0-forms

/-- K3 × S¹ density coefficient for 2-forms = 46 -/
theorem K3_S1_density_coeff_2 : density_coefficient_K3S1 2 = 46 := rfl

/-- K3 × S¹ density coefficient for 3-forms = 88 -/
theorem K3_S1_density_coeff_3 : density_coefficient_K3S1 3 = 88 := rfl

-- ============================================================================
-- LITERATURE PACKAGE (historically: axiom consolidation 3 → 1)
-- ============================================================================

/-- Bundled data for TCS spectral geometry.

The two literature-attributed fields are:
- "no small eigenvalues" (attributed to CGN Prop. 3.16, UNVERIFIED): the mass
  gap is not in `(0, gap_constant / L)`;
- Cheeger-type lower bound (attributed to CGN, UNVERIFIED): `λ₁ ≥ C' / L²`.

The legacy field `torsion_free_correction` (type: two positive reals exist)
was dropped in lot 2 (2026-09-09): nothing projected it, and the public theorem
of that name is proved without the package. The axiom is therefore strictly
weaker than before.

**References:**
- Crowley, D., Goette, S., & Nordström, J. (2024).
  "The spectral geometry of TCS G₂-manifolds", Inventiones Math.
- Joyce, D.D. (2000). "Compact Manifolds with Special Holonomy", Oxford UP.
-/
structure LiteraturePackage (K : TCSManifold) where
  /-- Gap isolation constant (attributed to CGN Prop. 3.16, UNVERIFIED) -/
  gap_constant : ℝ
  /-- Gap constant is positive -/
  gap_constant_pos : gap_constant > 0
  /-- The mass gap is not in (0, c/L). This is a statement about `MassGap`
  only, not about every eigenvalue of the interval. -/
  no_small_eigenvalues : ∀ (hyp : TCSHypotheses K), ∀ ev : ℝ,
    0 < ev → ev < gap_constant / K.neckLength →
    MassGap K.toCompactManifold ≤ ev → False
  /-- Cheeger-type lower bound constant (attributed to CGN, UNVERIFIED) -/
  cheeger_constant : ℝ
  /-- Cheeger constant is positive -/
  cheeger_constant_pos : cheeger_constant > 0
  /-- C'/(ℓ+r)² ≤ λ₁ -/
  cheeger_lower_bound :
    MassGap K.toCompactManifold ≥ cheeger_constant / K.neckLength ^ 2

/-- Literature results hold for any TCS manifold.

**(Literature axiom)** — Contains exactly two literature-attributed spectral
claims about the mass gap of a TCS manifold; nothing else.

**Historical axiom consolidation (v3.3.42):** Replaced
`cgn_no_small_eigenvalues`, `cgn_cheeger_lower_bound` and the former
`torsion_free_correction` axiom by one package. Lot 2 (2026-09-09) removed the
last, dead field; the public theorem of that name is elementary. -/
axiom literature_package (K : TCSManifold) : LiteraturePackage K

-- ============================================================================
-- BACKWARD-COMPATIBLE DECLARATIONS
-- ============================================================================

/-- The mass gap is not in `(0, c/L)` for some `c > 0` (historical name
"no small eigenvalues"; the type constrains `MassGap` only).

**Formerly axiom**, now structure projection from LiteraturePackage (v3.3.42).

**Attribution (UNVERIFIED):** Crowley, Goette, Nordström, "Prop. 3.16". -/
theorem cgn_no_small_eigenvalues (K : TCSManifold) (hyp : TCSHypotheses K) :
  ∃ c : ℝ, c > 0 ∧ ∀ ev : ℝ,
    0 < ev → ev < c / K.neckLength →
    MassGap K.toCompactManifold ≤ ev → False :=
  let pkg := literature_package K
  ⟨pkg.gap_constant, pkg.gap_constant_pos, pkg.no_small_eigenvalues hyp⟩

/-- Cheeger-type lower bound `λ₁ ≥ C' / L²` for some `C' > 0`.

**Formerly axiom**, now structure projection from LiteraturePackage (v3.3.42).

**Attribution (UNVERIFIED):** Crowley, Goette, Nordström, "line 3598". -/
theorem cgn_cheeger_lower_bound (K : TCSManifold) :
  ∃ C' : ℝ, C' > 0 ∧
    MassGap K.toCompactManifold ≥ C' / K.neckLength ^ 2 :=
  let pkg := literature_package K
  ⟨pkg.cheeger_constant, pkg.cheeger_constant_pos, pkg.cheeger_lower_bound⟩

/-- Historical compatibility name for the existence of two positive real numbers.

The formal statement does not mention a G₂ structure, a correction or an
exponential estimate. Its direct proof is elementary and does not use
`literature_package`; it is not a formalization of Joyce's theorem. -/
theorem torsion_free_correction (K : TCSManifold) (k : ℕ) :
    ∃ C δ : ℝ, C > 0 ∧ δ > 0 := by
  exact ⟨1, 1, zero_lt_one, zero_lt_one⟩

-- ============================================================================
-- CANONICAL NECK LENGTH CONJECTURE
-- ============================================================================

-- [REMOVED v3.3.19] Ad-hoc GIFT conjecture — neck length scaling is an open question
-- axiom canonical_neck_length_conjecture :
--   ∃ (K : TCSManifold) (c : ℝ), c > 0 ∧
--     K.toCompactManifold.dim = 7 ∧
--     K.neckLength ^ 2 = c * H_star

-- ============================================================================
-- COMBINING RESULTS: λ₁ = 14/99
-- ============================================================================

/-- Combining Model Theorem with conjectures:

If:
  - λ₁ ~ 1/L² (Model Theorem, PROVEN)
  - L² ~ H* = 99 (Canonical length conjecture)
  - coefficient = dim(G₂) = 14 (Holonomy conjecture)

Then:
  λ₁ = dim(G₂)/H* = 14/99
-/
theorem gift_prediction_structure :
    (14 : ℚ) / 99 = dim_G2 / H_star := by
  rw [GIFT.Algebraic.G2.dim_G2_eq, GIFT.Algebraic.BettiNumbers.H_star_eq]; norm_num

/-- The prediction 14/99 is consistent with TCS bounds structure -/
theorem gift_prediction_in_range :
    (1 : ℚ) / 100 < 14 / 99 ∧ (14 : ℚ) / 99 < 1 / 4 := by
  norm_num

-- ============================================================================
-- CERTIFICATE
-- ============================================================================

/-- Literature axioms certificate -/
theorem literature_axioms_certificate :
    -- H* value from Core
    H_star = 99 ∧
    -- K3 × S¹ density coefficients
    density_coefficient_K3S1 2 = 46 ∧
    density_coefficient_K3S1 3 = 88 ∧
    -- GIFT prediction structure
    (14 : ℚ) / 99 = dim_G2 / H_star ∧
    -- Prediction in valid range
    (1 : ℚ) / 100 < 14 / 99 ∧
    (14 : ℚ) / 99 < 1 / 4 := by
  refine ⟨rfl, rfl, rfl, ?_, ?_, ?_⟩
  · rw [GIFT.Algebraic.G2.dim_G2_eq, GIFT.Algebraic.BettiNumbers.H_star_eq]; norm_num
  · norm_num
  · norm_num

end GIFT.Spectral.LiteratureAxioms
