---
usemathjax: true
---

# GIFT: Geometric Information Field Theory

GIFT derives Standard Model parameters from E₈ × E₈ gauge theory compactified on G₂-holonomy manifolds, achieving **0.24% mean deviation** across 50+ physical observables with **460+ machine-verified relations** (7 axioms) and **zero free parameters**.

## Quick Links

* [**GIFT Blueprint v3.4.8**]({{ site.baseurl }}/gift_blueprint.html) - Dependency graph visualization
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
├── GIFT/           # Lean 4 formal proofs (130 files, 460+ relations, 7 axioms)
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
