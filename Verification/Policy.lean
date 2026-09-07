import Lean.Util.CollectAxioms
import Lean.Elab.Command

open Lean Elab Command

namespace Verification

def standardAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Require an audited declaration to use only the explicitly permitted axioms. -/
def checkAxioms (decl : Name) (allowed : Array Name) : CommandElabM Unit := do
  unless (← getEnv).contains decl do
    throwError "Missing audited declaration: {decl}"
  let axioms ← collectAxioms decl
  for axiomName in axioms do
    unless allowed.contains axiomName do
      throwError "{decl} depends on unapproved axiom {axiomName}"
  logInfo m!"{decl}: {axioms}"

end Verification
