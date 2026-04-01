"""Twisted Connected Sum (TCS) manifold construction.

A TCS G₂ manifold is built from two asymptotically cylindrical (ACyl)
Calabi-Yau 3-folds M₁, M₂ glued along their asymptotic K3 × S¹ necks.

Topological invariants:
    b₂(K₇) = b₂(M₁) + b₂(M₂)
    b₃(K₇) = b₃(M₁) + b₃(M₂)

References:
    Kovalev (2003), arXiv:math/0012189
    Corti-Haskins-Nordström-Pacini (2015), arXiv:1207.4470
"""

from dataclasses import dataclass, field
from typing import Optional


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


# Pre-built building blocks from the literature
QUINTIC = BuildingBlock("Quintic", b2=11, b3=40)
CI_2_2_2 = BuildingBlock("CI(2,2,2)", b2=10, b3=37)

# GIFT's K₇ manifold
K7_BLOCKS = (QUINTIC, CI_2_2_2)
