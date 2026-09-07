import Verification.AllImports
import Verification.AnalysisChecks
import Verification.Policy

open Lean Elab Command Verification

/-- Existing assumptions, individually named rather than counted as bundles. -/
def projectAxioms : Array Name := #[
  `GIFT.Spectral.CheegerInequality.cheeger_inequality,
  `GIFT.Spectral.LiteratureAxioms.literature_package,
  `GIFT.Spectral.TCSBounds.spectral_upper_bound,
  `GIFT.Spectral.TCSBounds.neck_dominates,
  `GIFT.Foundations.IntervalCertificates.det_g_at_half,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_0,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_1,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_2,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_3,
  `GIFT.Foundations.IntervalCertificates.det_g_at_half_bracketed,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_0_bracketed,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_1_bracketed,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_2_bracketed,
  `GIFT.Foundations.IntervalCertificates.K3_eigenvalue_3_bracketed,
  `GIFT.Foundations.IntervalCertificates.PSLQ_null_in_TCS_basis]

-- Legacy native computations are permitted here, but not in AnalysisChecks.
def nativeAxioms : Array Name := #[`Lean.ofReduceBool, `Lean.ofReduceNat, `Lean.trustCompiler]

/-- Lean 4.33 names native-evaluation axioms at the declaration that generated them. -/
def isNativeEvaluationAxiom (name : Name) : Bool :=
  nativeAxioms.contains name ||
    (name.toString.splitOn "._native.native_decide.ax").length > 1 ||
    (name.toString.splitOn "._native.bv_decide.ax").length > 1

run_cmd do
  let allowed := standardAxioms ++ projectAxioms
  let env ← getEnv
  let native := env.constants.toList.filterMap fun (name, info) =>
    match info with
    | .axiomInfo _ => if isNativeEvaluationAxiom name then some name else none
    | _ => none
  let allowed := allowed ++ native.toArray
  for decl in #[
    `GIFT.Certificate.Foundations.certified,
    `GIFT.Certificate.Predictions.certified,
    `GIFT.Certificate.Spectral.certified,
    `GIFT.Certificate.gift_master_certificate,
    `GIFT.Relations.KoideAssembly.koideQ_gift_lt_two_thirds] do
    checkAxioms decl allowed
  let mut count := 0
  let mut nativeCount := 0
  for (name, info) in env.constants.toList do
    let inLibrary := name.toString.startsWith "GIFT." || name.toString.startsWith "_private.GIFT."
    if inLibrary then
      match info with
      | .axiomInfo _ =>
        unless allowed.contains name do throwError "Unapproved library axiom: {name}"
      | _ => pure ()
    if inLibrary && info.isTheorem then
      count := count + 1
      let axioms ← collectAxioms name
      if axioms.any isNativeEvaluationAxiom then nativeCount := nativeCount + 1
      for axiomName in axioms do
        unless allowed.contains axiomName do
          throwError "{name} depends on unapproved axiom {axiomName}"
  logInfo m!"Audited {count} library theorems; {nativeCount} depend on native evaluation."
