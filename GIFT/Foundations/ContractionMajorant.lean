import Mathlib

-- GIFT Foundations: Contraction-Majorant Architecture (T1)
-- ========================================================
--
-- L'ARCHITECTURE d'un majorant de contraction — jamais ses nombres.
--
-- Ce module ne certifie AUCUNE mesure. Les quantités mesurées entrent comme
-- HYPOTHÈSES : la chaîne numérique dont il vient est design-grade (Monte-Carlo,
-- planchers empiriques). Ce qu'il certifie est la STRUCTURE du majorant, et
-- précisément les quatre modes d'erreur qui se sont réellement produits :
--
--   * confondre la somme quadratique de deux canaux séparés avec le gain de
--     l'opérateur JOINT — un majorant pris pour la valeur ;
--   * n'avoir aucun oracle indépendant du calcul qu'on audite ;
--   * MÉLANGER LES SENS DE BORNE (une entrée à son majorant favorable, une
--     autre à son majorant défavorable) puis conclure une réfutation ;
--   * publier une fourche dont certaines issues sont inatteignables.
--
-- Aucun n'avait été attrapé par des gates internes : seules des revues
-- adverses les ont vus. Ici, ils sont inexprimables.
--
-- Provenance : énoncés posés côté GIFT, preuves déchargées par Aristotle
-- (projet b74031e7-910e-47c4-9166-3dedb25bfeb5, 2026-08-21). Les huit énoncés
-- d'origine sont prouvés SANS MODIFICATION ; tout ajout porte un nom distinct.
-- Recompilé sur la toolchain du dépôt (v4.29.0) : toutes les preuves sont
-- complètes, et chaque théorème ne dépend que des trois axiomes standard
-- [propext, Classical.choice, Quot.sound].

/-!
# T1Majorant — l'architecture du majorant de contraction de T1

Six lemmes. Ils ne certifient AUCUN nombre : les quantités mesurées entrent
comme hypothèses. Ils certifient la STRUCTURE du majorant — et ce sont
exactement les quatre endroits où l'arc T1 s'est trompé les 2026-08-20/21.
-/

noncomputable section
open scoped RealInnerProductSpace

namespace GIFT.Foundations

namespace T1Majorant

/-! ## Bloc I — le canal joint et son encadrement -/

variable {E F G : Type*}
  [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [NormedAddCommGroup F] [InnerProductSpace ℝ F]
  [NormedAddCommGroup G] [InnerProductSpace ℝ G]

/-- Le gain de l'opérateur JOINT `[T_R  T_C]` : le sup de `‖T_R x + T_C y‖`
sur la boule unité de la somme directe euclidienne.

C'est l'objet que le contrat P0′ remplaçait par `√(‖T_R‖² + ‖T_C‖²)`. -/
def jointGain (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) : ℝ :=
  sSup {r : ℝ | ∃ x y, ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1 ∧ r = ‖T_R x + T_C y‖}

/-- L'ensemble des gains atteints sur la boule unité euclidienne du produit :
`jointGain` en est le `sSup`. -/
def jointGainSet (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) : Set ℝ :=
  {r : ℝ | ∃ x y, ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1 ∧ r = ‖T_R x + T_C y‖}

theorem jointGain_eq_sSup (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    jointGain T_R T_C = sSup (jointGainSet T_R T_C) := rfl

/-- Q2 (a) : l'ensemble est non vide — `(0, 0)` y contribue. -/
theorem jointGainSet_nonempty (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    (jointGainSet T_R T_C).Nonempty :=
  ⟨0, 0, 0, by norm_num, by simp⟩

/-- Q2 (b) : l'ensemble est majoré (par `‖T_R‖ + ‖T_C‖`), sans hypothèse
supplémentaire. Le `sSup` est donc bien défini. -/
theorem jointGainSet_bddAbove (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    BddAbove (jointGainSet T_R T_C) := by
  refine ⟨‖T_R‖ + ‖T_C‖, ?_⟩
  rintro r ⟨x, y, hxy, rfl⟩
  have hx : ‖x‖ ≤ 1 := by nlinarith [norm_nonneg x, norm_nonneg y, sq_nonneg (‖x‖ - 1)]
  have hy : ‖y‖ ≤ 1 := by nlinarith [norm_nonneg x, norm_nonneg y, sq_nonneg (‖y‖ - 1)]
  calc ‖T_R x + T_C y‖ ≤ ‖T_R x‖ + ‖T_C y‖ := norm_add_le _ _
    _ ≤ ‖T_R‖ * ‖x‖ + ‖T_C‖ * ‖y‖ := by
        gcongr <;> exact ContinuousLinearMap.le_opNorm _ _
    _ ≤ ‖T_R‖ * 1 + ‖T_C‖ * 1 := by gcongr
    _ = ‖T_R‖ + ‖T_C‖ := by ring

/-- Tout point de la boule unité euclidienne du produit est majoré par le
gain joint. -/
theorem norm_apply_le_jointGain (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) {x : E} {y : F}
    (h : ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1) : ‖T_R x + T_C y‖ ≤ jointGain T_R T_C :=
  le_csSup (jointGainSet_bddAbove T_R T_C) ⟨x, y, h, rfl⟩

theorem jointGain_nonneg (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    0 ≤ jointGain T_R T_C := by
  have := norm_apply_le_jointGain T_R T_C (x := (0 : E)) (y := (0 : F)) (by norm_num)
  simpa using this

/-- `jointGain` est le PLUS PETIT des majorants : c'est bien une norme
d'opérateur (cf. `jointGain_eq_opNorm`). -/
theorem jointGain_le_of_forall (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) {M : ℝ}
    (hM : ∀ (x : E) (y : F), ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1 → ‖T_R x + T_C y‖ ≤ M) :
    jointGain T_R T_C ≤ M := by
  refine csSup_le (jointGainSet_nonempty T_R T_C) ?_
  rintro r ⟨x, y, hxy, rfl⟩
  exact hM x y hxy

/-- **L1a — borne BASSE de l'encadrement.** Le gain joint domine chaque canal
séparé : restreindre à `y = 0` (resp. `x = 0`) est admissible. -/
theorem le_jointGain (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    max ‖T_R‖ ‖T_C‖ ≤ jointGain T_R T_C := by
  refine max_le ?_ ?_
  · refine ContinuousLinearMap.opNorm_le_of_unit_norm (jointGain_nonneg T_R T_C) ?_
    intro x hx
    have := norm_apply_le_jointGain T_R T_C (x := x) (y := (0 : F)) (by simp [hx])
    simpa using this
  · refine ContinuousLinearMap.opNorm_le_of_unit_norm (jointGain_nonneg T_R T_C) ?_
    intro y hy
    have := norm_apply_le_jointGain T_R T_C (x := (0 : E)) (y := y) (by simp [hy])
    simpa using this

/-- **L1b — borne HAUTE de l'encadrement (Cauchy–Schwarz).** C'est CELLE que
le contrat utilisait comme si c'était une égalité. -/
theorem jointGain_le (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    jointGain T_R T_C ≤ Real.sqrt (‖T_R‖ ^ 2 + ‖T_C‖ ^ 2) := by
  refine jointGain_le_of_forall T_R T_C ?_
  intro x y hxy
  have hstep : ‖T_R x + T_C y‖ ≤ ‖T_R‖ * ‖x‖ + ‖T_C‖ * ‖y‖ :=
    (norm_add_le _ _).trans (by gcongr <;> exact ContinuousLinearMap.le_opNorm _ _)
  refine (Real.le_sqrt (norm_nonneg _) (by positivity)).mpr ?_
  have h1 : ‖T_R x + T_C y‖ ^ 2 ≤ (‖T_R‖ * ‖x‖ + ‖T_C‖ * ‖y‖) ^ 2 := by
    nlinarith [norm_nonneg (T_R x + T_C y)]
  have h2 : (‖T_R‖ * ‖x‖ + ‖T_C‖ * ‖y‖) ^ 2
      ≤ (‖T_R‖ ^ 2 + ‖T_C‖ ^ 2) * (‖x‖ ^ 2 + ‖y‖ ^ 2) := by
    nlinarith [sq_nonneg (‖T_R‖ * ‖y‖ - ‖T_C‖ * ‖x‖)]
  nlinarith [sq_nonneg ‖T_R‖, sq_nonneg ‖T_C‖, sq_nonneg ‖x‖, sq_nonneg ‖y‖]

/-- L'opérateur JOINT `[T_R  T_C]` lui-même, comme application linéaire
continue sur la somme directe EUCLIDIENNE `WithLp 2 (E × F)`. -/
def jointOp (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) : WithLp 2 (E × F) →L[ℝ] G :=
  (T_R.coprod T_C).comp
    (WithLp.prodContinuousLinearEquiv 2 ℝ E F : WithLp 2 (E × F) →L[ℝ] E × F)

theorem jointOp_apply (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) (z : WithLp 2 (E × F)) :
    jointOp T_R T_C z = T_R z.fst + T_C z.snd := rfl

/-- **Réponse à Q2.** `jointGain` est EXACTEMENT la norme d'opérateur du
canal joint `[T_R  T_C]` pour la norme euclidienne du produit. Le `sSup`
de la définition est donc légitime et coïncide avec l'objet visé. -/
theorem jointGain_eq_opNorm (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) :
    jointGain T_R T_C = ‖jointOp T_R T_C‖ := by
  refine le_antisymm ?_ ?_
  · refine jointGain_le_of_forall T_R T_C ?_
    intro x y hxy
    have hsq : ‖(WithLp.toLp 2 (x, y) : WithLp 2 (E × F))‖ ^ 2 = ‖x‖ ^ 2 + ‖y‖ ^ 2 := by
      rw [WithLp.prod_norm_sq_eq_of_L2]; simp
    have hz : ‖(WithLp.toLp 2 (x, y) : WithLp 2 (E × F))‖ ≤ 1 := by
      nlinarith [norm_nonneg (WithLp.toLp 2 (x, y) : WithLp 2 (E × F))]
    have hle := (jointOp T_R T_C).le_opNorm (WithLp.toLp 2 (x, y))
    have heq : jointOp T_R T_C (WithLp.toLp 2 (x, y)) = T_R x + T_C y := rfl
    rw [heq] at hle
    calc ‖T_R x + T_C y‖
        ≤ ‖jointOp T_R T_C‖ * ‖(WithLp.toLp 2 (x, y) : WithLp 2 (E × F))‖ := hle
      _ ≤ ‖jointOp T_R T_C‖ * 1 := by gcongr
      _ = ‖jointOp T_R T_C‖ := mul_one _
  · refine ContinuousLinearMap.opNorm_le_of_unit_norm (jointGain_nonneg T_R T_C) ?_
    intro z hz
    have h2 : ‖z.fst‖ ^ 2 + ‖z.snd‖ ^ 2 ≤ 1 := by
      rw [← WithLp.prod_norm_sq_eq_of_L2, hz]; norm_num
    rw [jointOp_apply]
    exact norm_apply_le_jointGain T_R T_C h2

/-- La plus grande valeur propre de `[[a, b], [b, c]]`. -/
def lambdaMax2 (a b c : ℝ) : ℝ :=
  (a + c) / 2 + Real.sqrt (((a - c) / 2) ^ 2 + b ^ 2)

/-- Forme quadratique : `λ_max` majore bien le quotient de Rayleigh de
`[[a, b], [b, c]]` pour `b ≥ 0` (et donc pour tout `b` en valeur absolue). -/
theorem quadratic_le_lambdaMax2 {a b c u v : ℝ} (hb : 0 ≤ b) :
    a * u ^ 2 + 2 * b * (u * v) + c * v ^ 2 ≤ lambdaMax2 a b c * (u ^ 2 + v ^ 2) := by
  have hs2 : Real.sqrt (((a - c) / 2) ^ 2 + b ^ 2) ^ 2 = ((a - c) / 2) ^ 2 + b ^ 2 :=
    Real.sq_sqrt (by positivity)
  have habs : |(a - c) / 2| ≤ Real.sqrt (((a - c) / 2) ^ 2 + b ^ 2) := by
    rw [← Real.sqrt_sq_eq_abs]
    exact Real.sqrt_le_sqrt (by nlinarith [sq_nonneg b])
  have hup : (a - c) / 2 ≤ Real.sqrt (((a - c) / 2) ^ 2 + b ^ 2) :=
    (le_abs_self _).trans habs
  have hlo : -((a - c) / 2) ≤ Real.sqrt (((a - c) / 2) ^ 2 + b ^ 2) :=
    (neg_le_abs _).trans habs
  have hp0 : 0 ≤ lambdaMax2 a b c - a := by simp only [lambdaMax2]; linarith
  have hq0 : 0 ≤ lambdaMax2 a b c - c := by simp only [lambdaMax2]; linarith
  have hprod : (lambdaMax2 a b c - a) * (lambdaMax2 a b c - c) = b ^ 2 := by
    simp only [lambdaMax2]; nlinarith [hs2]
  have hsp : Real.sqrt (lambdaMax2 a b c - a) ^ 2 = lambdaMax2 a b c - a := Real.sq_sqrt hp0
  have hsq : Real.sqrt (lambdaMax2 a b c - c) ^ 2 = lambdaMax2 a b c - c := Real.sq_sqrt hq0
  have hpq : Real.sqrt (lambdaMax2 a b c - a) * Real.sqrt (lambdaMax2 a b c - c) = b := by
    rw [← Real.sqrt_mul hp0, hprod, Real.sqrt_sq hb]
  have expand :
      (Real.sqrt (lambdaMax2 a b c - a) * u - Real.sqrt (lambdaMax2 a b c - c) * v) ^ 2
        = (lambdaMax2 a b c - a) * u ^ 2 - 2 * b * (u * v)
          + (lambdaMax2 a b c - c) * v ^ 2 := by
    have h :
        (Real.sqrt (lambdaMax2 a b c - a) * u - Real.sqrt (lambdaMax2 a b c - c) * v) ^ 2
          = Real.sqrt (lambdaMax2 a b c - a) ^ 2 * u ^ 2
            - 2 * (Real.sqrt (lambdaMax2 a b c - a) * Real.sqrt (lambdaMax2 a b c - c)) * (u * v)
            + Real.sqrt (lambdaMax2 a b c - c) ^ 2 * v ^ 2 := by ring
    rw [h, hsp, hsq, hpq]
  have key := sq_nonneg
    (Real.sqrt (lambdaMax2 a b c - a) * u - Real.sqrt (lambdaMax2 a b c - c) * v)
  rw [expand] at key
  nlinarith [key]

/-- **L2 — l'ORACLE BLOC.** Si le couplage croisé est borné par `b`, le gain
joint est majoré par la racine de la plus grande valeur propre du 2×2 des
normes. Cet oracle n'utilise QUE `‖T_R‖`, `‖T_C‖` et `b` : il est indépendant
du calcul qui produit `jointGain`, donc il peut le contredire. -/
theorem jointGain_le_blockOracle (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G)
    (b : ℝ) (hb : 0 ≤ b)
    (hcross : ∀ x y, ⟪T_R x, T_C y⟫ ≤ b * (‖x‖ * ‖y‖)) :
    jointGain T_R T_C ≤ Real.sqrt (lambdaMax2 (‖T_R‖ ^ 2) b (‖T_C‖ ^ 2)) := by
  have hlam0 : 0 ≤ lambdaMax2 (‖T_R‖ ^ 2) b (‖T_C‖ ^ 2) := by
    have : 0 ≤ Real.sqrt (((‖T_R‖ ^ 2 - ‖T_C‖ ^ 2) / 2) ^ 2 + b ^ 2) := Real.sqrt_nonneg _
    simp only [lambdaMax2]
    positivity
  refine jointGain_le_of_forall T_R T_C ?_
  intro x y hxy
  refine (Real.le_sqrt (norm_nonneg _) hlam0).mpr ?_
  have hexp : ‖T_R x + T_C y‖ ^ 2 = ‖T_R x‖ ^ 2 + 2 * ⟪T_R x, T_C y⟫ + ‖T_C y‖ ^ 2 :=
    norm_add_sq_real _ _
  have h1 : ‖T_R x‖ ^ 2 ≤ ‖T_R‖ ^ 2 * ‖x‖ ^ 2 := by
    nlinarith [ContinuousLinearMap.le_opNorm T_R x, norm_nonneg (T_R x),
      norm_nonneg T_R, norm_nonneg x]
  have h2 : ‖T_C y‖ ^ 2 ≤ ‖T_C‖ ^ 2 * ‖y‖ ^ 2 := by
    nlinarith [ContinuousLinearMap.le_opNorm T_C y, norm_nonneg (T_C y),
      norm_nonneg T_C, norm_nonneg y]
  have h3 := hcross x y
  have hquad := quadratic_le_lambdaMax2 (a := ‖T_R‖ ^ 2) (b := b) (c := ‖T_C‖ ^ 2)
    (u := ‖x‖) (v := ‖y‖) hb
  nlinarith [hquad, hexp, h1, h2, h3, hlam0]

section Adjoint
variable [CompleteSpace E] [CompleteSpace G]

/-- **Réponse à Q4.** L'hypothèse `hcross` de `jointGain_le_blockOracle` dit
EXACTEMENT que la norme d'opérateur du bloc croisé `T_R^* T_C` est `≤ b`
(c'est-à-dire `‖M_RC‖₂ ≤ b` pour la matrice blanchie). En particulier la forme
à une seule inégalité n'est pas plus faible que la forme en valeur absolue :
remplacer `x` par `-x` la rend symétrique. -/
theorem cross_bound_iff_adjoint_opNorm_le (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G)
    {b : ℝ} (hb : 0 ≤ b) :
    (∀ x y, ⟪T_R x, T_C y⟫ ≤ b * (‖x‖ * ‖y‖)) ↔
      ‖(ContinuousLinearMap.adjoint T_R).comp T_C‖ ≤ b := by
  set S := (ContinuousLinearMap.adjoint T_R).comp T_C with hS
  have hinner : ∀ (x : E) (y : F), ⟪x, S y⟫ = ⟪T_R x, T_C y⟫ := by
    intro x y
    simp [hS, ContinuousLinearMap.adjoint_inner_right]
  constructor
  · intro h
    refine ContinuousLinearMap.opNorm_le_bound _ hb ?_
    intro y
    rcases eq_or_lt_of_le (norm_nonneg (S y)) with h0 | h0
    · rw [← h0]; positivity
    · have h1 : ⟪S y, S y⟫ = ‖S y‖ ^ 2 := real_inner_self_eq_norm_sq _
      have h2 := h (S y) y
      rw [← hinner (S y) y, h1] at h2
      nlinarith
  · intro h x y
    rw [← hinner x y]
    calc ⟪x, S y⟫ ≤ ‖x‖ * ‖S y‖ := real_inner_le_norm _ _
      _ ≤ ‖x‖ * (b * ‖y‖) := by
          gcongr
          exact (S.le_opNorm y).trans (by gcongr)
      _ = b * (‖x‖ * ‖y‖) := by ring

end Adjoint

/-! ## Bloc II — le sens de borne

C'est ici que l'arc T1 s'est trompé DEUX FOIS le 2026-08-21 : une fois en
prenant `μ` dans le sens favorable et `L` dans le sens défavorable, une fois
en écrivant le couple de la RÉFUTATION là où il fallait celui de la
CERTIFICATION. -/

/-- Le rayon du majorant à quadrature parfaite. -/
def rho (L mu : ℝ) : ℝ := L / Real.sqrt mu

/-- **L3a — CERTIFIER la fermeture** demande un MAJORANT de `L` et un
MINORANT de `μ`. -/
theorem certify_closure {L_true L_up mu_true mu_lo q : ℝ}
    (hL : 0 ≤ L_true) (hLup : L_true ≤ L_up)
    (hmu_lo : 0 < mu_lo) (hmu : mu_lo ≤ mu_true)
    (h : rho L_up mu_lo < q) :
    rho L_true mu_true < q := by
  refine lt_of_le_of_lt ?_ h
  have h1 : 0 < Real.sqrt mu_lo := Real.sqrt_pos.mpr hmu_lo
  have h2 : Real.sqrt mu_lo ≤ Real.sqrt mu_true := Real.sqrt_le_sqrt hmu
  have h3 : 0 < Real.sqrt mu_true := lt_of_lt_of_le h1 h2
  simp only [rho]
  rw [div_le_div_iff₀ h3 h1]
  nlinarith

/-- **L3b — RÉFUTER la fermeture** demande un MINORANT de `L` et un MAJORANT
de `μ`. C'est le couple OPPOSÉ à `certify_closure`. -/
theorem refute_closure {L_true L_lo mu_true mu_up q : ℝ}
    (hL : 0 ≤ L_lo) (hLlo : L_lo ≤ L_true)
    (hmu_true : 0 < mu_true) (hmu : mu_true ≤ mu_up)
    (h : q < rho L_lo mu_up) :
    q < rho L_true mu_true := by
  refine lt_of_lt_of_le h ?_
  have h1 : 0 < Real.sqrt mu_true := Real.sqrt_pos.mpr hmu_true
  have h2 : Real.sqrt mu_true ≤ Real.sqrt mu_up := Real.sqrt_le_sqrt hmu
  have h3 : 0 < Real.sqrt mu_up := lt_of_lt_of_le h1 h2
  simp only [rho]
  rw [div_le_div_iff₀ h3 h1]
  nlinarith

/-- **L3c — LE LEMME QUI AURAIT ATTRAPÉ L'ERREUR.** L'appariement MIXTE —
majorant de `L` ET majorant de `μ` — n'entraîne RIEN. Il existe des valeurs
où `rho L_up mu_up < q` alors que `rho L_true mu_true > q`.

C'est exactement la configuration du contrat P0′ : `μ` à sa borne supérieure
(favorable) et `L` à son majorant RSS (défavorable). -/
theorem mixed_bounds_entail_nothing :
    ∃ (L_true L_up mu_true mu_up q : ℝ),
      0 ≤ L_true ∧ L_true ≤ L_up ∧ 0 < mu_true ∧ mu_true ≤ mu_up ∧
      rho L_up mu_up < q ∧ q < rho L_true mu_true := by
  refine ⟨1, 1, 1, 4, 3 / 4, by norm_num, le_refl _, by norm_num, by norm_num, ?_, ?_⟩
  · have h4 : Real.sqrt 4 = 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    simp [rho, h4]
    norm_num
  · simp [rho, Real.sqrt_one]
    norm_num

/-- **L3c renforcé — l'appariement mixte ne contraint le ρ vrai en RIEN.**
Pour tout seuil `q > 0` et toute valeur cible `r ≥ 0`, il existe un
encadrement mixte (`L_true ≤ L_up`, `mu_true ≤ mu_up`) satisfaisant la
prémisse mixte `rho L_up mu_up < q` et dont le ρ vrai vaut exactement `r`.
Autrement dit : de la prémisse mixte on ne peut déduire AUCUNE proposition
non triviale sur `rho L_true mu_true`. -/
theorem mixed_bounds_entail_nothing_strong {q r : ℝ} (hq : 0 < q) (hr : 0 ≤ r) :
    ∃ (L_true L_up mu_true mu_up : ℝ),
      0 ≤ L_true ∧ L_true ≤ L_up ∧ 0 < mu_true ∧ mu_true ≤ mu_up ∧
      rho L_up mu_up < q ∧ rho L_true mu_true = r := by
  set M : ℝ := ((r + 1) / q) ^ 2 + 1 with hM
  have hM1 : (1 : ℝ) ≤ M := by
    simp only [hM]; nlinarith [sq_nonneg ((r + 1) / q)]
  refine ⟨r, r, 1, M, hr, le_refl _, one_pos, hM1, ?_, ?_⟩
  · have hMpos : 0 < M := lt_of_lt_of_le one_pos hM1
    have hsq : (r + 1) / q < Real.sqrt M := by
      rw [show (r + 1) / q = Real.sqrt (((r + 1) / q) ^ 2) from
        (Real.sqrt_sq (by positivity)).symm]
      exact Real.sqrt_lt_sqrt (by positivity) (by simp only [hM]; linarith)
    have hspos : 0 < Real.sqrt M := Real.sqrt_pos.mpr hMpos
    rw [rho, div_lt_iff₀ hspos]
    have : q * ((r + 1) / q) = r + 1 := by field_simp
    nlinarith [mul_lt_mul_of_pos_left hsq hq]
  · simp [rho, Real.sqrt_one]

/-! ## Bloc III — la dégénérescence à η → 0 et l'exhaustivité de la fourche -/

/-- Le majorant 3×3 à quadrature parfaite : deux canaux finis vers la queue,
tous les défauts finis annulés. -/
def Z0 (x y : ℝ) : Matrix (Fin 3) (Fin 3) ℝ :=
  !![0, 0, x; 0, 0, y; x, y, 0]

/-- **L4 — la dégénérescence.** Le rayon spectral de `Z0 x y` vaut
`√(x² + y²)` : le 3×3 à canaux SÉPARÉS ne dit rien de plus que leur somme
quadratique. C'est la raison pour laquelle mesurer le canal joint change la
classe. -/
theorem Z0_eigenvalue (x y : ℝ) :
    (Z0 x y).mulVec ![x, y, Real.sqrt (x ^ 2 + y ^ 2)]
      = (Real.sqrt (x ^ 2 + y ^ 2)) • ![x, y, Real.sqrt (x ^ 2 + y ^ 2)] := by
  have hs : Real.sqrt (x ^ 2 + y ^ 2) * Real.sqrt (x ^ 2 + y ^ 2) = x ^ 2 + y ^ 2 :=
    Real.mul_self_sqrt (by positivity)
  funext i
  fin_cases i <;>
    simp [Z0, Matrix.mulVec, dotProduct, Fin.sum_univ_three, hs] <;> ring

/-- **L4 renforcé — le spectre entier.** Le polynôme caractéristique de
`Z0 x y` est `-t³ + (x² + y²) t` : les valeurs propres réelles sont
exactement `0`, `+√(x²+y²)` et `−√(x²+y²)`. Le rayon spectral vaut donc
exactement `√(x²+y²)` — ce que `Z0_eigenvalue` seul n'établissait pas. -/
theorem Z0_det_sub (x y t : ℝ) :
    (Z0 x y - t • (1 : Matrix (Fin 3) (Fin 3) ℝ)).det = -t ^ 3 + t * (x ^ 2 + y ^ 2) := by
  simp [Matrix.det_fin_three, Z0, Matrix.sub_apply, Matrix.smul_apply]
  ring

theorem Z0_eigenvalue_iff (x y t : ℝ) :
    (Z0 x y - t • (1 : Matrix (Fin 3) (Fin 3) ℝ)).det = 0 ↔
      t = 0 ∨ t = Real.sqrt (x ^ 2 + y ^ 2) ∨ t = -Real.sqrt (x ^ 2 + y ^ 2) := by
  have hs : Real.sqrt (x ^ 2 + y ^ 2) ^ 2 = x ^ 2 + y ^ 2 := Real.sq_sqrt (by positivity)
  rw [Z0_det_sub]
  have hfac : ∀ t : ℝ, t * (t - Real.sqrt (x ^ 2 + y ^ 2)) * (t + Real.sqrt (x ^ 2 + y ^ 2))
      = -(-t ^ 3 + t * (x ^ 2 + y ^ 2)) := by
    intro t; linear_combination (-t) * hs
  constructor
  · intro h
    have h' : t * (t - Real.sqrt (x ^ 2 + y ^ 2)) * (t + Real.sqrt (x ^ 2 + y ^ 2)) = 0 := by
      rw [hfac, h]; ring
    rcases mul_eq_zero.mp h' with h1 | h1
    · rcases mul_eq_zero.mp h1 with h2 | h2
      · exact Or.inl h2
      · exact Or.inr (Or.inl (by linarith))
    · exact Or.inr (Or.inr (by linarith))
  · intro h
    have h' : t * (t - Real.sqrt (x ^ 2 + y ^ 2)) * (t + Real.sqrt (x ^ 2 + y ^ 2)) = 0 := by
      rcases h with rfl | rfl | rfl <;> ring
    rw [hfac] at h'
    linarith

/-- Les issues de la fourche P0′. -/
inductive Outcome
  | below     -- ρ < q
  | zeroMargin -- ρ = q
  | above     -- ρ > q
  deriving DecidableEq, Repr

def classify (rho q : ℝ) : Outcome :=
  if rho < q then .below else if rho = q then .zeroMargin else .above

/-- **L5 — la fourche est EXHAUSTIVE et EXCLUSIVE, et AUCUNE issue n'est
inatteignable.** Le contrat P0′ publiait quatre issues dont DEUX ne pouvaient
jamais être émises. -/
theorem classify_surjective : ∀ o : Outcome, ∃ rho q : ℝ, classify rho q = o := by
  intro o
  cases o
  · exact ⟨0, 1, by norm_num [classify]⟩
  · exact ⟨0, 0, by norm_num [classify]⟩
  · exact ⟨1, 0, by norm_num [classify]⟩

/-- **L5 renforcé — la fourche dit EXACTEMENT la trichotomie.** Chaque issue
est équivalente à sa condition ; l'exclusivité et l'exhaustivité en
découlent. -/
theorem classify_eq_below_iff (r q : ℝ) : classify r q = .below ↔ r < q := by
  rcases lt_trichotomy r q with h | h | h
  · simp [classify, h]
  · simp [classify, h]
  · simp [classify, not_lt.mpr h.le, h.ne']

theorem classify_eq_zeroMargin_iff (r q : ℝ) : classify r q = .zeroMargin ↔ r = q := by
  rcases lt_trichotomy r q with h | h | h
  · simp [classify, h, h.ne]
  · simp [classify, h]
  · simp [classify, not_lt.mpr h.le, h.ne']

theorem classify_eq_above_iff (r q : ℝ) : classify r q = .above ↔ q < r := by
  rcases lt_trichotomy r q with h | h | h
  · simp [classify, h, asymm h]
  · simp [classify, h]
  · simp [classify, not_lt.mpr h.le, h.ne', h]

/-! ## Bloc IV — un cinquième mode d'erreur (réponse à Q5)

L'encadrement `max(‖T_R‖,‖T_C‖) ≤ g ≤ √(‖T_R‖²+‖T_C‖²)` ne décide RIEN quand
le seuil tombe strictement à l'intérieur — ce qui était précisément le cas au
degré 5. Publier une classe à partir du seul encadrement est un mode d'erreur
distinct de ceux déjà typés ; seule une MESURE du gain joint (ou l'oracle
bloc) peut trancher. -/

/-- **L6 — un seuil INTÉRIEUR à l'encadrement n'entraîne rien.** Si
`lo < t < hi`, la seule connaissance de `lo ≤ g ≤ hi` est compatible avec
`g < t` comme avec `t < g` : les deux classes restent atteignables. -/
theorem bracket_with_interior_threshold_entails_nothing {lo hi t : ℝ}
    (h1 : lo < t) (h2 : t < hi) :
    (∃ g, lo ≤ g ∧ g ≤ hi ∧ g < t) ∧ (∃ g, lo ≤ g ∧ g ≤ hi ∧ t < g) := by
  refine ⟨⟨(lo + t) / 2, by linarith, by linarith, by linarith⟩,
    ⟨(t + hi) / 2, by linarith, by linarith, by linarith⟩⟩

/-- Corollaire typé : avec le seuil `q√μ` strictement dans l'encadrement, la
fourche `classify` peut rendre `below` comme `above` sans qu'aucune mesure
supplémentaire ne soit contredite. -/
theorem classify_undetermined_of_interior_threshold {lo hi t : ℝ}
    (h1 : lo < t) (h2 : t < hi) :
    (∃ g, lo ≤ g ∧ g ≤ hi ∧ classify g t = .below) ∧
      (∃ g, lo ≤ g ∧ g ≤ hi ∧ classify g t = .above) := by
  obtain ⟨⟨g₁, hg₁, hg₁', hg₁''⟩, ⟨g₂, hg₂, hg₂', hg₂''⟩⟩ :=
    bracket_with_interior_threshold_entails_nothing h1 h2
  exact ⟨⟨g₁, hg₁, hg₁', (classify_eq_below_iff _ _).mpr hg₁''⟩,
    ⟨g₂, hg₂, hg₂', (classify_eq_above_iff _ _).mpr hg₂''⟩⟩

/-! ### Q5 (suite) — un échantillonnage ne majore JAMAIS le gain joint

`jointGain` est un `sSup` : toute mesure Monte-Carlo sur un nuage fini de
directions en donne un MINORANT, jamais un majorant. Un gain joint
*échantillonné* peut donc servir à RÉFUTER (`refute_closure`) mais jamais à
CERTIFIER (`certify_closure`) : c'est la même asymétrie de sens de borne que
le Bloc II, portée cette fois sur `L` lui-même. Seuls les majorants
indépendants du calcul — `jointGain_le` (RSS) et `jointGain_le_blockOracle`
(oracle bloc) — sont utilisables du côté certification. -/

/-- Toute valeur échantillonnée est un MINORANT du gain joint. -/
theorem sampled_le_jointGain (T_R : E →L[ℝ] G) (T_C : F →L[ℝ] G) {x : E} {y : F}
    (h : ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1) : ‖T_R x + T_C y‖ ≤ jointGain T_R T_C :=
  norm_apply_le_jointGain T_R T_C h

/-- Et ce minorant peut être STRICT : il existe un canal joint et un point de
test admissible dont la valeur échantillonnée est strictement inférieure au
gain joint. Un `L_joint` échantillonné ne peut donc pas alimenter
`certify_closure`. -/
theorem sampling_can_underestimate_jointGain :
    ∃ (T_R T_C : ℝ →L[ℝ] ℝ) (x y : ℝ),
      ‖x‖ ^ 2 + ‖y‖ ^ 2 ≤ 1 ∧ ‖T_R x + T_C y‖ < jointGain T_R T_C := by
  refine ⟨ContinuousLinearMap.id ℝ ℝ, 0, 0, 0, by norm_num, ?_⟩
  have hlow : (1 : ℝ) ≤ jointGain (ContinuousLinearMap.id ℝ ℝ) (0 : ℝ →L[ℝ] ℝ) := by
    have := le_jointGain (ContinuousLinearMap.id ℝ ℝ) (0 : ℝ →L[ℝ] ℝ)
    rw [ContinuousLinearMap.norm_id] at this
    exact le_trans (le_max_left _ _) this
  simpa using lt_of_lt_of_le zero_lt_one hlow

end T1Majorant

end GIFT.Foundations
