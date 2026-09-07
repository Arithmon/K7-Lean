import GIFT.Certificate.Foundations
import GIFT.Certificate.Predictions
import GIFT.Certificate.Spectral

namespace GIFT.Certificate

/-- Conjunction of the three exported statements, under their respective dependencies.
This theorem does not establish the physical interpretation of the numerical relations. -/
theorem gift_master_certificate :
    Foundations.statement ∧
    Predictions.statement ∧
    Spectral.statement :=
  ⟨Foundations.certified, Predictions.certified, Spectral.certified⟩

end GIFT.Certificate
