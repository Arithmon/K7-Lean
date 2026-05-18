"""
GIFT Constants Package (v3.4.22).

All certified constants organized by theme:
- algebra: E8, G2, F4, E6, E7, Weyl group
- topology: K7, Betti numbers, TCS building blocks
- structural: Weyl triple identity, PSL(2,7)
- physics: Weinberg angle, Koide, mass ratios
- cosmology: Dark energy, Hubble, CMB

All values formally proven in Lean 4.
"""

# Exceptional Lie algebras
from .algebra import (
    # E8
    DIM_E8, RANK_E8, DIM_E8xE8,
    WEYL_FACTOR, WEYL_SQ, WEYL_E8_ORDER,
    # G2
    DIM_G2, RANK_G2, DIM_K7,
    # Other exceptional
    DIM_F4, DIM_E6, DIM_E7, DIM_FUND_E7,
    # Jordan
    DIM_J3O, DIM_J3O_TRACELESS,
    # Standard Model gauge
    DIM_SU3, DIM_SU2, DIM_U1, DIM_SM_GAUGE,
    # Exceptional chain
    PRIME_6, PRIME_8, PRIME_11,
    E6_CHAIN, E7_CHAIN, E8_CHAIN,
    E7_E6_GAP, E8_E7_GAP,
    EXCEPTIONAL_CHAIN, JORDAN_TRACELESS, DELTA_PENTA,
    # V3.3: E-series Jordan, magic 42, exceptional ranks
    E_SERIES_DIFF, J3O_FROM_E_SERIES,
    MAGIC_42, N_GEN, P2,
    RANK_E7, RANK_E6, RANK_F4, EXCEPTIONAL_RANKS_SUM,
)

# K7 topology
from .topology import (
    # TCS building blocks (v3.2)
    M1_B2, M1_B3, M1_EULER,
    M2_B2, M2_B3, M2_EULER,
    # Betti numbers (DERIVED)
    B0, B1, B2, B3, B4, B5, B6, B7,
    # Derived invariants
    H_STAR, P2, EULER_K7, FUND_E7,
    # G2 form decompositions
    DIM_OMEGA2_7, DIM_OMEGA2_14,
    DIM_OMEGA3_1, DIM_OMEGA3_7, DIM_OMEGA3_27,
    # M-theory
    D_BULK,
)

# Structural identities (v3.2)
from .structural import (
    N_GEN,
    # Weyl triple identity
    WEYL_PATH_1, WEYL_PATH_2, WEYL_PATH_3,
    # PSL(2,7)
    PSL27_ORDER, PSL27_PATH_1, PSL27_PATH_2, PSL27_PATH_3,
    # Duality
    DUALITY_GAP,
    # Extended decomposition relations
    ALPHA_SQ_B_SUM, WEYL_E8_FORMULA, DIM_F4_FROM_STRUCTURE_B,
    KAPPA_T_INV_FROM_F4,
    B2_BASE_DECOMPOSITION, B3_INTERMEDIATE, B3_BASE_DECOMPOSITION,
    H_STAR_INTERMEDIATE, H_STAR_BASE_DECOMPOSITION,
    QUOTIENT_SUM, N_OBSERVABLES, E6_DUAL_OBSERVABLES,
)

# Physical relations
from .physics import (
    # Electroweak
    SIN2_THETA_W, Q_KOIDE,
    # Mass ratios
    M_TAU_M_E, M_S_M_D, M_MU_M_E_BASE,
    # Torsion
    KAPPA_T, KAPPA_T_INV,
    # Metric
    DET_G,
    # CP violation
    DELTA_CP,
    # Higgs
    LAMBDA_H_NUM, LAMBDA_H_SQ,
    # Gamma GIFT
    GAMMA_GIFT_NUM, GAMMA_GIFT_DEN, GAMMA_GIFT,
    # Neutrino
    THETA_23, THETA_13_DENOM,
    # Fine structure
    ALPHA_INV_BASE, ALPHA_INV_COMPLETE,
    # Strong coupling
    ALPHA_S_DENOM, ALPHA_S_SQUARED,
    # Tau
    TAU,
    # Yukawa duality
    VISIBLE_DIM, HIDDEN_DIM,
    ALPHA_SQ_LEPTON_A, ALPHA_SQ_UP_A, ALPHA_SQ_DOWN_A,
    ALPHA_SUM_A, ALPHA_PROD_A,
    ALPHA_SQ_LEPTON_B, ALPHA_SQ_UP_B, ALPHA_SQ_DOWN_B,
    ALPHA_SUM_B, ALPHA_PROD_B,
    DUALITY_GAP_FROM_COLOR,
    # Topological extension
    ALPHA_S_SQ_NUM, ALPHA_S_SQ_DENOM, ALPHA_S_SQUARED_NUM, ALPHA_S_SQUARED_DEN,
    ALPHA_INV_ALGEBRAIC, ALPHA_INV_BULK,
    DELTA_PENTAGONAL_DENOM,
    THETA_23_NUM, THETA_23_DEN, THETA_12_RATIO_FACTOR,
    LAMBDA_H_SQ_NUM, LAMBDA_H_SQ_DEN,
    TAU_NUM_VALUE, TAU_DEN_VALUE, TAU_NUM_BASE13, to_base_13,
)

# Cosmology
from .cosmology import (
    # Dark energy
    OMEGA_DE_NUM, OMEGA_DE_DEN, OMEGA_DE_FRACTION, OMEGA_DE_PRODUCT,
    PHI_SQUARED_NUM, PHI_SQUARED_DEN,
    # Hubble
    HUBBLE_CMB, HUBBLE_LOCAL, HUBBLE_TENSION, H0_TOPOLOGICAL,
    # CMB
    T_CMB_mK,
    # Age
    AGE_UNIVERSE_UNIT,
    # Spectral index
    N_S_ZETA_BULK, N_S_ZETA_WEYL,
    # Impedance
    IMPEDANCE,
)

__all__ = [
    # Algebra
    'DIM_E8', 'RANK_E8', 'DIM_E8xE8',
    'WEYL_FACTOR', 'WEYL_SQ', 'WEYL_E8_ORDER',
    'DIM_G2', 'RANK_G2', 'DIM_K7',
    'DIM_F4', 'DIM_E6', 'DIM_E7', 'DIM_FUND_E7',
    'DIM_J3O', 'DIM_J3O_TRACELESS',
    'DIM_SU3', 'DIM_SU2', 'DIM_U1', 'DIM_SM_GAUGE',
    'PRIME_6', 'PRIME_8', 'PRIME_11',
    'E6_CHAIN', 'E7_CHAIN', 'E8_CHAIN',
    'E7_E6_GAP', 'E8_E7_GAP',
    'EXCEPTIONAL_CHAIN', 'JORDAN_TRACELESS', 'DELTA_PENTA',
    # V3.3: E-series Jordan, magic 42, exceptional ranks
    'E_SERIES_DIFF', 'J3O_FROM_E_SERIES',
    'MAGIC_42',
    'RANK_E7', 'RANK_E6', 'RANK_F4', 'EXCEPTIONAL_RANKS_SUM',
    # Topology
    'M1_B2', 'M1_B3', 'M1_EULER',
    'M2_B2', 'M2_B3', 'M2_EULER',
    'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'B7',
    'H_STAR', 'P2', 'EULER_K7', 'FUND_E7',
    'DIM_OMEGA2_7', 'DIM_OMEGA2_14',
    'DIM_OMEGA3_1', 'DIM_OMEGA3_7', 'DIM_OMEGA3_27',
    'D_BULK',
    # Structural
    'N_GEN',
    'WEYL_PATH_1', 'WEYL_PATH_2', 'WEYL_PATH_3',
    'PSL27_ORDER', 'PSL27_PATH_1', 'PSL27_PATH_2', 'PSL27_PATH_3',
    'DUALITY_GAP',
    'ALPHA_SQ_B_SUM', 'WEYL_E8_FORMULA', 'DIM_F4_FROM_STRUCTURE_B',
    'KAPPA_T_INV_FROM_F4',
    'B2_BASE_DECOMPOSITION', 'B3_INTERMEDIATE', 'B3_BASE_DECOMPOSITION',
    'H_STAR_INTERMEDIATE', 'H_STAR_BASE_DECOMPOSITION',
    'QUOTIENT_SUM', 'N_OBSERVABLES', 'E6_DUAL_OBSERVABLES',
    # Physics
    'SIN2_THETA_W', 'Q_KOIDE',
    'M_TAU_M_E', 'M_S_M_D', 'M_MU_M_E_BASE',
    'KAPPA_T', 'KAPPA_T_INV',
    'DET_G', 'DELTA_CP',
    'LAMBDA_H_NUM', 'LAMBDA_H_SQ',
    'GAMMA_GIFT_NUM', 'GAMMA_GIFT_DEN', 'GAMMA_GIFT',
    'THETA_23', 'THETA_13_DENOM',
    'ALPHA_INV_BASE', 'ALPHA_INV_COMPLETE',
    'ALPHA_S_DENOM', 'ALPHA_S_SQUARED',
    'TAU',
    # Yukawa duality
    'VISIBLE_DIM', 'HIDDEN_DIM',
    'ALPHA_SQ_LEPTON_A', 'ALPHA_SQ_UP_A', 'ALPHA_SQ_DOWN_A',
    'ALPHA_SUM_A', 'ALPHA_PROD_A',
    'ALPHA_SQ_LEPTON_B', 'ALPHA_SQ_UP_B', 'ALPHA_SQ_DOWN_B',
    'ALPHA_SUM_B', 'ALPHA_PROD_B',
    'DUALITY_GAP_FROM_COLOR',
    # Topological extension
    'ALPHA_S_SQ_NUM', 'ALPHA_S_SQ_DENOM', 'ALPHA_S_SQUARED_NUM', 'ALPHA_S_SQUARED_DEN',
    'ALPHA_INV_ALGEBRAIC', 'ALPHA_INV_BULK',
    'DELTA_PENTAGONAL_DENOM',
    'THETA_23_NUM', 'THETA_23_DEN', 'THETA_12_RATIO_FACTOR',
    'LAMBDA_H_SQ_NUM', 'LAMBDA_H_SQ_DEN',
    'TAU_NUM_VALUE', 'TAU_DEN_VALUE', 'TAU_NUM_BASE13', 'to_base_13',
    # Cosmology
    'OMEGA_DE_NUM', 'OMEGA_DE_DEN', 'OMEGA_DE_FRACTION', 'OMEGA_DE_PRODUCT',
    'PHI_SQUARED_NUM', 'PHI_SQUARED_DEN',
    'HUBBLE_CMB', 'HUBBLE_LOCAL', 'HUBBLE_TENSION', 'H0_TOPOLOGICAL',
    'T_CMB_mK', 'AGE_UNIVERSE_UNIT',
    'N_S_ZETA_BULK', 'N_S_ZETA_WEYL',
    'IMPEDANCE',
]
