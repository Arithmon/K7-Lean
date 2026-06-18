/-
  GIFT Foundations: Lean certificate for the Z_2^3-isotype decomposition
  of H^2(K3) on the Z_2^3-equivariant K3 surface
  X-tilde = V(Q_1, Q_2, Q_3) ⊂ P^5.

  The Z_2^3 group acts by diagonal sign flips on the six homogeneous
  coordinates:

      tau     flips z_1            char (1,0,0)   anti-symplectic
      sigma_A flips z_2, z_3       char (0,1,0)   symplectic
      sigma_B flips z_4, z_5       char (0,0,1)   symplectic

  so <sigma_A, sigma_B> is a Mukai V_4 and tau is anti-symplectic.

  A group element is encoded as (x, y, z) ∈ {0,1}^3 = tau^x sigma_A^y
  sigma_B^z, with flip-set size |S| = x + 2*y + 2*z (tau flips one
  coordinate, sigma_A and sigma_B flip two each).

  Topological Lefschetz fixed point theorem on the K3 surface
  (H^0 = H^4 = R trivial, H^1 = H^3 = 0):

      L(g) = chi(Fix g) = sum_i (-1)^i tr(g | H^i)
           = 1 + tr(g | H^2) + 1
      ==>  tr(g | H^2) = chi(Fix g) - 2.

  Fixed loci of a diagonal sign flip are linear sections of the
  CI(2,2,2) K3:

      |S| in {1,5} : genus-5 curve  (CI(2,2,2) ⊂ P^4),  chi = -8
      |S| in {2,4} : 8 points       (degree 2*2*2),      chi =  8
      |S| = 3      : empty           (3 generic conics),  chi =  0
      identity     : the K3 itself,                       chi = 24

  Genus of the CI(2,2,2) curve in P^4 (n=4, d=(2,2,2)):
      g = 1 + (1/2)(sum d_i - (n+1)) prod d_i
        = 1 + (1/2)(6 - 5) * 8 = 5      ==>  chi = 2 - 2g = -8.

  The 8 one-dimensional characters of Z_2^3 are
      chi_{abc}(tau^x sigma_A^y sigma_B^z) = (-1)^{a x + b y + c z}.
  Multiplicities:
      m_{abc} = (1/8) sum_{(x,y,z)} (-1)^{a x + b y + c z} tr((x,y,z)|H^2).

  Result (independently re-verified by Aristotle project 5e293f5d via
  #eval, and cross-checked in canonical/notes/phase_d8 + the standalone
  synthesis):

      chi_000 : 2   chi_100 : 8   chi_010 : 2   chi_001 : 2
      chi_110 : 2   chi_101 : 2   chi_011 : 0   chi_111 : 4    (sum 22)

  Self-dual (HK triple, 3-dim):  omega_I in chi_000 (Kähler),
  omega_J, omega_K in chi_100 (Re/Im Omega).  Anti-self-dual = the
  remaining 19, split = total - SD per character.

  All theorems below are `Int` arithmetic, verifiable by `native_decide`.

  NOTE (audit 5e293f5d): the rank-15 Néron–Severi lattice
  H ⊕ E_7(-1) ⊕ A_1(-1)^6 (G2IrrepLatticeCertificate Part B) is a
  SEPARATE algebraic-geometric datum; it is NOT carried by any single
  isotype block (dim H^2^{V_4} = m_000 + m_100 = 10 < 15). This module
  certifies only the Lefschetz-derived isotype arithmetic.

  NOTE (audit 1a8d87f2, 2026-06-18): sigma_A and sigma_B above are the
  AMBIENT symplectic involutions of the Mukai V_4 acting on
  X-tilde = V(Q_1, Q_2, Q_3) ⊂ P^5 by diagonal sign flips (parity 2
  ⟹ symplectic, Mukai 1988). They are DISTINCT from the abstract
  lattice isometry "sigma_A_phase_d8 = (+P, -D, -Q)" on NS constructed
  in canonical/notes/phase_d8_tau_sigmaA_explicit.md, which is a
  non-symplectic proxy (E_8(-2) root-free obstruction). The Lefschetz
  isotype arithmetic certified here uses sigma_A_ambient only, via its
  topological fixed-locus contribution. No identification between
  sigma_A_ambient and sigma_A_phase_d8 is needed or asserted by this
  module. See canonical/notes/sigma_A_sympl_vs_lattice_reconciliation_2026_06_18.md
  for the full upstream reconciliation.
-/

import GIFT.Core

namespace GIFT.Foundations.K3IsotypeLefschetzCertificate

/-! ### Group elements and flip-set sizes -/

/-- The eight elements of Z_2^3 as (x, y, z) with x = tau-power,
    y = sigma_A-power, z = sigma_B-power. -/
def elements : List (Nat × Nat × Nat) :=
  [(0,0,0), (1,0,0), (0,1,0), (0,0,1), (1,1,0), (1,0,1), (0,1,1), (1,1,1)]

/-- Flip-set size: tau flips 1 coordinate, sigma_A and sigma_B flip 2. -/
def flipSize (g : Nat × Nat × Nat) : Nat :=
  g.1 + 2 * g.2.1 + 2 * g.2.2

theorem flipSizes_correct :
    elements.map flipSize = [0, 1, 2, 2, 3, 3, 4, 5] := by native_decide

/-! ### Fixed-locus Euler characteristics -/

/-- Euler characteristic of Fix(g) on the CI(2,2,2) K3, by flip-set size:
    |S|∈{1,5} ↦ genus-5 curve (χ=-8); |S|∈{2,4} ↦ 8 points (χ=8);
    |S|=3 ↦ empty (χ=0); |S|=0 (identity) ↦ K3 itself (χ=24). -/
def chiFix (g : Nat × Nat × Nat) : Int :=
  match flipSize g with
  | 0 => 24
  | 1 => -8
  | 2 => 8
  | 3 => 0
  | 4 => 8
  | 5 => -8
  | _ => 0

/-- Genus-5 complete-intersection curve check: for CI(2,2,2) ⊂ P^4,
    g = 1 + (1/2)(Σd - (n+1))·Πd = 1 + (1/2)(6-5)·8 = 5, so χ = 2-2g = -8. -/
theorem genus5_curve_euler : (2 : Int) - 2 * 5 = -8 := by native_decide

theorem chiFix_values :
    elements.map chiFix = [24, -8, 8, 8, 0, 0, 8, -8] := by native_decide

/-! ### Trace on H^2 via topological Lefschetz -/

/-- tr(g | H^2(K3)) = χ(Fix g) − 2  (K3: H^0=H^4 trivial, H^1=H^3=0). -/
def traceH2 (g : Nat × Nat × Nat) : Int := chiFix g - 2

/-- Identity acts as the full 22-dimensional rank. -/
theorem trace_identity : traceH2 (0,0,0) = 22 := by native_decide

theorem traceH2_values :
    elements.map traceH2 = [22, -10, 6, 6, -2, -2, 6, -10] := by native_decide

/-! ### Character multiplicities -/

/-- Sign of the character chi_{abc} on the element (x,y,z):
    (-1)^{a x + b y + c z}. -/
def charSign (c g : Nat × Nat × Nat) : Int :=
  if (c.1 * g.1 + c.2.1 * g.2.1 + c.2.2 * g.2.2) % 2 = 0 then 1 else -1

/-- Eight times the multiplicity of character `c` in H^2:
    8 · m_c = Σ_g χ_c(g) · tr(g|H^2). -/
def mult8 (c : Nat × Nat × Nat) : Int :=
  (elements.map (fun g => charSign c g * traceH2 g)).foldl (· + ·) 0

/-- The isotype multiplicity (an integer: 8 ∣ mult8). -/
def mult (c : Nat × Nat × Nat) : Int := mult8 c / 8

theorem mult8_divisible :
    elements.all (fun c => decide (mult8 c % 8 = 0)) = true := by native_decide

/-- The eight isotype multiplicities of H^2(K3) = 22. -/
theorem multiplicities :
    elements.map mult = [2, 8, 2, 2, 2, 2, 0, 4] := by native_decide

/-- The multiplicities sum to dim H^2(K3) = 22. -/
theorem multiplicities_sum :
    (elements.map mult).foldl (· + ·) 0 = 22 := by native_decide

/-! ### Self-dual / anti-self-dual split -/

/-- SD content: the HK triple. omega_I (Kähler) is Z_2^3-invariant
    (chi_000); omega_J, omega_K = Re/Im Omega are in chi_100. -/
def sdContent (c : Nat × Nat × Nat) : Int :=
  if c = (0,0,0) then 1 else if c = (1,0,0) then 2 else 0

/-- Anti-self-dual multiplicity = total − SD. -/
def asdMult (c : Nat × Nat × Nat) : Int := mult c - sdContent c

theorem sd_total :
    (elements.map sdContent).foldl (· + ·) 0 = 3 := by native_decide

theorem asd_total :
    (elements.map asdMult).foldl (· + ·) 0 = 19 := by native_decide

/-- The 19 ASD forms by isotype:
    chi_000:1, chi_100:6, chi_010:2, chi_001:2,
    chi_110:2, chi_101:2, chi_011:0, chi_111:4. -/
theorem asd_isotype_profile :
    elements.map asdMult = [1, 6, 2, 2, 2, 2, 0, 4] := by native_decide

/-- The V_4 = <sigma_A, sigma_B>-invariant part of H^2 has dimension
    m_000 + m_100 = 2 + 8 = 10 (audit caveat: < 15 = rank of the
    separate Néron–Severi lattice). -/
theorem dim_H2_V4_invariant :
    mult (0,0,0) + mult (1,0,0) = 10 := by native_decide

/-! ### Aggregate certificate -/

/-- Composite Boolean certificate: every structural identity at once. -/
def k3IsotypeLefschetzCertificate : Bool :=
  decide (elements.map flipSize = [0, 1, 2, 2, 3, 3, 4, 5]) &&
  decide (elements.map chiFix = [24, -8, 8, 8, 0, 0, 8, -8]) &&
  decide (traceH2 (0,0,0) = 22) &&
  decide (elements.map traceH2 = [22, -10, 6, 6, -2, -2, 6, -10]) &&
  elements.all (fun c => decide (mult8 c % 8 = 0)) &&
  decide (elements.map mult = [2, 8, 2, 2, 2, 2, 0, 4]) &&
  decide ((elements.map mult).foldl (· + ·) 0 = 22) &&
  decide ((elements.map sdContent).foldl (· + ·) 0 = 3) &&
  decide ((elements.map asdMult).foldl (· + ·) 0 = 19) &&
  decide (elements.map asdMult = [1, 6, 2, 2, 2, 2, 0, 4]) &&
  decide (mult (0,0,0) + mult (1,0,0) = 10)

theorem k3IsotypeLefschetzCertificate_holds :
    k3IsotypeLefschetzCertificate = true := by native_decide

/-- Human-readable status. -/
def k3IsotypeLefschetzStatus : String :=
  "Z_2^3-isotype decomposition of H^2(K3)=22 via topological Lefschetz: traces [22,-10,6,6,-2,-2,6,-10], mults chi_000:2 chi_100:8 chi_010:2 chi_001:2 chi_110:2 chi_101:2 chi_011:0 chi_111:4 (sum 22); SD 3 (omega_I in chi_000, omega_J/K in chi_100), ASD 19 [1,6,2,2,2,2,0,4]; dim H^2^{V_4}=10."

theorem k3IsotypeLefschetzStatus_nonempty :
    k3IsotypeLefschetzStatus.length > 0 := by native_decide

end GIFT.Foundations.K3IsotypeLefschetzCertificate
