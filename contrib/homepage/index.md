---
usemathjax: true
---

# GIFT: Geometric Information Field Theory

Part of the **[Arithmon program](https://github.com/arithmon)** - the hypothesis that the constants of nature are counts.

GIFT explores whether Standard Model dimensionless parameters may be topological invariants of an E₈ × E₈ gauge theory compactified on a G₂-holonomy manifold K₇, with **zero free parameters**. The parameter-free core is **33 exact relations** among topological integers, machine-checked in Lean 4: **460+ certified relations**, **15 axioms** (4 on the prediction chain + 11 interval-arithmetic K3 certificates), **0 `sorry`**. *Precision (secondary):* 0.99% mean deviation on the 33 Type-I relations (NuFIT 6.1 / PDG 2024 / Planck 2018).

## Quick Links

* [**GIFT Blueprint**]({{ site.baseurl }}/gift_blueprint.html) - Dependency graph visualization
* [Blueprint (web)]({{ site.baseurl }}/blueprint/) - Lean blueprint with proofs
* [Blueprint (pdf)]({{ site.baseurl }}/blueprint.pdf) - Downloadable PDF
* [Dependency Graph]({{ site.baseurl }}/blueprint/dep_graph_document.html) - Proof dependencies
* [API Documentation]({{ site.baseurl }}/docs/) - Lean code documentation

## Key Results

| Constant | GIFT Value | Measured | Deviation |
|----------|------------|----------|-----------|
| sin²θ_W  | 3/13 ≈ 0.2308 | 0.2312 | 0.17% |
| α_EM⁻¹   | 137.036... | 137.036 | <0.001% |
| n_s      | ζ(11)/ζ(5) ≈ 0.965 | 0.965 | 0.03% |

## Repository Structure

```
gift-framework/core/
├── GIFT/           # Lean 4 formal proofs (144 files, 460+ relations, 15 axioms)
├── GIFTTest/       # Lean test files
├── contrib/        # Python package, blueprint, homepage
└── lakefile.lean   # Lake build configuration
```

## Getting Started

```bash
# Clone the repository
git clone https://github.com/gift-framework/core.git
cd core

# Build Lean proofs
lake build

# Install Python package
pip install giftpy
```

## Links

* [GitHub Repository](https://github.com/gift-framework/core)
* [Lean Zulip](https://leanprover.zulipchat.com/) - Lean community chat

---

> **GIFT is the founding framework of the [Arithmon program](https://github.com/arithmon).**
