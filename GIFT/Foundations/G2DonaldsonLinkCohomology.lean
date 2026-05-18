/-
  GIFT Foundations: Lean certificate for the Donaldson (2017)
  K_3-fibration topology formula.

  Headline theorem:

      b_3(M) = 1 + b_1(Sigma_2(L))

  for a Donaldson Kovalev-Lefschetz K_3-fibration `M -> S^3` with
  smooth K_3 fibre (Lambda_K3 = 3U + 2 E_8(-1)), discriminant link
  `L ⊂ S^3`, and uniform monodromy `rho = s_alpha` (reflection in a
  (-2)-class alpha in the transcendental lattice). Here `Sigma_2(L)`
  denotes the double cover of `S^3` branched over `L`.

  We do not formalise the analytic / sheaf-theoretic derivation
  (Donaldson 2017 §3.1 SES + localisation LES + double-cover
  identification of group cohomology). Instead, we formalise the
  topological / combinatorial part by:

  * defining a `LinkType` inductive describing the topological
    type of `L` to the extent that affects `b_1(Sigma_2(L))`,
    namely (i) k-component unlink, (ii) Hopf link, (iii) trefoil
    knot, (iv) disjoint unions of the above;

  * giving `b1Sigma2 : LinkType -> Nat` for these cases;

  * defining `b3Donaldson L = 1 + b1Sigma2 L` and
    `b2Donaldson = 21` for the uniform-reflection-monodromy case;

  * proving by `native_decide` the target match
    `b3Donaldson <77-unlink> = 77` and two alternative
    configurations that also achieve `(b_2, b_3) = (21, 77)`.

  The combinatorial values `b1Sigma2 (unlink k) = k - 1`,
  `b1Sigma2 hopf = 0`, `b1Sigma2 trefoil = 0` are consequences of
  Wirtinger presentation arithmetic and standard classical knot
  theory; they enter as definitions and are validated numerically.

  This module is a route-agnostic companion to
  `G2TCSLatticeCertificate.lean`: the K_3 lattice data established
  there is what feeds the monodromy `rho = s_alpha_1` used in the
  Donaldson framework formalised here.
-/

import GIFT.Core

namespace GIFT.Foundations.G2DonaldsonLinkCohomology

/-! ## Topological type of the discriminant -/

/-- Topological types of the discriminant link `L` ⊂ S^3 that may
arise in a Donaldson Kovalev-Lefschetz K3-fibration, restricted to
the cases tested in `donaldson_link_cohomology.py` of the private
repo. -/
inductive LinkType : Type
  | unlink (k : Nat) : LinkType
  | hopf : LinkType
  | trefoil : LinkType
  | disjoint (parts : List LinkType) : LinkType
  deriving Repr

/-! ## Cocycle dimension and first Betti number of the double cover

For a Wirtinger presentation with `n` generators and constraint
matrix of rank `r`, the *cocycle dimension* is `n - r`. By the
Wirtinger / double-cover derivation,
  `b_1(Sigma_2(L)) = dim H^1(pi_1, R_sign) = (n - r) - 1`,
where the `- 1` comes from the universal 1-dimensional coboundary
(the diagonal `(2w, 2w, ..., 2w)` image).

Cocycle dimension is *additive* on disjoint unions (since the free
product of Wirtinger presentations is again a Wirtinger presentation
with concatenated generators and relations), whereas `b_1` of the
double cover is not (because the coboundary is universal and is
shared among components).

Concretely:
- Unknot: 1 generator, 0 relations -> cocycleDim = 1.
- Hopf link: 2 generators, 1 commutator relation of rank 1
  -> cocycleDim = 1.
- Trefoil: 3 generators, 3 relations of total rank 2
  -> cocycleDim = 1.
- k-component unlink: k generators, 0 relations
  -> cocycleDim = k.
- Disjoint union: cocycleDim adds.

Then `b1Sigma2 L = cocycleDim L - 1` (saturating subtraction). -/
def cocycleDim : LinkType → Nat
  | .unlink k => k
  | .hopf => 1
  | .trefoil => 1
  | .disjoint parts =>
      let rec sumLoop : List LinkType → Nat
        | [] => 0
        | h :: t => cocycleDim h + sumLoop t
      sumLoop parts

/-- `b_1(Sigma_2(L)) = cocycleDim L - 1` for non-empty link. -/
def b1Sigma2 (L : LinkType) : Nat := cocycleDim L - 1

/-! ## Donaldson Betti formulas (uniform reflection monodromy on Λ_K3) -/

/-- `b_2(M) = dim H^2(K3)^rho` for Donaldson K3-fibration with
uniform reflection monodromy `rho = s_alpha` (alpha a (-2)-class).
The invariant subspace under a single reflection in the rank-22
lattice Λ_K3 has dimension 21. This is the Donaldson 2017 §4.1
result specialised to our setting. -/
def b2Donaldson : Nat := 21

/-- `b_3(M) = 1 + b_1(Sigma_2(L))` from the Donaldson 2017 §3.1
Leray short exact sequence combined with the localisation argument
(Wirtinger / branched-double-cover derivation). -/
def b3Donaldson (L : LinkType) : Nat := 1 + b1Sigma2 L

/-! ## Headline theorems

The GIFT target `(b_2, b_3) = (21, 77)` is realised by every
configuration with `b_1(Sigma_2(L)) = 76`. We verify three
representative cases by `native_decide`. -/

/-- The simplest configuration achieving the target: the 77-component
unlink. -/
theorem b3_77_unlink_realises_target :
    b2Donaldson = 21 ∧ b3Donaldson (.unlink 77) = 77 := by
  native_decide

/-- Alternative: 76 unknots plus a Hopf link (which contributes zero
to `b_1(Sigma_2)`). -/
theorem b3_76_unlink_plus_hopf_realises_target :
    b2Donaldson = 21 ∧
    b3Donaldson (.disjoint [.unlink 76, .hopf]) = 77 := by
  native_decide

/-- Alternative: 76 unknots plus a trefoil (which contributes zero
to `b_1(Sigma_2)`). -/
theorem b3_76_unlink_plus_trefoil_realises_target :
    b2Donaldson = 21 ∧
    b3Donaldson (.disjoint [.unlink 76, .trefoil]) = 77 := by
  native_decide

/-! ## Sanity-check theorems (small cases) -/

theorem b1_unlink_77 : b1Sigma2 (.unlink 77) = 76 := by native_decide
theorem b1_unlink_2 : b1Sigma2 (.unlink 2) = 1 := by native_decide
theorem b1_unlink_1 : b1Sigma2 (.unlink 1) = 0 := by native_decide
theorem b1_hopf : b1Sigma2 .hopf = 0 := by native_decide
theorem b1_trefoil : b1Sigma2 .trefoil = 0 := by native_decide
theorem b1_disjoint_unlink_hopf :
    b1Sigma2 (.disjoint [.unlink 76, .hopf]) = 76 := by native_decide

/-! ## Non-matching configurations

Three representative configurations that do NOT achieve the target. -/

theorem b3_single_unknot_not_77 : b3Donaldson (.unlink 1) ≠ 77 := by
  native_decide

theorem b3_hopf_not_77 : b3Donaldson .hopf ≠ 77 := by
  native_decide

theorem b3_trefoil_not_77 : b3Donaldson .trefoil ≠ 77 := by
  native_decide

theorem b3_unlink_100_not_77 : b3Donaldson (.unlink 100) ≠ 77 := by
  native_decide

/-! ## Discriminant-family characterisation

The discriminant links `L` that realise the GIFT target are *exactly*
those with `cocycleDim L = 77` (equivalently `b_1(Sigma_2(L)) = 76`).
This characterises the full admissible family — of which the 77-unlink
is the minimal representative — and subsumes any explicit
unlink-plus-units parametrisation. Companion: the private-repo note
`phase_i2_discriminant_family.md` (Pillar I.2). The underlying Leray /
double-branched-cover derivation remains a definition here (research-
level Mathlib formalisation, not attempted); this section certifies the
combinatorial characterisation on top of it. -/

/-- `L` realises the GIFT target `(b_2, b_3) = (21, 77)`. -/
def realisesTarget (L : LinkType) : Bool :=
  decide (b2Donaldson = 21 ∧ b3Donaldson L = 77)

/-- **Characterisation (general, all `LinkType`).** A discriminant link
realises `(21, 77)` iff its cocycle dimension is exactly 77. Proved by
`omega` (not `native_decide`): `LinkType` is infinite, so this is a
genuine universally-quantified statement, not a finite check. -/
theorem realises_iff_cocycleDim_77 (L : LinkType) :
    realisesTarget L = true ↔ cocycleDim L = 77 := by
  unfold realisesTarget
  simp only [decide_eq_true_eq]
  unfold b2Donaldson b3Donaldson b1Sigma2
  omega

/-- The minimal representative: the 77-component unlink realises it. -/
theorem realises_unlink_77 : realisesTarget (.unlink 77) = true := by
  native_decide

/-- Family witness: 75-unlink ⊔ Hopf ⊔ trefoil (each unit piece has
cocycleDim 1, total 75 + 1 + 1 = 77). -/
theorem realises_unlink75_hopf_trefoil :
    realisesTarget (.disjoint [.unlink 75, .hopf, .trefoil]) = true := by
  native_decide

/-- Family witness: 74-unlink ⊔ Hopf ⊔ Hopf ⊔ trefoil (74 + 1+1+1). -/
theorem realises_unlink74_three_units :
    realisesTarget (.disjoint [.unlink 74, .hopf, .hopf, .trefoil]) = true := by
  native_decide

/-- Off-family: the 76-unlink does NOT realise the target
(cocycleDim 76 ≠ 77). -/
theorem not_realises_unlink_76 : realisesTarget (.unlink 76) = false := by
  native_decide

/-- Off-family: 77-unlink ⊔ Hopf overshoots (cocycleDim 78 ≠ 77). -/
theorem not_realises_unlink77_hopf :
    realisesTarget (.disjoint [.unlink 77, .hopf]) = false := by
  native_decide

/-- Aggregate Bool for the discriminant-family characterisation. -/
def realisesTargetCharacterisation : Bool :=
  realisesTarget (.unlink 77) &&
  realisesTarget (.disjoint [.unlink 75, .hopf, .trefoil]) &&
  realisesTarget (.disjoint [.unlink 74, .hopf, .hopf, .trefoil]) &&
  (!realisesTarget (.unlink 76)) &&
  (!realisesTarget (.disjoint [.unlink 77, .hopf]))

theorem realises_target_characterisation_holds :
    realisesTargetCharacterisation = true := by native_decide

/-! ## Composite certificate -/

set_option linter.dupNamespace false in
structure G2DonaldsonLinkCertificate where
  b2_eq_21 : Bool
  b3_77_unlink_target : Bool
  b3_76_unlink_plus_hopf_target : Bool
  b3_76_unlink_plus_trefoil_target : Bool
  unlink_1_below_target : Bool
  hopf_alone_below_target : Bool
  trefoil_alone_below_target : Bool
  unlink_100_above_target : Bool
  deriving DecidableEq, Repr

def g2DonaldsonLinkCertificate : G2DonaldsonLinkCertificate where
  b2_eq_21 := b2Donaldson == 21
  b3_77_unlink_target := b3Donaldson (.unlink 77) == 77
  b3_76_unlink_plus_hopf_target :=
    b3Donaldson (.disjoint [.unlink 76, .hopf]) == 77
  b3_76_unlink_plus_trefoil_target :=
    b3Donaldson (.disjoint [.unlink 76, .trefoil]) == 77
  unlink_1_below_target := b3Donaldson (.unlink 1) != 77
  hopf_alone_below_target := b3Donaldson .hopf != 77
  trefoil_alone_below_target := b3Donaldson .trefoil != 77
  unlink_100_above_target := b3Donaldson (.unlink 100) != 77

theorem g2_donaldson_link_all_certified :
    g2DonaldsonLinkCertificate.b2_eq_21 = true ∧
    g2DonaldsonLinkCertificate.b3_77_unlink_target = true ∧
    g2DonaldsonLinkCertificate.b3_76_unlink_plus_hopf_target = true ∧
    g2DonaldsonLinkCertificate.b3_76_unlink_plus_trefoil_target = true ∧
    g2DonaldsonLinkCertificate.unlink_1_below_target = true ∧
    g2DonaldsonLinkCertificate.hopf_alone_below_target = true ∧
    g2DonaldsonLinkCertificate.trefoil_alone_below_target = true ∧
    g2DonaldsonLinkCertificate.unlink_100_above_target = true := by
  native_decide

/-- Human-readable status. -/
def g2DonaldsonLinkStatus : String :=
  "G_2 Donaldson link cohomology certificate: b_2 = 21 (single reflection invariants); b_3 = 1 + b_1(Sigma_2(L)); target (21, 77) realised by 77-unlink and two alternative configurations."

theorem g2_donaldson_link_status_nonempty : g2DonaldsonLinkStatus.length > 0 := by
  native_decide

end GIFT.Foundations.G2DonaldsonLinkCohomology
