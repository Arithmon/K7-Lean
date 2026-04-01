"""Newton-Kantorovich certification for G₂ metrics.

Given an approximate torsion-free G₂ metric, the NK theorem provides
rigorous bounds guaranteeing the existence of a true torsion-free
metric nearby, with quantitative error estimates.

Key parameters:
    beta: Inverse operator bound (1/lambda_1_perp)
    eta_0: Initial residual (||T(phi_0)|| / lambda_1_perp)
    rho: Contraction rate
    h: Kantorovich parameter (must be < 0.5 for convergence)
    r: Uniqueness ball radius (eta_0 / (1 - rho))
"""

from dataclasses import dataclass
from typing import Optional


@dataclass
class NKCertification:
    """Newton-Kantorovich certification result.

    Parameters:
        torsion_norm: ||T(phi_0)|| (C^0 norm of torsion)
        spectral_gap: lambda_1_perp (first nonzero eigenvalue)
        lipschitz: Lipschitz constant of the linearized operator
    """
    torsion_norm: float
    spectral_gap: float
    lipschitz: float

    @property
    def beta(self) -> float:
        """Inverse operator bound."""
        return 1.0 / self.spectral_gap

    @property
    def eta_0(self) -> float:
        """Initial step size."""
        return self.torsion_norm / self.spectral_gap

    @property
    def gamma(self) -> float:
        """Second derivative bound."""
        return self.lipschitz

    @property
    def h(self) -> float:
        """Kantorovich parameter h = beta * gamma * eta_0. Must be < 0.5."""
        return self.beta * self.gamma * self.eta_0

    @property
    def is_certified(self) -> bool:
        """Whether the NK certification succeeds (h < 0.5)."""
        return self.h < 0.5

    @property
    def contraction_rate(self) -> float:
        """Contraction rate rho = h / (1 - sqrt(1 - 2h))."""
        if not self.is_certified:
            return float("inf")
        import math
        return self.h / (1.0 - math.sqrt(1.0 - 2.0 * self.h))

    @property
    def uniqueness_radius(self) -> float:
        """Radius of the uniqueness ball."""
        rho = self.contraction_rate
        if rho >= 1.0:
            return float("inf")
        return self.eta_0 / (1.0 - rho)

    @property
    def safety_margin(self) -> float:
        """How far below the h < 0.5 threshold. Higher = safer."""
        return 0.5 / self.h if self.h > 0 else float("inf")

    def summary(self) -> dict:
        return {
            "certified": self.is_certified,
            "h": self.h,
            "h_threshold": 0.5,
            "safety_margin": f"{self.safety_margin:.1f}x",
            "contraction_rate": self.contraction_rate,
            "uniqueness_radius": self.uniqueness_radius,
            "torsion_norm": self.torsion_norm,
            "spectral_gap": self.spectral_gap,
        }

    def __repr__(self) -> str:
        status = "CERTIFIED" if self.is_certified else "FAILED"
        return (
            f"NKCertification({status}: h={self.h:.6f}, "
            f"margin={self.safety_margin:.1f}x, "
            f"rho={self.contraction_rate:.4f})"
        )
