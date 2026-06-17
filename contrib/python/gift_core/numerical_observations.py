"""GIFT numerical coincidences (observations, NOT formally proven theorems)."""

import math
from fractions import Fraction
from dataclasses import dataclass
from typing import Optional

# Import GIFT constants
from .constants import TAU, DIM_E8, RANK_E8, B2, B3

# Euler-Mascheroni constant (high precision)
EULER_GAMMA = 0.5772156649015329

# Golden ratio
PHI = (1 + math.sqrt(5)) / 2

# Coxeter number of E8
COXETER_E8 = 30


@dataclass
class NumericalObservation:
    """A numerical coincidence with computed deviation."""
    name: str
    computed: float
    target: float
    target_description: str
    deviation_percent: float
    formula: str
    significance: str  # "high", "medium", "low"

    def __str__(self) -> str:
        return (
            f"{self.name}: {self.computed:.6f} ≈ {self.target} ({self.target_description})\n"
            f"  Formula: {self.formula}\n"
            f"  Deviation: {self.deviation_percent:.4f}%\n"
            f"  Significance: {self.significance}"
        )


def compute_deviation(computed: float, target: float) -> float:
    """Compute percentage deviation."""
    if target == 0:
        return float('inf')
    return abs(computed - target) / abs(target) * 100


def tau_powers() -> list[NumericalObservation]:
    """Powers of tau with near-integer/structured values (approximate, not exact)."""
    tau = float(TAU)
    observations = []

    # tau^3 ≈ 60 - 1/phi^2
    tau3 = tau ** 3
    target3 = 60 - 1 / (PHI ** 2)
    observations.append(NumericalObservation(
        name="tau^3",
        computed=tau3,
        target=target3,
        target_description="60 - 1/φ²",
        deviation_percent=compute_deviation(tau3, target3),
        formula="τ³ ≈ 60 - φ⁻²",
        significance="low"
    ))

    # tau^4 ≈ 231 = 3 × 7 × 11
    tau4 = tau ** 4
    target4 = 231
    observations.append(NumericalObservation(
        name="tau^4",
        computed=tau4,
        target=target4,
        target_description="231 = 3×7×11",
        deviation_percent=compute_deviation(tau4, target4),
        formula="τ⁴ ≈ 231",
        significance="medium"
    ))

    # tau^5 ≈ 900 = h(E8)^2 where h(E8) = 30 is the Coxeter number
    tau5 = tau ** 5
    target5 = COXETER_E8 ** 2  # = 900
    observations.append(NumericalObservation(
        name="tau^5",
        computed=tau5,
        target=target5,
        target_description="900 = h(E₈)²",
        deviation_percent=compute_deviation(tau5, target5),
        formula="τ⁵ ≈ h(E₈)² = 30²",
        significance="medium"
    ))

    # tau^6 ≈ 3472 = numerator(tau)
    tau6 = tau ** 6
    target6 = 3472
    observations.append(NumericalObservation(
        name="tau^6",
        computed=tau6,
        target=target6,
        target_description="3472 = numerator(τ)",
        deviation_percent=compute_deviation(tau6, target6),
        formula="τ⁶ ≈ numerator(τ)",
        significance="low"
    ))

    return observations


def transcendental_relations() -> list[NumericalObservation]:
    """Relations involving transcendental constants (gamma, pi, e); no derivation."""
    tau = float(TAU)
    observations = []

    # tau ≈ 8 * gamma^(5*pi/12)
    exponent = 5 * math.pi / 12
    computed1 = 8 * (EULER_GAMMA ** exponent)
    observations.append(NumericalObservation(
        name="tau_gamma",
        computed=tau,
        target=computed1,
        target_description="8γ^(5π/12)",
        deviation_percent=compute_deviation(tau, computed1),
        formula="τ ≈ 8γ^(5π/12)",
        significance="high"  # Very small deviation
    ))

    # tau * gamma ≈ (3/2)^2 = 9/4
    tau_gamma = tau * EULER_GAMMA
    target2 = 2.25  # = 9/4
    observations.append(NumericalObservation(
        name="tau_times_gamma",
        computed=tau_gamma,
        target=target2,
        target_description="(3/2)² = 9/4",
        deviation_percent=compute_deviation(tau_gamma, target2),
        formula="τ × γ ≈ (3/2)²",
        significance="medium"
    ))

    return observations


def mass_relations() -> list[NumericalObservation]:
    """Approximate mass relations from tau (phenomenological; experiment from PDG 2024)."""
    tau = float(TAU)
    observations = []

    # m_W ≈ 2 * tau^2 * phi^2
    m_W_computed = 2 * (tau ** 2) * (PHI ** 2)
    m_W_exp = 80.377  # GeV (PDG 2024)
    observations.append(NumericalObservation(
        name="m_W",
        computed=m_W_computed,
        target=m_W_exp,
        target_description="80.377 GeV (PDG)",
        deviation_percent=compute_deviation(m_W_computed, m_W_exp),
        formula="m_W ≈ 2τ²φ²",
        significance="low"
    ))

    # m_H ≈ 32 * tau = 2^5 * tau
    m_H_computed = 32 * tau
    m_H_exp = 125.25  # GeV (PDG 2024)
    observations.append(NumericalObservation(
        name="m_H",
        computed=m_H_computed,
        target=m_H_exp,
        target_description="125.25 GeV (PDG)",
        deviation_percent=compute_deviation(m_H_computed, m_H_exp),
        formula="m_H ≈ 32τ = 2⁵τ",
        significance="medium"
    ))

    # alpha^-1 ≈ 35 * tau
    alpha_inv_computed = 35 * tau
    alpha_inv_exp = 137.036  # Fine structure constant inverse
    observations.append(NumericalObservation(
        name="alpha_inv",
        computed=alpha_inv_computed,
        target=alpha_inv_exp,
        target_description="137.036",
        deviation_percent=compute_deviation(alpha_inv_computed, alpha_inv_exp),
        formula="α⁻¹ ≈ 35τ",
        significance="medium"
    ))

    return observations


def verify_all_observations() -> dict[str, list[NumericalObservation]]:
    """Return all numerical observations, keyed by category."""
    return {
        "tau_powers": tau_powers(),
        "transcendental": transcendental_relations(),
        "mass_relations": mass_relations(),
    }


def print_all_observations() -> None:
    """Print all observations with their deviations."""
    all_obs = verify_all_observations()

    print("=" * 70)
    print("GIFT v3.3 NUMERICAL OBSERVATIONS")
    print("These are NOT formal proofs - they are numerical coincidences.")
    print("=" * 70)

    for category, observations in all_obs.items():
        print(f"\n## {category.upper().replace('_', ' ')}\n")
        for obs in observations:
            print(obs)
            print()


def get_summary() -> dict:
    """Return a summary dict keyed by observation name."""
    all_obs = verify_all_observations()
    summary = {}

    for category, observations in all_obs.items():
        for obs in observations:
            summary[obs.name] = {
                "computed": obs.computed,
                "target": obs.target,
                "deviation_percent": obs.deviation_percent,
                "formula": obs.formula,
            }

    return summary


if __name__ == "__main__":
    print_all_observations()
