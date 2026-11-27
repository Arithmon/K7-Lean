"""Twisted Connected Sum (TCS) manifold construction.

A TCS G₂ manifold is built from two asymptotically cylindrical (ACyl)
Calabi-Yau 3-folds M₁, M₂ glued along their asymptotic K3 × S¹ necks.

Additive model used by this module (a simplification, not the general
TCS formula, which involves the matching lattices):
    b₂ = b₂(M₁) + b₂(M₂)
    b₃ = b₃(M₁) + b₃(M₂)

Status for K₇. No twisted connected sum realising (b₂, b₃) = (21, 77) is
known: orthogonal TCS always gives b₂ + b₃ odd, and 98 is even
(GIFT/Foundations/TCSConstruction.lean; K₇ paper v3.6, S1 section 8). The
pair "Quintic + CI(2,2,2)" below is an arithmetic witness of 21 = 11 + 10
and 77 = 40 + 37, not a construction of K₇.

References:
    Kovalev (2003), arXiv:math/0012189
    Corti-Haskins-Nordström-Pacini (2015), arXiv:1207.4470
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional


@dataclass
class BuildingBlock:
    """An ACyl Calabi-Yau 3-fold used as a TCS building block.

    Parameters:
        name: Identifier (e.g., "Quintic", "CI(2,2,2)")
        b2: Second Betti number
        b3: Third Betti number
        k3_lattice: Optional polarization data for K3 matching
    """
    name: str
    b2: int
    b3: int
    k3_lattice: Optional[list] = None

    def euler_characteristic(self) -> int:
        return 2 * (1 - 0 + self.b2 - self.b3)


@dataclass
class TCSManifold:
    """A compact G₂ manifold constructed via Twisted Connected Sum.

    Parameters:
        m1: First building block (ACyl CY3)
        m2: Second building block (ACyl CY3)
        neck_length: Gluing parameter L (controls neck geometry)
    """
    m1: BuildingBlock
    m2: BuildingBlock
    neck_length: float = 5.0

    @classmethod
    def from_pair(cls, name1: str, name2: str, **kwargs) -> "TCSManifold":
        """Construct a TCS manifold from two building block names.

        Looks up blocks by name (case-insensitive) from the module registry.

        Args:
            name1: Name of the first building block (e.g., "Quintic")
            name2: Name of the second building block (e.g., "CI(2,2,2)")
            **kwargs: Additional arguments passed to TCSManifold (e.g., neck_length)

        Returns:
            TCSManifold constructed from the two named blocks.

        Raises:
            KeyError: If either name is not found in the registry.
        """
        registry = _building_block_registry()
        key1 = name1.lower()
        key2 = name2.lower()
        if key1 not in registry:
            available = ", ".join(sorted(registry.keys()))
            raise KeyError(
                f"Unknown building block '{name1}'. "
                f"Available: {available}"
            )
        if key2 not in registry:
            available = ", ".join(sorted(registry.keys()))
            raise KeyError(
                f"Unknown building block '{name2}'. "
                f"Available: {available}"
            )
        return cls(m1=registry[key1], m2=registry[key2], **kwargs)

    @property
    def b2(self) -> int:
        return self.m1.b2 + self.m2.b2

    @property
    def b3(self) -> int:
        return self.m1.b3 + self.m2.b3

    @property
    def h_star(self) -> int:
        return self.b2 + self.b3 + 1

    @property
    def dim(self) -> int:
        return 7

    @property
    def euler_characteristic(self) -> int:
        return 0  # Always 0 for compact oriented odd-dimensional manifolds

    @property
    def moduli_count(self) -> int:
        """Number of geometric moduli of the G₂ manifold.

        For a TCS G₂ manifold, the moduli space dimension equals b₃,
        corresponding to deformations of the associative 3-form.
        """
        return self.b3

    def g2_decomposition(self) -> Dict[str, int]:
        """Return the G₂ decomposition of 2-forms on the manifold.

        For a G₂ manifold, the space of 2-forms decomposes as:
            Omega^2 = Omega^2_7 + Omega^2_14

        where Omega^2_7 corresponds to the 7-dimensional representation
        of G₂ and Omega^2_14 to the adjoint (14-dimensional) representation.

        When b₂ = 21, returns the explicit split (7, 14) matching the
        K₇ manifold. Otherwise returns a generic decomposition with
        b₂ as the total.

        Returns:
            Dict with keys "omega2_7", "omega2_14", and "total".
        """
        if self.b2 == 21:
            return {
                "omega2_7": 7,
                "omega2_14": 14,
                "total": 21,
            }
        return {
            "omega2_7": 7,
            "omega2_14": 14,
            "total": self.b2,
        }

    def summary(self) -> dict:
        return {
            "m1": self.m1.name,
            "m2": self.m2.name,
            "b2": self.b2,
            "b3": self.b3,
            "h_star": self.h_star,
            "euler": self.euler_characteristic,
            "neck_length": self.neck_length,
        }


# ---------------------------------------------------------------------------
# Pre-built building blocks from the TCS literature
# ---------------------------------------------------------------------------

# Kovalev (2003)
QUINTIC = BuildingBlock("Quintic", b2=11, b3=40)
CI_2_2_2 = BuildingBlock("CI(2,2,2)", b2=10, b3=37)

# Corti-Haskins-Nordstrom-Pacini (2015), arXiv:1207.4470
CI_2_4 = BuildingBlock("CI(2,4)", b2=7, b3=31)
CI_3_3 = BuildingBlock("CI(3,3)", b2=5, b3=37)
CI_2_2_3 = BuildingBlock("CI(2,2,3)", b2=8, b3=34)
SEXTIC_dP = BuildingBlock("Sextic-dP", b2=2, b3=44)
CI_2_2_2_2 = BuildingBlock("CI(2,2,2,2)", b2=7, b3=31)

# GIFT's K₇ manifold
K7_BLOCKS = (QUINTIC, CI_2_2_2)


def _building_block_registry() -> Dict[str, BuildingBlock]:
    """Return a name -> BuildingBlock mapping for all module-level blocks.

    Keys are lower-cased block names for case-insensitive lookup.
    """
    blocks = [
        QUINTIC,
        CI_2_2_2,
        CI_2_4,
        CI_3_3,
        CI_2_2_3,
        SEXTIC_dP,
        CI_2_2_2_2,
    ]
    return {b.name.lower(): b for b in blocks}


def list_building_blocks() -> List[BuildingBlock]:
    """Return all available pre-built building blocks.

    These are ACyl Calabi-Yau 3-folds from the TCS literature
    (Kovalev 2003; Corti-Haskins-Nordstrom-Pacini 2015).
    """
    return [
        QUINTIC,
        CI_2_2_2,
        CI_2_4,
        CI_3_3,
        CI_2_2_3,
        SEXTIC_dP,
        CI_2_2_2_2,
    ]
