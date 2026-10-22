import GIFT.Certificate.Foundations
import GIFT.Certificate.Predictions
import GIFT.Certificate.Spectral
import GIFT.Certificate.RelationsV36

namespace GIFT.Certificate

/-- Conjunction of the four exported statements, under their respective dependencies.
`RelationsV36.statement` is the conjunction of the 33 relations A01–A33 of the K₇ paper
v3.6, each tied to its closed form (`RelationsV36.relations_v36_certified`).
These are arithmetic identities: this theorem does not establish the physical
interpretation of the numerical relations, the choice of formulas, or their mutual
consistency. -/
theorem gift_master_certificate :
    Foundations.statement ∧
    Predictions.statement ∧
    Spectral.statement ∧
    RelationsV36.statement :=
  ⟨Foundations.certified, Predictions.certified, Spectral.certified, RelationsV36.certified⟩

end GIFT.Certificate
