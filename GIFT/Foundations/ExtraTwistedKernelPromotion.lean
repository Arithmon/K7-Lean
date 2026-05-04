-- GIFT Foundations: Extra-Twisted Kernel Promotion
-- Basket-resolution evidence for the next XTCS geometric lock.

import GIFT.Foundations.ExtraTwistedGeometricCore

namespace GIFT.Foundations.ExtraTwistedKernelPromotion

open GIFT.Foundations.ExtraTwistedGeometricCore

/-!
The fano3 catalogue field `k3_rank` is not an XTCS kernel rank.  However, for
the two current proxy rows the evidence is sharper than a bare integer:

* row `5864` has basket `1/12(1,5,7)`, hence basket contribution `12 - 1 = 11`;
* row `4908` has basket `1/11(1,4,7)`, hence basket contribution `11 - 1 = 10`.

This module records that intermediate status.  It certifies the basket/K3
resolution-rank arithmetic while explicitly refusing to mark it as a promoted
XTCS kernel until the same geometry is unified with involution-block data,
polarising lattices, and matching data.
-/

/-- A cyclic quotient basket component `1/index(1, weightA, weightB)`. -/
structure CyclicBasketComponent where
  index : Nat
  weightA : Nat
  weightB : Nat
  deriving DecidableEq, Repr

/-- The K3 basket contribution described by the fano3 README. -/
def CyclicBasketComponent.k3RankContribution (C : CyclicBasketComponent) : Nat :=
  C.index - 1

/-- The current rows have the expected terminal-looking `1/r(1,a,r-a)` shape. -/
def CyclicBasketComponent.weightsClose (C : CyclicBasketComponent) : Prop :=
  C.weightA + C.weightB = C.index

def basket_1_12_5_7 : CyclicBasketComponent where
  index := 12
  weightA := 5
  weightB := 7

def basket_1_11_4_7 : CyclicBasketComponent where
  index := 11
  weightA := 4
  weightB := 7

theorem current_basket_component_ranks :
    basket_1_12_5_7.k3RankContribution = 11 /\
    basket_1_11_4_7.k3RankContribution = 10 /\
    basket_1_12_5_7.weightsClose /\
    basket_1_11_4_7.weightsClose := by
  simp [CyclicBasketComponent.k3RankContribution,
    CyclicBasketComponent.weightsClose, basket_1_12_5_7, basket_1_11_4_7]

/-- Inventory from the local fano3 scan, after requiring a single cyclic basket. -/
def fano3Rank11SingleBasketStableElephantCount : Nat := 36
def fano3Rank10SingleBasketStableElephantCount : Nat := 99
def fano3Rank11SingleBasketFormCount : Nat := 2
def fano3Rank10SingleBasketFormCount : Nat := 5

theorem fano3_single_basket_inventory_certificate :
    fano3Rank11SingleBasketStableElephantCount = 36 /\
    fano3Rank10SingleBasketStableElephantCount = 99 /\
    fano3Rank11SingleBasketFormCount = 2 /\
    fano3Rank10SingleBasketFormCount = 5 := by
  native_decide

/-- Evidence carried by a fano3 row toward an XTCS kernel promotion. -/
structure Fano3BasketKernelEvidence where
  fano3Id : Nat
  basketText : String
  component : CyclicBasketComponent
  k3Rank : Nat
  stable : Bool
  hasElephant : Bool
  singleBasket : Bool
  componentRankMatchesK3Rank : Bool
  promotedToXTCSKernel : Bool
  unifiedWithFanographyBlock : Bool
  deriving DecidableEq, Repr

def Fano3BasketKernelEvidence.componentRank
    (E : Fano3BasketKernelEvidence) : Nat :=
  E.component.k3RankContribution

/-- Full kernel usability requires more than the fano3 basket rank. -/
def Fano3BasketKernelEvidence.usableAsXTCSKernel
    (E : Fano3BasketKernelEvidence) : Prop :=
  E.stable = true /\
  E.hasElephant = true /\
  E.singleBasket = true /\
  E.componentRankMatchesK3Rank = true /\
  E.promotedToXTCSKernel = true /\
  E.unifiedWithFanographyBlock = true

def leftFano3BasketKernelEvidence : Fano3BasketKernelEvidence where
  fano3Id := 5864
  basketText := "1/12(1,5,7)"
  component := basket_1_12_5_7
  k3Rank := 11
  stable := true
  hasElephant := true
  singleBasket := true
  componentRankMatchesK3Rank := true
  promotedToXTCSKernel := false
  unifiedWithFanographyBlock := false

def rightFano3BasketKernelEvidence : Fano3BasketKernelEvidence where
  fano3Id := 4908
  basketText := "1/11(1,4,7)"
  component := basket_1_11_4_7
  k3Rank := 10
  stable := true
  hasElephant := true
  singleBasket := true
  componentRankMatchesK3Rank := true
  promotedToXTCSKernel := false
  unifiedWithFanographyBlock := false

theorem basket_evidence_matches_promotion_targets :
    leftFano3BasketKernelEvidence.k3Rank = leftPromotionTarget.kernelRank /\
    rightFano3BasketKernelEvidence.k3Rank = rightPromotionTarget.kernelRank /\
    leftFano3BasketKernelEvidence.componentRank +
      rightFano3BasketKernelEvidence.componentRank = GIFT.Core.b2 := by
  native_decide

theorem current_basket_proxy_rank_sum_matches_gift_b2 :
    leftFano3BasketKernelEvidence.componentRank +
      rightFano3BasketKernelEvidence.componentRank = GIFT.Core.b2 := by
  native_decide

theorem left_basket_kernel_not_promoted :
    leftFano3BasketKernelEvidence.usableAsXTCSKernel -> False := by
  intro h
  simp [Fano3BasketKernelEvidence.usableAsXTCSKernel,
    leftFano3BasketKernelEvidence] at h

theorem right_basket_kernel_not_promoted :
    rightFano3BasketKernelEvidence.usableAsXTCSKernel -> False := by
  intro h
  simp [Fano3BasketKernelEvidence.usableAsXTCSKernel,
    rightFano3BasketKernelEvidence] at h

/-- Kernel lock certificate: basket ranks close `b2`, XTCS kernels are not certified. -/
theorem extra_twisted_kernel_promotion_lock_certificate :
    leftFano3BasketKernelEvidence.componentRank = 11 /\
    rightFano3BasketKernelEvidence.componentRank = 10 /\
    leftFano3BasketKernelEvidence.componentRank +
      rightFano3BasketKernelEvidence.componentRank = GIFT.Core.b2 /\
    leftFano3BasketKernelEvidence.promotedToXTCSKernel = false /\
    rightFano3BasketKernelEvidence.promotedToXTCSKernel = false /\
    leftFano3BasketKernelEvidence.unifiedWithFanographyBlock = false /\
    rightFano3BasketKernelEvidence.unifiedWithFanographyBlock = false /\
    (leftFano3BasketKernelEvidence.usableAsXTCSKernel -> False) /\
    (rightFano3BasketKernelEvidence.usableAsXTCSKernel -> False) := by
  exact And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro (by native_decide)
    (And.intro left_basket_kernel_not_promoted
      right_basket_kernel_not_promoted)))))))

end GIFT.Foundations.ExtraTwistedKernelPromotion
