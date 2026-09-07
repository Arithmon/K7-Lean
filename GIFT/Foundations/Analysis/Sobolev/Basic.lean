/-!
Numerical Sobolev index conditions. These statements concern natural numbers;
they do not construct Sobolev spaces or prove a continuous embedding.
-/

import GIFT.Core

namespace GIFT.Foundations.Analysis.Sobolev

/-- Dimensional condition for Sobolev embedding H^k into C^0.

For a manifold of dimension n, H^k embeds into C^0 when 2k > n.
This is a computational condition we can verify with decide. -/
structure EmbeddingCondition (n k : ℕ) : Prop where
  condition : 2 * k > n

/-- Numerical condition `2 * 4 > 7`. -/
theorem sobolev_index_condition_dim7_order4 : EmbeddingCondition 7 4 :=
  ⟨by decide⟩

/-- Numerical condition `2 * 5 > 7 + 2`. -/
theorem sobolev_index_condition_dim7_order5_deriv1 : EmbeddingCondition 9 5 :=
  ⟨by decide⟩  -- 2 * 5 = 10 > 9 (n + 2j = 7 + 2 = 9)

/-- Numerical condition `2 * 6 > 7 + 4`. -/
theorem sobolev_index_condition_dim7_order6_deriv2 : EmbeddingCondition 11 6 :=
  ⟨by decide⟩  -- 2 * 6 = 12 > 11

/-- Three numerical index conditions in dimension seven. -/
theorem sobolev_index_conditions_dim7 :
    EmbeddingCondition 7 4 ∧
    EmbeddingCondition 9 5 ∧
    EmbeddingCondition 11 6 :=
  ⟨sobolev_index_condition_dim7_order4, sobolev_index_condition_dim7_order5_deriv1, sobolev_index_condition_dim7_order6_deriv2⟩

/-- Manifold dimension for K7 -/
def K7_dim : ℕ := 7

/-- Critical Sobolev index for C^0 embedding on K7 -/
def K7_critical_index : ℕ := 4

/-- The declared dimension and order satisfy the numerical index condition. -/
theorem K7_sobolev_index_condition : EmbeddingCondition K7_dim K7_critical_index :=
  ⟨by decide⟩

/-- Elliptic regularity gain (derivatives gained from Δu = f) -/
def elliptic_gain : ℕ := 2

/-- Bootstrap iterations: H^0 → H^2 → H^4 -/
def bootstrap_steps : ℕ := 2

/-- Bootstrap reaches critical index -/
theorem bootstrap_reaches_critical :
    bootstrap_steps * elliptic_gain = K7_critical_index := by
  decide

/-- All Sobolev dimensional conditions certified -/
theorem sobolev_conditions_certified :
    (2 * 4 > 7) ∧
    (2 * 5 > 9) ∧
    (2 * 2 = 4) ∧
    (K7_critical_index = 4) := by
  repeat (first | constructor | decide | rfl)


/-- Compatibility names for the numerical conditions; these do not assert embeddings. -/
abbrev embedding_H4_C0_dim7 := sobolev_index_condition_dim7_order4
abbrev embedding_H5_C1_dim7 := sobolev_index_condition_dim7_order5_deriv1
abbrev embedding_H6_C2_dim7 := sobolev_index_condition_dim7_order6_deriv2
abbrev embedding_chain_dim7 := sobolev_index_conditions_dim7
abbrev K7_embedding_condition := K7_sobolev_index_condition

end GIFT.Foundations.Analysis.Sobolev
