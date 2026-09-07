# Modernization validation

Branch: `codex/lean-modernization`.
Baseline: `7a017bc3c56d3864efa9235fe7344769f9c262a2` (Lean/Mathlib 4.29.1).
Target: Lean, Mathlib and doc-gen4 4.33.1; checkdecls pinned to its previous revision.

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

## Compilation status

Local compilation is blocked by executable initialization in the Work runtime:
Lean 4.29.1 and 4.33.1 report `error: failed to locate application` even for
`lean --version`. This is not a proof failure and is not recorded as a successful
baseline build. The baseline has a successful GitHub Actions Build step in
[run 33856820678](https://github.com/Arithmon/K7-Lean/actions/runs/33856820678).
The branch's GitHub Actions workflow runs the actual build and
axiom audit. Consult that run before merging; source checks alone are insufficient.

## Remaining obligations

No project axiom has been discharged in this change. Numerical enclosures need a
formal connection to the defined geometric quantities; spectral assumptions need
a precise mathematical review. The new cube estimate is not the dimension-seven
H⁴ embedding theorem. Historical constants, release tags and Koide comparison
inputs are unchanged. This branch does not claim a completed compact G₂ construction.

## First migration build

Run 34105836451 compiled both new analysis modules successfully. It exposed four
module docstrings placed before imports (corrected), plus Mathlib migration
changes in real inner-product simplification, coefficient rewriting for the
Hodge star, and type inference for finite harmonic-basis indices. The next
commit corrects these without changing theorem statements.
