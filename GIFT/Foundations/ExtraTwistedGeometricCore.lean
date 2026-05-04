-- GIFT Foundations: Extra-Twisted Geometric Core
-- The geometric promotion boundary for the catalogue XTCS shape check.

import GIFT.Core
import GIFT.Foundations.ExtraTwistedMetric
import GIFT.Foundations.MetricGapClosure

namespace GIFT.Foundations.ExtraTwistedGeometricCore

/-!
The catalogue XTCS gate now hits the GIFT Betti numbers as a Diophantine shape
check.  This file records the stricter geometric boundary needed to promote that
shape check into an actual torsion-free extra-twisted connected sum.

The point is intentionally conservative: every boolean below names a geometric
fact that must be supplied by a concrete construction, not inferred from a
rank-counting proxy.  The current hybrid witness passes the formula identity,
but it is not yet promoted because it fails auxiliary Nordstrom screens and the
Fanography/fano3 rows have not been unified with certified involution-block and
matching data.
-/

open GIFT.Foundations.ExtraTwistedMetric

/-- Block-level facts needed before an XTCS block can be glued analytically. -/
structure XTCSBuildingBlockCore where
  polarisingRank : Nat
  kernelRank : Nat
  b3Invariant : Nat
  hasHolomorphicInvolution : Bool
  fixedAnticanonicalK3 : Bool
  otherFixedFiberSmooth : Bool
  pleasant : Bool
  k2RestrictionInjective : Bool
  quotientH3TorsionFree : Bool
  mkEqualsConnectedComponents : Bool
  c2DataCertified : Bool
  ampGeneric : Bool
  kernelProxyPromoted : Bool
  deriving DecidableEq, Repr

/-- A block is ready only when all local XTCS geometric obligations are known. -/
def XTCSBuildingBlockCore.ready (B : XTCSBuildingBlockCore) : Prop :=
  B.hasHolomorphicInvolution = true /\
  B.fixedAnticanonicalK3 = true /\
  B.otherFixedFiberSmooth = true /\
  B.pleasant = true /\
  B.k2RestrictionInjective = true /\
  B.quotientH3TorsionFree = true /\
  B.mkEqualsConnectedComponents = true /\
  B.c2DataCertified = true /\
  B.ampGeneric = true /\
  B.kernelProxyPromoted = true

/-- Matching-level facts needed to invoke the extra-twisted analytic theorem. -/
structure XTCSMatchingCore where
  angleMultiplicity : Nat
  nonRectangular : Bool
  hyperKahlerRotation : Bool
  torusMatching : Bool
  primitiveLatticeEmbedding : Bool
  configurationAngleCertified : Bool
  spinCharacteristicCertified : Bool
  torsionLinkingCertified : Bool
  analyticTorsionFreeLimit : Bool
  deriving DecidableEq, Repr

/-- A matching is ready only when the lattice, angle, spin, and analytic gates close. -/
def XTCSMatchingCore.ready (M : XTCSMatchingCore) : Prop :=
  M.nonRectangular = true /\
  M.hyperKahlerRotation = true /\
  M.torusMatching = true /\
  M.primitiveLatticeEmbedding = true /\
  M.configurationAngleCertified = true /\
  M.spinCharacteristicCertified = true /\
  M.torsionLinkingCertified = true /\
  M.analyticTorsionFreeLimit = true

/-- Full candidate tying the shape gate, blocks, matching, and catalogue witness. -/
structure XTCSGeometricCandidate where
  gate : ExtraTwistedGate
  left : XTCSBuildingBlockCore
  right : XTCSBuildingBlockCore
  matching : XTCSMatchingCore
  witness : CatalogueHybridWitness
  deriving DecidableEq, Repr

/-- Promotion criterion from catalogue arithmetic to a geometric torsion-free XTCS candidate. -/
def XTCSGeometricallyPromotable (C : XTCSGeometricCandidate) : Prop :=
  C.left.ready /\
  C.right.ready /\
  C.matching.ready /\
  C.gate.predictedB3 = (GIFT.Core.b3 : Int) /\
  C.gate.kernelRankPlus + C.gate.kernelRankMinus = GIFT.Core.b2 /\
  C.witness.geometryUnified = true

/-- The left side of the current Fanography/fano3 hybrid, still a proxy. -/
def currentLeftCoreProxy : XTCSBuildingBlockCore where
  polarisingRank := catalogueHybridExtraTwistedGate.polarisingRankPlus
  kernelRank := catalogueHybridExtraTwistedGate.kernelRankPlus
  b3Invariant := catalogueHybridExtraTwistedGate.invariantB3Plus
  hasHolomorphicInvolution := false
  fixedAnticanonicalK3 := false
  otherFixedFiberSmooth := false
  pleasant := false
  k2RestrictionInjective := false
  quotientH3TorsionFree := false
  mkEqualsConnectedComponents := false
  c2DataCertified := false
  ampGeneric := false
  kernelProxyPromoted := false

/-- The right side of the current Fanography/fano3 hybrid, still a proxy. -/
def currentRightCoreProxy : XTCSBuildingBlockCore where
  polarisingRank := catalogueHybridExtraTwistedGate.polarisingRankMinus
  kernelRank := catalogueHybridExtraTwistedGate.kernelRankMinus
  b3Invariant := catalogueHybridExtraTwistedGate.invariantB3Minus
  hasHolomorphicInvolution := false
  fixedAnticanonicalK3 := false
  otherFixedFiberSmooth := false
  pleasant := false
  k2RestrictionInjective := false
  quotientH3TorsionFree := false
  mkEqualsConnectedComponents := false
  c2DataCertified := false
  ampGeneric := false
  kernelProxyPromoted := false

/-- The current matching has the non-rectangular arithmetic angle, not the geometry. -/
def currentMatchingCoreProxy : XTCSMatchingCore where
  angleMultiplicity := catalogueHybridExtraTwistedGate.angleMultiplicity
  nonRectangular := catalogueHybridExtraTwistedGate.nonRectangular
  hyperKahlerRotation := false
  torusMatching := false
  primitiveLatticeEmbedding := false
  configurationAngleCertified := false
  spinCharacteristicCertified := false
  torsionLinkingCertified := false
  analyticTorsionFreeLimit := false

/-- Current best candidate: formula-closed, catalogue-supported, geometrically pending. -/
def currentHybridGeometricCandidate : XTCSGeometricCandidate where
  gate := catalogueHybridExtraTwistedGate
  left := currentLeftCoreProxy
  right := currentRightCoreProxy
  matching := currentMatchingCoreProxy
  witness := firstCatalogueHybridWitness

/-- Concrete block signature that would promote one side of the hybrid gate. -/
structure XTCSBlockPromotionTarget where
  side : String
  polarisingRank : Nat
  kernelRank : Nat
  b3Invariant : Nat
  requiresUnifiedCatalogueBlock : Bool
  requiresInvolutionBlock : Bool
  requiresKernelProxyPromotion : Bool
  requiresC2Data : Bool
  requiresAmpConeData : Bool
  deriving DecidableEq, Repr

/-- Left promotion target: Fanography `4-10` plus fano3 proxy `5864`. -/
def leftPromotionTarget : XTCSBlockPromotionTarget where
  side := "left"
  polarisingRank := catalogueHybridExtraTwistedGate.polarisingRankPlus
  kernelRank := catalogueHybridExtraTwistedGate.kernelRankPlus
  b3Invariant := catalogueHybridExtraTwistedGate.invariantB3Plus
  requiresUnifiedCatalogueBlock := true
  requiresInvolutionBlock := true
  requiresKernelProxyPromotion := true
  requiresC2Data := true
  requiresAmpConeData := true

/-- Right promotion target: Fanography `5-2` plus fano3 proxy `4908`. -/
def rightPromotionTarget : XTCSBlockPromotionTarget where
  side := "right"
  polarisingRank := catalogueHybridExtraTwistedGate.polarisingRankMinus
  kernelRank := catalogueHybridExtraTwistedGate.kernelRankMinus
  b3Invariant := catalogueHybridExtraTwistedGate.invariantB3Minus
  requiresUnifiedCatalogueBlock := true
  requiresInvolutionBlock := true
  requiresKernelProxyPromotion := true
  requiresC2Data := true
  requiresAmpConeData := true

/-- The gate rebuilt only from the two block-promotion target signatures. -/
def promotionTargetGate : ExtraTwistedGate where
  polarisingRankPlus := leftPromotionTarget.polarisingRank
  polarisingRankMinus := rightPromotionTarget.polarisingRank
  b2M := GIFT.Core.b2
  invariantB3Plus := leftPromotionTarget.b3Invariant
  invariantB3Minus := rightPromotionTarget.b3Invariant
  angleMultiplicity := currentMatchingCoreProxy.angleMultiplicity
  kernelRankPlus := leftPromotionTarget.kernelRank
  kernelRankMinus := rightPromotionTarget.kernelRank
  nonRectangular := currentMatchingCoreProxy.nonRectangular

theorem current_hybrid_has_betti_gate :
    currentHybridGeometricCandidate.gate.predictedB3 = (GIFT.Core.b3 : Int) /\
    currentHybridGeometricCandidate.gate.kernelRankPlus +
      currentHybridGeometricCandidate.gate.kernelRankMinus = GIFT.Core.b2 := by
  native_decide

theorem promotion_targets_rebuild_current_gate :
    promotionTargetGate = catalogueHybridExtraTwistedGate := by
  native_decide

theorem promotion_targets_close_gift_betti_gate :
    promotionTargetGate.predictedB3 = (GIFT.Core.b3 : Int) /\
    promotionTargetGate.kernelRankPlus +
      promotionTargetGate.kernelRankMinus = GIFT.Core.b2 /\
    promotionTargetGate.invariantB3Sum -
      promotionTargetGate.polarisingRankSum = 32 := by
  native_decide

theorem promotion_targets_required_locks :
    leftPromotionTarget.requiresUnifiedCatalogueBlock = true /\
    rightPromotionTarget.requiresUnifiedCatalogueBlock = true /\
    leftPromotionTarget.requiresKernelProxyPromotion = true /\
    rightPromotionTarget.requiresKernelProxyPromotion = true /\
    leftPromotionTarget.requiresInvolutionBlock = true /\
    rightPromotionTarget.requiresInvolutionBlock = true /\
    leftPromotionTarget.requiresC2Data = true /\
    rightPromotionTarget.requiresC2Data = true /\
    leftPromotionTarget.requiresAmpConeData = true /\
    rightPromotionTarget.requiresAmpConeData = true := by
  native_decide

theorem current_hybrid_has_catalogue_support :
    currentHybridGeometricCandidate.witness.arithmeticFits = true /\
    currentHybridGeometricCandidate.witness.catalogueSupported = true /\
    currentHybridGeometricCandidate.witness.geometryUnified = false /\
    currentHybridGeometricCandidate.witness.kernelProxyCertifiedAsGeometry = false := by
  native_decide

theorem current_hybrid_core_proxy_flags :
    currentHybridGeometricCandidate.left.kernelProxyPromoted = false /\
    currentHybridGeometricCandidate.right.kernelProxyPromoted = false /\
    currentHybridGeometricCandidate.left.c2DataCertified = false /\
    currentHybridGeometricCandidate.right.c2DataCertified = false /\
    currentHybridGeometricCandidate.left.ampGeneric = false /\
    currentHybridGeometricCandidate.right.ampGeneric = false /\
    currentHybridGeometricCandidate.matching.hyperKahlerRotation = false /\
    currentHybridGeometricCandidate.matching.torusMatching = false /\
    currentHybridGeometricCandidate.matching.primitiveLatticeEmbedding = false /\
    currentHybridGeometricCandidate.matching.analyticTorsionFreeLimit = false := by
  native_decide

theorem current_hybrid_not_geometrically_promotable :
    XTCSGeometricallyPromotable currentHybridGeometricCandidate -> False := by
  intro h
  simp [XTCSGeometricallyPromotable, XTCSBuildingBlockCore.ready,
    XTCSMatchingCore.ready, currentHybridGeometricCandidate, currentLeftCoreProxy,
    currentRightCoreProxy, currentMatchingCoreProxy, firstCatalogueHybridWitness] at h

/-- Core certificate: formula identity closed, geometric promotion deliberately not claimed. -/
theorem extra_twisted_geometric_core_certificate :
    currentHybridGeometricCandidate.gate.predictedB3 = (GIFT.Core.b3 : Int) /\
    currentHybridGeometricCandidate.gate.kernelRankPlus +
      currentHybridGeometricCandidate.gate.kernelRankMinus = GIFT.Core.b2 /\
    currentHybridGeometricCandidate.witness.catalogueSupported = true /\
    currentHybridGeometricCandidate.witness.geometryUnified = false /\
    currentHybridGeometricCandidate.left.kernelProxyPromoted = false /\
    currentHybridGeometricCandidate.right.kernelProxyPromoted = false /\
    currentHybridGeometricCandidate.matching.hyperKahlerRotation = false /\
    currentHybridGeometricCandidate.matching.analyticTorsionFreeLimit = false /\
    (XTCSGeometricallyPromotable currentHybridGeometricCandidate -> False) := by
  exact And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
      current_hybrid_not_geometrically_promotable)))))))

end GIFT.Foundations.ExtraTwistedGeometricCore
