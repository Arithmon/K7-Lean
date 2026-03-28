# giftpy

Python package for the GIFT framework — formally verified mathematical constants (Lean 4).

All constants are certified by zero-sorry Lean 4 proofs in the [GIFT core repository](https://github.com/gift-framework/core).

## Installation

```bash
pip install giftpy
```

## Usage

```python
from gift_core import LAMBDA1, H_STAR, B2, B3, GAMMA_GIFT

print(LAMBDA1)   # 0.12467 — spectral gap λ₁
print(H_STAR)    # 99      — topological invariant b₂+b₃+1
print(B2)        # 21      — second Betti number
print(B3)        # 77      — third Betti number
```

## License

MIT
