"""Geometry module — G₂ metric construction and certification.

Submodules:
    tcs: Twisted Connected Sum assembly from building blocks
    metric: Chebyshev-Cholesky metric reconstruction
    holonomy: G₂ structure (phi0, torsion computation)
    certification: Newton-Kantorovich rigorous certification
"""

from .manifold import G2Manifold
from .tcs import TCSManifold
from .metric import ChebyshevMetric
from .holonomy import G2Structure
from .certification import NKCertification
from .donaldson import (
    BaseCoframeVariation,
    BaseGeometryCandidate,
    ChebyshevProfile,
    DonaldsonG2Ansatz,
    DonaldsonRadialSolution,
    DonaldsonSO3Connection,
    DonaldsonTopology,
    FanoIncidenceGraphIdentifier,
    FanoMeridianModel,
    FanoLinkBaseGeometry,
    FanoPLWirtingerCandidate,
    FanoSevenComponentLink,
    HeawoodGraph,
    HyperkahlerRotation,
    K7FanoColoredGraph,
    LinkProjectionCrossing,
    LinkProjectionDiagram,
    RotatingCoframeDonaldsonSolution,
    SignedDonaldsonRadialSolution,
    SpatialGraphCandidate,
    audit_fano_meridian_rotation,
    audit_global_base_geometry,
    audit_rotation_holonomy,
    audit_spatial_embedding_candidates,
    dense_donaldson_report,
    solve_fano_meridian_profile,
    solve_min_energy_radial_profile,
    solve_rotating_coframe_profile,
    solve_signed_radial_profile,
)

__all__ = [
    "G2Manifold",
    "TCSManifold",
    "ChebyshevMetric",
    "G2Structure",
    "NKCertification",
    "FanoMeridianModel",
    "FanoIncidenceGraphIdentifier",
    "SpatialGraphCandidate",
    "K7FanoColoredGraph",
    "HeawoodGraph",
    "FanoSevenComponentLink",
    "LinkProjectionCrossing",
    "LinkProjectionDiagram",
    "DonaldsonTopology",
    "DonaldsonG2Ansatz",
    "ChebyshevProfile",
    "DonaldsonSO3Connection",
    "HyperkahlerRotation",
    "BaseCoframeVariation",
    "BaseGeometryCandidate",
    "FanoLinkBaseGeometry",
    "FanoPLWirtingerCandidate",
    "DonaldsonRadialSolution",
    "SignedDonaldsonRadialSolution",
    "RotatingCoframeDonaldsonSolution",
    "solve_min_energy_radial_profile",
    "solve_rotating_coframe_profile",
    "solve_signed_radial_profile",
    "audit_global_base_geometry",
    "audit_rotation_holonomy",
    "audit_spatial_embedding_candidates",
    "audit_fano_meridian_rotation",
    "solve_fano_meridian_profile",
    "dense_donaldson_report",
]
