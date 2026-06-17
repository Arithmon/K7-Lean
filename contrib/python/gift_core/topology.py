"""Topological structures used in GIFT."""
from dataclasses import dataclass
from gift_core.constants import (
    DIM_K7, B2, B3, DIM_G2, DIM_E8, RANK_E8
)

__all__ = ['ManifoldK7', 'GroupG2', 'GroupE8', 'K7', 'G2', 'E8']

@dataclass(frozen=True)
class ManifoldK7:
    """The compact 7-manifold with G2 holonomy."""
    dim: int = DIM_K7
    b2: int = B2          # Second Betti number
    b3: int = B3          # Third Betti number
    holonomy: str = "G2"
    construction: str = "Twisted Connected Sum (TCS)"

    @property
    def euler_characteristic(self) -> int:
        """chi(K7) = 0 (compact oriented odd-dimensional manifold, by Poincare duality)."""
        return 0

    @property
    def two_b2(self) -> int:
        """Structural invariant 2*b2 = 42 (NOT chi(K7), despite older naming)."""
        return 2 * self.b2

    @property
    def h_star(self) -> int:
        """Effective degrees of freedom: H* = b2 + b3 + 1"""
        return self.b2 + self.b3 + 1

@dataclass(frozen=True)
class GroupG2:
    """The exceptional Lie group G2."""
    dim: int = DIM_G2
    rank: int = 2
    name: str = "G2"

    @property
    def is_exceptional(self) -> bool:
        return True

@dataclass(frozen=True)
class GroupE8:
    """The exceptional Lie group E8."""
    dim: int = DIM_E8
    rank: int = RANK_E8
    root_count: int = 240
    name: str = "E8"

    @property
    def weyl_order(self) -> int:
        """|W(E8)| = 696,729,600 = 2^14 * 3^5 * 5^2 * 7"""
        return 696_729_600

# Singleton instances
K7 = ManifoldK7()
G2 = GroupG2()
E8 = GroupE8()
