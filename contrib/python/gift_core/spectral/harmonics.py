"""Harmonic form computation on G₂ manifolds.

Harmonic k-forms span H^k(M) and are needed for:
    - Yukawa couplings: Y_ijk = integral omega_i ^ omega_j ^ omega_k
    - Moduli space geometry
    - Physical observable extraction

Methods:
    - PINN (Physics-Informed Neural Networks) — learns harmonic forms
    - Hodge decomposition — projects onto harmonic subspace
    - Spectral methods — from eigenbasis of Laplacian
"""

from dataclasses import dataclass
from typing import Optional
import numpy as np


@dataclass
class HarmonicBasis:
    """A basis of harmonic k-forms on a manifold.

    Parameters:
        degree: Form degree k
        dimension: Number of independent harmonic k-forms (= b_k)
        coefficients: Coefficient matrix (n_points x b_k x n_components)
    """
    degree: int
    dimension: int
    coefficients: Optional[np.ndarray] = None

    @property
    def is_computed(self) -> bool:
        return self.coefficients is not None

    def inner_product(self, i: int, j: int) -> float:
        """Compute <omega_i, omega_j> = integral omega_i ^ *omega_j."""
        if not self.is_computed:
            raise ValueError("Harmonic basis not yet computed")
        return float(np.sum(
            self.coefficients[:, i, :] * self.coefficients[:, j, :]
        ))

    def orthonormality_check(self) -> np.ndarray:
        """Check orthonormality: returns the Gram matrix."""
        if not self.is_computed:
            raise ValueError("Harmonic basis not yet computed")
        gram = np.zeros((self.dimension, self.dimension))
        for i in range(self.dimension):
            for j in range(self.dimension):
                gram[i, j] = self.inner_product(i, j)
        return gram
