"""
The 33 relations of the K7 paper, version 3.6 (A01 ... A33).

Each entry evaluates the paper's closed form from the structural constants of
this package and carries the value stated by the Lean certificate
`GIFT.Certificate.RelationsV36.relations_v36_certified`
(file GIFT/Certificate/RelationsV36.lean). `scripts/test_relations_v36.py`
parses that Lean file and fails if an entry here disagrees with it.

Scope. These are arithmetic identities. They do not establish a physical
identification of any quantity, the choice of a formula among the many with
the same value, or the mutual consistency of the relations: several of them
are mutually incompatible as exact equalities (lepton, CKM and cosmological
sectors). The comparison with experiment is in the paper and its dataset
(https://doi.org/10.5281/zenodo.16891489), not in this module.

What the Lean certificate states for the non-rational entries:
  A02, A03, A23  equality in R of the closed form with its evaluated form;
  A07            dim J3(O) = 27 and the bounds 206 < 27^phi < 209 only;
  A15            the integer 197 only (the unit, degrees, is an assignment of
                 the paper);
  A24            the indices (11, 5) and the quotient zeta(11)/zeta(5), with no
                 numerical bound.
The floats given here for those entries are evaluations, not certified values.
"""
import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Union

from gift_core.constants.algebra import (
    DIM_E8, RANK_E8, DIM_G2, DIM_K7, DIM_F4, DIM_E6, DIM_FUND_E7, DIM_J3O,
    WEYL_FACTOR,
)
from gift_core.constants.topology import B0, B2, B3, H_STAR, P2, D_BULK
from gift_core.constants.structural import N_GEN, PSL27_ORDER

__all__ = [
    'RelationV36', 'RELATIONS_V36', 'get_relation_v36',
    'DET_G_NUM', 'DET_G_DEN', 'KAPPA_T_DEN', 'ALPHA_SUM', 'DIM_E8XE8',
]

# Structural constants named as in GIFT/Core.lean
DET_G_NUM = 65                        # det_g_num
DET_G_DEN = 32                        # det_g_den
KAPPA_T_DEN = 61                      # kappa_T_den = kappa_T^-1
ALPHA_SUM = RANK_E8 + WEYL_FACTOR     # alpha_sum = 13
DIM_E8XE8 = 2 * DIM_E8                # 496

PHI = (1 + math.sqrt(5)) / 2


def _zeta(s: int, n: int = 64) -> float:
    """Riemann zeta at an integer s >= 2 (direct sum with Euler-Maclaurin tail)."""
    head = math.fsum(k ** -s for k in range(1, n))
    tail = n ** (1 - s) / (s - 1) + 0.5 * n ** -s + s * n ** (-s - 1) / 12
    return head + tail


@dataclass(frozen=True)
class RelationV36:
    """One relation of the K7 paper v3.6.

    Attributes:
        id: label in the paper and the dataset (A01 ... A33).
        symbol: the quantity the paper assigns the closed form to.
        formula: the closed form in the structural constants.
        value: the closed form evaluated from this package's constants
            (int or Fraction when exact, float otherwise).
        stated: the value as written in the Lean statement (fractions are
            left unreduced there, e.g. 246/21).
        kind: 'rational', 'integer', 'real' (closed form in R), 'bounds'
            (A07) or 'zeta' (A24).
        lean_theorem: theorem name in GIFT.Certificate.RelationsV36.
    """
    id: str
    symbol: str
    formula: str
    value: Union[int, Fraction, float]
    stated: str
    kind: str
    lean_theorem: str

    def __float__(self) -> float:
        return float(self.value)

    def __repr__(self) -> str:
        return f"{self.id} {self.symbol} = {self.stated}"


def _q(num, den) -> Fraction:
    return Fraction(num, den)


RELATIONS_V36 = [
    RelationV36('A01', 'sin^2(theta_W)', 'b2/(b3 + dim G2)',
                _q(B2, B3 + DIM_G2), '3/13', 'rational', 'A01_sin2_theta_W'),
    RelationV36('A02', 'alpha_s(M_Z)', 'sqrt(2)/(dim G2 - p2)',
                math.sqrt(2) / (DIM_G2 - P2), 'sqrt(2)/12', 'real', 'A02_alpha_s'),
    RelationV36('A03', 'lambda_H', 'sqrt(dim G2 + N_gen)/det_den',
                math.sqrt(DIM_G2 + N_GEN) / DET_G_DEN, 'sqrt(17)/32', 'real',
                'A03_lambda_H'),
    RelationV36('A04', 'alpha^-1(0)',
                '(dim E8 + rank E8)/2 + H*/D_bulk + det_num/(det_den * kappa_T^-1)',
                _q(DIM_E8 + RANK_E8, 2) + _q(H_STAR, D_BULK)
                + _q(DET_G_NUM, DET_G_DEN * KAPPA_T_DEN),
                '267489/1952', 'rational', 'A04_alpha_inv'),
    RelationV36('A05', 'Q_Koide', 'dim G2/b2',
                _q(DIM_G2, B2), '2/3', 'rational', 'A05_Q_Koide'),
    RelationV36('A06', 'm_tau/m_e', 'dim K7 + 10 dim E8 + 10 H*',
                DIM_K7 + 10 * DIM_E8 + 10 * H_STAR, '3477', 'integer',
                'A06_m_tau_m_e'),
    RelationV36('A07', 'm_mu/m_e', '(dim J3(O))^phi = 27^phi',
                DIM_J3O ** PHI, '206 < 27^phi < 209', 'bounds', 'A07_m_mu_m_e'),
    RelationV36('A08', 'm_s/m_d', 'p2^2 * Weyl',
                P2 * P2 * WEYL_FACTOR, '20', 'integer', 'A08_m_s_m_d'),
    RelationV36('A09', 'm_c/m_s', '(dim E8 - p2)/b2',
                _q(DIM_E8 - P2, B2), '246/21', 'rational', 'A09_m_c_m_s'),
    RelationV36('A10', 'm_b/m_t', '1/(2 b2)',
                _q(1, 2 * B2), '1/42', 'rational', 'A10_m_b_m_t'),
    RelationV36('A11', 'm_u/m_d', '(1 + dim E6)/|PSL(2,7)|',
                _q(B0 + DIM_E6, PSL27_ORDER), '79/168', 'rational', 'A11_m_u_m_d'),
    RelationV36('A12', 'sin^2(theta_12) PMNS', '(1 + N_gen)/alpha_sum',
                _q(B0 + N_GEN, ALPHA_SUM), '4/13', 'rational',
                'A12_sin2_theta12_PMNS'),
    RelationV36('A13', 'sin^2(theta_23) PMNS', '(D_bulk - Weyl)/D_bulk',
                _q(D_BULK - WEYL_FACTOR, D_BULK), '6/11', 'rational',
                'A13_sin2_theta23_PMNS'),
    RelationV36('A14', 'sin^2(theta_13) PMNS', 'D_bulk/dim(E8 x E8)',
                _q(D_BULK, DIM_E8XE8), '11/496', 'rational',
                'A14_sin2_theta13_PMNS'),
    RelationV36('A15', 'delta_CP', 'dim K7 * dim G2 + H*',
                DIM_K7 * DIM_G2 + H_STAR, '197', 'integer', 'A15_delta_CP'),
    RelationV36('A16', 'sin(theta_12) CKM', 'fund(E7)/dim E8',
                _q(DIM_FUND_E7, DIM_E8), '56/248', 'rational',
                'A16_sin_theta12_CKM'),
    RelationV36('A17', 'A (Wolfenstein)', '(Weyl + dim E6)/H*',
                _q(WEYL_FACTOR + DIM_E6, H_STAR), '83/99', 'rational', 'A17_A_Wolf'),
    RelationV36('A18', 'sin(theta_23) CKM', 'dim K7/|PSL(2,7)|',
                _q(DIM_K7, PSL27_ORDER), '7/168', 'rational',
                'A18_sin_theta23_CKM'),
    RelationV36('A19', 'm_H/m_t', 'fund(E7)/b3',
                _q(DIM_FUND_E7, B3), '56/77', 'rational', 'A19_m_H_m_t'),
    RelationV36('A20', 'm_H/m_W', '(N_gen + dim E6)/dim F4',
                _q(N_GEN + DIM_E6, DIM_F4), '81/52', 'rational', 'A20_m_H_m_W'),
    RelationV36('A21', 'm_W/m_Z', '(2 b2 - Weyl)/(2 b2)',
                _q(2 * B2 - WEYL_FACTOR, 2 * B2), '37/42', 'rational',
                'A21_m_W_m_Z'),
    RelationV36('A22', 'm_mu/m_tau', '(b2 - D_bulk)/|PSL(2,7)|',
                _q(B2 - D_BULK, PSL27_ORDER), '10/168', 'rational',
                'A22_m_mu_m_tau'),
    RelationV36('A23', 'Omega_DE', 'log(2) * (b2 + b3)/H*',
                math.log(2) * (B2 + B3) / H_STAR, 'log(2) * 98/99', 'real',
                'A23_Omega_DE'),
    RelationV36('A24', 'n_s', 'zeta(D_bulk)/zeta(Weyl)',
                _zeta(D_BULK) / _zeta(WEYL_FACTOR), 'zeta(11)/zeta(5)', 'zeta',
                'A24_n_s'),
    RelationV36('A25', 'Omega_DM/Omega_b', '(1 + 2 b2)/rank E8',
                _q(B0 + 2 * B2, RANK_E8), '43/8', 'rational', 'A25_Omega_DM_b'),
    RelationV36('A26', 'Omega_c/Omega_Lambda', 'det_num/|PSL(2,7)|',
                _q(DET_G_NUM, PSL27_ORDER), '65/168', 'rational',
                'A26_Omega_c_Lambda'),
    RelationV36('A27', 'Omega_Lambda/Omega_m', '(dim G2 + H*)/dim F4',
                _q(DIM_G2 + H_STAR, DIM_F4), '113/52', 'rational',
                'A27_Omega_Lambda_m'),
    RelationV36('A28', 'h', '(|PSL(2,7)| - 1)/dim E8',
                _q(PSL27_ORDER - B0, DIM_E8), '167/248', 'rational',
                'A28_hubble_h'),
    RelationV36('A29', 'Omega_b/Omega_m', 'Weyl/det_den',
                _q(WEYL_FACTOR, DET_G_DEN), '5/32', 'rational', 'A29_Omega_b_m'),
    RelationV36('A30', 'Omega_c/Omega_m', '(det_den - Weyl)/det_den',
                _q(DET_G_DEN - WEYL_FACTOR, DET_G_DEN), '27/32', 'rational',
                'A30_Omega_c_m'),
    RelationV36('A31', 'sigma_8', '(p2 + det_den)/(2 b2)',
                _q(P2 + DET_G_DEN, 2 * B2), '34/42', 'rational', 'A31_sigma_8'),
    RelationV36('A32', 'Y_p', '(1 + dim G2)/kappa_T^-1',
                _q(B0 + DIM_G2, KAPPA_T_DEN), '15/61', 'rational', 'A32_Y_p'),
    RelationV36('A33', 'Omega_m/Omega_Lambda', '(1 + dim J3(O))/kappa_T^-1',
                _q(B0 + DIM_J3O, KAPPA_T_DEN), '28/61', 'rational',
                'A33_Omega_m_Lambda'),
]


def get_relation_v36(key: str) -> RelationV36:
    """Get a v3.6 relation by its id ('A13') or its symbol."""
    for r in RELATIONS_V36:
        if key in (r.id, r.symbol):
            return r
    raise KeyError(f"Unknown v3.6 relation: {key}")
