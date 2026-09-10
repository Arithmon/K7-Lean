# Proof guide

## Reusable analysis

`GIFT/Foundations/Analysis/Sobolev/Box.lean` bounds the value of a globally Cⁿ,
complex-valued function on an n-dimensional cube by a sum of L² norms of its
iterated Fréchet derivatives through order n. The proof gives the constant
`(2 * max 1 ℓ⁻¹)^n * sqrt(ℓ^n)`, uniformly in the position of the cube, for ℓ > 0.
It does not establish the optimal H⁴ → C⁰ embedding in dimension seven, nor an
embedding on a compact manifold. The latter requires charts, norm comparisons,
localization and the appropriate regularity theorem.

`GIFT/Foundations/Analysis/SmoothFamily.lean` gives a uniform bound on finitely many
iterated derivatives of smooth one-variable slices, with parameters in a compact
set and the variable in a closed bounded interval. The bound is existential, not
a numerical enclosure suitable for an interval certificate.

Both proofs are adapted from Anthropic's FLT artifact; see `NOTICE`. They depend
on Mathlib, not on the framework's constants or spectral assumptions.

## Arithmetic interfaces and geometric models

`Sobolev/Basic.lean`, `Elliptic/Basic.lean`, and `IFT/Basic.lean` contain arithmetic
conditions and finite records. Their data alone do not prove Sobolev embedding,
elliptic regularity, or Joyce's theorem. `JoyceAnalytic.constant_model_torsion_free`
concerns the constant form model on ℝ⁷. Historical theorem names remain aliases.

The three `Certificate.*.certified` theorems package their respective `statement`
definitions. `Certificate.gift_master_certificate` conjoins these statements; a
reader must inspect their types and dependencies, not infer a broader theorem
from the word “certificate”.

The Koide comparison in `Relations/KoideAssembly.lean` retains its published
statement and fixed input 3477. Neither its constants nor its interpretation are
changed by this modernization.

## Dependency policy

- `propext`, `Classical.choice`, and `Quot.sound` are the standard logical axioms.
- Project axioms are unproved assumptions even when attributed to literature or
  supported by an external computation. Moving them into fields or combining
  them into one declaration does not prove their contents.
- Native reduction is tracked separately; eliminating a source occurrence of
  `native_decide` does not remove a transitive dependency from other lemmas.
- A `sorryAx` dependency is forbidden, including when inherited indirectly.

The source scanner ignores comments and strings and checks explicit holes. It
cannot replace the Lean audit. `Verification/AxiomAudit.lean` imports all library
modules and traverses their declarations, rejects unlisted axioms and prints the
axioms of the main certificates. `Verification/AnalysisChecks.lean` applies a
strict standard-axiom-only policy to the new analysis results and numerical index
conditions. No claim of independent-kernel replay is made.

## Remaining mathematical work

The interval module leaves five real quantities unspecified and assumes five
properties. A genuine elimination needs definitions of the corresponding metric
quantities and proofs relating exact enclosures to those definitions. Checking
an integer aggregate of externally supplied endpoints does not prove that the
endpoints enclose the intended geometric quantity.

The spectral literature package was reviewed statement by statement on
2026-09-09 (lot 2). Its legacy `torsion_free_correction` field was removed: nothing
projected it, and the public theorem of that name proves its elementary statement
without the package, so the axiom `literature_package` is now strictly weaker. The
two remaining fields constrain the mass gap only (`λ₁ ∉ (0, c/L)` and
`λ₁ ≥ C'/L²`); their docstrings now say exactly that. Their attributions could not
be confirmed: the cited CGN title and DOI placeholder were not found, and the
Langlais reference resolves to arXiv:2301.03513 rather than a journal article. Both
are marked UNVERIFIED in the source. Neither declaration formalizes Joyce's
correction theorem, and the `K3_S1` Betti table is data, not a proof of the
cohomology of a product. These items must not be advertised as a formalization of
the cited geometric results. The mathematical review of the two claims themselves
(is the statement in the literature, with which constants and hypotheses) is still
open.

The Chebyshev U completeness lemma from FLT has not been imported: no current
result here requires it. A Chebyshev–Cholesky error estimate needs approximation
and truncation bounds, which that completeness statement alone does not supply.
