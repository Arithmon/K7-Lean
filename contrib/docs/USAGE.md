# giftpy Usage Guide

Complete documentation for the `giftpy` Python package (v3.4.28).

## Installation

```bash
pip install giftpy
```

For visualization (optional):
```bash
pip install giftpy matplotlib numpy
```

## Quick Start

```python
from gift_core import *

# Certified constants
print(SIN2_THETA_W)      # Fraction(3, 13)
print(B2, B3, H_STAR)    # 21, 77, 99 (all DERIVED from TCS!)

# E8 root system (240 actual vectors in R^8)
from gift_core.roots import E8_ROOTS, E8_SIMPLE_ROOTS
print(len(E8_ROOTS))     # 240

# Fano plane / G2 cross product
from gift_core.fano import cross_product, FANO_LINES
u = (1, 0, 0, 0, 0, 0, 0)
v = (0, 1, 0, 0, 0, 0, 0)
print(cross_product(u, v))  # 7D cross product

# K7 topology
from gift_core.topology import K7
print(K7.euler_characteristic)  # 0
print(K7.two_b2)                # 42 (structural invariant)

# Verify all relations
from gift_core import verify
print(verify())          # True
```

---

## Lean 4 Module Reference

### Core Constants

```lean
import GIFT.Core
open GIFT.Core

#check b2        -- 21
#check b3        -- 77
#check H_star    -- 99
#check dim_E8    -- 248
#check dim_G2    -- 14
#check dim_K7    -- 7
```

### Certificate Structure

The certificate is organized into domain-specific sub-modules:

```
GIFT/Certificate/
├── Core.lean         # Master: Foundations ∧ Predictions ∧ Spectral
├── Foundations.lean  # E₈, G₂, octonions, K₇, Joyce, conformal rigidity
├── Predictions.lean  # 33+ published relations, V5.0 observables, hierarchy
└── Spectral.lean     # Mass gap 14/99, TCS bounds, selection principle
```

```lean
-- Import the master certificate
import GIFT.Certificate.Core

-- Access sub-certificates
#check GIFT.Certificate.gift_master_certificate
-- : Foundations.statement ∧ Predictions.statement ∧ Spectral.statement

-- Or import individual pillars
import GIFT.Certificate.Predictions
#check GIFT.Certificate.Predictions.observables_certified
```

**Adding new relations:** Add imports and abbrevs to the appropriate sub-module (`Foundations.lean`, `Predictions.lean`, or `Spectral.lean`), then add conjuncts to its `def statement : Prop`.

**Backward compatibility:** `import GIFT.Certificate` still works and provides legacy aliases.

### Spectral Theory

```lean
import GIFT.Spectral

-- Mass gap ratio (proven, no axioms!)
#check GIFT.Spectral.MassGapRatio.mass_gap_ratio_value       -- 14/99
#check GIFT.Spectral.MassGapRatio.mass_gap_ratio_irreducible -- gcd(14,99) = 1

-- Physical spectral gap (zero axioms)
#check physical_gap_from_topology   -- 13/99 = (dim(G₂) - h) / H*
#check pell_equation                -- 99² - 50 × 14² = 1

-- TCS Bounds
#check tcs_spectral_bounds          -- c₁/L² ≤ λ₁ ≤ c₂/L²
```

### Computed Spectral Physics

Formalization of headline numerical results from the Spectral Physics paper:

```lean
import GIFT.Spectral.ComputedSpectrum

-- Q22 intersection form: 3 SD forms = 3 fermion generations
#check GIFT.Spectral.ComputedSpectrum.SD_eq_N_gen           -- Q22_pos = N_gen
#check GIFT.Spectral.ComputedSpectrum.Q22_total_eq_b2_plus_1 -- Q22_total = b2 + 1

-- SD/ASD eigenvalue gap > 2000x (geometric mass hierarchy origin)
#check GIFT.Spectral.ComputedSpectrum.sd_asd_gap_large      -- gap > 2000x
#check GIFT.Spectral.ComputedSpectrum.sd_eigenvalue_order   -- smallest SD > 1
#check GIFT.Spectral.ComputedSpectrum.asd_eigenvalue_small  -- largest ASD < 0.01

-- Gauge coupling B-test: B = 7/5 at 0.24%
#check GIFT.Spectral.ComputedSpectrum.B_above_7_5           -- B > 7/5
#check GIFT.Spectral.ComputedSpectrum.B_deviation_exact     -- deviation = 165/70000

-- Coupling deviations vs PDG
#check GIFT.Spectral.ComputedSpectrum.sin2w_deviation_small -- sin2 theta_W < 0.2%
#check GIFT.Spectral.ComputedSpectrum.alpha_s_deviation_small -- alpha_s < 0.3% (squared)
```

### Geometry (axiom-free)

```lean
import GIFT.Geometry

-- ψ = ⋆φ is a THEOREM, not an axiom!
#check HodgeStarR7.psi_eq_star_phi
#check HodgeStarCompute.hodgeStar_invol_3  -- ⋆⋆ = +1 PROVEN
#check HodgeStarR7.standardG2Geom_torsionFree
```

### Explicit G₂ Metric

Lean modules formalizing the published analytical metric:

```lean
import GIFT.Foundations.ExplicitG2Metric
import GIFT.Foundations.NewtonKantorovich
import GIFT.Foundations.K3HarmonicCorrection

-- 169-parameter Chebyshev-Cholesky metric
#check GIFT.Foundations.ExplicitG2Metric.n_params_total        -- 169
#check GIFT.Foundations.ExplicitG2Metric.n_params_eq_alpha_sum_sq  -- 169 = 13²

-- Newton-Kantorovich unconditional certification
#check GIFT.Foundations.NewtonKantorovich.nk_contraction_certified  -- h < 1/2
#check GIFT.Foundations.NewtonKantorovich.nk_safety_margin          -- margin > 7.5M

-- K3 harmonic correction: ×2995 torsion reduction
#check GIFT.Foundations.K3HarmonicCorrection.torsion_space_total   -- 1+7+14+27 = 49
#check GIFT.Foundations.K3HarmonicCorrection.K3_torsion_small      -- K3 < 0.1%
```

### Torsion Reduction Chain

Full formalization of the torsion chain connecting the explicit metric to G₂ holonomy:

```lean
import GIFT.Foundations.NewtonKantorovich
import GIFT.Foundations.K3HarmonicCorrection

-- NK parameter decomposition: h = β · η · ω
#check GIFT.Foundations.NewtonKantorovich.beta_num       -- 2962 (β ≤ 0.02962)
#check GIFT.Foundations.NewtonKantorovich.eta_num        -- 316  (η ≤ 3.16e-5)
#check GIFT.Foundations.NewtonKantorovich.omega_num      -- 713  (ω ≤ 0.0713)
#check GIFT.Foundations.NewtonKantorovich.nk_product_bound  -- 2×β×η×ω < 1

-- Joyce iteration table: T₀ > T₁ > T₂ > T₃ > T₄ > T₅
#check GIFT.Foundations.K3HarmonicCorrection.joyce_full_monotone  -- 5-way conjunction
#check GIFT.Foundations.K3HarmonicCorrection.joyce_step4_acceleration  -- T₃/T₄ > 100

-- Two convergence regimes
#check GIFT.Foundations.K3HarmonicCorrection.reduction_steps_12  -- T₀/T₂ > 2 (linear)
#check GIFT.Foundations.K3HarmonicCorrection.reduction_steps_35  -- T₂/T₅ > 1000 (quadratic)
```

### Ambrose-Singer Holonomy Diagnostics

Formalizes the gap between torsion-free G₂ structures and G₂ holonomy:

```lean
import GIFT.Foundations.AmbroseSinger

-- so(7) = g₂ ⊕ g₂⊥ decomposition
#check so7_g2_decomposition         -- 21 = 14 + 7
#check dim_g2_complement_eq_dim_K7  -- dim(g₂⊥) = 7 = dim(K₇)
#check b2_holonomy_manifold_sum     -- b₂ = dim(g₂) + dim(K₇)

-- Holonomy rank gap
#check holonomy_rank_gap            -- 21 - 14 = 7
#check as_constraints_per_point     -- 147 = 7 × 21

-- Master certificate (10 conjuncts, all proven)
#check ambrose_singer_certificate
```

**Key insight**: Torsion-free (nabla phi = 0) is NECESSARY but NOT SUFFICIENT for G₂ holonomy. The curvature must additionally lie in g₂ subset so(7) (Ambrose-Singer theorem).

### Axiom Classification (38 published)

All axioms carry category labels:

| Category | Count | Description |
|----------|-------|-------------|
| A | ~5 | Definitions |
| B | ~8 | Standard results (Cheeger, Weil) |
| C | ~15 | Geometric structure |
| D | ~3 | Literature axioms (CGN 2024) |
| E | 0 | GIFT claims |
| F | ~6 | Numerically verified |

---

## Python API

### Certified Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `SIN2_THETA_W` | 3/13 | Weinberg angle |
| `TAU` | 3472/891 | Hierarchy parameter |
| `KAPPA_T` | 1/61 | Torsion parameter |
| `DET_G` | 65/32 | Metric determinant |
| `Q_KOIDE` | 2/3 | Koide formula |
| `H_STAR` | 99 | Topological invariant |
| `N_GEN` | 3 | Number of generations |
| `GAMMA_GIFT` | 511/884 | GIFT parameter |

### Topological Constants

```python
from gift_core import *

print(DIM_E8)      # 248
print(RANK_E8)     # 8
print(DIM_G2)      # 14
print(DIM_K7)      # 7
print(B2)          # 21
print(B3)          # 77
print(DIM_J3O)     # 27
print(WEYL_FACTOR) # 5
print(D_BULK)      # 11
```

### E8 Root System

```python
from gift_core.roots import E8_ROOTS, E8_SIMPLE_ROOTS, E8_CARTAN_MATRIX
from gift_core.roots import inner_product, weyl_reflection, root_statistics

print(len(E8_ROOTS))     # 240
stats = root_statistics()
print(stats['coxeter_number'])  # 30
```

### Fano Plane & G2 Cross Product

```python
from gift_core.fano import FANO_LINES, epsilon, cross_product, phi0

print(FANO_LINES)           # 7 lines, each with 3 points
print(epsilon(0, 1, 3))     # +1
print(cross_product(u, v))  # 7D result
```

### Verification

```python
from gift_core import verify, verify_all, print_verification_report

assert verify()           # True
print_verification_report()
```

### Joyce Existence

```python
from gift_core.analysis import JoyceCertificate, verify_joyce_bounds

assert verify_joyce_bounds()  # K7 admits torsion-free G2!
cert = JoyceCertificate.verify()
print(cert.safety_margin)    # ~20.4x
```

## Building Proofs Locally

```bash
lake build
```

## Blueprint

```bash
cd blueprint
pip install leanblueprint
leanblueprint build
# Open _build/html/index.html
```

## Version History

See [CHANGELOG.md](../CHANGELOG.md) for detailed version history.
