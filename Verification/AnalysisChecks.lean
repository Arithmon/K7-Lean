import GIFT.Foundations.Analysis.Sobolev.Box
import GIFT.Foundations.Analysis.SmoothFamily
import GIFT.Foundations.Analysis.Sobolev.Basic
import GIFT.Foundations.Analysis.Elliptic.Basic
import GIFT.Foundations.Analysis.IFT.Basic
import GIFT.Algebraic.GIFTConstants
import Verification.Policy

open Verification in
run_cmd do
  for decl in #[
    `Sobolev.exists_forall_norm_le_mul_sum_sqrt_integral_norm_iteratedFDeriv_sq_of_contDiff_box,
    `ContDiff.exists_forall_norm_iteratedDeriv_slice_le_of_isCompact,
    `GIFT.Foundations.Analysis.Sobolev.sobolev_conditions_certified,
    `GIFT.Foundations.Analysis.Elliptic.elliptic_certified,
    `GIFT.Foundations.Analysis.IFT.ift_certified,
    `GIFT.Algebraic.BettiNumbers.b2_eq,
    `GIFT.Algebraic.G2.omega3_total,
    `GIFT.Algebraic.GIFTConstants.kappa_T_inv_prime] do
    checkAxioms decl standardAxioms
