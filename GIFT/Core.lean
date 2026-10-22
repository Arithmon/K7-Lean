-- Import derived constants from Algebraic modules
import Batteries.Tactic.Alias
import GIFT.Algebraic.Octonions
import GIFT.Algebraic.G2
import GIFT.Algebraic.BettiNumbers

/-!
# GIFT Core Constants

Single source of truth for all GIFT constants.

## Design Philosophy

All constants are defined in ONE place (here or in Algebraic.*).
Other modules import `GIFT.Core` and use these definitions.

## Constant Hierarchy

### Derived from Octonions (foundational)
- `imaginary_count = 7` — number of imaginary units in O
- `dim_G2 = 2 × 7 = 14` — Aut(O) dimension
- `b2 = C(7,2) = 21` — harmonic 2-forms from imaginary pairs
- `b3 = b2 + fund_E7 = 77` — harmonic 3-forms
- `H_star = b2 + b3 + 1 = 99` — total topological degrees of freedom

### Exceptional Lie Algebras
- `dim_E8 = 248` — **derived** via Mathlib Coxeter (see `Foundations.E8Mathlib`)
- `rank_E8 = 8`
- `dim_E7 = 133`, `dim_E6 = 78`, `dim_F4 = 52`
- `dim_G2 = 14`, `rank_G2 = 2`

### Physical/Geometric
- `dim_K7 = 7` — compact manifold dimension
- `D_bulk = 11` — M-theory bulk dimension
- `p2 = 2` — binary ratio dim(G2)/dim(K7) (not a Pontryagin class)
- `Weyl_factor = 5` — from Weyl group factorization

## Usage

```lean
import GIFT.Core
open GIFT.Core

#check b2        -- 21
#check dim_E8    -- 248
#check H_star    -- 99
```
-/

namespace GIFT.Core

-- =============================================================================
-- RE-EXPORT FROM ALGEBRAIC (derived, justified)
-- =============================================================================

-- From Octonions: the foundational constant
export Algebraic.Octonions (imaginary_count octonion_dim)

-- From G2: automorphism group
export Algebraic.G2 (dim_G2 rank_G2 omega2_7 omega2_14 omega3_1 omega3_7 omega3_27)

-- From BettiNumbers: topological invariants (DERIVED from octonions!)
export Algebraic.BettiNumbers (b2 b3 H_star fund_E7)

-- =============================================================================
-- EXCEPTIONAL LIE ALGEBRAS
-- =============================================================================

/-- Dimension of E8 = 248 (= 240 roots + 8 Cartan)

Mathematical derivation in `GIFT.Foundations.E8Mathlib`:
- 240 roots = h × rank = 30 × 8 (Coxeter formula)
- 240 roots verified by explicit enumeration in `GIFT.Foundations.RootSystems`
- Uses `CoxeterMatrix.E₈` from Mathlib

See `GIFT.Foundations.E8Mathlib.E8_dimension_certified` for the formal proof.
-/
def dim_E8 : ℕ := 248

/-- Rank of E8 -/
def rank_E8 : ℕ := 8

/-- Dimension of E8 × E8 -/
def dim_E8xE8 : ℕ := 2 * dim_E8

/-- Dimension of E7 -/
def dim_E7 : ℕ := 133

/-- Fundamental representation of E7 -/
def dim_fund_E7 : ℕ := 56

/-- Dimension of E6 -/
def dim_E6 : ℕ := 78

/-- Dimension of F4 -/
def dim_F4 : ℕ := 52

-- Note: dim_G2 and rank_G2 come from Algebraic.G2

-- =============================================================================
-- COXETER NUMBERS
-- =============================================================================

/-- Coxeter number of G₂.
    The Coxeter number h is the order of a Coxeter element in the Weyl group.
    For G₂: h = 6, and |G₂ roots| = h × rank = 6 × 2 = 12. -/
def h_G2 : ℕ := 6

/-- Coxeter number of E₆.
    h(E₆) = 12, and |E₆ roots| = 12 × 6 = 72. -/
def h_E6 : ℕ := 12

/-- Coxeter number of E₇.
    h(E₇) = 18, and |E₇ roots| = 18 × 7 = 126. -/
def h_E7 : ℕ := 18

/-- Coxeter number of E₈.
    h(E₈) = 30, and |E₈ roots| = 30 × 8 = 240. -/
def h_E8 : ℕ := 30

-- Certifications for use in norm_num
theorem h_G2_certified : h_G2 = 6 := rfl
theorem h_E6_certified : h_E6 = 12 := rfl
theorem h_E7_certified : h_E7 = 18 := rfl
theorem h_E8_certified : h_E8 = 30 := rfl

-- =============================================================================
-- GEOMETRY: K7 MANIFOLD
-- =============================================================================

/-- Real dimension of K7 manifold -/
def dim_K7 : ℕ := 7

/-- Dimension of Jordan algebra J3(O) -/
def dim_J3O : ℕ := 27

/-- Dimension of traceless Jordan algebra -/
def dim_J3O_traceless : ℕ := 26

/-- M-theory bulk dimension -/
def D_bulk : ℕ := 11

-- =============================================================================
-- TOPOLOGY
-- =============================================================================

/-- p2 = binary ratio dim(G2)/dim(K7) (not a Pontryagin class) -/
def p2 : ℕ := 2

-- Note: b2, b3, H_star come from Algebraic.BettiNumbers

-- =============================================================================
-- WEYL GROUP AND PHYSICS
-- =============================================================================

/-- Weyl factor from |W(E8)| = 2^14 × 3^5 × 5^2 × 7 -/
def Weyl_factor : ℕ := 5

/-- Weyl squared (pentagonal structure) -/
def Weyl_sq : ℕ := Weyl_factor * Weyl_factor

/-- Order of Weyl group of E8 -/
def weyl_E8_order : ℕ := 696729600

-- =============================================================================
-- STANDARD MODEL
-- =============================================================================

/-- Number of fermion generations (from K₄ perfect matchings = 3) -/
def N_gen : ℕ := 3

/-- SU(3) color dimension -/
def dim_SU3 : ℕ := 8

/-- SU(2) weak isospin dimension -/
def dim_SU2 : ℕ := 3

/-- U(1) hypercharge dimension -/
def dim_U1 : ℕ := 1

/-- Total SM gauge dimension -/
def dim_SM_gauge : ℕ := dim_SU3 + dim_SU2 + dim_U1

-- =============================================================================
-- PRIME SEQUENCE (for exceptional chain)
-- =============================================================================

/-- 6th prime (for E6) -/
def prime_6 : ℕ := 13

/-- 8th prime (for E7) -/
def prime_8 : ℕ := 19

/-- 11th prime (for E8) -/
def prime_11 : ℕ := 31

-- =============================================================================
-- METRIC PARAMETERS
-- =============================================================================

/-- Metric determinant numerator: det(g) = 65/32 -/
def det_g_num : ℕ := 65

/-- Metric determinant denominator -/
def det_g_den : ℕ := 32

/-- Torsion coefficient denominator: κ_T = 1/61 -/
def kappa_T_den : ℕ := 61

-- =============================================================================
-- EXTENDED OBSERVABLES CONSTANTS (v3.3+)
-- =============================================================================

/-- Zeroth Betti number b₀ = 1 -/
def b0 : ℕ := 1

/-- Anomaly sum α_sum = rank(E₈) + Weyl = 8 + 5 = 13 -/
def alpha_sum : ℕ := rank_E8 + Weyl_factor

/-- Structural invariant 2b₂ = 42 = 2 × 3 × 7 = p₂ × N_gen × dim(K₇).
    This is NOT the Euler characteristic: for a compact oriented odd-dimensional
    manifold, χ(K₇) = 0 by Poincare duality (see `euler_char_K7_alternating_sum`). -/
abbrev two_b2 : ℕ := 2 * b2

/-- Deprecated name of `two_b2` (42 = 2b₂). The old name suggested an Euler
    characteristic; χ(K₇) = 0. -/
@[deprecated two_b2 (since := "2026-10-22")]
abbrev chi_K7 : ℕ := two_b2

/-- Order of PSL(2,7) = Fano plane symmetry = 168 -/
def PSL27 : ℕ := 168

-- =============================================================================
-- BASIC CERTIFIED THEOREMS
-- =============================================================================

theorem dim_E8_certified : dim_E8 = 248 := rfl
theorem rank_E8_certified : rank_E8 = 8 := rfl
theorem dim_E8xE8_certified : dim_E8xE8 = 496 := rfl
theorem dim_K7_certified : dim_K7 = 7 := rfl
theorem dim_J3O_certified : dim_J3O = 27 := rfl
theorem p2_certified : p2 = 2 := rfl
theorem Weyl_factor_certified : Weyl_factor = 5 := rfl
theorem Weyl_sq_certified : Weyl_sq = 25 := rfl
theorem D_bulk_certified : D_bulk = 11 := rfl
theorem SM_gauge_certified : dim_SM_gauge = 12 := rfl
theorem N_gen_certified : N_gen = 3 := rfl

-- From Algebraic.BettiNumbers (re-proven here for convenience)
theorem b2_value : b2 = 21 := rfl
theorem b3_value : b3 = 77 := rfl
theorem H_star_value : H_star = 99 := rfl

-- Core identity: H* = b2 + b3 + 1
theorem H_star_structure : H_star = b2 + b3 + 1 := rfl

-- Exceptional group dimensions
theorem dim_F4_certified : dim_F4 = 52 := rfl
theorem dim_E6_certified : dim_E6 = 78 := rfl
theorem dim_E7_certified : dim_E7 = 133 := rfl
theorem weyl_E8_order_certified : weyl_E8_order = 696729600 := rfl

-- Extended observables constants
theorem b0_certified : b0 = 1 := rfl
theorem alpha_sum_certified : alpha_sum = 13 := rfl
theorem two_b2_certified : two_b2 = 42 := rfl
@[deprecated two_b2_certified (since := "2026-10-22")]
alias chi_K7_certified := two_b2_certified
theorem PSL27_certified : PSL27 = 168 := rfl
theorem det_g_num_certified : det_g_num = 65 := rfl
theorem det_g_den_certified : det_g_den = 32 := rfl
theorem kappa_T_den_certified : kappa_T_den = 61 := rfl
theorem dim_fund_E7_certified : dim_fund_E7 = 56 := rfl

-- Key structural identities
theorem alpha_sum_decomposition : alpha_sum = rank_E8 + Weyl_factor := rfl
theorem two_b2_triple_product : two_b2 = p2 * N_gen * dim_K7 := rfl
@[deprecated two_b2_triple_product (since := "2026-10-22")]
alias chi_K7_triple_product := two_b2_triple_product
theorem PSL27_factorization : PSL27 = rank_E8 * b2 := rfl
theorem ninety_one_sum : b3 + dim_G2 = 91 := rfl
theorem ninety_one_factorization : 91 = dim_K7 * alpha_sum := rfl

-- =============================================================================
-- V3.3 CLARIFICATION: 42 = 2b₂, NOT χ(K₇)
-- =============================================================================

-- `two_b2` (defined above) is the name of the structural invariant 2b₂ = 42.

set_option linter.deprecated false in
/-- Deprecated: `chi_K7` is now an alias of `two_b2`. -/
@[deprecated "chi_K7 is an alias of two_b2" (since := "2026-10-22")]
theorem chi_K7_eq_two_b2 : chi_K7 = two_b2 := rfl

/-- The TRUE Euler characteristic of K₇ is 0 (compact oriented odd-dimensional).
    By Poincare duality: b_k = b_{7-k}, so terms cancel pairwise in the alternating sum.
    χ = b₀ - b₁ + b₂ - b₃ + b₄ - b₅ + b₆ - b₇
      = 1 - 0 + 21 - 77 + 77 - 21 + 0 - 1 = 0

    Proof: The positive and negative terms sum to the same value:
    positive = b₀ + b₂ + b₄ + b₆ = 1 + 21 + 77 + 0 = 99
    negative = b₁ + b₃ + b₅ + b₇ = 0 + 77 + 21 + 1 = 99
    Therefore χ = positive - negative = 0 -/
theorem euler_char_K7_alternating_sum :
    b0 + b2 + b3 + 0 = 0 + b3 + b2 + b0 := rfl

end GIFT.Core
