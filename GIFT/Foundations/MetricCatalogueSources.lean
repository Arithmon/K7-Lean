-- GIFT Foundations: Metric Catalogue Sources
-- Catalogue-aware constraints for turning Fano/semi-Fano data into
-- analytic TCS building-block targets.

import GIFT.Core
import GIFT.Foundations.MetricCandidateSearch

namespace GIFT.Foundations.MetricCatalogueSources

/-!
This module records the catalogue layer used by the metric search.  It does not
claim that any catalogue entry has already produced the missing GIFT building
blocks; instead it pins down the source inventory and the CHNP topological
formulae that every candidate must pass.

The important separation is:

* `MetricCandidateSearch` finds the arithmetic GIFT witness `(11,40)+(10,37)`.
* The catalogue layer asks whether real semi-Fano/TCS building blocks can
  realize the corresponding analytic geometry.
* In the orthogonal, generic semi-Fano, `K = 0` regime the GIFT target forces
  the block `b3` sum to be `75`, so the current arithmetic witness is not an
  orthogonal CHNP witness.
-/

/-- A source of Fano/semi-Fano catalogue information. -/
structure CatalogueSource where
  name : String
  localRef : String
  url : String
  recordCount : Nat
  recordCountKnown : Bool
  machineReadable : Bool
  deriving Repr

/-- Fanography lists the 105 smooth Fano threefold deformation families. -/
def fanographySmoothFano : CatalogueSource where
  name := "Fanography smooth Fano threefolds"
  localRef := "remote: https://www.fanography.info/"
  url := "https://www.fanography.info/"
  recordCount := 105
  recordCountKnown := true
  machineReadable := true

/-- The local index-one Fano 3-fold database archive. -/
def fano3IndexOneDatabase : CatalogueSource where
  name := "Fano 3-fold database, index 1"
  localRef := "tmp/5820338.zip"
  url := "https://doi.org/10.5281/zenodo.5820338"
  recordCount := 52646
  recordCountKnown := true
  machineReadable := true

/-- The local toric canonical Fano 3-fold database archive. -/
def toricCanonicalFano3Database : CatalogueSource where
  name := "Toric canonical Fano 3-fold database"
  localRef := "tmp/5866330.zip"
  url := "https://doi.org/10.5281/zenodo.5866330"
  recordCount := 674688
  recordCountKnown := true
  machineReadable := true

/-- CHNP ACyl Calabi-Yau building-block source, stored locally as arXiv source. -/
def chnpAcylCalabiYauSource : CatalogueSource where
  name := "CHNP ACyl Calabi-Yau 3-folds from weak Fano 3-folds"
  localRef := "tmp/arXiv-1206.2277v3.tar.gz"
  url := "https://arxiv.org/abs/1206.2277"
  recordCount := 0
  recordCountKnown := false
  machineReadable := false

/-- CHNP semi-Fano G2/TCS source, stored locally as arXiv source. -/
def chnpG2SemiFanoSource : CatalogueSource where
  name := "CHNP G2-manifolds via semi-Fano 3-folds"
  localRef := "tmp/arXiv-1207.4470v3.tar.gz"
  url := "https://arxiv.org/abs/1207.4470"
  recordCount := 0
  recordCountKnown := false
  machineReadable := false

/-- Rank-two weak Fano update provided in the local catalogue folder. -/
def rankTwoWeakFanoUpdateSource : CatalogueSource where
  name := "Update on rank 2 weak Fano threefolds"
  localRef := "tmp/2408.13097v3.pdf"
  url := "https://arxiv.org/abs/2408.13097"
  recordCount := 0
  recordCountKnown := false
  machineReadable := false

/-- Extra-twisted connected sums are the natural escape hatch from orthogonal TCS. -/
def extraTwistedConnectedSumSource : CatalogueSource where
  name := "Extra-twisted connected sum G2-manifolds"
  localRef := "tmp/s10455-023-09893-1.pdf"
  url := "https://doi.org/10.1007/s10455-023-09893-1"
  recordCount := 0
  recordCountKnown := false
  machineReadable := false

def localMachineReadableRecordCount : Nat :=
  fano3IndexOneDatabase.recordCount + toricCanonicalFano3Database.recordCount

theorem fanography_smooth_fano_family_count :
    fanographySmoothFano.recordCount = 105 := rfl

theorem local_machine_readable_record_count_value :
    localMachineReadableRecordCount = 727334 := by native_decide

/-!
## Catalogue rank ceilings

The local scans show that the smooth-Fano and toric-canonical catalogues are
excellent for `b3` arithmetic, but cannot by themselves provide `b2 = 21` in a
`K = 0` gluing:

* Fanography smooth Fanos have Picard rank at most `10`.
* The toric canonical Fano 3-fold catalogue has Picard rank at most `7`.
* In the index-one Fano 3-fold database, `k3_rank` means the basket sum
  `sum (r - 1)`, not a Picard rank.  It is therefore a singularity/K3-basket
  proxy for possible lattice supply, not a certified XTCS kernel rank.
-/

def fanographyMaxPicardRank : Nat := 10
def toricCanonicalMaxPicardRank : Nat := 7
def fano3MaxK3Rank : Nat := 22
def fano3HighK3RankCount : Nat := 667
def fano3StableHighK3RankCount : Nat := 495
def fano3HighK3WithToricMatchCount : Nat := 0
def fano3BasketK3Rank11Count : Nat := 2236
def fano3StableBasketK3Rank11Count : Nat := 1674
def fano3BasketK3Rank10Count : Nat := 1822
def fano3StableBasketK3Rank10Count : Nat := 1367
def fano3K3RankIsBasketSum : Bool := true
def fano3K3RankIsCertifiedKernelRank : Bool := false

theorem fanography_picard_rank_ceiling :
    fanographyMaxPicardRank = 10 := rfl

theorem toric_canonical_picard_rank_ceiling :
    toricCanonicalMaxPicardRank = 7 := rfl

theorem k0_catalogues_below_gift_b2 :
    fanographyMaxPicardRank < GIFT.Core.b2 /\
    toricCanonicalMaxPicardRank < GIFT.Core.b2 := by
  native_decide

theorem fano3_high_k3_rank_supply :
    fano3MaxK3Rank = 22 /\
    fano3HighK3RankCount = 667 /\
    fano3StableHighK3RankCount = 495 /\
    fano3HighK3RankCount > 0 := by
  native_decide

theorem fano3_k3_rank_semantics_certificate :
    fano3K3RankIsBasketSum = true /\
    fano3K3RankIsCertifiedKernelRank = false /\
    fano3BasketK3Rank11Count = 2236 /\
    fano3StableBasketK3Rank11Count = 1674 /\
    fano3BasketK3Rank10Count = 1822 /\
    fano3StableBasketK3Rank10Count = 1367 := by
  native_decide

/-- A representative stable index-one Fano row with maximal K3 rank. -/
structure Fano3K3Candidate where
  id : Nat
  k3Rank : Nat
  stable : Bool
  hasElephant : Bool
  degreeNum : Nat
  degreeDen : Nat
  genus : Int
  codimension : Nat
  basketSize : Nat
  deriving DecidableEq, Repr

def fano3_rank22_candidate_450 : Fano3K3Candidate where
  id := 450
  k3Rank := 22
  stable := true
  hasElephant := true
  degreeNum := 22
  degreeDen := 119
  genus := -1
  codimension := 20
  basketSize := 2

theorem fano3_rank22_candidate_450_certificate :
    fano3_rank22_candidate_450.k3Rank = 22 /\
    fano3_rank22_candidate_450.stable = true /\
    fano3_rank22_candidate_450.hasElephant = true := by
  native_decide

def fano3_rank11_proxy_candidate_5864 : Fano3K3Candidate where
  id := 5864
  k3Rank := 11
  stable := true
  hasElephant := true
  degreeNum := 11
  degreeDen := 12
  genus := 0
  codimension := 6
  basketSize := 1

def fano3_rank10_proxy_candidate_4908 : Fano3K3Candidate where
  id := 4908
  k3Rank := 10
  stable := true
  hasElephant := true
  degreeNum := 2
  degreeDen := 11
  genus := 0
  codimension := 2
  basketSize := 1

theorem fano3_kernel_proxy_pair_certificate :
    fano3_rank11_proxy_candidate_5864.k3Rank +
      fano3_rank10_proxy_candidate_4908.k3Rank = GIFT.Core.b2 /\
    fano3_rank11_proxy_candidate_5864.stable = true /\
    fano3_rank10_proxy_candidate_4908.stable = true /\
    fano3K3RankIsCertifiedKernelRank = false := by
  native_decide

/-!
## From smooth Fano data to a semi-Fano block target

For a generic semi-Fano block built by blowing up the base curve of an
anticanonical pencil, CHNP gives `K = 0`, `N ~= Pic(Y)`, and the blow-up adds
`2g(C) = (-K_Y)^3 + 2` to `b3`.  Thus the block target is

`b3(Z) = b3(Y) + (-K_Y)^3 + 2 = 2 h^{1,2}(Y) + (-K_Y)^3 + 2`

for a smooth Fano threefold `Y`.
-/

/-- Minimal smooth-Fano invariants exposed by Fanography and CHNP tables. -/
structure SmoothFanoInvariant where
  rho : Nat
  anticanonicalDegree : Nat
  h12 : Nat
  deriving DecidableEq, Repr

/-- For smooth Fano threefolds, `b3(Y) = 2 h^{1,2}(Y)`. -/
def SmoothFanoInvariant.b3Y (Y : SmoothFanoInvariant) : Nat :=
  2 * Y.h12

/-- Generic semi-Fano block `b3` target from CHNP. -/
def semiFanoBlockB3 (anticanonicalDegree b3Y : Nat) : Nat :=
  b3Y + anticanonicalDegree + 2

/-- The generic block `b3` target associated to a smooth Fano invariant row. -/
def SmoothFanoInvariant.blockB3 (Y : SmoothFanoInvariant) : Nat :=
  semiFanoBlockB3 Y.anticanonicalDegree Y.b3Y

def fanography_1_1_double_sextic : SmoothFanoInvariant where
  rho := 1
  anticanonicalDegree := 2
  h12 := 52

def fanography_1_10_v22 : SmoothFanoInvariant where
  rho := 1
  anticanonicalDegree := 22
  h12 := 0

def fanography_1_17_p3 : SmoothFanoInvariant where
  rho := 1
  anticanonicalDegree := 64
  h12 := 0

def fanography_10_1_high_rho : SmoothFanoInvariant where
  rho := 10
  anticanonicalDegree := 6
  h12 := 0

def fanography_2_36_xtcs_left : SmoothFanoInvariant where
  rho := 2
  anticanonicalDegree := 62
  h12 := 0

def fanography_8_1_xtcs_right : SmoothFanoInvariant where
  rho := 8
  anticanonicalDegree := 18
  h12 := 0

def fanography_4_10_xtcs_left : SmoothFanoInvariant where
  rho := 4
  anticanonicalDegree := 42
  h12 := 0

def fanography_5_2_xtcs_right : SmoothFanoInvariant where
  rho := 5
  anticanonicalDegree := 36
  h12 := 0

theorem fanography_sample_block_b3_values :
    fanography_1_1_double_sextic.blockB3 = 108 /\
    fanography_1_10_v22.blockB3 = 24 /\
    fanography_1_17_p3.blockB3 = 66 /\
    fanography_10_1_high_rho.blockB3 = 8 := by
  native_decide

theorem fanography_sample_block_b3_even :
    fanography_1_1_double_sextic.blockB3 % 2 = 0 /\
    fanography_1_10_v22.blockB3 % 2 = 0 /\
    fanography_1_17_p3.blockB3 % 2 = 0 /\
    fanography_10_1_high_rho.blockB3 % 2 = 0 := by
  native_decide

theorem fanography_xtcs_pair_block_b3_values :
    fanography_2_36_xtcs_left.blockB3 = 64 /\
    fanography_8_1_xtcs_right.blockB3 = 20 /\
    fanography_2_36_xtcs_left.blockB3 / 2 = 32 /\
    fanography_8_1_xtcs_right.blockB3 / 2 = 10 := by
  native_decide

theorem fanography_ranked_xtcs_pair_block_b3_values :
    fanography_4_10_xtcs_left.blockB3 = 44 /\
    fanography_5_2_xtcs_right.blockB3 = 38 /\
    fanography_4_10_xtcs_left.blockB3 / 2 = 22 /\
    fanography_5_2_xtcs_right.blockB3 / 2 = 19 := by
  native_decide

/-!
## The GIFT orthogonal-K0 target

For orthogonal CHNP gluing with generic semi-Fano blocks (`K_+ = K_- = 0`),
Lemma 6.7 gives:

`b2(M) + b3(M) = b3(Z_+) + b3(Z_-) + 23`.

The GIFT target has `b2 + b3 = 98`, hence an orthogonal-K0 search would need
`b3(Z_+) + b3(Z_-) = 75`.  This is intentionally different from the symbolic
GIFT arithmetic witness `(11,40)+(10,37)`, whose block `b3` sum is `77`.
-/

inductive MetricSearchRegime where
  | orthogonalK0
  | nonOrthogonal
  | extraTwisted
  | newG2Variant
  deriving DecidableEq, Repr

/-- A catalogue-stage gate for a particular TCS/G2 search regime. -/
structure MetricCatalogueGate where
  regime : MetricSearchRegime
  requiredBlockB3Sum : Nat
  requiredK3IntersectionRank : Nat
  evenBlockB3Compatible : Bool
  deriving Repr

def giftBettiPairTotal : Nat :=
  GIFT.Core.b2 + GIFT.Core.b3

def chnpOrthogonalConstant : Nat := 23

def orthogonalK0RequiredBlockB3Sum : Nat :=
  giftBettiPairTotal - chnpOrthogonalConstant

def giftOrthogonalK0Gate : MetricCatalogueGate where
  regime := .orthogonalK0
  requiredBlockB3Sum := orthogonalK0RequiredBlockB3Sum
  requiredK3IntersectionRank := GIFT.Core.b2
  evenBlockB3Compatible := false

def symbolicPairBlockB3Sum : Nat :=
  GIFT.Foundations.MetricCandidateSearch.canonicalPair.left.b3 +
    GIFT.Foundations.MetricCandidateSearch.canonicalPair.right.b3

theorem gift_betti_pair_total_value :
    giftBettiPairTotal = 98 := by native_decide

theorem orthogonal_k0_required_block_b3_sum_value :
    orthogonalK0RequiredBlockB3Sum = 75 := by native_decide

theorem orthogonal_k0_required_block_b3_sum_odd :
    orthogonalK0RequiredBlockB3Sum % 2 = 1 := by native_decide

theorem gift_orthogonal_k0_gate_certificate :
    giftOrthogonalK0Gate.requiredBlockB3Sum = 75 /\
    giftOrthogonalK0Gate.requiredK3IntersectionRank = 21 /\
    giftOrthogonalK0Gate.evenBlockB3Compatible = false := by
  native_decide

theorem symbolic_pair_block_b3_sum_value :
    symbolicPairBlockB3Sum = 77 := by native_decide

theorem symbolic_pair_not_orthogonal_k0 :
    symbolicPairBlockB3Sum = orthogonalK0RequiredBlockB3Sum -> False := by
  native_decide

/-- Master certificate for the catalogue source layer and the orthogonal-K0 gate. -/
theorem metric_catalogue_sources_certificate :
    fanographySmoothFano.recordCount = 105 /\
    localMachineReadableRecordCount = 727334 /\
    fanography_1_17_p3.blockB3 = 66 /\
    orthogonalK0RequiredBlockB3Sum = 75 /\
    orthogonalK0RequiredBlockB3Sum % 2 = 1 /\
    symbolicPairBlockB3Sum = 77 /\
    (symbolicPairBlockB3Sum = orthogonalK0RequiredBlockB3Sum -> False) := by
  native_decide

end GIFT.Foundations.MetricCatalogueSources
