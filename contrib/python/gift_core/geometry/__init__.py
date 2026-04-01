"""Geometry module — G₂ metric construction and certification.

Submodules:
    tcs: Twisted Connected Sum assembly from building blocks
    metric: Chebyshev-Cholesky metric reconstruction
    holonomy: G₂ structure (phi0, torsion computation)
    certification: Newton-Kantorovich rigorous certification
"""

from .tcs import TCSManifold
from .metric import ChebyshevMetric
from .holonomy import G2Structure
from .certification import NKCertification

__all__ = ["TCSManifold", "ChebyshevMetric", "G2Structure", "NKCertification"]
