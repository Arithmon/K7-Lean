-- GIFT Foundations: Metric Candidate Search
-- Symbolic search layer for the analytic/torsion-free building-block gate.
--
-- The search here is deliberately small and exact: enumerate Betti signatures
-- compatible with the K7 target, score them against the structural GIFT
-- constraints, and hand the unique zero-score signature to MetricGapClosure.
-- No catalogue or ML dependency is required at this layer.

import GIFT.Foundations.MetricGapClosure

namespace GIFT.Foundations.MetricCandidateSearch

/-- A minimal Betti signature for one putative building block. -/
structure BlockBetti where
  b2 : Nat
  b3 : Nat
  deriving DecidableEq, Repr

/-- Ordered pair of putative building blocks. -/
structure BlockPair where
  left : BlockBetti
  right : BlockBetti
  deriving DecidableEq, Repr

/-- Effective cohomological degrees of freedom, H* = 1 + b2 + b3. -/
def BlockBetti.Hstar (B : BlockBetti) : Nat :=
  1 + B.b2 + B.b3

/-- Absolute difference on natural numbers, written with truncated subtraction. -/
def absDiff (a b : Nat) : Nat :=
  (a - b) + (b - a)

/-- Build a pair by choosing the left block and using the K7 Betti target
    to fill the right block. The search space below only calls this with
    `left.b2 <= b2` and `left.b3 <= b3`. -/
def pairFromLeft (left_b2 left_b3 : Nat) : BlockPair where
  left := { b2 := left_b2, b3 := left_b3 }
  right := {
    b2 := GIFT.Core.b2 - left_b2
    b3 := GIFT.Core.b3 - left_b3
  }

/-- The current arithmetic witness, recovered as a candidate rather than
    hard-coded into the search result. -/
def canonicalPair : BlockPair :=
  pairFromLeft 11 40

/-- Finite symbolic search space: all ordered Betti decompositions
    `(b2_left, b3_left) + (b2_right, b3_right) = (21,77)`. -/
def searchSpace : List BlockPair :=
  (List.range (GIFT.Core.b2 + 1)).flatMap (fun left_b2 =>
    (List.range (GIFT.Core.b3 + 1)).map (fun left_b3 =>
      pairFromLeft left_b2 left_b3))

/-- Symbolic GIFT score.

Zero means:
* total Betti numbers match K7;
* ordered b2 asymmetry is 1;
* ordered b3 asymmetry is N_gen = 3;
* left block has H* = dim(F4) = 52;
* right block has H* = h(G2) * rank(E8) = 48.
-/
def pairScore (P : BlockPair) : Nat :=
  absDiff (P.left.b2 + P.right.b2) GIFT.Core.b2 +
  absDiff (P.left.b3 + P.right.b3) GIFT.Core.b3 +
  absDiff (P.left.b2 - P.right.b2) 1 +
  absDiff (P.left.b3 - P.right.b3) GIFT.Core.N_gen +
  absDiff P.left.Hstar GIFT.Core.dim_F4 +
  absDiff P.right.Hstar (GIFT.Core.h_G2 * GIFT.Core.rank_E8)

/-- Boolean exactness predicate used by `List.filter`. -/
def isExactCandidate (P : BlockPair) : Bool :=
  pairScore P == 0

/-- All zero-score candidates in the finite symbolic search. -/
def exactCandidates : List BlockPair :=
  searchSpace.filter isExactCandidate

theorem search_space_size : searchSpace.length = 1716 := by native_decide

theorem canonical_pair_score_zero : pairScore canonicalPair = 0 := by native_decide

/-- The symbolic constraints isolate a single ordered Betti signature. -/
theorem exact_candidates_unique :
    exactCandidates = [canonicalPair] := by native_decide

theorem exact_candidate_count : exactCandidates.length = 1 := by native_decide

theorem canonical_pair_values :
    canonicalPair.left.b2 = 11 ∧
    canonicalPair.left.b3 = 40 ∧
    canonicalPair.right.b2 = 10 ∧
    canonicalPair.right.b3 = 37 := by
  native_decide

theorem canonical_pair_Hstars :
    canonicalPair.left.Hstar = GIFT.Core.dim_F4 ∧
    canonicalPair.right.Hstar = GIFT.Core.h_G2 * GIFT.Core.rank_E8 := by
  native_decide

/-- Convert a Betti-only search result into the stricter metric-gap gate type. -/
def BlockBetti.toGapCandidate
    (B : BlockBetti)
    (semiFano analytic torsionFree : Bool) :
    GIFT.Foundations.MetricGapClosure.CandidateBuildingBlock where
  b2 := B.b2
  b3 := B.b3
  semiFanoIdentified := semiFano
  analyticMetric := analytic
  torsionFreeMetric := torsionFree

def canonical_left_gap_candidate :
    GIFT.Foundations.MetricGapClosure.CandidateBuildingBlock :=
  canonicalPair.left.toGapCandidate false false false

def canonical_right_gap_candidate :
    GIFT.Foundations.MetricGapClosure.CandidateBuildingBlock :=
  canonicalPair.right.toGapCandidate false false false

/-- The arithmetic search can find the signature, but cannot promote it
    until geometry and metric certificates are supplied. -/
theorem canonical_pair_still_needs_geometry :
    ¬ GIFT.Foundations.MetricGapClosure.BlocksPromotable
      canonical_left_gap_candidate canonical_right_gap_candidate := by
  simp [
    GIFT.Foundations.MetricGapClosure.BlocksPromotable,
    canonical_left_gap_candidate,
    BlockBetti.toGapCandidate
  ]

/-- Stage-2 master certificate: the symbolic search is finite, non-empty,
    unique at score zero, and still blocked by the metric promotion gate. -/
theorem metric_candidate_search_certificate :
    searchSpace.length = 1716 ∧
    pairScore canonicalPair = 0 ∧
    exactCandidates = [canonicalPair] ∧
    exactCandidates.length = 1 ∧
    canonicalPair.left.Hstar = GIFT.Core.dim_F4 ∧
    canonicalPair.right.Hstar = GIFT.Core.h_G2 * GIFT.Core.rank_E8 ∧
    ¬ GIFT.Foundations.MetricGapClosure.BlocksPromotable
      canonical_left_gap_candidate canonical_right_gap_candidate := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact search_space_size
  · exact canonical_pair_score_zero
  · exact exact_candidates_unique
  · exact exact_candidate_count
  · exact canonical_pair_Hstars.left
  · exact canonical_pair_Hstars.right
  · exact canonical_pair_still_needs_geometry

end GIFT.Foundations.MetricCandidateSearch
