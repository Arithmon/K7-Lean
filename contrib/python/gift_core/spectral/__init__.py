"""Spectral module — eigenvalue computation and spectral gap analysis.

Submodules:
    laplacian: Eigenvalue bounds (Gershgorin, Rayleigh quotient)
    harmonics: Harmonic form computation
    gap: Mass gap lambda_1 analysis
"""

from .gap import SpectralGap

__all__ = ["SpectralGap"]
