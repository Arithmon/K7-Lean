"""
GIFT Core - Formally Verified Mathematical Constants.

All values proven in Lean 4.
460+ certified relations, 4 published axioms, modular certificate structure.

v3.4.23 Features:
- Certificate Modularization: Foundations / Predictions / Spectral pillars
- Spectral Theory: algebraic ratio dim(G₂)/H* = 14/99, TCS bounds, Yang-Mills connection
- Computed Spectrum: Q₂₂ signature (3,19), SD/ASD gap >2000×
- Spectral Democracy: SD spread <2%, coupling ratio <1.02
- G₂ Geometry: Axiom-free Hodge star, ψ=⋆φ proven
- E8 Roots: 240 vectors in R^8 with full operations
- Fano Plane: Octonion multiplication and G₂ cross product

Quick Start:
    from gift_core import *
    print(SIN2_THETA_W)   # Fraction(3, 13)
    print(B2, B3, H_STAR) # 21, 77, 99 (all DERIVED!)

    # Verify all relations
    from gift_core import verify
    verify()  # True

    # E8 root system
    from gift_core.roots import E8_ROOTS, E8_SIMPLE_ROOTS
    print(len(E8_ROOTS))  # 240

    # Fano plane / G2 cross product
    from gift_core.fano import cross_product, FANO_LINES

    # Visualization (requires matplotlib)
    from gift_core.visualize import plot_fano, plot_e8_projection
"""

from gift_core._version import __version__

# =============================================================================
# CONSTANTS (v3.2 restructured package)
# =============================================================================

from gift_core.constants import (
    # === ALGEBRA ===
    DIM_E8, RANK_E8, DIM_E8xE8,
    WEYL_FACTOR, WEYL_SQ, WEYL_E8_ORDER,
    DIM_G2, RANK_G2, DIM_K7,
    DIM_F4, DIM_E6, DIM_E7, DIM_FUND_E7,
    DIM_J3O, DIM_J3O_TRACELESS,
    DIM_SU3, DIM_SU2, DIM_U1, DIM_SM_GAUGE,
    PRIME_6, PRIME_8, PRIME_11,
    E6_CHAIN, E7_CHAIN, E8_CHAIN,
    EXCEPTIONAL_CHAIN, JORDAN_TRACELESS, DELTA_PENTA,

    # === TOPOLOGY (TCS v3.2) ===
    M1_B2, M1_B3, M1_EULER,  # Quintic building block
    M2_B2, M2_B3, M2_EULER,  # CI building block
    B0, B1, B2, B3, B4, B5, B6, B7,  # Betti numbers (DERIVED!)
    H_STAR, P2, EULER_K7, FUND_E7,
    D_BULK,

    # === STRUCTURAL (v3.2) ===
    N_GEN,
    WEYL_PATH_1, WEYL_PATH_2, WEYL_PATH_3,  # Weyl triple identity
    PSL27_ORDER, PSL27_PATH_1, PSL27_PATH_2, PSL27_PATH_3,  # Fano symmetry
    DUALITY_GAP,
    # Extended decomposition
    ALPHA_SQ_B_SUM, WEYL_E8_FORMULA, DIM_F4_FROM_STRUCTURE_B,
    KAPPA_T_INV_FROM_F4,
    B2_BASE_DECOMPOSITION, B3_INTERMEDIATE, B3_BASE_DECOMPOSITION,
    H_STAR_INTERMEDIATE, H_STAR_BASE_DECOMPOSITION,
    QUOTIENT_SUM, N_OBSERVABLES, E6_DUAL_OBSERVABLES,

    # === PHYSICS ===
    SIN2_THETA_W, Q_KOIDE,
    M_TAU_M_E, M_S_M_D, M_MU_M_E_BASE,
    KAPPA_T, KAPPA_T_INV,
    DET_G, DELTA_CP,
    LAMBDA_H_NUM, LAMBDA_H_SQ,
    GAMMA_GIFT_NUM, GAMMA_GIFT_DEN, GAMMA_GIFT,
    THETA_23, THETA_13_DENOM,
    ALPHA_INV_BASE, ALPHA_INV_COMPLETE,
    ALPHA_S_DENOM, ALPHA_S_SQUARED,
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

    # === COSMOLOGY ===
    OMEGA_DE_NUM, OMEGA_DE_DEN, OMEGA_DE_FRACTION, OMEGA_DE_PRODUCT,
    PHI_SQUARED_NUM, PHI_SQUARED_DEN,
    HUBBLE_CMB, HUBBLE_LOCAL, HUBBLE_TENSION, H0_TOPOLOGICAL,
    T_CMB_mK, AGE_UNIVERSE_UNIT,
    N_S_ZETA_BULK, N_S_ZETA_WEYL,
    IMPEDANCE,
)

# =============================================================================
# NEW MODULES (v3.2)
# =============================================================================

# E8 Root System (actual vectors in R^8)
from gift_core.roots import (
    E8_ROOTS, D8_ROOTS, HALF_INTEGER_ROOTS,
    E8_SIMPLE_ROOTS, E8_CARTAN_MATRIX,
    inner_product, norm, norm_sq,
    weyl_reflection, is_root, is_in_E8_lattice,
    positive_roots, negative_roots, highest_root,
    root_statistics,
)

# Fano Plane & G2 Cross Product
from gift_core.fano import (
    FANO_LINES, EPSILON,
    cross_product, epsilon, phi0,
    inner_product_7, norm_sq_7,
    verify_lagrange_identity,
    octonion_multiply_imaginaries,
    fano_summary, verify_fano_properties,
)

# Verification
from gift_core.verify import (
    verify, verify_all, verify_summary,
    print_verification_report,
    VerificationResult,
)

# Proven Relations
from gift_core.relations import (
    PROVEN_RELATIONS, get_relation, ProvenRelation,
)

# V3.3 Numerical Observations (approximate relations)
from gift_core.numerical_observations import (
    verify_all_observations as verify_numerical_observations,
    get_summary as get_numerical_summary,
    NumericalObservation,
    tau_powers, transcendental_relations, mass_relations,
)

# =============================================================================
# LEGACY COMPATIBILITY
# =============================================================================

# Backward compatibility aliases
from gift_core.constants.physics import (
    SIN2_THETA_W as WEINBERG_ANGLE,
)

# =============================================================================
# OPTIONAL MODULES
# =============================================================================

# Visualization (requires matplotlib)
MATPLOTLIB_AVAILABLE = False
try:
    from gift_core.visualize import (
        plot_fano, plot_e8_projection,
        plot_dynkin_e8, plot_gift_constants,
        plot_all,
        MATPLOTLIB_AVAILABLE,
    )
except ImportError:
    plot_fano = None
    plot_e8_projection = None
    plot_dynkin_e8 = None
    plot_gift_constants = None
    plot_all = None

# NumPy-dependent modules
NUMPY_AVAILABLE = False
try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    pass

# Analysis (Joyce certificate)
try:
    from gift_core.analysis import (
        Interval, JoyceCertificate,
        TORSION_BOUND, JOYCE_THRESHOLD,
        verify_joyce_bounds,
    )
except ImportError:
    Interval = JoyceCertificate = None
    TORSION_BOUND = JOYCE_THRESHOLD = None
    verify_joyce_bounds = None

# =============================================================================
# __all__ - Public API
# =============================================================================

__all__ = [
    # Version
    '__version__',

    # === ALGEBRA ===
    'DIM_E8', 'RANK_E8', 'DIM_E8xE8',
    'WEYL_FACTOR', 'WEYL_SQ', 'WEYL_E8_ORDER',
    'DIM_G2', 'RANK_G2', 'DIM_K7',
    'DIM_F4', 'DIM_E6', 'DIM_E7', 'DIM_FUND_E7',
    'DIM_J3O', 'DIM_SU3', 'DIM_SU2', 'DIM_U1', 'DIM_SM_GAUGE',

    # === TOPOLOGY (TCS v3.2) ===
    'M1_B2', 'M1_B3', 'M2_B2', 'M2_B3',  # Building blocks
    'B2', 'B3', 'H_STAR', 'P2', 'D_BULK',

    # === STRUCTURAL (v3.2) ===
    'N_GEN', 'PSL27_ORDER', 'DUALITY_GAP',
    'ALPHA_SQ_B_SUM', 'WEYL_E8_FORMULA', 'DIM_F4_FROM_STRUCTURE_B',
    'KAPPA_T_INV_FROM_F4',
    'B2_BASE_DECOMPOSITION', 'B3_INTERMEDIATE', 'B3_BASE_DECOMPOSITION',
    'H_STAR_INTERMEDIATE', 'H_STAR_BASE_DECOMPOSITION',
    'QUOTIENT_SUM', 'N_OBSERVABLES', 'E6_DUAL_OBSERVABLES',

    # === PHYSICS ===
    'SIN2_THETA_W', 'Q_KOIDE', 'KAPPA_T', 'DET_G',
    'M_TAU_M_E', 'M_S_M_D', 'DELTA_CP', 'TAU',
    'GAMMA_GIFT', 'ALPHA_INV_BASE', 'ALPHA_INV_COMPLETE',
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

    # === COSMOLOGY ===
    'OMEGA_DE_FRACTION', 'OMEGA_DE_PRODUCT', 'HUBBLE_CMB', 'HUBBLE_LOCAL',

    # === E8 ROOTS (v3.2) ===
    'E8_ROOTS', 'D8_ROOTS', 'HALF_INTEGER_ROOTS',
    'E8_SIMPLE_ROOTS', 'E8_CARTAN_MATRIX',
    'weyl_reflection', 'is_root', 'is_in_E8_lattice',
    'root_statistics',

    # === FANO / G2 (v3.2) ===
    'FANO_LINES', 'cross_product', 'epsilon',
    'verify_lagrange_identity', 'fano_summary',

    # === VERIFICATION (v3.2) ===
    'verify', 'verify_all', 'verify_summary',

    # === RELATIONS ===
    'PROVEN_RELATIONS', 'get_relation', 'ProvenRelation',

    # === VISUALIZATION (optional) ===
    'MATPLOTLIB_AVAILABLE',
    'plot_fano', 'plot_e8_projection', 'plot_dynkin_e8',

    # === V3.3 NUMERICAL OBSERVATIONS ===
    'verify_numerical_observations', 'get_numerical_summary',
    'NumericalObservation',

    # === OPTIONAL MODULES ===
    'NUMPY_AVAILABLE',
]
