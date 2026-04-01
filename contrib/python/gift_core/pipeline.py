"""Pipeline orchestrator for G₂ metric computation.

Usage:
    from gift_core.pipeline import Pipeline
    from gift_core.geometry.tcs import QUINTIC, CI_2_2_2

    # GIFT's K₇
    p = Pipeline.k7()
    print(p.manifold.summary())
    print(p.spectral_gap.summary())
    print(p.certification.summary())

    # Custom manifold
    p = Pipeline(
        m1=BuildingBlock("MyBlock1", b2=12, b3=45),
        m2=BuildingBlock("MyBlock2", b2=8, b3=30),
    )
    p.load_metric("my_metric.json")
    p.certify()
"""

from dataclasses import dataclass, field
from typing import Optional

from .geometry.tcs import TCSManifold, BuildingBlock, QUINTIC, CI_2_2_2
from .geometry.metric import ChebyshevMetric
from .geometry.holonomy import G2Structure
from .geometry.certification import NKCertification
from .spectral.gap import SpectralGap


@dataclass
class Pipeline:
    """End-to-end G₂ metric computation pipeline.

    Stages:
        1. Topology: Define manifold from building blocks
        2. Metric: Construct/load Chebyshev-Cholesky parameterization
        3. Holonomy: Verify G₂ structure and compute torsion
        4. Certification: Newton-Kantorovich rigorous bounds
        5. Spectral: Compute eigenvalues and mass gap
        6. Observables: Extract physical predictions
    """
    manifold: Optional[TCSManifold] = None
    metric: Optional[ChebyshevMetric] = None
    g2_structure: Optional[G2Structure] = None
    certification: Optional[NKCertification] = None
    spectral_gap: Optional[SpectralGap] = None

    def __init__(self, m1: Optional[BuildingBlock] = None,
                 m2: Optional[BuildingBlock] = None,
                 neck_length: float = 5.0):
        if m1 is not None and m2 is not None:
            self.manifold = TCSManifold(m1=m1, m2=m2, neck_length=neck_length)
        self.metric = None
        self.g2_structure = None
        self.certification = None
        self.spectral_gap = None

    def load_metric(self, path: str) -> "Pipeline":
        """Load metric parameters from a JSON artifact."""
        self.metric = ChebyshevMetric.from_json(path)
        return self

    def certify(self, torsion_norm: float, spectral_gap: float,
                lipschitz: float) -> NKCertification:
        """Run Newton-Kantorovich certification with given bounds."""
        self.certification = NKCertification(
            torsion_norm=torsion_norm,
            spectral_gap=spectral_gap,
            lipschitz=lipschitz,
        )
        return self.certification

    def summary(self) -> dict:
        """Full pipeline status."""
        result = {}
        if self.manifold:
            result["manifold"] = self.manifold.summary()
        if self.metric:
            result["metric"] = {"n_params": self.metric.n_params}
        if self.certification:
            result["certification"] = self.certification.summary()
        if self.spectral_gap:
            result["spectral"] = self.spectral_gap.summary()
        return result

    @classmethod
    def k7(cls) -> "Pipeline":
        """Pre-configured pipeline for GIFT's K₇ manifold.

        K₇ = Quintic ∪_K3 CI(2,2,2), b₂=21, b₃=77
        """
        p = cls(m1=QUINTIC, m2=CI_2_2_2)
        p.metric = ChebyshevMetric(dim=7, n_cheb=6)
        p.g2_structure = G2Structure.canonical()
        p.certification = NKCertification(
            torsion_norm=2.98e-5,
            spectral_gap=0.12467,
            lipschitz=0.0089,
        )
        p.spectral_gap = SpectralGap.k7()
        return p
