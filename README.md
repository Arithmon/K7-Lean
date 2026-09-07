# K₇-Lean

[![Formal Verification](https://github.com/Arithmon/K7-Lean/actions/workflows/verify.yml/badge.svg)](https://github.com/Arithmon/K7-Lean/actions/workflows/verify.yml)

Lean 4 formalizations of algebraic identities, finite-dimensional models, numerical
inequalities and conditional geometric statements associated with the
[Arithmon K₇ framework](https://github.com/Arithmon/K7).

The Lean statements specify the scope of each result. In particular, arithmetic
conditions on Sobolev indices are not embedding theorems, and the constant
three-form model on ℝ⁷ is not a construction of a compact manifold with G₂ holonomy.
Physical interpretations of the numerical relations are outside the formal proofs.

## Build and verify

Install [elan](https://github.com/leanprover/elan), then run:

```sh
git clone https://github.com/Arithmon/K7-Lean.git
cd K7-Lean
lake exe cache get
lake build
python3 scripts/proof_inventory.py --check
lake build Verification
```

Lean, Mathlib and doc-gen4 target **4.33.1**. Exact dependency revisions are recorded
in `lake-manifest.json`. Routine builds use that lockfile; `lake update` is reserved
for deliberate dependency updates. Migration validation is recorded in
[docs/modernization.md](docs/modernization.md).

## Reading the library

| Directory | Contents |
| --- | --- |
| `GIFT/Algebraic/` | Octonions, explicit G₂ tensors and finite matrix identities |
| `GIFT/Foundations/` | Root systems, numerical inequalities and geometric models |
| `GIFT/Foundations/Analysis/` | Analysis lemmas and arithmetic interfaces |
| `GIFT/Geometry/` | Coordinate calculations with differential forms |
| `GIFT/Spectral/` | Spectral models and statements with explicit project assumptions |
| `GIFT/Relations/`, `GIFT/Observables/` | Relations among the framework's declared constants |
| `GIFT/Certificate/` | Conjunctions of exported statements |
| `Verification/` | Transitive axiom audit and checks for the analysis lemmas |
| `blueprint/` | Mathematical exposition and declaration references |
| `contrib/` | Python package, website and historical documentation |

Start with [the proof guide](docs/proof-guide.md) and consult the exact theorem types
before interpreting a module title. The `GIFT` namespace and historical aliases are
retained so existing imports and published references continue to resolve.

## Proof dependencies

The current library declares **15 axioms**: five unspecified real quantities, six
assumptions in the numerical-certificate module, and four assumptions in the spectral
modules. This count is a source inventory, not a measure of mathematical completeness.
Bundling assumptions into a structure does not discharge them.

The library also uses `native_decide` for finite computations. These proofs have a
different trust boundary from proofs reduced entirely by the kernel. The generated
[source inventory](docs/proof-inventory.json) lists occurrences. The Lean audit
reports transitive dependencies of exported certificates and fails on `sorryAx` or
unlisted axioms; stricter checks require only Lean's standard axioms for the new
analysis lemmas and elementary index conditions.

See [the dependency policy](docs/proof-guide.md#dependency-policy) for the distinction
between kernel axioms, project assumptions, and native computation.

## Related artifacts and attribution

- [K₇ framework](https://github.com/Arithmon/K7): accompanying mathematical exposition.
- [Python package](contrib/python/README.md): optional export of numerical constants.
- [Contribution guide](CONTRIBUTING.md) and [changelog](contrib/CHANGELOG.md).
- [MIT license](LICENSE); adapted analysis proofs retain their
  [Apache-2.0 license](LICENSES/Apache-2.0.txt) and [attribution](NOTICE).

Former repository: `gift-framework/core`. Existing release tags and the
pre-registration reference `v3.4.29` / `667c8b9` are retained.

*K₇-Lean v3.4.29*
