# GIFT Core

> ### This repository is moving
>
> **`gift-framework/core` → [`Arithmon/K7-Lean`](https://github.com/Arithmon/K7-Lean)**
>
> The K₇ framework's certified Lean 4 core joins the [Arithmon](https://github.com/Arithmon)
> organisation alongside [K7](https://github.com/Arithmon/K7) (the framework, formerly
> `gift-framework/GIFT`), Atlas, Program, Lean and Sieve. Not to be confused with
> [Arithmon/Lean](https://github.com/Arithmon/Lean), the Sieve/Q5 methodology layer:
> this repository is the framework's formal core, formerly known as "GIFT Core".
>
> **Nothing you cite will break.** The published papers (immutable PDFs on Zenodo) cite
> `github.com/gift-framework/core` dozens of times. GitHub redirects the old URLs (web
> *and* `git clone` / `fetch` / `push`), and those redirects are load-bearing
> infrastructure, so the old path will never be reused. Release tags and the
> pre-registration pointer (`v3.4.29`, `667c8b9`) are unaffected.

---

[![Formal Verification](https://github.com/Arithmon/K7-Lean/actions/workflows/verify.yml/badge.svg)](https://github.com/Arithmon/K7-Lean/actions/workflows/verify.yml)
[![PyPI](https://img.shields.io/pypi/v/giftpy)](https://pypi.org/project/giftpy/)

Part of the **[Arithmon program](https://github.com/arithmon)** — the hypothesis that the constants of nature are counts.

Formally verified mathematical relations from the GIFT framework. 460+ certified relations, **15 axioms** (4 logical on the main prediction chain + 11 interval-arithmetic certificates for the K3 block of g*), all theorems proven in **Lean 4** (8394 build jobs).

## Structure

```
GIFT/                           # Lean 4 formalization (root library)
├── Core.lean                   # Constants (dim_E8, b2, b3, H*, ...)
├── Certificate/                # Modular certificate system
│   ├── Core.lean               # Master: Foundations ∧ Predictions ∧ Spectral
│   ├── Foundations.lean        # E₈, G₂, octonions, K₇, Joyce, NK cert (34 conjuncts)
│   ├── Predictions.lean        # 33+ relations, ~50 observables (56 conjuncts)
│   └── Spectral.lean           # Mass gap, TCS, computed spectrum, Weyl law (37 conjuncts)
├── Foundations/                 # Mathematical foundations (23 files)
│   ├── RootSystems.lean        # E₈ roots in ℝ⁸ (240 vectors)
│   ├── E8Lattice.lean          # E₈ lattice, Weyl reflection
│   ├── G2CrossProduct.lean     # 7D cross product, Fano plane
│   ├── ExplicitG2Metric.lean   # 169-param Chebyshev-Cholesky
│   ├── NewtonKantorovich.lean  # NK cert: h < 0.5, decomposed
│   ├── NumericalBounds.lean    # Taylor series bounds (axiom-free)
│   └── Analysis/               # G₂ forms, Hodge theory, Sobolev
├── Geometry/                   # Axiom-free DG infrastructure
│   ├── HodgeStarR7.lean        # ⋆, ψ=⋆φ PROVEN, TorsionFree
│   └── HodgeStarCompute.lean   # Explicit Hodge star (Levi-Civita)
├── Spectral/                   # Spectral gap theory (17 files)
│   ├── PhysicalSpectralGap.lean # dim(G₂)−h = 13 algebraic (zero axioms)
│   ├── ComputedSpectrum.lean   # Q22 sig, SD/ASD gap, B-test
│   └── CheegerInequality.lean  # Cheeger-Buser bounds
├── Algebraic/                  # Octonion/G₂ algebraic foundations
│   └── G2ThreeForm.lean        # φ₀ 3-form, G₂=Stab(φ₀), g₂=ker(L_φ₀), dim=14
├── Relations/                  # Physical predictions (22 files)
├── Observables/                # PMNS, CKM, quark masses, cosmology
├── Hierarchy/                  # Dimensional gap, absolute masses

GIFTTest/                       # Lean test files

blueprint/                      # Leanblueprint dependency graph

contrib/                        # Non-Lean assets
├── python/                     # Python package (giftpy on PyPI)
│   └── gift_core/              # Certified constants export
├── homepage/                   # GitHub Pages / Jekyll site
└── docs/                       # Extended documentation
```

## Quick Start

```bash
pip install giftpy
```

```python
from gift_core import *

print(SIN2_THETA_W)   # Fraction(3, 13)
print(GAMMA_GIFT)     # Fraction(511, 884)
print(TAU)            # Fraction(3472, 891)
```

## Building Proofs

```bash
lake build
```

## Documentation

For extended observables, publications, and detailed analysis:

**[Arithmon/K7](https://github.com/Arithmon/K7)**

---

> **K₇ (formerly GIFT) is the founding framework of the [Arithmon program](https://github.com/arithmon).**

[Changelog](contrib/CHANGELOG.md) | [MIT License](LICENSE)

*GIFT Core v3.4.29*
