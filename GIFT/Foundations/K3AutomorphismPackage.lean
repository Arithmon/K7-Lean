-- GIFT Foundations: K3 automorphism package for the JK route.
-- Mixed symplectic / non-symplectic bookkeeping for the active fixed locus.

import GIFT.Core
import GIFT.Foundations.K3NewtonKantorovich

namespace GIFT.Foundations.K3AutomorphismPackage

/-!
This module isolates the K3-side bookkeeping needed by the
Joyce-Karigiannis route.

The active target is not "three Nikulin generators".  It is a mixed-parity
`Z2^3` action on the K3 surface:

* a rank-two symplectic subgroup, whose three non-identity elements are
  Nikulin involutions with eight isolated fixed points each;
* one anti-symplectic coset of four elements, whose fixed loci are curves.

The point part supplies `24` raw isolated points and saturates the natural
symplectic `V4` orbit ceiling at `12` quotient point orbits.  The curve part is
encoded as a Nikulin-formula arithmetic target with `9` quotient curve
components and total genus `5`.  The actual K3 action and CI(2,2,2) coordinate
model remain explicit geometric locks.
-/

/-- Fixed-curve data for a non-symplectic involution on a K3 surface.

For the ordinary Nikulin case, the formula screen records
`g = (22-r-a)/2` and `k = (r-a)/2`, where `r` is the invariant-lattice rank,
`a` is the discriminant length, `g` is the genus of the non-rational curve, and
`k` is the number of rational curves.
-/
structure NonSymplecticInvolutionCurveCase where
  invariantRank : Nat
  discriminantLength : Nat
  delta : Nat
  deltaSpecified : Bool
  genus : Nat
  rationalCurves : Nat
  tableCaseCertified : Bool
  deriving DecidableEq, Repr

def NonSymplecticInvolutionCurveCase.curveComponents
    (C : NonSymplecticInvolutionCurveCase) : Nat :=
  1 + C.rationalCurves

def NonSymplecticInvolutionCurveCase.nikulinFormulaScreen
    (C : NonSymplecticInvolutionCurveCase) : Bool :=
  decide (2 * C.genus + C.invariantRank + C.discriminantLength = 22 /\
    2 * C.rationalCurves + C.discriminantLength = C.invariantRank)

/-- Garbagnati-Sarti order-two screen: for `delta=1`, compatibility with a
symplectic involution is certified when `a > 16-r`.
-/
def NonSymplecticInvolutionCurveCase.garbagnatiSartiOrderTwoScreen
    (C : NonSymplecticInvolutionCurveCase) : Bool :=
  decide (C.delta = 1 /\ C.discriminantLength > 16 - C.invariantRank)

def NonSymplecticInvolutionCurveCase.literatureCertifiedScreen
    (C : NonSymplecticInvolutionCurveCase) : Bool :=
  C.deltaSpecified &&
    C.tableCaseCertified &&
    C.nikulinFormulaScreen &&
    C.garbagnatiSartiOrderTwoScreen

/-- A curve case with `(g,k)=(2,2)` and lattice arithmetic `(r,a,delta)=(11,7,1)`. -/
def genusTwoTwoRationalCurveCase : NonSymplecticInvolutionCurveCase where
  invariantRank := 11
  discriminantLength := 7
  delta := 1
  deltaSpecified := true
  genus := 2
  rationalCurves := 2
  tableCaseCertified := true

/-- A curve case with `(g,k)=(1,1)` and lattice arithmetic `(r,a,delta)=(11,9,1)`. -/
def ellipticOneRationalCurveCase : NonSymplecticInvolutionCurveCase where
  invariantRank := 11
  discriminantLength := 9
  delta := 1
  deltaSpecified := true
  genus := 1
  rationalCurves := 1
  tableCaseCertified := true

theorem basic_non_symplectic_curve_cases_pass_formula_screen :
    genusTwoTwoRationalCurveCase.curveComponents = 3 /\
    genusTwoTwoRationalCurveCase.nikulinFormulaScreen = true /\
    genusTwoTwoRationalCurveCase.garbagnatiSartiOrderTwoScreen = true /\
    genusTwoTwoRationalCurveCase.literatureCertifiedScreen = true /\
    ellipticOneRationalCurveCase.curveComponents = 2 /\
    ellipticOneRationalCurveCase.nikulinFormulaScreen = true /\
    ellipticOneRationalCurveCase.garbagnatiSartiOrderTwoScreen = true /\
    ellipticOneRationalCurveCase.literatureCertifiedScreen = true := by
  native_decide

/-- Four anti-symplectic elements in the non-symplectic coset. -/
structure AntiSymplecticCosetCurveDecomposition where
  generator : NonSymplecticInvolutionCurveCase
  symplecticA_mul_generator : NonSymplecticInvolutionCurveCase
  symplecticB_mul_generator : NonSymplecticInvolutionCurveCase
  symplecticAB_mul_generator : NonSymplecticInvolutionCurveCase
  quotientCurveOrbitCertified : Bool
  ci222CoordinateModelCertified : Bool
  deriving DecidableEq, Repr

def AntiSymplecticCosetCurveDecomposition.totalCurveComponents
    (D : AntiSymplecticCosetCurveDecomposition) : Nat :=
  D.generator.curveComponents +
    D.symplecticA_mul_generator.curveComponents +
    D.symplecticB_mul_generator.curveComponents +
    D.symplecticAB_mul_generator.curveComponents

def AntiSymplecticCosetCurveDecomposition.totalGenusSum
    (D : AntiSymplecticCosetCurveDecomposition) : Nat :=
  D.generator.genus +
    D.symplecticA_mul_generator.genus +
    D.symplecticB_mul_generator.genus +
    D.symplecticAB_mul_generator.genus

def AntiSymplecticCosetCurveDecomposition.formulaScreens
    (D : AntiSymplecticCosetCurveDecomposition) : Bool :=
  D.generator.nikulinFormulaScreen &&
    D.symplecticA_mul_generator.nikulinFormulaScreen &&
    D.symplecticB_mul_generator.nikulinFormulaScreen &&
    D.symplecticAB_mul_generator.nikulinFormulaScreen

def AntiSymplecticCosetCurveDecomposition.literatureScreens
    (D : AntiSymplecticCosetCurveDecomposition) : Bool :=
  D.generator.literatureCertifiedScreen &&
    D.symplecticA_mul_generator.literatureCertifiedScreen &&
    D.symplecticB_mul_generator.literatureCertifiedScreen &&
    D.symplecticAB_mul_generator.literatureCertifiedScreen

/-- Minimal arithmetic curve decomposition: `(2,2) + 3*(1,1)`. -/
def mixedParityCurveDecomposition : AntiSymplecticCosetCurveDecomposition where
  generator := genusTwoTwoRationalCurveCase
  symplecticA_mul_generator := ellipticOneRationalCurveCase
  symplecticB_mul_generator := ellipticOneRationalCurveCase
  symplecticAB_mul_generator := ellipticOneRationalCurveCase
  quotientCurveOrbitCertified := false
  ci222CoordinateModelCertified := false

theorem mixed_parity_curve_decomposition_arithmetic :
    mixedParityCurveDecomposition.totalCurveComponents = 9 /\
    mixedParityCurveDecomposition.totalGenusSum = 5 /\
    mixedParityCurveDecomposition.formulaScreens = true /\
    mixedParityCurveDecomposition.literatureScreens = true /\
    mixedParityCurveDecomposition.quotientCurveOrbitCertified = false /\
    mixedParityCurveDecomposition.ci222CoordinateModelCertified = false := by
  native_decide

/-- Mixed-parity `Z2^3` K3 action target for the JK ledger. -/
structure MixedParityZ2CubedK3Package where
  groupRank : Nat
  symplecticGeneratorCount : Nat
  nonSymplecticGeneratorCount : Nat
  symplecticNonidentityElementCount : Nat
  antiSymplecticElementCount : Nat
  fixedPointsPerSymplecticElement : Nat
  rawSymplecticFixedPoints : Nat
  pointOrbitCeiling : Nat
  pointOrbitsAfterSymplecticQuotient : Nat
  curveDecomposition : AntiSymplecticCosetCurveDecomposition
  quotientOrbitGeometryCertified : Bool
  ci222CoordinateModelCertified : Bool
  deriving DecidableEq, Repr

def MixedParityZ2CubedK3Package.pointOrbitCeilingScreen
    (P : MixedParityZ2CubedK3Package) : Bool :=
  decide (P.pointOrbitsAfterSymplecticQuotient <= P.pointOrbitCeiling)

def MixedParityZ2CubedK3Package.curveComponents
    (P : MixedParityZ2CubedK3Package) : Nat :=
  P.curveDecomposition.totalCurveComponents

def MixedParityZ2CubedK3Package.curveGenusSum
    (P : MixedParityZ2CubedK3Package) : Nat :=
  P.curveDecomposition.totalGenusSum

def MixedParityZ2CubedK3Package.fixedLocusB0
    (P : MixedParityZ2CubedK3Package) : Nat :=
  P.pointOrbitsAfterSymplecticQuotient + P.curveComponents

def MixedParityZ2CubedK3Package.fixedLocusB1
    (P : MixedParityZ2CubedK3Package) : Nat :=
  3 * P.pointOrbitsAfterSymplecticQuotient +
    P.curveComponents + 2 * P.curveGenusSum

def mixedParityZ2CubedK3Target : MixedParityZ2CubedK3Package where
  groupRank := 3
  symplecticGeneratorCount := 2
  nonSymplecticGeneratorCount := 1
  symplecticNonidentityElementCount := 3
  antiSymplecticElementCount := 4
  fixedPointsPerSymplecticElement := 8
  rawSymplecticFixedPoints := 24
  pointOrbitCeiling := 12
  pointOrbitsAfterSymplecticQuotient := 12
  curveDecomposition := mixedParityCurveDecomposition
  quotientOrbitGeometryCertified := false
  ci222CoordinateModelCertified := false

theorem mixed_parity_z2_cubed_k3_target_certificate :
    mixedParityZ2CubedK3Target.groupRank = 3 /\
    mixedParityZ2CubedK3Target.symplecticGeneratorCount = 2 /\
    mixedParityZ2CubedK3Target.nonSymplecticGeneratorCount = 1 /\
    mixedParityZ2CubedK3Target.symplecticNonidentityElementCount = 3 /\
    mixedParityZ2CubedK3Target.antiSymplecticElementCount = 4 /\
    mixedParityZ2CubedK3Target.rawSymplecticFixedPoints = 24 /\
    mixedParityZ2CubedK3Target.pointOrbitsAfterSymplecticQuotient = 12 /\
    mixedParityZ2CubedK3Target.pointOrbitCeilingScreen = true /\
    mixedParityZ2CubedK3Target.curveComponents = 9 /\
    mixedParityZ2CubedK3Target.curveGenusSum = 5 /\
    mixedParityZ2CubedK3Target.fixedLocusB0 = 21 /\
    mixedParityZ2CubedK3Target.fixedLocusB1 = 55 /\
    mixedParityZ2CubedK3Target.curveDecomposition.literatureScreens = true /\
    mixedParityZ2CubedK3Target.quotientOrbitGeometryCertified = false /\
    mixedParityZ2CubedK3Target.ci222CoordinateModelCertified = false := by
  native_decide

/-!
## CI(2,2,2) coordinate-model audit

The NK certificate proves an analytic CI(2,2,2) K3 metric target exists in the
local formal stack.  It does not, by itself, provide the three symmetric quadric
matrices whose span would let us test a coordinate `Z2^3` action.  The current
state is therefore an explicit lock: the analytic K3 certificate is available,
but the coordinate symmetry model is not.
-/

structure CI222CoordinateSymmetryAudit where
  nkCertificateAvailable : Bool
  explicitQuadricMatricesProvided : Bool
  coordinateSignActionAnsatz : Bool
  quadricNetInvariantCertified : Bool
  smoothCompleteIntersectionCertified : Bool
  mixedParityActionRealized : Bool
  quotientCohomologyRealized : Bool
  deriving DecidableEq, Repr

def CI222CoordinateSymmetryAudit.ready
    (A : CI222CoordinateSymmetryAudit) : Bool :=
  A.nkCertificateAvailable &&
    A.explicitQuadricMatricesProvided &&
    A.coordinateSignActionAnsatz &&
    A.quadricNetInvariantCertified &&
    A.smoothCompleteIntersectionCertified &&
    A.mixedParityActionRealized &&
    A.quotientCohomologyRealized

def currentCI222CoordinateSymmetryAudit : CI222CoordinateSymmetryAudit where
  nkCertificateAvailable := true
  explicitQuadricMatricesProvided := false
  coordinateSignActionAnsatz := true
  quadricNetInvariantCertified := false
  smoothCompleteIntersectionCertified := false
  mixedParityActionRealized := false
  quotientCohomologyRealized := false

theorem current_ci222_coordinate_symmetry_audit_certificate :
    currentCI222CoordinateSymmetryAudit.nkCertificateAvailable = true /\
    K3NewtonKantorovich.ci222_k3_nk_certificate.n_params = 31752 /\
    currentCI222CoordinateSymmetryAudit.explicitQuadricMatricesProvided = false /\
    currentCI222CoordinateSymmetryAudit.coordinateSignActionAnsatz = true /\
    currentCI222CoordinateSymmetryAudit.quadricNetInvariantCertified = false /\
    currentCI222CoordinateSymmetryAudit.mixedParityActionRealized = false /\
    currentCI222CoordinateSymmetryAudit.ready = false := by
  native_decide

theorem mixed_parity_k3_target_blocked_by_ci222_coordinate_model :
    mixedParityZ2CubedK3Target.ci222CoordinateModelCertified = false /\
    currentCI222CoordinateSymmetryAudit.ready = false := by
  native_decide

/-!
## Diagonal sign-action screen

A tempting first coordinate model is a diagonal CI(2,2,2) net invariant under
coordinate sign changes.  This correctly gives eight fixed points for a
symplectic two-flip involution, but its anti-symplectic curve profiles do not
match the active mixed-parity curve package.

For a generic diagonal net in `P5`, anti-symplectic one-flips give one genus-5
curve, while anti-symplectic three-flips give no curve.  Enumerating rank-three
projective sign subgroups with a rank-two symplectic kernel gives the four
profiles below, none with `9` curve components and genus sum `5`.
-/

structure CI222DiagonalSignZ2CubedProfile where
  oneFlipAntiElements : Nat
  threeFlipAntiElements : Nat
  subgroupCount : Nat
  deriving DecidableEq, Repr

def CI222DiagonalSignZ2CubedProfile.genericAntiCurveComponents
    (P : CI222DiagonalSignZ2CubedProfile) : Nat :=
  P.oneFlipAntiElements

def CI222DiagonalSignZ2CubedProfile.genericAntiGenusSum
    (P : CI222DiagonalSignZ2CubedProfile) : Nat :=
  5 * P.oneFlipAntiElements

def CI222DiagonalSignZ2CubedProfile.matchesMixedParityCurveTarget
    (P : CI222DiagonalSignZ2CubedProfile) : Bool :=
  decide (P.genericAntiCurveComponents = mixedParityZ2CubedK3Target.curveComponents /\
    P.genericAntiGenusSum = mixedParityZ2CubedK3Target.curveGenusSum)

def ci222DiagonalSignZ2CubedProfiles :
    List CI222DiagonalSignZ2CubedProfile := [
  { oneFlipAntiElements := 0, threeFlipAntiElements := 4, subgroupCount := 15 },
  { oneFlipAntiElements := 1, threeFlipAntiElements := 3, subgroupCount := 60 },
  { oneFlipAntiElements := 2, threeFlipAntiElements := 2, subgroupCount := 45 },
  { oneFlipAntiElements := 3, threeFlipAntiElements := 1, subgroupCount := 20 }
]

def ci222DiagonalSignProfilesMatchTarget : Bool :=
  ci222DiagonalSignZ2CubedProfiles.any
    (fun P => P.matchesMixedParityCurveTarget)

theorem ci222_diagonal_sign_profiles_do_not_match_mixed_parity_curve_target :
    ci222DiagonalSignZ2CubedProfiles.length = 4 /\
    (ci222DiagonalSignZ2CubedProfiles.map
      (fun P => (P.oneFlipAntiElements, P.threeFlipAntiElements, P.subgroupCount)) =
      [(0, 4, 15), (1, 3, 60), (2, 2, 45), (3, 1, 20)]) /\
    ci222DiagonalSignProfilesMatchTarget = false := by
  native_decide

end GIFT.Foundations.K3AutomorphismPackage
