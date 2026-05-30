/-
  GIFT Foundations: Lean certificate for the exact smoothness of the
  Z_2^3-equivariant complete-intersection K3 surface
  X = V(Q_1, Q_2, Q_3) ⊂ P^5,  Q_k(z) = Σ_i Λ_{k,i} z_i^2,
  with Λ the 3×6 Vandermonde matrix on the six integer nodes

      a = (a_0,...,a_5) = (1, 2, 3, 5, 7, 11),     Λ_{k,i} = a_i^k  (k=0,1,2).

  The geometric smoothness proof (paper §3.3) reduces to a FINITE, EXACT
  fact over ℤ:

    (1) every 3×3 minor of Λ on columns i<j<k equals the Vandermonde
        determinant (a_j-a_i)(a_k-a_i)(a_k-a_j), hence is a nonzero
        integer  ==>  Jacobian J(z) = 2 Λ diag(z) has full rank 3 at every
        point with ≥ 3 nonzero coordinates;

    (2) every relevant 2×2 minor of Λ is a nonzero integer  ==>  no point
        of X has ≤ 2 nonzero coordinates (the |S|=1 column has leading
        entry a_i^0 = 1 ≠ 0; the |S|=2 system has trivial kernel because
        the rows-0,1 minor a_j - a_i ≠ 0).

  Together (1)+(2) give: every point of X has the full-rank Jacobian, so X
  is a smooth complete intersection CI(2,2,2), i.e. a smooth K3 (paper
  Theorem 2.2 / 3.3).  The present module machine-checks the finite integer
  content (1)+(2); the passage from "all these minors are nonzero" to
  "smooth K3" is the elementary Jacobian-criterion argument of §3.3, given
  in the paper.

  All theorems below are `Int` / `Nat` arithmetic, discharged by
  `native_decide` with no incomplete proofs and zero added axiom — same
  standing as K3IsotypeLefschetzCertificate.
-/

import GIFT.Core

namespace GIFT.Foundations.K3VandermondeSmoothness

/-! ### The Vandermonde nodes and matrix -/

/-- The six integer nodes a_0,...,a_5. -/
def nodes : List Int := [1, 2, 3, 5, 7, 11]

/-- The (k,i) entry of Λ is a_i^k, k ∈ {0,1,2}. -/
def lam (k i : Nat) : Int := (nodes.getD i 0) ^ k

/-- Λ as an explicit 3×6 integer matrix (rows = powers 0,1,2). -/
def Lambda : List (List Int) :=
  [[1, 1, 1, 1, 1, 1],
   [1, 2, 3, 5, 7, 11],
   [1, 4, 9, 25, 49, 121]]

/-- The entries computed from `lam` reproduce the explicit matrix. -/
theorem Lambda_entries :
    (List.range 3).map (fun k => (List.range 6).map (fun i => lam k i))
      = Lambda := by native_decide

/-! ### The twenty 3×3 minors equal Vandermonde products -/

/-- All ascending triples 0 ≤ i < j < k ≤ 5 (there are C(6,3)=20). -/
def triples : List (Nat × Nat × Nat) :=
  (List.range 6).flatMap (fun i =>
    (List.range 6).flatMap (fun j =>
      (List.range 6).map (fun k => (i, j, k))))
  |>.filter (fun t => t.1 < t.2.1 && t.2.1 < t.2.2)

theorem triples_count : triples.length = 20 := by native_decide

/-- The 3×3 minor of Λ on columns (i,j,k), expanded along the constant
    top row (Λ_{0,·} = 1): det = (col j det) - (col i…) … computed directly
    from the entries a^0, a^1, a^2. -/
def minor3 (t : Nat × Nat × Nat) : Int :=
  let i := t.1; let j := t.2.1; let k := t.2.2
  let ai := nodes.getD i 0; let aj := nodes.getD j 0; let ak := nodes.getD k 0
  -- det [[1,1,1],[ai,aj,ak],[ai^2,aj^2,ak^2]]
  (aj * ak^2 - ak * aj^2)
    - (ai * ak^2 - ak * ai^2)
    + (ai * aj^2 - aj * ai^2)

/-- The Vandermonde product (a_j-a_i)(a_k-a_i)(a_k-a_j) for a triple. -/
def vproduct (t : Nat × Nat × Nat) : Int :=
  let i := t.1; let j := t.2.1; let k := t.2.2
  let ai := nodes.getD i 0; let aj := nodes.getD j 0; let ak := nodes.getD k 0
  (aj - ai) * (ak - ai) * (ak - aj)

/-- Lemma 2.1 / 3.1 (identity form): every 3×3 minor equals the
    corresponding Vandermonde product. -/
theorem minor3_eq_vproduct :
    triples.all (fun t => decide (minor3 t = vproduct t)) = true := by
  native_decide

/-- Lemma 2.1 / 3.1 (nonvanishing form): every one of the twenty 3×3 minors
    is a nonzero integer. -/
theorem minor3_all_nonzero :
    triples.all (fun t => decide (minor3 t ≠ 0)) = true := by native_decide

/-- The explicit list of the twenty minor values (absolute values range
    from 2 to 240, as stated in the paper's reproducibility appendix). -/
theorem minor3_values :
    triples.map minor3 =
      [2, 12, 30, 90, 16, 48, 160, 48, 240, 240, 6, 20, 72,
       30, 162, 180, 16, 96, 128, 48] := by native_decide

/-! ### The relevant 2×2 minors are nonzero -/

/-- All ascending pairs 0 ≤ i < j ≤ 5 (there are C(6,2)=15). -/
def pairs : List (Nat × Nat) :=
  (List.range 6).flatMap (fun i =>
    (List.range 6).map (fun j => (i, j)))
  |>.filter (fun p => p.1 < p.2)

theorem pairs_count : pairs.length = 15 := by native_decide

/-- 2×2 minor of rows 0,1 on a column pair (i,j): a_j - a_i. -/
def minor2_rows01 (p : Nat × Nat) : Int :=
  nodes.getD p.2 0 - nodes.getD p.1 0

/-- 2×2 minor of rows 0,2 on (i,j): a_j^2 - a_i^2. -/
def minor2_rows02 (p : Nat × Nat) : Int :=
  (nodes.getD p.2 0)^2 - (nodes.getD p.1 0)^2

/-- 2×2 minor of rows 1,2 on (i,j): a_i a_j (a_j - a_i). -/
def minor2_rows12 (p : Nat × Nat) : Int :=
  (nodes.getD p.1 0) * (nodes.getD p.2 0) *
    (nodes.getD p.2 0 - nodes.getD p.1 0)

/-- Lemma 2.1 / 3.2: every 2×2 minor of Λ (on rows {0,1}, {0,2}, {1,2})
    is a nonzero integer. This is what excludes points of X with exactly
    two nonzero coordinates. -/
theorem minor2_all_nonzero :
    pairs.all (fun p =>
      decide (minor2_rows01 p ≠ 0) &&
      decide (minor2_rows02 p ≠ 0) &&
      decide (minor2_rows12 p ≠ 0)) = true := by native_decide

/-- The |S|=1 exclusion: the leading entry of every column of Λ is
    a_i^0 = 1 ≠ 0, so Q_1 = z_i^2 ≠ 0 there. -/
theorem leading_row_all_one :
    (List.range 6).all (fun i => decide (lam 0 i = 1)) = true := by
  native_decide

/-! ### Aggregate certificate -/

/-- Composite Boolean certificate: the finite integer content of the exact
    Vandermonde smoothness argument (paper §3.3 / Theorem 2.2). -/
def k3VandermondeSmoothnessCertificate : Bool :=
  decide (triples.length = 20) &&
  triples.all (fun t => decide (minor3 t = vproduct t)) &&
  triples.all (fun t => decide (minor3 t ≠ 0)) &&
  decide (pairs.length = 15) &&
  pairs.all (fun p =>
    decide (minor2_rows01 p ≠ 0) &&
    decide (minor2_rows02 p ≠ 0) &&
    decide (minor2_rows12 p ≠ 0)) &&
  (List.range 6).all (fun i => decide (lam 0 i = 1))

theorem k3VandermondeSmoothnessCertificate_holds :
    k3VandermondeSmoothnessCertificate = true := by native_decide

/-- Human-readable status. -/
def k3VandermondeSmoothnessStatus : String :=
  "Exact Vandermonde smoothness of X = V(Q_1,Q_2,Q_3) ⊂ P^5 on nodes (1,2,3,5,7,11): all 20 of the 3×3 minors equal the node-difference products (a_j-a_i)(a_k-a_i)(a_k-a_j) and are nonzero (so rank J = 3 wherever ≥3 coordinates are nonzero); all 15·3 relevant 2×2 minors are nonzero and the leading row is all ones (so no point of X has ≤2 nonzero coordinates). Hence X is a smooth CI(2,2,2) K3 (paper Theorem 2.2)."

theorem k3VandermondeSmoothnessStatus_nonempty :
    k3VandermondeSmoothnessStatus.length > 0 := by native_decide

end GIFT.Foundations.K3VandermondeSmoothness
