"""
Physical Relations from GIFT Framework.

Weinberg angle, Koide parameter, mass ratios, mixing angles.
All values proven in Lean 4 (GIFT.Relations.*) as arithmetic identities.

The 33 relations of the K7 paper v3.6 are in gift_core.relations_v36. Some
names below predate version 3.6 and are kept for compatibility; they are
marked "legacy" where the paper no longer uses them.
"""
from fractions import Fraction
from .algebra import DIM_E8, RANK_E8, DIM_G2, DIM_J3O, WEYL_FACTOR, WEYL_SQ, DIM_K7
from .topology import B2, B3, H_STAR, P2, D_BULK
from .structural import N_GEN

# =============================================================================
# WEINBERG ANGLE
# =============================================================================

# sin^2(theta_W) = b2 / (b3 + dim_G2) = 21 / 91 = 3/13
SIN2_THETA_W = Fraction(3, 13)

# =============================================================================
# KOIDE PARAMETER
# =============================================================================

# Q = dim_G2 / b2 = 14 / 21 = 2/3
Q_KOIDE = Fraction(2, 3)

# =============================================================================
# MASS RATIOS
# =============================================================================

# m_tau / m_e = (b3 - b2) * 62 + 5 = 56 * 62 + 5 = 3477
# Also: 3477 = 3 * 19 * 61 = N_gen * prime_8 * kappa_T_inv
M_TAU_M_E = 3477

# m_s / m_d = 4 * 5 = 20
M_S_M_D = 20

# m_mu / m_e base = 27 = dim(J3(O))
M_MU_M_E_BASE = DIM_J3O  # = 27

# =============================================================================
# TORSION PARAMETER
# =============================================================================

# kappa_T = 1 / (b3 - dim_G2 - p2) = 1/61
KAPPA_T = Fraction(1, 61)
KAPPA_T_INV = 61

# =============================================================================
# METRIC DETERMINANT
# =============================================================================

# det(g) = 65/32 (from G2 metric constraints)
DET_G = Fraction(65, 32)

# =============================================================================
# CP VIOLATION
# =============================================================================

# delta_CP = 7 * dim_G2 + H* = 98 + 99 = 197 degrees
DELTA_CP = 7 * DIM_G2 + H_STAR  # = 197

# =============================================================================
# HIGGS COUPLING
# =============================================================================

# lambda_H^2 = 17/1024
LAMBDA_H_NUM = DIM_G2 + N_GEN  # = 17
LAMBDA_H_SQ = Fraction(17, 1024)

# =============================================================================
# GAMMA GIFT
# =============================================================================

# gamma_GIFT = (2*rank_E8 + 5*H*) / (10*dim_G2 + 3*dim_E8) = 511/884
GAMMA_GIFT_NUM = 2 * RANK_E8 + 5 * H_STAR  # = 511
GAMMA_GIFT_DEN = 10 * DIM_G2 + 3 * DIM_E8  # = 884
GAMMA_GIFT = Fraction(GAMMA_GIFT_NUM, GAMMA_GIFT_DEN)

# =============================================================================
# NEUTRINO MIXING ANGLES
# =============================================================================

# v3.6 (A12, A13, A14): squared sines of the PMNS angles
SIN2_THETA_12_PMNS = Fraction(1 + N_GEN, RANK_E8 + WEYL_FACTOR)  # = 4/13
SIN2_THETA_23_PMNS = Fraction(D_BULK - WEYL_FACTOR, D_BULK)      # = 6/11
SIN2_THETA_13_PMNS = Fraction(D_BULK, 2 * DIM_E8)                # = 11/496

# legacy (before v3.6): theta_23 = 85/99 rad. The paper v3.6 uses
# sin^2(theta_23) = 6/11 instead (SIN2_THETA_23_PMNS).
THETA_23 = Fraction(RANK_E8 + B3, H_STAR)  # = 85/99

# legacy (before v3.6): theta_13 = pi/21 (divisor = b2)
THETA_13_DENOM = B2  # = 21

# =============================================================================
# FINE STRUCTURE CONSTANT
# =============================================================================

# alpha^-1 = 128 + 9 + 65/(32*61) = 137.033...
ALPHA_INV_BASE = (DIM_E8 + RANK_E8) // 2 + H_STAR // D_BULK  # = 137
ALPHA_INV_COMPLETE = Fraction(267489, 1952)  # ~ 137.033

# =============================================================================
# STRONG COUPLING
# =============================================================================

# alpha_s denominator = dim_G2 - p2 = 12
ALPHA_S_DENOM = DIM_G2 - P2  # = 12

# alpha_s^2 = 1/72
ALPHA_S_SQUARED = Fraction(1, 72)

# =============================================================================
# TAU HIERARCHY PARAMETER
# =============================================================================

# tau = (dim_E8xE8 * b2) / (dim_J3O * H*) = 3472/891
TAU = Fraction(3472, 891)

# =============================================================================
# YUKAWA DUALITY (v1.3.0)
# =============================================================================

# Sector dimensions
VISIBLE_DIM = 43   # Visible sector dimension
HIDDEN_DIM = 34    # Hidden sector dimension = F_9

# Structure A (Topological): alpha^2 = {2, 3, 7}
ALPHA_SQ_LEPTON_A = 2
ALPHA_SQ_UP_A = 3
ALPHA_SQ_DOWN_A = DIM_K7  # = 7
ALPHA_SUM_A = ALPHA_SQ_LEPTON_A + ALPHA_SQ_UP_A + ALPHA_SQ_DOWN_A  # = 12
ALPHA_PROD_A = ALPHA_SQ_LEPTON_A * ALPHA_SQ_UP_A * ALPHA_SQ_DOWN_A  # = 42

# Structure B (Algebraic): alpha^2 = {2, 5, 6}
ALPHA_SQ_LEPTON_B = 2
ALPHA_SQ_UP_B = WEYL_FACTOR  # = 5
ALPHA_SQ_DOWN_B = 2 * N_GEN  # = 6
ALPHA_SUM_B = ALPHA_SQ_LEPTON_B + ALPHA_SQ_UP_B + ALPHA_SQ_DOWN_B  # = 13
ALPHA_PROD_B = ALPHA_SQ_LEPTON_B * ALPHA_SQ_UP_B * ALPHA_SQ_DOWN_B  # = 60

# Duality gap from color
DUALITY_GAP_FROM_COLOR = P2 * N_GEN * N_GEN  # = 18

# =============================================================================
# TOPOLOGICAL EXTENSION CONSTANTS (v1.2.0)
# =============================================================================

# Alpha_s squared components
ALPHA_S_SQ_NUM = 2
ALPHA_S_SQ_DENOM = 144  # = 12²
ALPHA_S_SQUARED_NUM = DIM_G2 // DIM_K7  # = 2
ALPHA_S_SQUARED_DEN = (DIM_G2 - P2) ** 2  # = 144

# Alpha^-1 components
ALPHA_INV_ALGEBRAIC = (DIM_E8 + RANK_E8) // 2  # = 128
ALPHA_INV_BULK = H_STAR // D_BULK              # = 9

# Pentagonal phase
DELTA_PENTAGONAL_DENOM = WEYL_SQ  # = 25

# Theta_23 components (legacy, before v3.6)
THETA_23_NUM = RANK_E8 + B3  # = 85
THETA_23_DEN = H_STAR        # = 99

# Theta_12 structure (legacy, before v3.6)
THETA_12_RATIO_FACTOR = WEYL_SQ * GAMMA_GIFT_NUM  # = 12775

# Lambda_H^2 components
LAMBDA_H_SQ_NUM = DIM_G2 + N_GEN  # = 17
LAMBDA_H_SQ_DEN = 32 * 32         # = 1024

# =============================================================================
# TAU BASE-13 REPRESENTATION
# =============================================================================

TAU_NUM_VALUE = 3472
TAU_DEN_VALUE = 891


def to_base_13(n: int) -> list:
    """Convert integer to base 13 digits (most significant first)."""
    if n == 0:
        return [0]
    digits = []
    while n > 0:
        digits.append(n % 13)
        n //= 13
    return list(reversed(digits))


TAU_NUM_BASE13 = to_base_13(TAU_NUM_VALUE)  # = [1, 7, 7, 1]
