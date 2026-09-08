# Modernization validation

The modernization was merged by [PR #162](https://github.com/Arithmon/K7-Lean/pull/162)
into `main` at `528e4aadb50e984bcfa9b65d235e26aa35105238` on 2026-09-07.
Its baseline was `7a017bc3c56d3864efa9235fe7344769f9c262a2` (Lean/Mathlib 4.29.1),
and the merged source branch ended at `50b0b4b606395c896e10395ec8702aa78e1ac752`.

The merged dependency set is:

- Lean `4.33.1` (`leanprover/lean4:v4.33.1`);
- Mathlib `v4.33.1`, resolved to `0df444a360eaa60ab8c11dca51a86af692955474`;
- doc-gen4 `v4.33.1`, resolved to `e2af49a7b7e5e1a9224008c1f15e7aa4f58a4015`;
- checkdecls pinned to `3d425859e73fcfbef85b9638c2a91708ef4a22d4`.

These revisions are recorded in `lake-manifest.json`. No dependency update is
part of the follow-up work described here.

## Changes

- Shortened the README and analysis module commentary; documented the exact scope
  of numerical index conditions and the constant form model.
- Introduced precise Sobolev and constant-model names, retaining existing aliases.
- Replaced 45 elementary native-decide occurrences with kernel-reduced `decide`.
- Adapted the cube Sobolev inequality and smooth-family derivative bounds from
  the FLT artifact, with source revision and Apache-2.0 attribution.
- Added a comment-aware source inventory, complete audit imports and a Lean
  transitive-axiom policy, including strict checks for the analysis results.
- Removed routine dependency updates from verification; cache keys include the
  toolchain, Lake configuration and dependency lockfile.

## Source validation

| Check | Baseline | Branch |
| --- | ---: | ---: |
| Explicit project axiom declarations | 15 | 15 |
| Explicit `sorry`, `admit`, `sorryAx` outside comments/strings | 0 | 0 |
| `native_decide` occurrences outside comments/strings | 1526 | 1481 |

The source scanner's nested-comment and inline-hole regression tests pass.
The blueprint declaration synchronization and version checks pass on this branch.
The old local version check expected “GIFT Core” while the README used “K₇-Lean”;
the old verification workflow also matched comments containing “no sorry”, while
a missing `GIFTTest/` directory could mask the check with a grep error exit code.

## Merge validation

All three reported CI workflows passed on the source head:

| Check | Result | Run |
| --- | --- | --- |
| Blueprint | success | [34147970401](https://github.com/Arithmon/K7-Lean/actions/runs/34147970401) |
| Version and axiom consistency | success | [34147970486](https://github.com/Arithmon/K7-Lean/actions/runs/34147970486) |
| Lean 4 verification | success | [34147970551](https://github.com/Arithmon/K7-Lean/actions/runs/34147970551) |

The same three workflows then passed on `main` at the merge commit:

| Check | Result | Run |
| --- | --- | --- |
| Blueprint | success | [34151140575](https://github.com/Arithmon/K7-Lean/actions/runs/34151140575) |
| Version and axiom consistency | success | [34151140603](https://github.com/Arithmon/K7-Lean/actions/runs/34151140603) |
| Lean 4 verification | success | [34151140616](https://github.com/Arithmon/K7-Lean/actions/runs/34151140616) |

The post-merge Lean run's source checks, Mathlib cache retrieval, full
`lake build`, `lake build Verification`, transitive axiom audit and manifest
cleanliness check all completed successfully.

On 2026-09-08, a local reference check at the same commit confirmed Lean 4.33.1,
Lake 5.0.0, 150 Lean source files, 15 explicit project axioms, zero explicit
holes and 1,481 source occurrences of `native_decide`. The scanner regression
tests, generated inventory freshness, verification-import freshness and blueprint
declaration synchronization also passed.

## Remaining obligations

No project axiom has been discharged in this change. Numerical enclosures need a
formal connection to the defined geometric quantities; spectral assumptions need
a precise mathematical review. The new cube estimate is not the dimension-seven
H⁴ embedding theorem. Historical constants, release tags and Koide comparison
inputs are unchanged. This branch does not claim a completed compact G₂ construction.

## Migration build history

[Run 34105836451](https://github.com/Arithmon/K7-Lean/actions/runs/34105836451)
failed after compiling both new analysis modules. It exposed four module docstrings
placed before imports, plus Mathlib migration changes in real inner-product
simplification, coefficient rewriting for the Hodge star and type inference for
finite harmonic-basis indices. Those issues were corrected before the merge
without changing theorem statements.
