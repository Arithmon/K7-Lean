"""
The 13 formally proven relations.
"""
from dataclasses import dataclass
from fractions import Fraction
from typing import Union

__all__ = ['ProvenRelation', 'PROVEN_RELATIONS', 'get_relation']

@dataclass(frozen=True)
class ProvenRelation:
    """A relation proven in Lean 4."""
    name: str
    symbol: str
    value: Union[int, Fraction, float]
    formula: str
    lean_theorem: str

    def __repr__(self):
        return f"{self.symbol} = {self.value}"

PROVEN_RELATIONS = [
    ProvenRelation(
        name="Weinberg angle",
        symbol="sin^2(theta_W)",
        value=Fraction(3, 13),
        formula="b2/(b3 + dim(G2)) = 21/91",
        lean_theorem="weinberg_angle_certified"
    ),
    ProvenRelation(
        name="Hierarchy parameter",
        symbol="tau",
        value=Fraction(3472, 891),
        formula="(496*21)/(27*99)",
        lean_theorem="tau_certified"
    ),
    ProvenRelation(
        name="Metric determinant",
        symbol="det(g)",
        value=Fraction(65, 32),
        formula="5*13/32",
        lean_theorem="det_g_certified"
    ),
    ProvenRelation(
        name="Torsion coefficient",
        symbol="kappa_T",
        value=Fraction(1, 61),
        formula="1/(b3 - dim(G2) - p2)",
        lean_theorem="kappa_T_certified"
    ),
    ProvenRelation(
        name="CP violation phase",
        symbol="delta_CP",
        value=197,
        formula="7*dim(G2) + H* = 7*14 + 99",
        lean_theorem="delta_CP_certified"
    ),
    ProvenRelation(
        name="Tau/electron mass ratio",
        symbol="m_tau/m_e",
        value=3477,
        formula="7 + 10*248 + 10*99",
        lean_theorem="m_tau_m_e_certified"
    ),
    ProvenRelation(
        name="Strange/down quark ratio",
        symbol="m_s/m_d",
        value=20,
        formula="4*5 = b2 - 1",
        lean_theorem="m_s_m_d_certified"
    ),
    ProvenRelation(
        name="Koide parameter",
        symbol="Q_Koide",
        value=Fraction(2, 3),
        formula="dim(G2)/b2 = 14/21",
        lean_theorem="koide_certified"
    ),
    ProvenRelation(
        name="Higgs coupling numerator",
        symbol="lambda_H_num",
        value=17,
        formula="dim(G2) + N_gen = 14 + 3",
        lean_theorem="lambda_H_num_certified"
    ),
    ProvenRelation(
        name="Effective degrees of freedom",
        symbol="H*",
        value=99,
        formula="b2 + b3 + 1 = 21 + 77 + 1",
        lean_theorem="H_star_certified"
    ),
    ProvenRelation(
        name="Binary ratio p2",
        symbol="p2",
        value=2,
        formula="dim(G2)/dim(K7) = 14/7",
        lean_theorem="p2_certified"
    ),
    ProvenRelation(
        name="Number of generations",
        symbol="N_gen",
        value=3,
        formula="Topological (rank - Weyl)",
        lean_theorem="N_gen_certified"
    ),
    ProvenRelation(
        name="E8xE8 dimension",
        symbol="dim(E8xE8)",
        value=496,
        formula="2*248",
        lean_theorem="E8xE8_dim_certified"
    ),
]

def get_relation(symbol: str) -> ProvenRelation:
    """Get a relation by its symbol."""
    for r in PROVEN_RELATIONS:
        if r.symbol == symbol:
            return r
    raise KeyError(f"Unknown relation: {symbol}")
