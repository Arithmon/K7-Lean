"""Spectral gap computation for G₂ manifolds.

The mass gap lambda_1 is the first nonzero eigenvalue of the
Laplace-Beltrami operator on the compact G₂ manifold.

For K₇: lambda_1 = 6 pi^2 / 475 ~ 0.12467 (analytical)
        lambda_1 ~ 0.12461 (numerical, Richardson extrapolation N=1200)
"""

from dataclasses import dataclass
from fractions import Fraction
from typing import Optional
import math


@dataclass
class SpectralGap:
    """Spectral gap analysis for a G₂ manifold.

    Can be initialized from:
        - Analytical formula (if known)
        - Numerical computation
        - Cheeger/Rayleigh bounds
    """
    analytical: Optional[Fraction] = None
    numerical: Optional[float] = None
    lower_bound: Optional[float] = None
    upper_bound: Optional[float] = None

    @property
    def lambda1(self) -> float:
        """Best estimate of the spectral gap."""
        if self.analytical is not None:
            return float(self.analytical) * math.pi ** 2
        if self.numerical is not None:
            return self.numerical
        if self.lower_bound is not None and self.upper_bound is not None:
            return (self.lower_bound + self.upper_bound) / 2
        raise ValueError("No spectral gap data available")

    @property
    def is_positive(self) -> bool:
        """Whether lambda_1 > 0 (mass gap exists)."""
        if self.lower_bound is not None:
            return self.lower_bound > 0
        return self.lambda1 > 0

    def summary(self) -> dict:
        result = {"lambda1": self.lambda1, "mass_gap_exists": self.is_positive}
        if self.analytical is not None:
            result["analytical_formula"] = f"{self.analytical} * pi^2"
        if self.lower_bound is not None:
            result["lower_bound"] = self.lower_bound
        if self.upper_bound is not None:
            result["upper_bound"] = self.upper_bound
        return result

    @classmethod
    def k7(cls) -> "SpectralGap":
        """Spectral gap for GIFT's K₇ manifold.

        lambda_1 = pi^2 / (L^2 * g_ss) = pi^2 / (25 * 19/6) = 6*pi^2/475
        """
        return cls(
            analytical=Fraction(6, 475),
            numerical=0.12461,
            lower_bound=0.3726,
            upper_bound=1.4459,
        )
