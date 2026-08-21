# Contributing to K7-Lean

This repository is the machine-checked layer of the K₇ framework: the
relations that the framework asserts, stated and proven in Lean 4 so that
they hold or fail without anyone's opinion entering. The most valuable
contribution is therefore the one that reduces what has to be trusted: an
axiom discharged into a theorem, a proof that stops depending on a numeric
bound, a statement found to say less than it appears to.

Org-wide rules (what helps, what does not, house style) are in the
[organization CONTRIBUTING](https://github.com/arithmon/.github/blob/main/CONTRIBUTING.md).
This file covers the four procedures this repository owns.

## Build before you open anything

Continuous integration runs `lake build` and then refuses any occurrence of
`sorry` in the Lean sources. A branch that does not build is not reviewable,
and the policy is not negotiated per pull request.

1. `lake update && lake exe cache get && lake build` must succeed locally.
2. No `sorry`, and no axiom introduced to avoid one. An incomplete proof is
   better opened as an issue than merged behind a placeholder.
3. Mathlib is the default source of standard results. Restating one locally
   needs a reason in the commit message.

## Discharge an axiom

The main prediction chain rests on a small number of axioms, and each one is
a debt rather than a decision. Turning one into a proven theorem is the most
useful thing that can happen here.

1. Open an issue titled `axiom: <name>` before starting, so the work is not
   duplicated and the intended statement can be discussed.
2. The discharged theorem must have the same statement as the axiom it
   replaces, not a weaker one that happens to be provable. If the provable
   statement is weaker, say so explicitly: what the framework consumes
   downstream then has to be re-examined.
3. The axiom count in the README is updated in the same pull request. A count
   that drifts from the sources is worse than no count.

## Challenge a numeric certificate

Part of the arithmetic rests on interval-arithmetic certificates rather than
symbolic proof. These are the weakest link by construction, and they are
labelled as such rather than blended into the theorem count.

1. Report a certificate whose interval you cannot reproduce, with your
   output and your toolchain version.
2. A certificate that is not reproducible is treated as unsupported until it
   is, and the relation that depends on it is relabelled, not defended.
3. Replacing a certificate by a symbolic proof is always accepted, even when
   the resulting bound is looser.

## Report a statement that says less than it claims

A theorem can be true, machine-checked, and still not support the sentence
written next to it in prose. This is the failure mode that formal
verification does not catch, and reports of it are welcome.

1. Quote the Lean statement and the prose claim side by side.
2. Name the gap: a quantifier that is narrower than the prose, a hypothesis
   that is assumed rather than established, an invariant proven for one
   generator where the prose says the group.
3. Such reports are resolved by correcting the prose, not by widening the
   theorem after the fact.

## Python

The Python package under `giftpy` is checked by the same standard as the
Lean sources: a numerical routine that disagrees with a proven relation is a
defect in the routine. Numerical gradients are not used anywhere in the
physics computations, by design.

---

Siblings: [K7](https://github.com/arithmon/K7) ·
[Program](https://github.com/arithmon/program) ·
[Sieve](https://github.com/arithmon/sieve) ·
[Atlas](https://github.com/arithmon/atlas) ·
[Lean](https://github.com/arithmon/lean)

<sub>K₇ (formerly GIFT) is the founding framework of the Arithmon program.
Program: [arithmon.com](https://arithmon.com) ·
[github.com/arithmon](https://github.com/arithmon)</sub>
