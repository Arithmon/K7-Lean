"""Laplace-Beltrami eigenvalue bounds.

Methods:
    - Gershgorin circle theorem (cheap, rough bounds)
    - Rayleigh quotient (variational, tighter bounds)
    - Cheeger inequality (isoperimetric, lower bound)
"""

from typing import Optional
import numpy as np


def gershgorin_bounds(stiffness_matrix: np.ndarray) -> tuple:
    """Compute Gershgorin eigenvalue bounds from stiffness matrix.

    Args:
        stiffness_matrix: Symmetric matrix from FEM discretization

    Returns:
        (min_eigenvalue_bound, max_eigenvalue_bound)
    """
    diag = np.diag(stiffness_matrix)
    off_diag_sum = np.sum(np.abs(stiffness_matrix), axis=1) - np.abs(diag)
    lower = np.min(diag - off_diag_sum)
    upper = np.max(diag + off_diag_sum)
    return (float(lower), float(upper))


def rayleigh_quotient(stiffness: np.ndarray, mass: np.ndarray,
                      v: np.ndarray) -> float:
    """Compute the Rayleigh quotient R(v) = (v^T K v) / (v^T M v).

    Args:
        stiffness: Stiffness matrix K
        mass: Mass matrix M
        v: Test vector

    Returns:
        Rayleigh quotient (upper bound on lambda_1 if v is not an eigenmode)
    """
    numerator = float(v @ stiffness @ v)
    denominator = float(v @ mass @ v)
    if denominator == 0:
        raise ValueError("Test vector is in the null space of the mass matrix")
    return numerator / denominator


def cheeger_lower_bound(cheeger_constant: float) -> float:
    """Lower bound on lambda_1 from Cheeger's inequality.

    lambda_1 >= h^2 / 4

    Args:
        cheeger_constant: Cheeger isoperimetric constant h(M)

    Returns:
        Lower bound on the spectral gap
    """
    return cheeger_constant ** 2 / 4.0
