"""
Gauge coupling constants from G2 compactification.

GIFT predictions:
- sin^2(theta_W) = 3/13 ~ 0.231
- alpha_s denominator = 12
- alpha^{-1} base = 137
"""

from dataclasses import dataclass
from typing import Dict
from fractions import Fraction


# GIFT certified coupling values
SIN2_THETA_W = Fraction(3, 13)
ALPHA_S_DENOM = 12
ALPHA_INV_BASE = 137


@dataclass
class GaugeCouplings:
    """
    Standard Model gauge couplings from G2 geometry.

    The gauge couplings are determined by:
    1. Betti numbers: b2 = 21, b3 = 77
    2. G2 holonomy: dim(G2) = 14
    3. E8 structure: dim(E8) = 248, rank = 8

    Attributes:
        b2: Second Betti number
        b3: Third Betti number
        dim_g2: Dimension of G2
    """

    b2: int = 21
    b3: int = 77
    dim_g2: int = 14
    dim_e8: int = 248
    rank_e8: int = 8
    weyl_factor: int = 5
    d_bulk: int = 11

    @property
    def h_star(self) -> int:
        """H* = b2 + b3 + 1 = 99."""
        return self.b2 + self.b3 + 1

    @property
    def p2(self) -> int:
        """Binary ratio p2 = dim(G2)/dim(K7) = 2 (not a Pontryagin class)."""
        return self.dim_g2 // 7

    @property
    def sin2_theta_w(self) -> Fraction:
        """
        Weinberg angle: sin^2(theta_W) = b2 / (b3 + dim(G2)).

        = 21 / (77 + 14) = 21/91 = 3/13
        """
        return Fraction(self.b2, self.b3 + self.dim_g2)

    @property
    def sin2_theta_w_float(self) -> float:
        """Weinberg angle as float."""
        return float(self.sin2_theta_w)

    @property
    def alpha_s_structure(self) -> Dict:
        """
        Strong coupling structure.

        alpha_s ~ 2 / (dim(G2) - p2)^2 = 2/144 = 1/72
        """
        denom = self.dim_g2 - self.p2  # = 12
        return {
            'denominator': denom,
            'denominator_sq': denom ** 2,  # = 144
            'alpha_s_approx': 2 / (denom ** 2)  # ~ 0.0139
        }

    @property
    def alpha_em_inverse_base(self) -> int:
        """
        Fine structure constant base.

        alpha^{-1} ~ (dim(E8) + rank(E8))/2 + H*/D_bulk
                   = 128 + 9 = 137
        """
        algebraic = (self.dim_e8 + self.rank_e8) // 2  # = 128
        bulk = self.h_star // self.d_bulk  # = 9
        return algebraic + bulk  # = 137

    @property
    def n_generations(self) -> int:
        """
        Number of generations: N_gen = rank(E8) - Weyl = 3.
        """
        return self.rank_e8 - self.weyl_factor

    def summary(self) -> Dict:
        """
        Summary of all gauge coupling predictions.

        Returns:
            Dictionary with all predictions
        """
        return {
            'sin2_theta_w': {
                'value': self.sin2_theta_w,
                'float': self.sin2_theta_w_float,
                'experimental': 0.23122,
                'deviation_percent': abs(self.sin2_theta_w_float - 0.23122) / 0.23122 * 100
            },
            'alpha_s_denominator': {
                'value': self.alpha_s_structure['denominator'],
                'formula': 'dim(G2) - p2 = 14 - 2 = 12'
            },
            'alpha_inverse_base': {
                'value': self.alpha_em_inverse_base,
                'formula': '(dim(E8) + rank(E8))/2 + H*/D_bulk'
            },
            'n_generations': {
                'value': self.n_generations,
                'formula': 'rank(E8) - Weyl = 8 - 5 = 3'
            }
        }


# Pre-configured GIFT couplings
GIFT_COUPLINGS = GaugeCouplings()


def coupling_unification() -> Dict:
    """
    Gauge coupling unification from G2 geometry.

    At the GUT scale, couplings should unify.
    The running is determined by beta functions
    with G2-determined particle content.

    Returns:
        Unification data
    """
    couplings = GIFT_COUPLINGS

    # GUT-scale couplings (simplified)
    sin2_w = couplings.sin2_theta_w_float
    cos2_w = 1 - sin2_w

    # At unification:
    # g1^2 / g^2 = sin^2(theta_W)
    # g2^2 / g^2 = cos^2(theta_W)

    return {
        'sin2_theta_w_gut': sin2_w,
        'cos2_theta_w_gut': cos2_w,
        'unification_scale': 'M_GUT ~ 10^16 GeV',
        'proton_decay': {
            'mode': 'p -> e+ pi0',
            'lifetime': '> 10^34 years (experimental bound)'
        }
    }


def electroweak_mixing() -> Dict:
    """
    Electroweak mixing parameters.

    sin^2(theta_W) = g'^2 / (g^2 + g'^2)

    where g is SU(2) coupling and g' is U(1) coupling.
    """
    sin2_w = float(SIN2_THETA_W)

    return {
        'sin2_theta_w': sin2_w,
        'cos2_theta_w': 1 - sin2_w,
        'theta_w_degrees': np.arcsin(np.sqrt(sin2_w)) * 180 / np.pi,
        'experimental': {
            'value': 0.23122,
            'uncertainty': 0.00004,
            'source': 'PDG 2024'
        }
    }


# Import numpy for arcsin
import numpy as np
