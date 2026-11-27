"""
Physical scales and dimensional parameters.

Provides Planck, string, and GUT scale parameters for
dimensional analysis and Monte Carlo simulations.
"""
from dataclasses import dataclass
from typing import Optional
import math

__all__ = [
    'M_PLANCK', 'M_PLANCK_REDUCED', 'M_STRING_DEFAULT', 'M_STRING_MIN', 'M_STRING_MAX',
    'M_GUT', 'M_EW', 'M_Z', 'M_W', 'LAMBDA_QCD',
    'ScaleHierarchy', 'S7Parameters', 'DEFAULT_SCALES',
    'string_scale_from_volume', 'effective_4d_planck',
]

# =============================================================================
# FUNDAMENTAL SCALES (in GeV unless noted)
# =============================================================================

# Planck scale: M_P = sqrt(hbar * c / G_N)
M_PLANCK = 1.22089e19  # GeV (reduced Planck mass)
M_PLANCK_REDUCED = 2.435e18  # GeV (M_P / sqrt(8*pi))

# String scale: varies with compactification
M_STRING_DEFAULT = 5.0e17  # GeV (typical heterotic)
M_STRING_MIN = 1.0e16  # GeV (lower bound from proton decay)
M_STRING_MAX = M_PLANCK  # GeV (cannot exceed Planck)

# GUT scale
M_GUT = 2.0e16  # GeV (gauge coupling unification)

# Electroweak scale
M_EW = 246.22  # GeV (Higgs VEV)
M_Z = 91.1876  # GeV (Z boson mass)
M_W = 80.377  # GeV (W boson mass)

# QCD scale
LAMBDA_QCD = 0.217  # GeV (MS-bar)


@dataclass
class ScaleHierarchy:
    """
    Physical scale hierarchy for dimensional analysis.

    The string scale M_s relates to Planck scale via:
        M_s = M_P * g_s^(1/4) / V_K7^(1/2)

    where g_s is string coupling and V_K7 is K7 volume.
    """
    m_planck: float = M_PLANCK
    m_string: float = M_STRING_DEFAULT
    m_gut: float = M_GUT
    m_ew: float = M_EW

    @property
    def ratio_string_planck(self) -> float:
        """M_s / M_P ratio (compactification dependent)."""
        return self.m_string / self.m_planck

    @property
    def ratio_gut_string(self) -> float:
        """M_GUT / M_s ratio."""
        return self.m_gut / self.m_string

    @property
    def hierarchy_ew_planck(self) -> float:
        """M_EW / M_P (the hierarchy problem)."""
        return self.m_ew / self.m_planck

    def log_ratio(self, scale1: float, scale2: float) -> float:
        """log10(scale1/scale2) for RG running."""
        return math.log10(scale1 / scale2)


@dataclass
class S7Parameters:
    """
    Parameters for S7 (7-sphere) geometry in M-theory.

    The 7-sphere appears as:
    - Internal space in 11D supergravity: M_11 = M_4 x S7
    - Hopf fibration: S7 -> S4 with S3 fiber
    - G2 holonomy deformation: S7 -> K7

    The deformation parameter controls torsion.
    """
    # Radius of S7 in Planck units
    radius: float = 1.0

    # Squashing parameter (1 = round, <1 = squashed)
    squash: float = 1.0

    # Torsion deformation: S7 -> K7 with G2 holonomy
    # kappa controls the strength of torsion
    kappa: float = 1.0 / 61  # Default: kappa_T from GIFT

    @property
    def volume_s7(self) -> float:
        """
        Volume of unit S7: Vol(S7) = pi^4 / 3
        Actual volume scaled by radius^7.
        """
        return (math.pi ** 4 / 3) * (self.radius ** 7)

    @property
    def volume_k7(self) -> float:
        """
        Volume model for K7 (heuristic, not a certified quantity).
        Related to S7 by torsion deformation.
        """
        # Torsion reduces effective volume
        torsion_factor = 1.0 - self.kappa * self.squash
        return self.volume_s7 * abs(torsion_factor)


def string_scale_from_volume(v_k7: float, g_s: float = 0.1,
                              m_p: float = M_PLANCK) -> float:
    """
    Compute string scale from K7 volume and string coupling.

    M_s = M_P * g_s^(1/4) / V^(1/2)

    Args:
        v_k7: Dimensionless K7 volume (in Planck units^7)
        g_s: String coupling constant
        m_p: Planck mass in GeV

    Returns:
        String scale in GeV
    """
    return m_p * (g_s ** 0.25) / math.sqrt(v_k7)


def effective_4d_planck(m_11: float, v_7: float) -> float:
    """
    4D Planck mass from 11D M-theory compactification.

    M_P^2 = M_11^9 * V_7

    Args:
        m_11: 11D Planck mass
        v_7: Volume of internal 7-manifold

    Returns:
        4D Planck mass
    """
    return math.sqrt((m_11 ** 9) * v_7)


# Default instances
DEFAULT_SCALES = ScaleHierarchy()
DEFAULT_S7 = S7Parameters()
