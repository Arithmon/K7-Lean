# Exact McKay / golden-character-field certificate

This packet replaces the arithmetic shadow `phi_path_mckay` with an exact executable reconstruction. It does not change any observable or physical interpretation.

## Construction and independent replay

`scripts/mckay_golden_field_certificate.py` builds the 120 unit quaternions from the three standard H4/600-cell coordinate families, using rational pairs `a + b sqrt(5)` and exact Hamilton multiplication. It checks closure, inverses, center `{+1,-1}`, and the quaternion-algebra associativity basis identities. The coordinate provenance is the standard 600-cell/H4 coordinate description; see [Tumarkin, Combinatorics lecture outline](https://www.maths.dur.ac.uk/users/pavel.tumarkin/Combinatorics/outline_term2.pdf), p. 21. The implementation independently checks the closure assertion exactly.

The canonical quaternion-to-complex-matrix map has entries in `Q(sqrt(5), i)`. Exact checks establish the homomorphism, determinant one, trivial kernel, central `-1` action `-I_2`, and character norm one. Thus this is a faithful irreducible determinant-one doublet. The trace values lie in `Q(sqrt(5))`; a trace with nonzero `sqrt(5)` coefficient generates that quadratic field. This distinguishes the coefficient field from the character field.

Conjugacy classes are enumerated from the group law. Irreducibles are discovered from symmetric-power characters, exact inner products, constituent subtraction and field conjugation; neither a dimension list nor a character table is supplied as input. The recovered dimensions are `1,2,2,3,3,4,5,6,4`, with pairwise orthogonality and squared-dimension sum 120. Tensor-by-doublet multiplicities are then computed by exact character inner products.

`scripts/verify_mckay_golden_field_independent.py` imports no producer code. It obtains the group by closure from two exact quaternion generators, uses a separate rational-pair arithmetic implementation, reconstructs classes, irreducibles and both fusion matrices again, and checks the direct-enumeration element-set digest. Only after deriving the graph does it compare it with an independently encoded affine-E8 tree and return explicit graph isomorphisms.

## Frozen result

- Group order 120; center `{+1,-1}`; 9 conjugacy classes of sizes `1,1,12,12,12,12,20,20,30`.
- Nine irreducibles; squared dimensions sum to 120.
- The faithful doublet fusion graph has 9 vertices, 8 edges, is connected and a tree, and its dimension vector is a 2-eigenvector. An explicit affine-E8 isomorphism is in `certificates/mckay_golden_field_reference.json`.
- The exact character field is `Q(sqrt(5))`, not merely the matrix coefficient field.
- Under `sqrt(5) -> -sqrt(5)` with `i` fixed, the conjugate doublet is distinct, faithful and irreducible. Its fusion matrix is recomputed and its graph is again affine E8. The labeled graph changes; the graph type does not.
- Consequently the McKay graph does not select between `phi=(1+sqrt(5))/2` and `psi=1-phi=(1-sqrt(5))/2`.

The two independently implemented quaternion constructions agree exactly on the element-set digest. `SL(2,F5)` is separately enumerated and verified to have order 120 and center `{+I,-I}`; this packet does **not** prove an explicit isomorphism `2I ≅ SL(2,F5)`, and does not identify the groups solely from those matching invariants.

## Reproduction

From the repository root:

```bash
python3 -B scripts/mckay_golden_field_certificate.py
python3 -B scripts/verify_mckay_golden_field_independent.py
python3 -B -m pytest -q scripts/test_mckay_golden_field_certificate.py
```

The first script writes the raw producer receipt; the second independently writes the verified reference receipt. The hostile suite includes target-leak, Galois-reuse, reducibility, field-erasure and graph-count-only controls.

## Pinned external cross-control

After commit `c6f69b502d30f465868e0127c2f2e1d30f5791ed` froze the Arithmon producer and independent replay, the pinned OPH producer at commit `4ae2148a26ce15591adaac78ff408fb2cc32d3a2` (blob `2938db085477737cab6eb09a3a87f7330c37f473`) was executed from that commit's source tree. The exact output schema was `oph.sl2f5_mckay_e8.v1`. The compared structural invariants all agree; see `certificates/oph_mckay_golden_field_cross_control.json` and run `python3 -B scripts/verify_mckay_golden_field_cross_control.py` to check the frozen comparison against the Arithmon receipts.

This is independent exact agreement on the listed invariants. It does not produce an explicit isomorphism between Arithmon's quaternion carrier and OPH's `SL(2,F5) carrier, and OPH did not contribute premises to the derivation. The OPH test suite was not run in this workstream.

## Proof boundary

This is an exact executable certificate with an independent replay, not a Lean-native reconstruction of finite representation theory. No OPH data is a derivation input; no Koide, observable, experimental data, physical-particle identification or real-embedding selector is used. The old `phi_path_mckay` proposition remains unchanged and is only an arithmetic shadow; its documentation points here for the actual finite construction. The result establishes the golden character field and the Galois nonselection boundary, not a physical choice of `phi`.
