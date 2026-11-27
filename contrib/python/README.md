# giftpy

Python companion of [K₇-Lean](https://github.com/Arithmon/K7-Lean): the structural constants of the K₇ framework and the arithmetic relations that the Lean 4 development certifies.

## Installation

```bash
pip install giftpy
```

## Usage

```python
from gift_core import B2, B3, H_STAR, RELATIONS_V36, get_relation_v36

print(B2, B3, H_STAR)             # 21 77 99

for r in RELATIONS_V36:           # the 33 relations A01 ... A33 of the paper, v3.6
    print(r.id, r.symbol, r.stated, float(r))

print(get_relation_v36("A13"))    # A13 sin^2(theta_23) PMNS = 6/11
```

## What the package states

- `gift_core.relations_v36` holds the 33 relations of the K₇ paper, version 3.6 ([concept DOI 10.5281/zenodo.16891489](https://doi.org/10.5281/zenodo.16891489)). Each value is computed from the package's constants and checked against the Lean certificate `GIFT.Certificate.RelationsV36` by `scripts/test_relations_v36.py`.
- These are arithmetic identities. They do not establish a physical identification, the choice of a formula among the many with the same value, or the mutual consistency of the relations. The comparison with experiment is in the paper and its dataset.
- No twisted-connected-sum realisation of (b₂, b₃) = (21, 77) is claimed. The names `M1_B2`, `QUINTIC`, `TCSManifold` and the like are kept from version 3.2 as arithmetic witnesses.
- Names that predate version 3.6 (`THETA_23`, `PROVEN_RELATIONS`, the modules `experimental`, `monte_carlo`, `pipeline`, `scales`) are kept for compatibility and are not the paper's current statements.

## License

MIT
