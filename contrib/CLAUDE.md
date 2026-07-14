# CLAUDE.md - Development Guide for GIFT Core

> **Persistent context**: Read `../.claude-persistent-context.md` at session start for cross-session memory (key insights, ongoing experiments, decisions).

This file contains development conventions and lessons learned to avoid repeating past mistakes.

---

## ⚠️ PRIORITY: Academic Terminology

**Before writing or modifying code, ensure all comments, docstrings, and documentation use standard academic mathematical vocabulary.**

If you encounter internal jargon (e.g., "B1-B5", "Tier 1/2", "A1-A12"), **rename it immediately** to standard terminology:

| Internal Jargon | Standard Academic Term |
|-----------------|------------------------|
| B1, B2, B3... | Descriptive names: "Cross product bilinearity", "Lagrange identity" |
| Tier 1, Tier 2 | "E₈ root system properties", "G₂ cross product properties" |
| A1-A12 | "Root enumeration", "Basis orthonormality", "Inner product formula" |

See **Terminology Standards** section below for complete reference.

---

## Project Structure

```
Arithmon/K7-Lean/
├── GIFT.lean               # Main entry point (root-level, Lean 4 standard)
├── GIFT/                   # Lean 4 formal proofs (140 files)
│   ├── Core.lean           # Source of truth for constants
│   ├── Certificate/        # Modular certificate system
│   │   ├── Core.lean       # Master: Foundations ∧ Predictions ∧ Spectral
│   │   ├── Foundations.lean # E₈, G₂, octonions, K₇, Joyce
│   │   ├── Predictions.lean # 33+ published relations, observables
│   │   └── Spectral.lean   # Mass gap 14/99, TCS, selection
│   ├── Foundations/         # Mathematical foundations
│   ├── Geometry/            # Axiom-free DG infrastructure
│   ├── Spectral/            # Spectral gap theory
│   ├── Relations/           # Physical predictions (22 files)
│   └── ...
├── GIFTTest/               # Lean test files (Aristotle tests)
├── lakefile.lean           # Lake build config (Lean 4 standard)
├── lean-toolchain          # leanprover/lean4:v4.27.0
├── lake-manifest.json      # Dependency lock file
│
├── contrib/                # Non-Lean assets
│   ├── python/             # Python package (giftpy on PyPI)
│   │   ├── gift_core/      # Certified constants export
│   │   └── pyproject.toml
│   ├── homepage/           # GitHub Pages / Jekyll site
│   ├── blueprint/          # Leanblueprint dependency graph
│   ├── docs/               # Extended documentation
│   ├── CLAUDE.md           # This file
│   └── CHANGELOG.md
│
└── .github/workflows/      # CI/CD
    ├── verify.yml          # Lean 4 verification
    ├── publish.yml         # PyPI publish on release
    └── blueprint.yml       # Leanblueprint generation
```

---

## Terminology Standards

Use **standard academic mathematical vocabulary**. Avoid internal jargon or classification labels.

### ❌ Internal Jargon (avoid)
```
"B4 is now proven via epsilon contraction decomposition"
"Tier 2 axioms resolved"
"B5 timeout issue"
```

### ✅ Standard Academic Terminology
```
"The Lagrange identity ‖u × v‖² = ‖u‖²‖v‖² - ⟨u,v⟩² for the
G₂-invariant cross product in ℝ⁷ is now formally verified"

"G₂ cross product properties complete"

"Octonion structure constants verification pending (343-case check)"
```

### Reference Table

| Old (jargon) | Standard Academic |
|--------------|-------------------|
| B1 | `reflect_preserves_lattice` — Weyl reflection preserves E₈ lattice |
| B2 | `G2_cross_bilinear` — Cross product bilinearity |
| B3 | `G2_cross_antisymm` — Cross product antisymmetry |
| B4 | Lagrange identity for 7D cross product |
| B5 | `cross_is_octonion_structure` — Octonion multiplication structure |
| B6 | `G2_equiv_characterizations` — G₂ equivalent characterizations |
| A1-A5 | Root enumeration (D₈ roots, half-integer roots, decomposition) |
| A6-A8 | E₈ lattice properties (integrality, evenness, basis generation) |
| A9-A12 | Basis properties (orthonormality, norm, inner product formulas) |
| Tier 1 | E₈ root system properties |
| Tier 2 | G₂ cross product properties |
| Tier 1/2 primes | Direct/derived prime expressions |

### Directory Naming

Use descriptive mathematical names, not internal labels:

| ❌ Avoid | ✅ Preferred |
|----------|-------------|
| `Tier1/` | `G2Forms/` |
| `Tier2/` | `CrossProduct/` |
| `AxiomResolution/` | `Foundations/` |

---

## Critical Rules

### 1. Lean 4 Theorem Aliases

**Problem**: Can't use `theorem foo := bar` syntax.

```lean
-- BAD - syntax error
theorem all_relations_certified := all_13_relations_certified

-- GOOD - use abbrev
abbrev all_relations_certified := all_13_relations_certified
```

### 2. Update Python Exports

When adding new constants:

1. Add to appropriate file in `contrib/python/gift_core/constants/` (algebra, topology, structural, physics, or cosmology)
2. Import in `contrib/python/gift_core/__init__.py`
3. Add to `__all__` list in `contrib/python/gift_core/__init__.py`
4. Bump version in `contrib/python/gift_core/_version.py`

### 3. Version Bumping (SemVer)

- `MAJOR.MINOR.PATCH`
- New relations/features → bump MINOR (1.0.0 → 1.1.0)
- Bug fixes only → bump PATCH (1.0.0 → 1.0.1)
- Breaking changes → bump MAJOR (1.0.0 → 2.0.0)

---

## Proof Tactics

```lean
-- For definitional equalities (most common)
theorem foo : 14 - 2 = 12 := rfl

-- For computed equalities
theorem bar : 2 * rank_E8 + 5 * H_star = 511 := by native_decide

-- For conjunctions
theorem baz : a = 1 ∧ b = 2 := ⟨rfl, rfl⟩

-- For many conjunctions
theorem qux : ... := by
  repeat (first | constructor | native_decide | rfl)
```

---

## CI/CD Workflows

### verify.yml
- Triggers on: push, PR
- Builds Lean 4 proofs (`lake build`)
- Must pass before merge

### publish.yml
- Triggers on: GitHub release published
- Verifies proofs first
- Builds and publishes to PyPI
- Uses trusted publishing (OIDC)

**To publish a new version**:
1. Merge PR to main
2. Create GitHub release with tag `vX.Y.Z`
3. Workflow auto-publishes to PyPI

---

## Testing Locally

```bash
# Lean 4
lake build

# Quick verification of constants
python -c "from gift_core import *; print(GAMMA_GIFT)"
```

---

## Adding New Certified Relations

1. **Lean**: Create/update file in `GIFT/Relations/`
2. **Lean**: Add import + abbrev to appropriate `Certificate/` sub-module:
   - `Certificate/Foundations.lean` — math infrastructure (E₈, G₂, K₇, Joyce)
   - `Certificate/Predictions.lean` — physical predictions, observables
   - `Certificate/Spectral.lean` — spectral gap, TCS, selection
3. **Lean**: Add conjunct to the sub-module's `def statement : Prop`
4. **Python**: Add constants to appropriate file in `contrib/python/gift_core/constants/`
5. **Python**: Export in `contrib/python/gift_core/__init__.py`
6. **Docs**: Update `README.md`
8. **Version**: Bump in `contrib/python/gift_core/_version.py`

---

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `unexpected token ':='` | Lean4 theorem alias | Use `abbrev` |
| `ImportError` | Missing export | Add to `__init__.py` |
| `native_decide failed` | Computation too complex | Split into smaller lemmas |
| `Ambiguous term` (e.g., `R7`, `AllInteger`) | Multiple `open` with same names | Use qualified names (see below) |
| `expected ℝ, got Prop` in `Real.log_inv` | Mathlib 4 signature change | Use `Real.log_inv x` (value, not proof) |
| `Real.decidableEq noncomputable` | `native_decide` on ℝ equality | Prove on ℕ first, then `simp + norm_num` |
| `n • v.ofLp i = ↑n * v.ofLp i` unsolved | Wrong smul lemma for PiLp | Use `PiLp.smul_apply` + `zsmul_eq_mul` (see §8) |
| `Int.odd_iff_not_even` unknown | Lemma doesn't exist in Mathlib 4 | Use `Int.even_or_odd` pattern matching (see §8) |
| `(mkR8 f).ofLp i` not simplifying | `mkR8_apply` uses wrong pattern | Use `.ofLp` accessor: `(mkR8 f).ofLp i = f i` (see §12) |
| Sum `∑ x, v.ofLp x` not expanded | `rw [Fin.sum_univ_eight]` only rewrites first | Use `simp only [Fin.sum_univ_eight]` (see §13) |
| `ring` fails with nested sums | Inner sums not expanded | Expand all sums before `ring` with `simp only` |
| `unterminated comment` at EOF | `+/-` in docstrings triggers nested `/-` comment | Replace `+/-` with `(error X)` format (see §15) |
| `Ambiguous term b0` | Multiple namespaces with same names (V33.b0, Core.b0) | Use qualified names like `Core.b0` (see §15) |
| `norm_num` fails on `Weyl_factor` | Missing certified theorem for constant value | Add `Weyl_factor_certified : Weyl_factor = 5 := rfl` (see §15) |
| `No applicable extensionality theorem` | Custom structure missing `@[ext]` | Add `@[ext] theorem MyStruct.ext` (see §16) |
| `simp` can't close `(a • x).field` | Typeclass instance not transparent to simp | Add `@[simp]` lemmas for field access (see §17) |
| `not supported by code generator` | Definition uses axiom | Mark definition as `noncomputable` (see §18) |
| `∧ₑ` causes parse errors | Subscript conflicts with do-notation | Use `∧'` notation instead (see §19) |
| `exp (y * log x)` vs `exp (log x * y)` | `rpow_def_of_pos` gives `exp(log x * y)` | Match multiplication order (see §34) |
| `norm_num` proves bound is false | Arithmetic error (e.g. 5.33 > 5.329692) | Double-check calculations before coding (see §35) |
| `nlinarith` fails on products | Can't handle `a < b → a*c < b*c` | Use `mul_lt_mul_of_pos_right` explicitly (see §36) |
| `native_decide` evaluates False on ℚ | Type annotation only on first conjunct | Annotate each conjunct: `(16 : ℚ) * ...` (see §47) |
| `revision not found` for checkdecls | Wrong branch name | Use `rev = "master"` not `"main"` (see §48) |
| `no such file` for Mathlib imports | Mathlib version mismatch | Pin mathlib to match lean-toolchain (see §48) |
| `unexpected token 'λ'` | `λ` is reserved keyword in Lean 4 | Use `ev`, `eigval`, or other ASCII names (see §49) |
| `norm_num` can't prove `n ≤ MyStruct.field` | Structure field not unfolded | Use `rfl` for definitional equality, or unfold definition (see §49) |

### 6. Namespace Conflicts in Lean 4

**Problem**: Opening multiple namespaces that define the same names causes ambiguous term errors.

```lean
-- BAD - Both define R7, AllInteger, AllHalfInteger
open InnerProductSpace
open GIFT.Foundations.RootSystems  -- CONFLICT!

-- GOOD - Only open one, use qualified names for the other
open InnerProductSpace
-- Use RootSystems.D8_card, RootSystems.E8_enumeration, etc.
```

**Known conflicts:**

| Name | Defined in | Also in |
|------|-----------|---------|
| `R7` | `InnerProductSpace` | `G2CrossProduct` |
| `R8` | `InnerProductSpace` | `RootSystems` |
| `AllInteger` | `InnerProductSpace` | `RootSystems` |
| `AllHalfInteger` | `InnerProductSpace` | `RootSystems` |

**Rule**: When importing from `RootSystems` or `G2CrossProduct`, do NOT use `open`. Instead, reference theorems with qualified names:

```lean
import GIFT.Foundations.RootSystems
-- DON'T: open GIFT.Foundations.RootSystems

-- DO: Use qualified names
theorem foo : RootSystems.E8_enumeration.card = 240 := RootSystems.E8_enumeration_card
```

### 7. Numerical Bounds and Real Coercions in Mathlib 4

**Problem 1**: `Real.log_inv` takes `ℝ` directly, not a proof.

```lean
-- BAD - type mismatch (expects ℝ, not Prop)
have hphi_pos : 0 < phi := phi_pos
rw [Real.log_inv hphi_pos]  -- ERROR!

-- GOOD - pass the value directly
rw [Real.log_inv phi]
```

**Problem 2**: `native_decide` doesn't work for ℕ→ℝ coercions.

```lean
-- BAD - Real.decidableEq is noncomputable
have hH : (H_star : ℝ) = 99 := by native_decide  -- ERROR!

-- GOOD - prove on ℕ first, then convert
have hH : (H_star : ℕ) = 99 := by native_decide
have hH_real : (H_star : ℝ) = 99 := by simp only [hH]; norm_num
```

**Problem 3**: Numerical bounds requiring interval arithmetic.

Some bounds (e.g., `e < 2.72`, `log(φ) < 0.49`) cannot be proven with standard tactics. Convert to documented axioms:

```lean
-- Axiom for bounds requiring interval arithmetic
/-- e < 2.72. Numerically verified: e = 2.71828... < 2.72
    Proof requires Taylor series or interval arithmetic. -/
axiom exp_one_lt : Real.exp 1 < (272 : ℝ) / 100

-- Theorem using the axiom with monotonicity
theorem my_bound : some_expr < threshold := by
  have h_base := exp_one_lt
  calc ...
```

**Problem 4**: `simp only` may not fully unfold nested definitions.

```lean
-- BAD - leaves imaginary_count.choose 2 unexpanded
simp only [H_star, rank_E8, b2, b3]

-- GOOD - use native_decide on ℕ, then convert
have hH : (H_star : ℕ) = 99 := by native_decide
```

### 8. PiLp/EuclideanSpace Scalar Multiplication in Mathlib 4

**Problem 1**: `EuclideanSpace ℝ (Fin n)` is defined as `PiLp 2 (fun _ => ℝ)`. The standard `Pi.smul_apply` doesn't work; use `PiLp.smul_apply`.

```lean
-- BAD - simp can't close the goal
have : (n • v) i = n * (v i) := by simp only [Pi.smul_apply, smul_eq_mul]  -- ERROR!

-- GOOD - use PiLp-specific lemma
have : (n • v) i = n * (v i) := by simp only [PiLp.smul_apply, zsmul_eq_mul]
```

**Problem 2**: For `n : ℤ` and `x : ℝ`, the scalar action `n • x` is `zsmul`, not ring multiplication. Use `zsmul_eq_mul` (not `smul_eq_mul`).

```lean
-- After PiLp.smul_apply, we have: n • (v i) where n : ℤ, v i : ℝ
-- Need: zsmul_eq_mul to get ↑n * (v i)
simp only [PiLp.smul_apply, zsmul_eq_mul]  -- Now works!
```

**Problem 3**: `Int.odd_iff_not_even` doesn't exist. Use `Int.even_or_odd` with pattern matching.

```lean
-- BAD - lemma doesn't exist
by_cases hn : Even n
· ...
· rw [Int.odd_iff_not_even] at hn  -- ERROR!
  ...

-- GOOD - use pattern matching
rcases Int.even_or_odd n with ⟨k, hk⟩ | ⟨k, hk⟩
· -- n = 2k (even case)
  exact ... ⟨k, hk⟩
· -- n = 2k + 1 (odd case)
  exact ... ⟨k, hk⟩
```

**Complete pattern for ℤ-smul on EuclideanSpace vectors:**

```lean
theorem E8_lattice_smul (n : ℤ) (v : R8) (hv : v ∈ E8_lattice) : n • v ∈ E8_lattice := by
  ...
  cases htype with
  | inl hi =>
    intro i
    have : (n • v) i = n * (v i) := by simp only [PiLp.smul_apply, zsmul_eq_mul]
    rw [this]
    exact (hi i).zsmul n
  | inr hh =>
    rcases Int.even_or_odd n with ⟨k, hk⟩ | ⟨k, hk⟩
    · -- even case
      intro i
      have : (n • v) i = n * (v i) := by simp only [PiLp.smul_apply, zsmul_eq_mul]
      rw [this]
      exact (hh i).zsmul_even ⟨k, hk⟩
    · -- odd case
      intro i
      have : (n • v) i = n * (v i) := by simp only [PiLp.smul_apply, zsmul_eq_mul]
      rw [this]
      exact (hh i).zsmul_odd ⟨k, hk⟩
```

---

## Topological Constants Reference

| Constant | Value | Definition |
|----------|-------|------------|
| `dim_E8` | 248 | Dimension of E8 |
| `rank_E8` | 8 | Rank of E8 |
| `dim_G2` | 14 | Dimension of G2 |
| `b2` | 21 | Second Betti number |
| `b3` | 77 | Third Betti number |
| `H_star` | 99 | b2 + b3 + 1 |
| `p2` | 2 | Pontryagin class |
| `dim_J3O` | 27 | Jordan algebra dim |
| `Weyl_factor` | 5 | From Weyl group |
| `D_bulk` | 11 | M-theory dimension |
| `two_b2` | 42 | Structural invariant 2*b2 (v3.3+) |
| `chi_K7` | 42 | **DEPRECATED** name for two_b2 (NOT Euler char!) |

### V3.3 Clarification: chi(K7) vs 2b2

**IMPORTANT**: The true Euler characteristic of K7 is **zero** (chi(K7) = 0), not 42!

For any compact oriented odd-dimensional manifold, Poincare duality implies b_k = b_{n-k},
so the alternating sum vanishes:
```
chi = b0 - b1 + b2 - b3 + b4 - b5 + b6 - b7
    = 1 - 0 + 21 - 77 + 77 - 21 + 0 - 1 = 0
```

The value 42 = 2*b2 = p2 * N_gen * dim_K7 is a **structural invariant**, not chi(K7).
The name `chi_K7` is kept for backwards compatibility but `two_b2` is preferred.

---

## Development History

> Historical version-by-version development notes (v3.0–v3.3.32) — per-version module additions, Lean/Mathlib sprint patterns, and axiom-status snapshots — have been archived to [dev_history.md](dev_history.md).

---

*For archived per-version development history, see [dev_history.md](dev_history.md).*
