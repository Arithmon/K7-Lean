# GIFT Core

[![Formal Verification](https://github.com/gift-framework/core/actions/workflows/verify.yml/badge.svg)](https://github.com/gift-framework/core/actions/workflows/verify.yml)
[![PyPI](https://img.shields.io/pypi/v/giftpy)](https://pypi.org/project/giftpy/)

Formally verified mathematical relations from the GIFT framework. 460+ certified relations, **15 axioms** (4 logical on the main prediction chain + 11 interval-arithmetic certificates for the K3 block of g*), all theorems proven in **Lean 4** (8380 build jobs).

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

**[gift-framework/GIFT](https://github.com/gift-framework/GIFT)**

---

[Changelog](contrib/CHANGELOG.md) | [MIT License](LICENSE)

*GIFT Core v3.4.15*
