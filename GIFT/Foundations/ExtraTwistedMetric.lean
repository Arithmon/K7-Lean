-- GIFT Foundations: Extra-Twisted Metric Gate
-- A catalogue-stage model for the non-rectangular extra-twisted connected
-- sum regime suggested by Nordstrom's XTCS construction.

import GIFT.Core
import GIFT.Foundations.MetricCatalogueSources

namespace GIFT.Foundations.ExtraTwistedMetric

/-!
The ordinary orthogonal TCS gate is blocked for the GIFT target because
`b2 + b3 = 98` is even, while rectangular/orthogonal TCS forces odd `b2+b3`.

Nordstrom's extra-twisted connected sums remove that parity obstruction.  The
Mayer-Vietoris rank formula used here is the rational-rank part of Sect. 7.1:

`b3(M) = 23 - r+ - r- + b2(M) + b3plus(Z+) + b3plus(Z-) + d_angle`.

Here `r+`, `r-` are polarising ranks, `b3plus` is the invariant third-cohomology
rank of the block, and `d_angle` is the multiplicity of the non-rectangular
configuration angle.  This module records a finite Diophantine shape check for
the next search stage; it does not certify that the listed ranks have already
been realized by algebraic blocks with matching involutions or by a valid
Nordstrom matching instance.
-/

/-- Rank-level data needed by the extra-twisted Betti formula. -/
structure ExtraTwistedGate where
  polarisingRankPlus : Nat
  polarisingRankMinus : Nat
  b2M : Nat
  invariantB3Plus : Nat
  invariantB3Minus : Nat
  angleMultiplicity : Nat
  kernelRankPlus : Nat
  kernelRankMinus : Nat
  nonRectangular : Bool
  deriving DecidableEq, Repr

def ExtraTwistedGate.invariantB3Sum (G : ExtraTwistedGate) : Nat :=
  G.invariantB3Plus + G.invariantB3Minus

def ExtraTwistedGate.polarisingRankSum (G : ExtraTwistedGate) : Nat :=
  G.polarisingRankPlus + G.polarisingRankMinus

/-- Nordstrom XTCS rank formula, kept in `Int` to avoid truncated subtraction. -/
def ExtraTwistedGate.predictedB3 (G : ExtraTwistedGate) : Int :=
  (23 : Int)
    - (G.polarisingRankPlus : Int)
    - (G.polarisingRankMinus : Int)
    + (G.b2M : Int)
    + (G.invariantB3Plus : Int)
    + (G.invariantB3Minus : Int)
    + (G.angleMultiplicity : Int)

/-- Parity side of Nordstrom Remark 7.3:
    `1+b2+b3 = r+ + r- + d_angle (mod 2)`. -/
def ExtraTwistedGate.configurationParity (G : ExtraTwistedGate) : Nat :=
  (G.polarisingRankPlus + G.polarisingRankMinus + G.angleMultiplicity) % 2

def giftSemiCharacteristicParity : Nat :=
  (1 + GIFT.Core.b2 + GIFT.Core.b3) % 2

/-- Standard projective K3 Picard-rank ceiling used by polarising lattices. -/
def projectiveK3PicardRankCeiling : Nat := 20

theorem gift_b2_exceeds_projective_k3_picard_ceiling :
    Not (GIFT.Core.b2 <= projectiveK3PicardRankCeiling) := by
  native_decide

/-- Under the standard `H^2(M)=N+ cap N-` reading, `b2` is bounded by both ranks. -/
def standardNordstromIntersectionB2Screen
    (b2M polarisingRankPlus polarisingRankMinus : Nat) : Bool :=
  decide (b2M <= polarisingRankPlus /\ b2M <= polarisingRankMinus)

theorem no_standard_nordstrom_b2_under_projective_k3_ceiling
    (rPlus rMinus : Nat)
    (hPlus : rPlus <= projectiveK3PicardRankCeiling)
    (_hMinus : rMinus <= projectiveK3PicardRankCeiling) :
    Not (GIFT.Core.b2 <= rPlus /\ GIFT.Core.b2 <= rMinus) := by
  intro h
  exact gift_b2_exceeds_projective_k3_picard_ceiling
    (Nat.le_trans h.left hPlus)

theorem no_projective_k3_standard_nordstrom_intersection_witness_for_gift_b2 :
    Not (Exists fun rPlus : Nat =>
      Exists fun rMinus : Nat =>
        rPlus <= projectiveK3PicardRankCeiling /\
        rMinus <= projectiveK3PicardRankCeiling /\
        GIFT.Core.b2 <= rPlus /\
        GIFT.Core.b2 <= rMinus) := by
  intro h
  rcases h with ⟨rPlus, rMinus, hPlus, hMinus, hB2Plus, hB2Minus⟩
  exact no_standard_nordstrom_b2_under_projective_k3_ceiling
    rPlus rMinus hPlus hMinus ⟨hB2Plus, hB2Minus⟩

/-!
## Audit screens for Nordstrom auxiliary constraints

The `predictedB3` identity below is only the rank formula shape.  The current
catalogue witness is not a valid XTCS instance unless auxiliary constraints are
also supplied: parity screens for invariant `b3`, the intersection-rank bound
`b2(M) <= min(r+, r-)` when `b2` is interpreted as `rk(N+ cap N-)`, primitive
lattice embeddings, and certified angle/matching data.
-/

/-- Audit screen: both invariant `b3plus` entries pass the evenness check. -/
def ExtraTwistedGate.invariantB3EvenScreen (G : ExtraTwistedGate) : Bool :=
  decide (G.invariantB3Plus % 2 = 0 /\ G.invariantB3Minus % 2 = 0)

/-- Audit screen for the intersection-only interpretation of `b2(M)`. -/
def ExtraTwistedGate.intersectionRankBoundScreen (G : ExtraTwistedGate) : Bool :=
  standardNordstromIntersectionB2Screen G.b2M
    G.polarisingRankPlus G.polarisingRankMinus

/-- What has actually been checked for a candidate gate. -/
structure NordstromConstraintAudit where
  diophantineIdentityChecked : Bool
  invariantB3EvenScreenChecked : Bool
  intersectionRankBoundChecked : Bool
  primitiveEmbeddingCertified : Bool
  angleMatchingCertified : Bool
  hyperKahlerRotationCertified : Bool
  spinCharacteristicCertified : Bool
  deriving DecidableEq, Repr

def ExtraTwistedGate.constraintAudit (G : ExtraTwistedGate) :
    NordstromConstraintAudit where
  diophantineIdentityChecked :=
    decide (G.predictedB3 = (GIFT.Core.b3 : Int))
  invariantB3EvenScreenChecked := G.invariantB3EvenScreen
  intersectionRankBoundChecked := G.intersectionRankBoundScreen
  primitiveEmbeddingCertified := false
  angleMatchingCertified := false
  hyperKahlerRotationCertified := false
  spinCharacteristicCertified := false

/-- A deliberately balanced non-rectangular Diophantine shape gate.

The invariant block contribution is `26+26 = dim F4`, the polarising ranks use
the maximum smooth-Fano Picard-rank scale visible in Fanography (`10+10`), and
the minimal odd angle multiplicity supplies the parity correction.
-/
def balancedExtraTwistedGate : ExtraTwistedGate where
  polarisingRankPlus := 10
  polarisingRankMinus := 10
  b2M := GIFT.Core.b2
  invariantB3Plus := 26
  invariantB3Minus := 26
  angleMultiplicity := 1
  kernelRankPlus := 11
  kernelRankMinus := 10
  nonRectangular := true

theorem balanced_extra_twisted_rank_sum :
    balancedExtraTwistedGate.polarisingRankSum = 20 := by
  native_decide

theorem balanced_extra_twisted_invariant_b3_sum :
    balancedExtraTwistedGate.invariantB3Sum = GIFT.Core.dim_F4 := by
  native_decide

theorem balanced_extra_twisted_minimal_angle :
    balancedExtraTwistedGate.angleMultiplicity = 1 := rfl

theorem balanced_extra_twisted_non_rectangular :
    balancedExtraTwistedGate.nonRectangular = true := rfl

theorem balanced_extra_twisted_predicts_b2 :
    balancedExtraTwistedGate.b2M = GIFT.Core.b2 := rfl

theorem balanced_extra_twisted_b2_from_kernels :
    balancedExtraTwistedGate.kernelRankPlus +
      balancedExtraTwistedGate.kernelRankMinus = GIFT.Core.b2 := by
  native_decide

theorem balanced_extra_twisted_predicts_b3 :
    balancedExtraTwistedGate.predictedB3 = (GIFT.Core.b3 : Int) := by
  native_decide

theorem balanced_extra_twisted_parity_matches :
    balancedExtraTwistedGate.configurationParity = giftSemiCharacteristicParity := by
  native_decide

theorem gift_betti_sum_even_extra_twisted_allowed :
    (GIFT.Core.b2 + GIFT.Core.b3) % 2 = 0 /\
    balancedExtraTwistedGate.nonRectangular = true /\
    balancedExtraTwistedGate.predictedB3 = (GIFT.Core.b3 : Int) := by
  native_decide

/-- The extra-twisted correction needed by the balanced gate. -/
def balancedAngleCorrection : Int :=
  (GIFT.Core.b3 : Int)
    - ((23 : Int)
      - (balancedExtraTwistedGate.polarisingRankPlus : Int)
      - (balancedExtraTwistedGate.polarisingRankMinus : Int)
      + (balancedExtraTwistedGate.b2M : Int)
      + (balancedExtraTwistedGate.invariantB3Plus : Int)
      + (balancedExtraTwistedGate.invariantB3Minus : Int))

theorem balanced_angle_correction_value :
    balancedAngleCorrection = 1 := by
  native_decide

def minimumKernelSupplyBeyondFanographyK0 : Nat :=
  GIFT.Core.b2 -
    _root_.GIFT.Foundations.MetricCatalogueSources.fanographyMaxPicardRank

def minimumKernelSupplyBeyondToricK0 : Nat :=
  GIFT.Core.b2 -
    _root_.GIFT.Foundations.MetricCatalogueSources.toricCanonicalMaxPicardRank

theorem kernel_supply_required_by_catalogue_rank_ceilings :
    minimumKernelSupplyBeyondFanographyK0 = 11 /\
    minimumKernelSupplyBeyondToricK0 = 14 /\
    _root_.GIFT.Foundations.MetricCatalogueSources.fano3HighK3RankCount = 667 := by
  native_decide

/-- A first catalogue-supported XTCS proxy:

* Fanography rows `4-10` and `5-2` supply the optimistic invariant `b3`
  contribution `22+19`.
* Fano3 rows `5864` and `4908` supply basket `k3_rank` proxies `11+10`.
* The proxy status is explicit: fano3 `k3_rank` is a basket sum, not yet a
  certified XTCS kernel rank.
* This is a Diophantine shape witness, not a valid Nordstrom instance.
-/
def catalogueHybridExtraTwistedGate : ExtraTwistedGate where
  polarisingRankPlus := 4
  polarisingRankMinus := 5
  b2M := GIFT.Core.b2
  invariantB3Plus := 22
  invariantB3Minus := 19
  angleMultiplicity := 1
  kernelRankPlus := 11
  kernelRankMinus := 10
  nonRectangular := true

/-- Minimal off-ceiling target that passes the hard rank screens.

This uses the known pleasant-involution `b3plus` values `28` and `46` observed
in the local Nordstrom table scan.  It passes the formula, parity, evenness, and
`b2 <= min(r+, r-)` screens, but asks for `r+ = r- = 21`, one rank beyond the
projective K3 Picard-rank ceiling.  This is therefore a genuine next target for
a non-standard or lifted construction, not a completed standard XTCS example.
-/
def rank21OffCeilingExtraTwistedTarget : ExtraTwistedGate where
  polarisingRankPlus := 21
  polarisingRankMinus := 21
  b2M := GIFT.Core.b2
  invariantB3Plus := 28
  invariantB3Minus := 46
  angleMultiplicity := 1
  kernelRankPlus := 0
  kernelRankMinus := 0
  nonRectangular := true

theorem rank21_off_ceiling_target_passes_hard_rank_screens :
    rank21OffCeilingExtraTwistedTarget.predictedB3 = (GIFT.Core.b3 : Int) /\
    rank21OffCeilingExtraTwistedTarget.invariantB3EvenScreen = true /\
    rank21OffCeilingExtraTwistedTarget.intersectionRankBoundScreen = true /\
    rank21OffCeilingExtraTwistedTarget.configurationParity =
      giftSemiCharacteristicParity := by
  native_decide

theorem rank21_off_ceiling_target_exceeds_projective_k3_ceiling :
    Not (rank21OffCeilingExtraTwistedTarget.polarisingRankPlus <=
      projectiveK3PicardRankCeiling) /\
    Not (rank21OffCeilingExtraTwistedTarget.polarisingRankMinus <=
      projectiveK3PicardRankCeiling) := by
  native_decide

structure CatalogueHybridWitness where
  fanographyLeftRank : Nat
  fanographyLeftNumber : Nat
  fanographyRightRank : Nat
  fanographyRightNumber : Nat
  fano3KernelProxyLeftId : Nat
  fano3KernelProxyRightId : Nat
  arithmeticFits : Bool
  catalogueSupported : Bool
  geometryUnified : Bool
  kernelProxyCertifiedAsGeometry : Bool
  deriving DecidableEq, Repr

def firstCatalogueHybridWitness : CatalogueHybridWitness where
  fanographyLeftRank := 4
  fanographyLeftNumber := 10
  fanographyRightRank := 5
  fanographyRightNumber := 2
  fano3KernelProxyLeftId :=
    _root_.GIFT.Foundations.MetricCatalogueSources.fano3_rank11_proxy_candidate_5864.id
  fano3KernelProxyRightId :=
    _root_.GIFT.Foundations.MetricCatalogueSources.fano3_rank10_proxy_candidate_4908.id
  arithmeticFits := true
  catalogueSupported := true
  geometryUnified := false
  kernelProxyCertifiedAsGeometry := false

theorem catalogue_hybrid_predicts_b2 :
    catalogueHybridExtraTwistedGate.kernelRankPlus +
      catalogueHybridExtraTwistedGate.kernelRankMinus = GIFT.Core.b2 := by
  native_decide

theorem catalogue_hybrid_predicts_b3 :
    catalogueHybridExtraTwistedGate.predictedB3 = (GIFT.Core.b3 : Int) := by
  native_decide

def catalogueHybridNordstromAudit : NordstromConstraintAudit :=
  catalogueHybridExtraTwistedGate.constraintAudit

theorem catalogue_hybrid_fails_b3plus_even_screen :
    catalogueHybridExtraTwistedGate.invariantB3EvenScreen = false /\
    catalogueHybridExtraTwistedGate.invariantB3Plus % 2 = 0 /\
    catalogueHybridExtraTwistedGate.invariantB3Minus % 2 = 1 := by
  native_decide

theorem catalogue_hybrid_fails_intersection_rank_bound :
    catalogueHybridExtraTwistedGate.intersectionRankBoundScreen = false /\
    Not (catalogueHybridExtraTwistedGate.b2M <=
      catalogueHybridExtraTwistedGate.polarisingRankPlus) /\
    Not (catalogueHybridExtraTwistedGate.b2M <=
      catalogueHybridExtraTwistedGate.polarisingRankMinus) := by
  native_decide

theorem catalogue_hybrid_is_shape_check_not_valid_nordstrom_instance :
    catalogueHybridNordstromAudit.diophantineIdentityChecked = true /\
    catalogueHybridNordstromAudit.invariantB3EvenScreenChecked = false /\
    catalogueHybridNordstromAudit.intersectionRankBoundChecked = false /\
    catalogueHybridNordstromAudit.primitiveEmbeddingCertified = false /\
    catalogueHybridNordstromAudit.angleMatchingCertified = false /\
    catalogueHybridNordstromAudit.hyperKahlerRotationCertified = false /\
    catalogueHybridNordstromAudit.spinCharacteristicCertified = false := by
  native_decide

theorem catalogue_hybrid_sources_certificate :
    firstCatalogueHybridWitness.fanographyLeftRank = 4 /\
    firstCatalogueHybridWitness.fanographyLeftNumber = 10 /\
    firstCatalogueHybridWitness.fanographyRightRank = 5 /\
    firstCatalogueHybridWitness.fanographyRightNumber = 2 /\
    firstCatalogueHybridWitness.fano3KernelProxyLeftId = 5864 /\
    firstCatalogueHybridWitness.fano3KernelProxyRightId = 4908 /\
    firstCatalogueHybridWitness.arithmeticFits = true /\
    firstCatalogueHybridWitness.catalogueSupported = true /\
    firstCatalogueHybridWitness.geometryUnified = false /\
    firstCatalogueHybridWitness.kernelProxyCertifiedAsGeometry = false := by
  native_decide

theorem catalogue_hybrid_gate_certificate :
    catalogueHybridExtraTwistedGate.b2M = GIFT.Core.b2 /\
    catalogueHybridExtraTwistedGate.predictedB3 = (GIFT.Core.b3 : Int) /\
    catalogueHybridExtraTwistedGate.kernelRankPlus +
      catalogueHybridExtraTwistedGate.kernelRankMinus = GIFT.Core.b2 /\
    catalogueHybridExtraTwistedGate.invariantB3Sum = 41 /\
    catalogueHybridExtraTwistedGate.polarisingRankSum = 9 /\
    catalogueHybridExtraTwistedGate.angleMultiplicity = 1 /\
    firstCatalogueHybridWitness.geometryUnified = false := by
  native_decide

/-- Stage certificate: XTCS supplies an arithmetic non-rectangular gate for K7. -/
theorem extra_twisted_metric_gate_certificate :
    balancedExtraTwistedGate.b2M = GIFT.Core.b2 /\
    balancedExtraTwistedGate.kernelRankPlus +
      balancedExtraTwistedGate.kernelRankMinus = GIFT.Core.b2 /\
    balancedExtraTwistedGate.predictedB3 = (GIFT.Core.b3 : Int) /\
    balancedExtraTwistedGate.invariantB3Sum = GIFT.Core.dim_F4 /\
    balancedExtraTwistedGate.polarisingRankSum = 20 /\
    balancedExtraTwistedGate.angleMultiplicity = 1 /\
    balancedExtraTwistedGate.configurationParity = giftSemiCharacteristicParity /\
    balancedExtraTwistedGate.nonRectangular = true := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact balanced_extra_twisted_predicts_b2
  · exact balanced_extra_twisted_b2_from_kernels
  · exact balanced_extra_twisted_predicts_b3
  · exact balanced_extra_twisted_invariant_b3_sum
  · exact balanced_extra_twisted_rank_sum
  · exact balanced_extra_twisted_minimal_angle
  · exact balanced_extra_twisted_parity_matches
  · exact balanced_extra_twisted_non_rectangular

end GIFT.Foundations.ExtraTwistedMetric
