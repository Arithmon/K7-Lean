"""Chebyshev-Cholesky metric reconstruction.

Represents a G₂ metric via its Cholesky factor L(s) parameterized
by Chebyshev polynomials. The metric is g(s) = L(s) L(s)^T,
ensuring positive-definiteness by construction.

The parameter space is R^N where N = n_params (e.g., 169 for K₇).
"""

from dataclasses import dataclass, field
from typing import Optional
import numpy as np


@dataclass
class ChebyshevMetric:
    """A G₂ metric parameterized by Chebyshev-Cholesky coefficients.

    Parameters:
        dim: Manifold dimension (7 for G₂)
        n_cheb: Number of Chebyshev modes per Cholesky entry
        params: Flattened parameter vector (Chebyshev coefficients)
    """
    dim: int = 7
    n_cheb: int = 6
    params: Optional[np.ndarray] = None

    @property
    def n_cholesky_entries(self) -> int:
        """Number of independent entries in lower-triangular Cholesky factor."""
        return self.dim * (self.dim + 1) // 2

    @property
    def n_params(self) -> int:
        """Total parameter count."""
        return self.n_cholesky_entries * self.n_cheb

    def cholesky_factor(self, s: np.ndarray) -> np.ndarray:
        """Evaluate L(s) at coordinate points s.

        Args:
            s: Coordinate array of shape (n_points, dim)

        Returns:
            L: Cholesky factors of shape (n_points, dim, dim)
        """
        if self.params is None:
            raise ValueError("Metric parameters not set. Load or optimize first.")

        n_points = s.shape[0]
        L = np.zeros((n_points, self.dim, self.dim))

        idx = 0
        for i in range(self.dim):
            for j in range(i + 1):
                coeffs = self.params[idx * self.n_cheb:(idx + 1) * self.n_cheb]
                L[:, i, j] = self._eval_chebyshev(s, coeffs)
                idx += 1

        return L

    def metric_tensor(self, s: np.ndarray) -> np.ndarray:
        """Evaluate g(s) = L(s) L(s)^T at coordinate points.

        Args:
            s: Coordinate array of shape (n_points, dim)

        Returns:
            g: Metric tensors of shape (n_points, dim, dim)
        """
        L = self.cholesky_factor(s)
        return np.einsum("...ij,...kj->...ik", L, L)

    def determinant(self, s: np.ndarray) -> np.ndarray:
        """Evaluate det(g) = det(L)^2 at coordinate points."""
        L = self.cholesky_factor(s)
        det_L = np.prod(np.diagonal(L, axis1=-2, axis2=-1), axis=-1)
        return det_L ** 2

    @staticmethod
    def _eval_chebyshev(s: np.ndarray, coeffs: np.ndarray) -> np.ndarray:
        """Evaluate a Chebyshev series at points s[:,0] (1D for now)."""
        t = s[:, 0] if s.ndim > 1 else s
        result = np.zeros_like(t)
        for k, c in enumerate(coeffs):
            result += c * np.cos(k * np.arccos(np.clip(t, -1, 1)))
        return result

    @classmethod
    def from_json(cls, path: str) -> "ChebyshevMetric":
        """Load metric parameters from a JSON artifact."""
        import json
        with open(path) as f:
            data = json.load(f)
        metric = cls(
            dim=data.get("dim", 7),
            n_cheb=data.get("n_cheb", 6),
        )
        metric.params = np.array(data["params"])
        return metric
