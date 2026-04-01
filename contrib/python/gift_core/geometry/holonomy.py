"""G₂ holonomy structure — 3-form, torsion, and holonomy verification.

A G₂ structure on a 7-manifold is defined by a positive 3-form phi
satisfying the torsion-free condition: d(phi) = 0 and d(*phi) = 0.
"""

from dataclasses import dataclass
from typing import Optional
import numpy as np


# Bryant-Joyce canonical phi_0 on R^7
# 7 nonzero coefficients from the Fano plane
PHI0_TRIPLES = [
    (0, 1, 2, +1),
    (0, 3, 4, +1),
    (0, 5, 6, +1),
    (1, 3, 5, +1),
    (1, 4, 6, -1),
    (2, 3, 6, -1),
    (2, 4, 5, -1),
]


def phi0_tensor() -> np.ndarray:
    """Construct the canonical G₂ 3-form phi_0 as a (7,7,7) tensor."""
    phi = np.zeros((7, 7, 7))
    for i, j, k, sign in PHI0_TRIPLES:
        for p, q, r in [(i, j, k), (j, k, i), (k, i, j)]:
            phi[p, q, r] = sign
        for p, q, r in [(j, i, k), (i, k, j), (k, j, i)]:
            phi[p, q, r] = -sign
    return phi


@dataclass
class G2Structure:
    """A G₂ structure on a 7-manifold.

    Parameters:
        phi: The defining 3-form (7x7x7 tensor at each point)
        metric: The induced metric tensor
    """
    phi: Optional[np.ndarray] = None
    metric: Optional[np.ndarray] = None

    def torsion_norm(self, d_phi: np.ndarray, d_star_phi: np.ndarray) -> float:
        """Compute ||T|| = ||d(phi)||^2 + ||d(*phi)||^2.

        Args:
            d_phi: Exterior derivative of phi
            d_star_phi: Exterior derivative of *phi

        Returns:
            Torsion norm (0 = torsion-free = G₂ holonomy)
        """
        return float(np.sqrt(np.sum(d_phi ** 2) + np.sum(d_star_phi ** 2)))

    def is_torsion_free(self, d_phi: np.ndarray, d_star_phi: np.ndarray,
                        threshold: float = 1e-4) -> bool:
        """Check if the G₂ structure is approximately torsion-free."""
        return self.torsion_norm(d_phi, d_star_phi) < threshold

    @classmethod
    def canonical(cls) -> "G2Structure":
        """Return the canonical flat G₂ structure on R^7."""
        phi = phi0_tensor()
        metric = np.eye(7)  # Flat metric for canonical structure
        return cls(phi=phi, metric=metric)
