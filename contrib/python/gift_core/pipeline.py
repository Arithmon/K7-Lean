"""Pipeline orchestrator for G₂ metric computation."""

from dataclasses import dataclass, field
from typing import Optional, Dict, List, Any

from .geometry.tcs import TCSManifold, BuildingBlock, QUINTIC, CI_2_2_2
from .geometry.metric import ChebyshevMetric
from .geometry.holonomy import G2Structure
from .geometry.certification import NKCertification
from .spectral.gap import SpectralGap

# Optional imports with graceful fallback

try:
    from .physics.coupling_constants import GaugeCouplings, GIFT_COUPLINGS
    _HAS_COUPLINGS = True
except ImportError:
    _HAS_COUPLINGS = False

try:
    from .experimental import GIFT_COMPARISONS, summary_table, Comparison
    _HAS_EXPERIMENTAL = True
except ImportError:
    _HAS_EXPERIMENTAL = False

try:
    from .relations import PROVEN_RELATIONS
    _HAS_RELATIONS = True
except ImportError:
    _HAS_RELATIONS = False

try:
    from .topology import K7, G2, E8
    _HAS_TOPOLOGY = True
except ImportError:
    _HAS_TOPOLOGY = False

try:
    from .constants import (
        B2, B3, H_STAR, DIM_G2, DIM_E8, RANK_E8, DIM_K7,
        SIN2_THETA_W, Q_KOIDE, M_TAU_M_E, M_S_M_D,
        ALPHA_INV_BASE, ALPHA_S_DENOM, N_GEN, DELTA_CP,
    )
    _HAS_CONSTANTS = True
except ImportError:
    _HAS_CONSTANTS = False


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

    @classmethod
    def from_approximate_metric(cls, manifold: TCSManifold,
                                torsion_norm: float,
                                spectral_gap: float,
                                lipschitz: float,
                                metric_path: Optional[str] = None,
                                ) -> "Pipeline":
        """Certify any approximate G₂ metric via Newton-Kantorovich.

        Args:
            manifold: The TCS manifold (topology only)
            torsion_norm: Measured ||T(phi)||_C0 of the approximate metric
            spectral_gap: Lower bound on first nonzero Laplacian eigenvalue
            lipschitz: Lipschitz constant of the torsion map linearization
            metric_path: Optional path to metric coefficients (JSON)

        Returns:
            Pipeline with certification status.
        """
        p = cls.__new__(cls)
        p.manifold = manifold
        p.metric = None
        if metric_path:
            p.metric = ChebyshevMetric.from_json(metric_path)
        p.g2_structure = G2Structure.canonical()
        p.certification = NKCertification(
            torsion_norm=torsion_norm,
            spectral_gap=spectral_gap,
            lipschitz=lipschitz,
        )
        p.spectral_gap = SpectralGap(
            numerical=spectral_gap,
            lower_bound=spectral_gap * 0.9,
            upper_bound=spectral_gap * 2.0,
        )
        return p

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

    def extract_observables(self) -> Dict[str, Any]:
        """Extract all physical observables from the pipeline state.

        Collects topology, gauge couplings, mass ratios, spectral data,
        certification status, proven relations, and experimental comparisons
        into a single dictionary.

        Returns:
            Dictionary with keys: 'topology', 'couplings', 'mass_ratios',
            'spectral', 'certification', 'proven_relations',
            'experimental_comparison'.
        """
        obs: Dict[str, Any] = {}

        # --- Topology ---
        if self.manifold is not None:
            obs['topology'] = {
                'b2': self.manifold.b2,
                'b3': self.manifold.b3,
                'h_star': self.manifold.h_star,
                'euler': self.manifold.euler_characteristic,
                'dim': self.manifold.dim,
            }
        elif _HAS_TOPOLOGY:
            obs['topology'] = {
                'b2': K7.b2,
                'b3': K7.b3,
                'h_star': K7.h_star,
                'euler': K7.euler_characteristic,
                'dim': K7.dim,
            }

        # --- Gauge couplings ---
        if _HAS_COUPLINGS:
            gc = GIFT_COUPLINGS
            obs['couplings'] = {
                'sin2_theta_w': float(gc.sin2_theta_w),
                'sin2_theta_w_exact': str(gc.sin2_theta_w),
                'alpha_s_denominator': gc.alpha_s_structure['denominator'],
                'alpha_em_inv_base': gc.alpha_em_inverse_base,
                'n_generations': gc.n_generations,
            }
        elif _HAS_CONSTANTS:
            from fractions import Fraction
            obs['couplings'] = {
                'sin2_theta_w': float(SIN2_THETA_W),
                'sin2_theta_w_exact': str(SIN2_THETA_W),
                'alpha_s_denominator': ALPHA_S_DENOM,
                'alpha_em_inv_base': ALPHA_INV_BASE,
                'n_generations': N_GEN,
            }

        # --- Mass ratios ---
        if _HAS_CONSTANTS:
            from fractions import Fraction
            obs['mass_ratios'] = {
                'm_tau_over_m_e': M_TAU_M_E,
                'm_s_over_m_d': M_S_M_D,
                'Q_Koide': float(Q_KOIDE),
                'Q_Koide_exact': str(Q_KOIDE),
                'delta_CP': DELTA_CP,
            }
        else:
            # Hardcoded fallback from certified values
            obs['mass_ratios'] = {
                'm_tau_over_m_e': 3477,
                'm_s_over_m_d': 20,
                'Q_Koide': 2 / 3,
                'Q_Koide_exact': '2/3',
                'delta_CP': 197,
            }

        # --- Spectral data ---
        if self.spectral_gap is not None:
            obs['spectral'] = {
                'lambda1': self.spectral_gap.lambda1,
                'mass_gap_exists': self.spectral_gap.is_positive,
            }
            if self.spectral_gap.analytical is not None:
                obs['spectral']['analytical_formula'] = (
                    f"{self.spectral_gap.analytical} * pi^2"
                )

        # --- Certification ---
        if self.certification is not None:
            obs['certification'] = self.certification.summary()

        # --- Proven relations ---
        if _HAS_RELATIONS:
            obs['proven_relations'] = [
                {
                    'name': r.name,
                    'symbol': r.symbol,
                    'value': float(r.value) if hasattr(r.value, '__float__') else r.value,
                    'formula': r.formula,
                    'lean_theorem': r.lean_theorem,
                }
                for r in PROVEN_RELATIONS
            ]

        # --- Experimental comparison ---
        if _HAS_EXPERIMENTAL:
            obs['experimental_comparison'] = [
                {
                    'name': c.name,
                    'symbol': c.symbol,
                    'prediction': c.prediction,
                    'experimental': c.measurement.value,
                    'sigma_deviation': c.deviation,
                    'percent_diff': c.percent_diff,
                    'agrees_3sigma': c.agrees,
                    'gift_formula': c.gift_formula,
                }
                for c in GIFT_COMPARISONS
            ]

        return obs

    def validate(self) -> Dict[str, Any]:
        """Generate a validation report comparing predictions to experiment.

        Returns:
            Dictionary with keys: 'total_predictions', 'tested',
            'within_1_percent', 'exact_matches', 'mean_deviation_percent',
            'comparisons'.
        """
        if not _HAS_EXPERIMENTAL:
            return {
                'error': 'experimental module not available',
                'total_predictions': 0,
                'tested': 0,
                'within_1_percent': 0,
                'exact_matches': 0,
                'mean_deviation_percent': float('nan'),
                'comparisons': [],
            }

        comparisons: List[Dict[str, Any]] = []
        within_1 = 0
        exact = 0
        total_pct = 0.0

        for c in GIFT_COMPARISONS:
            pct = abs(c.percent_diff)
            entry = {
                'name': c.name,
                'symbol': c.symbol,
                'prediction': c.prediction,
                'experimental': c.measurement.value,
                'experimental_error': c.measurement.error,
                'sigma_deviation': c.deviation,
                'percent_diff': c.percent_diff,
                'agrees_3sigma': c.agrees,
            }
            comparisons.append(entry)
            total_pct += pct
            if pct < 1.0:
                within_1 += 1
            if pct < 0.01:
                exact += 1

        tested = len(comparisons)
        mean_dev = total_pct / tested if tested > 0 else 0.0

        # Count total predictions (proven relations if available)
        total = len(PROVEN_RELATIONS) if _HAS_RELATIONS else tested

        return {
            'total_predictions': total,
            'tested': tested,
            'within_1_percent': within_1,
            'exact_matches': exact,
            'mean_deviation_percent': mean_dev,
            'comparisons': comparisons,
        }

    def __repr__(self) -> str:
        parts = ["Pipeline("]

        # Manifold
        if self.manifold is not None:
            m = self.manifold
            parts.append(
                f"  manifold: {m.m1.name} U {m.m2.name}, "
                f"b2={m.b2}, b3={m.b3}, H*={m.h_star}"
            )
        else:
            parts.append("  manifold: not configured")

        # Metric
        if self.metric is not None:
            parts.append(f"  metric: Chebyshev-Cholesky, {self.metric.n_params} params")
        else:
            parts.append("  metric: not loaded")

        # G2 structure
        if self.g2_structure is not None:
            parts.append("  g2_structure: configured")
        else:
            parts.append("  g2_structure: not configured")

        # Certification
        if self.certification is not None:
            cert = self.certification
            parts.append(
                f"  certification: torsion={cert.torsion_norm:.2e}, "
                f"certified={cert.is_certified}"
            )
        else:
            parts.append("  certification: not run")

        # Spectral gap
        if self.spectral_gap is not None:
            sg = self.spectral_gap
            parts.append(
                f"  spectral_gap: lambda1={sg.lambda1:.5f}, "
                f"mass_gap={sg.is_positive}"
            )
        else:
            parts.append("  spectral_gap: not computed")

        # Validation summary (if experimental data available)
        if _HAS_EXPERIMENTAL:
            report = self.validate()
            parts.append(
                f"  validation: {report['tested']} tested, "
                f"{report['within_1_percent']} within 1%, "
                f"mean_dev={report['mean_deviation_percent']:.4f}%"
            )

        parts.append(")")
        return "\n".join(parts)

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
