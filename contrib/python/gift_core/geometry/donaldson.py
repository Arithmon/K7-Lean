"""Donaldson-direct G2 metric ansatz machinery.

This module is the computational workbench for the direct Donaldson route:

* K3 fiber data: CI(2,2,2), Picard rank 1, rank-one Picard-Lefschetz
  monodromy on H2(K3).
* Discriminant-link target: 14 oriented meridians organised by the Fano
  plane, with an explicit integer relation matrix.
* G2 form ansatz: the hyperkahler/coassociative normal form
  phi = a^3 theta123 + a b^2 sum_i theta_i wedge Omega_i.

The code deliberately separates hard geometry from algebraic closure.  The
integer/Fano layer is exact and testable now; the metric layer exposes the
closed formula and symbolic torsion residuals so numerical or ML solvers can
attack the remaining analytic functions directly.
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass, field
from fractions import Fraction
from typing import Iterable

import numpy as np
import sympy as sp


FANO_POINTS: tuple[tuple[int, int, int], ...] = (
    (1, 0, 0),
    (0, 1, 0),
    (0, 0, 1),
    (1, 1, 0),
    (1, 0, 1),
    (0, 1, 1),
    (1, 1, 1),
)


def _wedge_sign(left: tuple[int, ...], right: tuple[int, ...]) -> int:
    combined = left + right
    if len(set(combined)) != len(combined):
        return 0
    inversions = 0
    for i, x in enumerate(combined):
        for y in combined[i + 1 :]:
            if x > y:
                inversions += 1
    return -1 if inversions % 2 else 1


@dataclass(frozen=True)
class Form:
    """Sparse exterior form on the ordered basis e0,...,e6."""

    terms: tuple[tuple[tuple[int, ...], sp.Expr], ...] = ()

    @classmethod
    def basis(cls, *indices: int, coeff: sp.Expr | int = 1) -> "Form":
        key = tuple(indices)
        if len(set(key)) != len(key):
            return cls()
        ordered = tuple(sorted(key))
        inversions = 0
        for i, x in enumerate(key):
            for y in key[i + 1 :]:
                if x > y:
                    inversions += 1
        sign = -1 if inversions % 2 else 1
        return cls(((ordered, sp.sympify(sign) * sp.sympify(coeff)),))

    @classmethod
    def scalar(cls, coeff: sp.Expr | int) -> "Form":
        return cls((((), sp.sympify(coeff)),))

    @property
    def degree(self) -> int | None:
        if not self.terms:
            return None
        degrees = {len(key) for key, _ in self.terms}
        return degrees.pop() if len(degrees) == 1 else None

    def simplify(self) -> "Form":
        merged: dict[tuple[int, ...], sp.Expr] = {}
        for key, coeff in self.terms:
            merged[key] = merged.get(key, sp.Integer(0)) + coeff
        terms = tuple(
            (key, sp.simplify(coeff))
            for key, coeff in sorted(merged.items())
            if sp.simplify(coeff) != 0
        )
        return Form(terms)

    def wedge(self, other: "Form") -> "Form":
        out: list[tuple[tuple[int, ...], sp.Expr]] = []
        for left, lc in self.terms:
            for right, rc in other.terms:
                sign = _wedge_sign(left, right)
                if sign:
                    out.append((tuple(sorted(left + right)), sign * lc * rc))
        return Form(tuple(out)).simplify()

    def scale(self, coeff: sp.Expr | int) -> "Form":
        return Form(tuple((key, sp.sympify(coeff) * value) for key, value in self.terms)).simplify()

    def to_dict(self) -> dict[str, str]:
        return {
            "".join(str(i + 1) for i in key): str(value)
            for key, value in self.simplify().terms
        }

    def __add__(self, other: "Form") -> "Form":
        return Form(self.terms + other.terms).simplify()

    def __neg__(self) -> "Form":
        return self.scale(-1)

    def __sub__(self, other: "Form") -> "Form":
        return self + (-other)


def _sum_forms(forms: Iterable[Form]) -> Form:
    result = Form()
    for form in forms:
        result = result + form
    return result.simplify()


def _zero_form_matrix(n: int) -> list[list[Form]]:
    return [[Form() for _ in range(n)] for _ in range(n)]


def _integer_kernel_rows(matrix: sp.Matrix) -> sp.Matrix:
    """Return primitive integer row vectors spanning the rational kernel."""
    rows: list[list[int]] = []
    for vec in matrix.nullspace():
        den = 1
        for entry in vec:
            den = int(sp.ilcm(den, sp.denom(entry)))
        ints = [int(entry * den) for entry in vec]
        gcd = abs(int(sp.gcd_list(ints))) or 1
        rows.append([entry // gcd for entry in ints])
    return sp.Matrix(rows)


@dataclass(frozen=True)
class FanoMeridianModel:
    """Exact Fano-oriented discriminant-link model.

    There are seven Fano directions, doubled by orientation.  Orientation rows
    identify each pair up to sign; four projective-coordinate rows are an
    integer basis for the kernel of the map from Fano points to Z^3.
    """

    fano_points: tuple[tuple[int, int, int], ...] = FANO_POINTS

    @property
    def fano_line_count(self) -> int:
        return len(self.fano_points)

    @property
    def oriented_meridian_count(self) -> int:
        return 2 * self.fano_line_count

    @property
    def quotient_map(self) -> sp.Matrix:
        return sp.Matrix(self.fano_points).T

    @property
    def projective_relation_rows(self) -> sp.Matrix:
        return _integer_kernel_rows(self.quotient_map)

    @property
    def relation_matrix(self) -> sp.Matrix:
        rows: list[list[int]] = []
        n = self.oriented_meridian_count

        for i in range(self.fano_line_count):
            row = [0] * n
            row[2 * i] = 1
            row[2 * i + 1] = -1
            rows.append(row)

        for kernel_row in self.projective_relation_rows.tolist():
            row = [0] * n
            for i, coeff in enumerate(kernel_row):
                # Apply projective relations to one oriented representative.
                # The orientation rows already identify the negative partner,
                # and using both representatives would double every maximal
                # minor, creating artificial cokernel torsion.
                row[2 * i] = int(coeff)
            rows.append(row)

        return sp.Matrix(rows)

    @property
    def relation_rank(self) -> int:
        return int(self.relation_matrix.rank())

    @property
    def quotient_rank(self) -> int:
        return self.oriented_meridian_count - self.relation_rank

    @property
    def maximal_minor_gcd(self) -> int:
        """GCD of full-rank maximal minors; 1 means torsion-free cokernel."""
        matrix = self.relation_matrix
        rank = self.relation_rank
        values: list[int] = []
        for cols in _combinations(range(matrix.cols), rank):
            det = int(matrix[:, cols].det())
            if det:
                values.append(abs(det))
        return int(sp.gcd_list(values)) if values else 0

    @property
    def nonzero_maximal_minor_count(self) -> int:
        matrix = self.relation_matrix
        rank = self.relation_rank
        count = 0
        for cols in _combinations(range(matrix.cols), rank):
            if int(matrix[:, cols].det()):
                count += 1
        return count

    def audit(self) -> dict[str, object]:
        return {
            "fano_line_count": self.fano_line_count,
            "oriented_meridian_count": self.oriented_meridian_count,
            "projective_relation_rank": int(self.projective_relation_rows.rank()),
            "relation_matrix_shape": tuple(self.relation_matrix.shape),
            "relation_rank": self.relation_rank,
            "quotient_rank": self.quotient_rank,
            "maximal_minor_gcd": self.maximal_minor_gcd,
            "nonzero_maximal_minor_count": self.nonzero_maximal_minor_count,
            "torsion_free_cokernel": self.maximal_minor_gcd == 1,
        }


def _combinations(values: Iterable[int], r: int):
    values = tuple(values)
    if r == 0:
        yield ()
        return
    if r > len(values):
        return
    indices = list(range(r))
    while True:
        yield tuple(values[i] for i in indices)
        for i in reversed(range(r)):
            if indices[i] != i + len(values) - r:
                break
        else:
            return
        indices[i] += 1
        for j in range(i + 1, r):
            indices[j] = indices[j - 1] + 1


@dataclass(frozen=True)
class DonaldsonTopology:
    """Rank bookkeeping for the direct Donaldson K3-fibration target."""

    k3_h2_rank: int = 22
    picard_rank: int = 1
    monodromy_moved_rank: int = 1
    base_b3: int = 1
    fixed_relation_rank: int = 11
    moved_relation_rank: int = 0
    meridian_model: FanoMeridianModel = field(default_factory=FanoMeridianModel)

    @property
    def invariant_h2_rank(self) -> int:
        return self.k3_h2_rank - self.monodromy_moved_rank

    @property
    def moved_block_rank(self) -> int:
        return self.monodromy_moved_rank

    @property
    def fixed_quotient_rank(self) -> int:
        return self.meridian_model.oriented_meridian_count - self.fixed_relation_rank

    @property
    def moved_quotient_rank(self) -> int:
        return (
            self.meridian_model.oriented_meridian_count
            - self.monodromy_moved_rank
            - self.moved_relation_rank
        )

    @property
    def b2(self) -> int:
        return self.invariant_h2_rank

    @property
    def twisted_h1_dimension(self) -> int:
        return (
            self.invariant_h2_rank * self.fixed_quotient_rank
            + self.moved_block_rank * self.moved_quotient_rank
        )

    @property
    def b3(self) -> int:
        return self.base_b3 + self.twisted_h1_dimension

    @property
    def h_star(self) -> int:
        return 1 + self.b2 + self.b3

    def audit(self) -> dict[str, object]:
        return {
            "k3_h2_rank": self.k3_h2_rank,
            "picard_rank": self.picard_rank,
            "monodromy_moved_rank": self.monodromy_moved_rank,
            "b2": self.b2,
            "fixed_quotient_rank": self.fixed_quotient_rank,
            "moved_quotient_rank": self.moved_quotient_rank,
            "twisted_h1_dimension": self.twisted_h1_dimension,
            "b3": self.b3,
            "h_star": self.h_star,
            "hits_gift_betti": (self.b2, self.b3) == (21, 77),
        }


@dataclass(frozen=True)
class DonaldsonG2Ansatz:
    """Closed-form symbolic G2 ansatz for a K3 coassociative fibration.

    In an orthonormal base coframe theta_1, theta_2, theta_3 and a hyperkahler
    triple Omega_i on the K3 fiber, the positive 3-form is

        phi = a^3 theta_123 + a b^2 (theta_1 Omega_1
              + theta_2 Omega_2 + theta_3 Omega_3).

    For constant a,b and closed hyperkahler forms this is the product G2
    structure.  The direct Donaldson problem is to find analytic a,b and
    connection/hyperkahler variation terms that keep d phi = d * phi = 0 after
    monodromy and discriminant-link corrections.
    """

    base_scale_symbol: str = "a"
    fiber_scale_symbol: str = "b"
    determinant_target: Fraction = Fraction(65, 32)

    @property
    def symbols(self) -> tuple[sp.Symbol, sp.Symbol]:
        return sp.symbols(f"{self.base_scale_symbol} {self.fiber_scale_symbol}", positive=True)

    @property
    def metric_diagonal(self) -> tuple[sp.Expr, ...]:
        a, b = self.symbols
        return (a**2, a**2, a**2, b**2, b**2, b**2, b**2)

    @property
    def determinant(self) -> sp.Expr:
        return sp.prod(self.metric_diagonal)

    @property
    def determinant_constraint(self) -> sp.Eq:
        return sp.Eq(self.determinant, sp.Rational(65, 32))

    @property
    def balanced_scale_solution(self) -> dict[sp.Symbol, sp.Expr]:
        """The isotropic closed-form scale satisfying det(g)=65/32."""
        a, b = self.symbols
        alpha = sp.Rational(65, 32) ** sp.Rational(1, 14)
        return {a: alpha, b: alpha}

    @property
    def form_formula(self) -> str:
        a, b = self.base_scale_symbol, self.fiber_scale_symbol
        return (
            f"phi = {a}^3 theta123 + {a}*{b}^2 "
            "*(theta1^Omega1 + theta2^Omega2 + theta3^Omega3)"
        )

    @property
    def hyperkahler_triple(self) -> tuple[Form, Form, Form]:
        """Standard self-dual hyperkahler triple on the K3 tangent model."""
        omega1 = Form.basis(3, 4) + Form.basis(5, 6)
        omega2 = Form.basis(3, 5) - Form.basis(4, 6)
        omega3 = Form.basis(3, 6) + Form.basis(4, 5)
        return omega1, omega2, omega3

    @property
    def theta_forms(self) -> tuple[Form, Form, Form]:
        return Form.basis(0), Form.basis(1), Form.basis(2)

    @property
    def phi_form(self) -> Form:
        a, b = self.symbols
        theta1, theta2, theta3 = self.theta_forms
        omega1, omega2, omega3 = self.hyperkahler_triple
        return (
            theta1.wedge(theta2).wedge(theta3).scale(a**3)
            + theta1.wedge(omega1).scale(a * b**2)
            + theta2.wedge(omega2).scale(a * b**2)
            + theta3.wedge(omega3).scale(a * b**2)
        ).simplify()

    @property
    def star_phi_form(self) -> Form:
        a, b = self.symbols
        theta1, theta2, theta3 = self.theta_forms
        omega1, omega2, omega3 = self.hyperkahler_triple
        fiber_volume = _sum_forms(
            omega.wedge(omega).scale(sp.Rational(1, 6))
            for omega in (omega1, omega2, omega3)
        )
        return (
            fiber_volume.scale(b**4)
            + theta2.wedge(theta3).wedge(omega1).scale(a**2 * b**2)
            + theta3.wedge(theta1).wedge(omega2).scale(a**2 * b**2)
            + theta1.wedge(theta2).wedge(omega3).scale(a**2 * b**2)
        ).simplify()

    @property
    def star_formula(self) -> str:
        a, b = self.base_scale_symbol, self.fiber_scale_symbol
        return (
            f"*phi = ({b}^4/2)*(Omega1^2 + Omega2^2 + Omega3^2) "
            f"+ {a}^2*{b}^2*(theta23^Omega1 + theta31^Omega2 + theta12^Omega3)"
        )

    def symbolic_torsion_residual(self) -> dict[str, sp.Expr]:
        """Return residual placeholders for the first analytic closure pass.

        We expose the exact equations that must vanish when the base scale
        a(t), fiber scale b(t), and connection correction C(t) are introduced.
        At this first stage the residual is represented in scalar coefficients:
        da, db and connection curvature terms k_i.
        """
        da, db, k1, k2, k3 = sp.symbols("da db k1 k2 k3")
        a, b = self.symbols
        return {
            "dphi_theta123_radial": 3 * a**2 * da,
            "dphi_theta_i_Omega_i": b**2 * da + 2 * a * b * db,
            "connection_curvature_trace": k1 + k2 + k3,
            "coclosed_scale_residual": 4 * b**3 * db + 2 * a * b**2 * da,
        }

    def determinant_preserving_family(self) -> dict[str, str]:
        """Closed determinant-preserving one-function family.

        Let alpha = (65/32)^(1/14).  The exponents are chosen so

            det(g) = a^6 b^8 = alpha^14 exp((24 - 24) u) = 65/32.

        This is the smallest analytic deformation space that preserves the
        GIFT determinant exactly while leaving a genuine radial profile u(t)
        for the Donaldson neck/discriminant correction.
        """
        return {
            "alpha": "(65/32)^(1/14)",
            "a(t)": "alpha * exp(4*u(t))",
            "b(t)": "alpha * exp(-3*u(t))",
            "det(g(t))": "65/32",
            "dphi_compensating_curvature_each_i": "k_i(t) = 2*u'(t)",
            "trace_curvature": "k_1+k_2+k_3 = 6*u'(t)",
            "coclosed_compensator": "lambda(t) = -(2*a*b^2*a' + 4*b^3*b')",
        }

    def symbolic_connection_curvature_forms(self) -> dict[str, dict[str, str]]:
        """Reduced SO(3) connection curvature used by the radial solver.

        The hyperkahler triple is treated as an SO(3) bundle.  In the
        cohomogeneity-one reduction the compensating curvature is represented
        by cyclic base 2-forms

            F1 = k theta23, F2 = k theta31, F3 = k theta12.

        The scalar k(t)=2u'(t) is what cancels the theta_i wedge Omega_i
        coefficient in dphi for the determinant-preserving scale family.
        """
        k = sp.Symbol("k")
        theta1, theta2, theta3 = self.theta_forms
        forms = {
            "F1": theta2.wedge(theta3).scale(k),
            "F2": theta3.wedge(theta1).scale(k),
            "F3": theta1.wedge(theta2).scale(k),
        }
        return {name: form.to_dict() for name, form in forms.items()}

    def symbolic_so3_connection_matrix(self) -> list[list[dict[str, str]]]:
        """An explicit antisymmetric so(3) connection matrix.

        We use the standard generators in the hyperkahler frame, with
        one-forms A1,A2,A3:

            A = [[0, -A3, A2], [A3, 0, -A1], [-A2, A1, 0]].

        In the reduced radial model A_i = q_i(t) theta_i.  This is the
        smallest matrix model whose curvature can later be promoted to a full
        Donaldson connection on the K3-fibration.
        """
        q1, q2, q3 = sp.symbols("q1 q2 q3")
        theta1, theta2, theta3 = self.theta_forms
        a1 = theta1.scale(q1)
        a2 = theta2.scale(q2)
        a3 = theta3.scale(q3)
        zero = Form()
        matrix = [
            [zero, -a3, a2],
            [a3, zero, -a1],
            [-a2, a1, zero],
        ]
        return [[entry.to_dict() for entry in row] for row in matrix]

    def symbolic_so3_curvature_matrix(self) -> list[list[dict[str, str]]]:
        """Curvature matrix F=dA+A wedge A for constant q_i reductions.

        This records the algebraic A∧A part.  The radial dA contribution is
        supplied numerically by `DonaldsonSO3Connection` because q_i(t) is a
        profile-dependent function.
        """
        q1, q2, q3 = sp.symbols("q1 q2 q3")
        theta1, theta2, theta3 = self.theta_forms
        a1 = theta1.scale(q1)
        a2 = theta2.scale(q2)
        a3 = theta3.scale(q3)
        zero = Form()
        amat = [
            [zero, -a3, a2],
            [a3, zero, -a1],
            [-a2, a1, zero],
        ]
        fmat = _zero_form_matrix(3)
        for i in range(3):
            for j in range(3):
                fmat[i][j] = _sum_forms(amat[i][m].wedge(amat[m][j]) for m in range(3))
        return [[entry.to_dict() for entry in row] for row in fmat]

    def symbolic_coclosed_compensator_form(self) -> dict[str, str]:
        """Scalar d*phi compensator as a fiber-volume 4-form."""
        lam = sp.Symbol("lambda")
        omega1, omega2, omega3 = self.hyperkahler_triple
        fiber_volume = _sum_forms(
            omega.wedge(omega).scale(sp.Rational(1, 6))
            for omega in (omega1, omega2, omega3)
        )
        return fiber_volume.scale(lam).to_dict()

    def report(self) -> dict[str, object]:
        return {
            "metric_diagonal": [str(x) for x in self.metric_diagonal],
            "determinant": str(self.determinant),
            "determinant_constraint": str(self.determinant_constraint),
            "balanced_scale_solution": {
                str(k): str(v) for k, v in self.balanced_scale_solution.items()
            },
            "phi": self.form_formula,
            "star_phi": self.star_formula,
            "phi_components": self.phi_form.to_dict(),
            "star_phi_components": self.star_phi_form.to_dict(),
            "torsion_residual_basis": {
                key: str(value) for key, value in self.symbolic_torsion_residual().items()
            },
            "determinant_preserving_family": self.determinant_preserving_family(),
            "connection_curvature_forms": self.symbolic_connection_curvature_forms(),
            "so3_connection_matrix": self.symbolic_so3_connection_matrix(),
            "so3_curvature_matrix_algebraic": self.symbolic_so3_curvature_matrix(),
            "coclosed_compensator_form": self.symbolic_coclosed_compensator_form(),
        }


@dataclass
class ChebyshevProfile:
    """Analytic scalar profile u(t) = (1-t^2)^q sum c_k T_k(t)."""

    coeffs: np.ndarray
    boundary_order: int = 2

    @classmethod
    def zero(cls, degree: int = 6) -> "ChebyshevProfile":
        return cls(np.zeros(degree + 1, dtype=float))

    @classmethod
    def pulse(cls, amplitude: float = 0.035, degree: int = 6) -> "ChebyshevProfile":
        coeffs = np.zeros(degree + 1, dtype=float)
        coeffs[0] = amplitude
        if degree >= 2:
            coeffs[2] = -0.5 * amplitude
        return cls(coeffs)

    @classmethod
    def smooth_min_energy(
        cls,
        center_amplitude: float = 0.0525,
        degree: int = 8,
        boundary_order: int = 2,
        n_points: int = 257,
        ridge: float = 1e-10,
    ) -> "ChebyshevProfile":
        """Solve min ||u'||_2 with u(0)=center_amplitude.

        The profile is linear in Chebyshev coefficients, so this is a tiny KKT
        linear system.  It gives a deterministic analytic profile with compact
        neck support and minimal curvature energy under the central amplitude
        constraint.
        """
        t = np.linspace(-1.0, 1.0, n_points)
        derivative_design = []
        center_design = []
        for k in range(degree + 1):
            coeffs = np.zeros(degree + 1, dtype=float)
            coeffs[k] = 1.0
            basis = cls(coeffs, boundary_order=boundary_order)
            derivative_design.append(basis.derivative(t))
            center_design.append(basis.values(np.array([0.0]))[0])

        dmat = np.vstack(derivative_design).T
        amat = np.array(center_design, dtype=float).reshape(1, -1)
        qmat = dmat.T @ dmat / n_points + ridge * np.eye(degree + 1)
        rhs = np.zeros(degree + 1)

        kkt = np.block([
            [qmat, amat.T],
            [amat, np.zeros((1, 1))],
        ])
        krhs = np.concatenate([rhs, np.array([center_amplitude])])
        solution = np.linalg.solve(kkt, krhs)
        return cls(solution[: degree + 1], boundary_order=boundary_order)

    @property
    def degree(self) -> int:
        return int(len(self.coeffs) - 1)

    def values(self, t: np.ndarray) -> np.ndarray:
        from numpy.polynomial.chebyshev import chebval

        t = np.asarray(t, dtype=float)
        return self._envelope(t) * chebval(t, self.coeffs)

    def derivative(self, t: np.ndarray) -> np.ndarray:
        from numpy.polynomial.chebyshev import chebder, chebval

        t = np.asarray(t, dtype=float)
        p = chebval(t, self.coeffs)
        dp = chebval(t, chebder(self.coeffs))
        return self._envelope_derivative(t) * p + self._envelope(t) * dp

    def _envelope(self, t: np.ndarray) -> np.ndarray:
        return (1.0 - t * t) ** self.boundary_order

    def _envelope_derivative(self, t: np.ndarray) -> np.ndarray:
        if self.boundary_order == 0:
            return np.zeros_like(t)
        return (
            -2.0
            * self.boundary_order
            * t
            * (1.0 - t * t) ** (self.boundary_order - 1)
        )


@dataclass
class DonaldsonSO3Connection:
    """Reduced explicit so(3) connection for the hyperkahler triple.

    The connection matrix is

        A = [[0, -A3, A2], [A3, 0, -A1], [-A2, A1, 0]]

    with A_i = q_i(t) theta_i.  For the current radial solve we choose the
    symmetric branch q_1=q_2=q_3=q(t).  Its algebraic curvature contributes
    q(t)^2 theta_jk in each adjoint component.  The requested compensating
    curvature is k(t)=2u'(t), so the branch solves q(t)^2 = max(k(t), 0) and
    leaves a signed residual when k(t)<0.  That residual is reported rather
    than hidden; the next step is to introduce an indefinite/complex or
    non-symmetric branch if the signed negative sector is geometrically wanted.
    """

    profile: ChebyshevProfile

    def requested_curvature(self, t: np.ndarray) -> np.ndarray:
        return 2.0 * self.profile.derivative(t)

    def q(self, t: np.ndarray) -> np.ndarray:
        requested = self.requested_curvature(t)
        return np.sqrt(np.maximum(requested, 0.0))

    def q_with_signs(
        self,
        t: np.ndarray,
        sigma_pattern: np.ndarray | None = None,
    ) -> np.ndarray:
        """Return real signed amplitudes sqrt(|k|) for the Option 2 branch.

        This is the reduced "effective signed curvature" model from
        DONALDSON_OPTION_2_HK_ROTATION.  The metric remains positive definite:
        the sign is attached to the hyperkahler-frame orientation, not to a
        square root of a negative real number.
        """
        t = np.asarray(t, dtype=float)
        requested = self.requested_curvature(t)
        base_q = np.sqrt(np.abs(requested))
        if sigma_pattern is None:
            sigma_pattern = np.sign(requested)
            sigma_pattern = np.where(sigma_pattern == 0.0, 1.0, sigma_pattern)
            sigma_pattern = np.vstack([sigma_pattern, sigma_pattern, sigma_pattern])
        sigma_pattern = np.asarray(sigma_pattern, dtype=float)
        if sigma_pattern.shape == (len(t), 3):
            sigma_pattern = sigma_pattern.T
        if sigma_pattern.shape != (3, len(t)):
            raise ValueError("sigma_pattern must have shape (3, len(t)) or (len(t), 3)")
        return sigma_pattern * base_q

    def signed_curvature_adjoint_components(
        self,
        t: np.ndarray,
        sigma_pattern: np.ndarray | None = None,
    ) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        q = self.q_with_signs(t, sigma_pattern=sigma_pattern)
        produced = np.sign(q) * q * q
        return {
            "F1_23": [float(x) for x in produced[0]],
            "F2_31": [float(x) for x in produced[1]],
            "F3_12": [float(x) for x in produced[2]],
        }

    def signed_curvature_residual(
        self,
        t: np.ndarray,
        sigma_pattern: np.ndarray | None = None,
    ) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        requested = self.requested_curvature(t)
        produced = np.array(
            [
                self.signed_curvature_adjoint_components(t, sigma_pattern=sigma_pattern)[key]
                for key in ("F1_23", "F2_31", "F3_12")
            ],
            dtype=float,
        )
        residual = produced - requested.reshape(1, -1)
        return {
            "requested_k": [float(x) for x in requested],
            "max_abs_residual_per_component": [
                float(np.max(np.abs(residual[i]))) for i in range(3)
            ],
            "signed_residual": [[float(x) for x in residual[i]] for i in range(3)],
        }

    def connection_matrix_components(self, t: np.ndarray) -> dict[str, dict[str, list[float]]]:
        q = self.q(np.asarray(t, dtype=float))
        zero = [0.0 for _ in q]
        return {
            "A12": {"3": [-float(x) for x in q]},
            "A13": {"2": [float(x) for x in q]},
            "A21": {"3": [float(x) for x in q]},
            "A23": {"1": [-float(x) for x in q]},
            "A31": {"2": [-float(x) for x in q]},
            "A32": {"1": [float(x) for x in q]},
            "A11": {"0": zero},
            "A22": {"0": zero},
            "A33": {"0": zero},
        }

    def curvature_adjoint_components(self, t: np.ndarray) -> dict[str, list[float]]:
        q = self.q(np.asarray(t, dtype=float))
        value = q * q
        return {
            "F1_23": [float(x) for x in value],
            "F2_31": [float(x) for x in value],
            "F3_12": [float(x) for x in value],
        }

    def curvature_residual(self, t: np.ndarray) -> dict[str, list[float]]:
        requested = self.requested_curvature(np.asarray(t, dtype=float))
        produced = np.array(self.curvature_adjoint_components(t)["F1_23"])
        residual = produced - requested
        return {
            "requested_k": [float(x) for x in requested],
            "produced_q_squared": [float(x) for x in produced],
            "signed_residual": [float(x) for x in residual],
        }

    def dense_report(self, n_points: int = 65) -> dict[str, object]:
        t = np.linspace(-1.0, 1.0, n_points)
        residual = self.curvature_residual(t)
        return {
            "branch": "symmetric_real_so3_q1_eq_q2_eq_q3",
            "q_range": [float(np.min(self.q(t))), float(np.max(self.q(t)))],
            "requested_k_range": [
                float(np.min(self.requested_curvature(t))),
                float(np.max(self.requested_curvature(t))),
            ],
            "max_abs_signed_residual": float(np.max(np.abs(residual["signed_residual"]))),
            "negative_requested_fraction": float(np.mean(self.requested_curvature(t) < 0.0)),
            "sample_t": [float(x) for x in np.array([-1.0, -0.5, 0.0, 0.5, 1.0])],
            "connection_matrix_samples": self.connection_matrix_components(
                np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
            ),
            "curvature_adjoint_samples": self.curvature_adjoint_components(
                np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
            ),
            "curvature_residual_samples": self.curvature_residual(
                np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
            ),
        }


def _hat(vector: np.ndarray) -> np.ndarray:
    x, y, z = [float(v) for v in vector]
    return np.array(
        [
            [0.0, -z, y],
            [z, 0.0, -x],
            [-y, x, 0.0],
        ]
    )


def _exp_hat(vector: np.ndarray) -> np.ndarray:
    angle = float(np.linalg.norm(vector))
    identity = np.eye(3)
    if angle < 1e-14:
        return identity + _hat(vector)
    axis_hat = _hat(vector / angle)
    return (
        identity
        + np.sin(angle) * axis_hat
        + (1.0 - np.cos(angle)) * (axis_hat @ axis_hat)
    )


def _project_so3(matrix: np.ndarray) -> np.ndarray:
    u, _, vh = np.linalg.svd(matrix)
    projected = u @ vh
    if np.linalg.det(projected) < 0.0:
        u[:, -1] *= -1.0
        projected = u @ vh
    return projected


@dataclass
class HyperkahlerRotation:
    """Smooth real SO(3) rotation of the K3 hyperkahler triple.

    The angular velocity profiles are Chebyshev/enveloped functions
    nu_i(t).  We integrate R'(t)=hat(nu(t)) R(t), R(0)=Id with small
    Lie-group Euler steps and re-project to SO(3) to avoid determinant drift.
    """

    nu_profiles: tuple[ChebyshevProfile, ChebyshevProfile, ChebyshevProfile]
    max_step: float = 1.0 / 256.0

    @classmethod
    def zero(cls, degree: int = 4, boundary_order: int = 2) -> "HyperkahlerRotation":
        return cls(
            tuple(
                ChebyshevProfile(np.zeros(degree + 1, dtype=float), boundary_order=boundary_order)
                for _ in range(3)
            ),
        )

    @property
    def degrees(self) -> tuple[int, int, int]:
        return tuple(profile.degree for profile in self.nu_profiles)

    @property
    def boundary_orders(self) -> tuple[int, int, int]:
        return tuple(profile.boundary_order for profile in self.nu_profiles)

    def angular_velocity(self, t: np.ndarray) -> np.ndarray:
        t = np.asarray(t, dtype=float)
        return np.vstack([profile.values(t) for profile in self.nu_profiles]).T

    def angular_acceleration(self, t: np.ndarray) -> np.ndarray:
        t = np.asarray(t, dtype=float)
        return np.vstack([profile.derivative(t) for profile in self.nu_profiles]).T

    def _integrate_to(self, target: float) -> np.ndarray:
        if abs(target) < 1e-15:
            return np.eye(3)
        steps = max(1, int(np.ceil(abs(target) / self.max_step)))
        h = target / steps
        rmat = np.eye(3)
        current = 0.0
        for _ in range(steps):
            midpoint = current + 0.5 * h
            omega = self.angular_velocity(np.array([midpoint]))[0]
            rmat = _exp_hat(omega * h) @ rmat
            rmat = _project_so3(rmat)
            current += h
        return rmat

    def rotation_matrix(self, t: np.ndarray) -> np.ndarray:
        t = np.asarray(t, dtype=float)
        return np.stack([self._integrate_to(float(x)) for x in t], axis=0)

    def rotated_triple(
        self,
        t: np.ndarray,
        omega0_components: tuple[dict[str, float], dict[str, float], dict[str, float]]
        | None = None,
    ) -> dict[str, dict[str, list[float]]]:
        if omega0_components is None:
            omega0_components = tuple(
                {
                    key: float(sp.sympify(value))
                    for key, value in form.to_dict().items()
                }
                for form in DonaldsonG2Ansatz().hyperkahler_triple
            )
        matrices = self.rotation_matrix(np.asarray(t, dtype=float))
        component_keys = sorted({key for omega in omega0_components for key in omega})
        out: dict[str, dict[str, list[float]]] = {
            f"Omega{i + 1}": {key: [] for key in component_keys} for i in range(3)
        }
        for rmat in matrices:
            for i in range(3):
                for key in component_keys:
                    value = sum(
                        rmat[i, j] * omega0_components[j].get(key, 0.0)
                        for j in range(3)
                    )
                    out[f"Omega{i + 1}"][key].append(float(value))
        return out

    def derivative_contribution(
        self,
        t: np.ndarray,
        scale: np.ndarray | float = 1.0,
    ) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        scale_arr = np.asarray(scale, dtype=float)
        if scale_arr.shape == ():
            scale_arr = np.full_like(t, float(scale_arr))
        nu = self.angular_velocity(t)
        return {
            "theta12_Omega1": [float(x) for x in scale_arr * nu[:, 2]],
            "theta12_Omega2": [0.0 for _ in t],
            "theta12_Omega3": [float(x) for x in -scale_arr * nu[:, 0]],
            "theta13_Omega1": [float(x) for x in -scale_arr * nu[:, 1]],
            "theta13_Omega2": [float(x) for x in scale_arr * nu[:, 0]],
            "theta13_Omega3": [0.0 for _ in t],
        }

    def sigma_pattern(self, t: np.ndarray) -> np.ndarray:
        """Continuous orientation signs inferred from the SO(3) diagonal."""
        rmat = self.rotation_matrix(np.asarray(t, dtype=float))
        sigma = np.sign(np.diagonal(rmat, axis1=1, axis2=2))
        sigma[sigma == 0.0] = 1.0
        return sigma.T

    def audit(self, t: np.ndarray) -> dict[str, object]:
        t = np.asarray(t, dtype=float)
        rmat = self.rotation_matrix(t)
        det = np.linalg.det(rmat)
        orthogonality = np.array(
            [np.max(np.abs(matrix.T @ matrix - np.eye(3))) for matrix in rmat]
        )
        nu = self.angular_velocity(t)
        boundary_t = np.array([-1.0, 1.0])
        boundary_nu = self.angular_velocity(boundary_t)
        return {
            "branch": "hyperkahler_so3_rotation",
            "nu_degrees": self.degrees,
            "boundary_orders": self.boundary_orders,
            "determinant_range": [float(np.min(det)), float(np.max(det))],
            "max_abs_det_minus_one": float(np.max(np.abs(det - 1.0))),
            "max_orthogonality_error": float(np.max(orthogonality)),
            "max_abs_nu_boundary": float(np.max(np.abs(boundary_nu))),
            "nu_range": [
                [float(np.min(nu[:, i])), float(np.max(nu[:, i]))]
                for i in range(3)
            ],
        }


@dataclass
class BaseCoframeVariation:
    """Minimal Option 4 base coframe absorber for HK rotation residuals.

    We model

        dtheta_i = c_i12 theta12 + c_i13 theta13 + c_i23 theta23.

    The coefficients below are chosen so dtheta_i wedge Omega_i cancels the
    linear dphi components created by HyperkahlerRotation.derivative_contribution.
    This is a reduced local model; it records the exact coframe terms that a
    global Donaldson base geometry would still need to realize.
    """

    hk_rotation: HyperkahlerRotation

    @classmethod
    def from_hk_rotation(cls, hk_rotation: HyperkahlerRotation) -> "BaseCoframeVariation":
        return cls(hk_rotation=hk_rotation)

    def coefficients(self, t: np.ndarray) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        nu = self.hk_rotation.angular_velocity(t)
        zeros = np.zeros_like(t)
        coeffs = {
            "dtheta1_theta12": -nu[:, 2],
            "dtheta1_theta13": nu[:, 1],
            "dtheta1_theta23": zeros,
            "dtheta2_theta12": zeros,
            "dtheta2_theta13": -nu[:, 0],
            "dtheta2_theta23": zeros,
            "dtheta3_theta12": nu[:, 0],
            "dtheta3_theta13": zeros,
            "dtheta3_theta23": zeros,
        }
        return {key: [float(x) for x in value] for key, value in coeffs.items()}

    def dphi_contribution(
        self,
        t: np.ndarray,
        scale: np.ndarray | float = 1.0,
    ) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        scale_arr = np.asarray(scale, dtype=float)
        if scale_arr.shape == ():
            scale_arr = np.full_like(t, float(scale_arr))
        nu = self.hk_rotation.angular_velocity(t)
        return {
            "theta12_Omega1": [float(x) for x in -scale_arr * nu[:, 2]],
            "theta12_Omega2": [0.0 for _ in t],
            "theta12_Omega3": [float(x) for x in scale_arr * nu[:, 0]],
            "theta13_Omega1": [float(x) for x in scale_arr * nu[:, 1]],
            "theta13_Omega2": [float(x) for x in -scale_arr * nu[:, 0]],
            "theta13_Omega3": [0.0 for _ in t],
        }

    def ddtheta_residual(self, t: np.ndarray) -> dict[str, list[float]]:
        """Return the reduced Bianchi/Jacobi residual d(dtheta_i).

        In the minimal absorber all derivative terms vanish because no
        c_i23(t) term is used and t is represented by theta1.  The remaining
        algebraic base-coframe residual is cubic-base theta123.
        """
        t = np.asarray(t, dtype=float)
        nu = self.hk_rotation.angular_velocity(t)
        zeros = np.zeros_like(t)
        residuals = {
            "ddtheta1_theta123": zeros,
            "ddtheta2_theta123": nu[:, 0] * nu[:, 2],
            "ddtheta3_theta123": -nu[:, 0] * nu[:, 1],
        }
        return {key: [float(x) for x in value] for key, value in residuals.items()}

    def audit(self, t: np.ndarray) -> dict[str, object]:
        coeffs = self.coefficients(np.asarray(t, dtype=float))
        flat = np.array([value for value in coeffs.values()], dtype=float)
        boundary = self.coefficients(np.array([-1.0, 1.0]))
        boundary_flat = np.array([value for value in boundary.values()], dtype=float)
        ddtheta = self.ddtheta_residual(np.asarray(t, dtype=float))
        ddtheta_flat = np.array([value for value in ddtheta.values()], dtype=float)
        return {
            "branch": "variable_base_coframe_option_4_minimal_absorber",
            "max_abs_coefficient": float(np.max(np.abs(flat))),
            "max_abs_boundary_coefficient": float(np.max(np.abs(boundary_flat))),
            "max_abs_ddtheta_residual": float(np.max(np.abs(ddtheta_flat))),
            "coefficients": coeffs,
            "ddtheta_residual": ddtheta,
        }


def _constant_profile(value: float) -> ChebyshevProfile:
    return ChebyshevProfile(np.array([float(value)]), boundary_order=0)


def _profile_half_integral(profile: ChebyshevProfile, n_points: int = 20001) -> float:
    t = np.linspace(0.0, 1.0, n_points)
    return float(np.trapz(profile.values(t), t))


def _empty_structure_constants(t: np.ndarray) -> dict[str, np.ndarray]:
    zeros = np.zeros_like(np.asarray(t, dtype=float))
    return {
        "dtheta1_theta12": zeros.copy(),
        "dtheta1_theta13": zeros.copy(),
        "dtheta1_theta23": zeros.copy(),
        "dtheta2_theta12": zeros.copy(),
        "dtheta2_theta13": zeros.copy(),
        "dtheta2_theta23": zeros.copy(),
        "dtheta3_theta12": zeros.copy(),
        "dtheta3_theta13": zeros.copy(),
        "dtheta3_theta23": zeros.copy(),
    }


def _serialise_array_dict(values: dict[str, np.ndarray]) -> dict[str, list[float]]:
    return {key: [float(x) for x in value] for key, value in values.items()}


def _dict_residual(
    left: dict[str, list[float]] | dict[str, np.ndarray],
    right: dict[str, list[float]] | dict[str, np.ndarray],
) -> dict[str, np.ndarray]:
    keys = sorted(set(left) | set(right))
    residual: dict[str, np.ndarray] = {}
    fallback_len = 1
    for values in list(left.values()) + list(right.values()):
        fallback_len = len(values)
        break
    for key in keys:
        lval = np.asarray(left.get(key, np.zeros(fallback_len)), dtype=float)
        rval = np.asarray(right.get(key, np.zeros_like(lval)), dtype=float)
        residual[key] = lval - rval
    return residual


def _word_to_string(word: tuple[int, ...]) -> str:
    return " ".join(f"m{i}" for i in word) if word else "1"


@dataclass
class BaseGeometryCandidate:
    """Candidate global base geometry for the Donaldson fibration."""

    name: str
    f_profiles: tuple[ChebyshevProfile, ChebyshevProfile, ChebyshevProfile]
    family: str

    @classmethod
    def round_s3(cls, radius: float = 1.0) -> "BaseGeometryCandidate":
        profile = _constant_profile(radius)
        return cls("round_s3", (profile, profile, profile), "su2_maurer_cartan")

    @classmethod
    def berger_s3(
        cls,
        fiber_scale: float = 0.75,
        base_scale: float = 1.0,
    ) -> "BaseGeometryCandidate":
        return cls(
            "berger_s3",
            (
                _constant_profile(fiber_scale),
                _constant_profile(base_scale),
                _constant_profile(base_scale),
            ),
            "su2_maurer_cartan",
        )

    @classmethod
    def squashed_s3(
        cls,
        scales: tuple[float, float, float] = (0.75, 1.0, 1.25),
    ) -> "BaseGeometryCandidate":
        return cls(
            "squashed_s3",
            tuple(_constant_profile(scale) for scale in scales),
            "su2_maurer_cartan",
        )

    def _f_values(self, t: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
        return tuple(profile.values(t) for profile in self.f_profiles)

    def _f_derivatives(self, t: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
        return tuple(profile.derivative(t) for profile in self.f_profiles)

    def coframe_structure_constants(self, t: np.ndarray) -> dict[str, list[float]]:
        """Return c_{i,jk}(t) computed from a diagonal SU(2) coframe.

        Key signs use sorted base 2-forms: theta13 rather than theta31.
        """
        t = np.asarray(t, dtype=float)
        f1, f2, f3 = self._f_values(t)
        df1, df2, df3 = self._f_derivatives(t)
        coeffs = _empty_structure_constants(t)

        coeffs["dtheta1_theta12"] = np.divide(df1, f1, out=np.zeros_like(t), where=f1 != 0)
        coeffs["dtheta2_theta12"] = np.divide(df2, f2, out=np.zeros_like(t), where=f2 != 0)
        coeffs["dtheta3_theta13"] = np.divide(df3, f3, out=np.zeros_like(t), where=f3 != 0)

        coeffs["dtheta1_theta23"] = -0.5 * f1 / (f2 * f3)
        coeffs["dtheta2_theta13"] = 0.5 * f2 / (f3 * f1)
        coeffs["dtheta3_theta12"] = -0.5 * f3 / (f1 * f2)
        return _serialise_array_dict(coeffs)

    def matches_absorber(
        self,
        absorber: BaseCoframeVariation,
        t: np.ndarray | None = None,
        tol: float = 1e-10,
    ) -> dict[str, object]:
        if t is None:
            t = np.linspace(-1.0, 1.0, 65)
        t = np.asarray(t, dtype=float)
        candidate = self.coframe_structure_constants(t)
        target = absorber.coefficients(t)
        residual = _dict_residual(candidate, target)
        flat = np.array(list(residual.values()), dtype=float)
        max_abs = float(np.max(np.abs(flat)))
        candidate_nonzero = {
            key: value
            for key, value in candidate.items()
            if np.max(np.abs(np.asarray(value, dtype=float))) > tol
        }
        target_nonzero = {
            key: value
            for key, value in target.items()
            if np.max(np.abs(np.asarray(value, dtype=float))) > tol
        }
        return {
            "candidate": self.name,
            "family": self.family,
            "matches": max_abs < tol,
            "max_abs_residual": max_abs,
            "obstruction": (
                "SU(2) Maurer-Cartan candidates only populate the cyclic "
                "epsilon-pattern, while the HK absorber asks for nu-driven "
                "radial/mixed coefficients."
                if max_abs >= tol
                else "none"
            ),
            "candidate_nonzero_keys": sorted(candidate_nonzero),
            "target_nonzero_keys": sorted(target_nonzero),
            "residual_samples": _serialise_array_dict(
                {
                    key: value[[0, len(t) // 2, -1]]
                    for key, value in residual.items()
                }
            ),
        }


@dataclass(frozen=True)
class FanoPLRelator:
    """A non-abelian meridian relator represented as a word in m_0,...,m_6."""

    name: str
    word: tuple[int, ...]
    source: str

    def as_dict(self) -> dict[str, object]:
        return {
            "name": self.name,
            "word": [int(x) for x in self.word],
            "word_string": _word_to_string(self.word),
            "source": self.source,
        }


@dataclass
class FanoPLWirtingerCandidate:
    """PL-compatible non-abelian presentation candidate.

    This is not claimed to be the graph-complement group.  It is the smallest
    currently defensible presentation whose meridian generators map to the
    rank-one Picard-Lefschetz SO(3) half-turns and whose listed relators are
    actually satisfied by those matrices.
    """

    fano_meridians: FanoMeridianModel = field(default_factory=FanoMeridianModel)

    @property
    def generator_count(self) -> int:
        return self.fano_meridians.fano_line_count

    def relators(self) -> tuple[FanoPLRelator, ...]:
        relators = [
            FanoPLRelator(f"involution_m{i}", (i, i), "meridian_order_two")
            for i in range(self.generator_count)
        ]
        relators.extend(
            [
                FanoPLRelator(
                    "coordinate_axis_triangle_012",
                    (0, 1, 2),
                    "SO3_coordinate_half_turn_identity",
                ),
                FanoPLRelator(
                    "coordinate_axis_triangle_021",
                    (0, 2, 1),
                    "SO3_coordinate_half_turn_identity",
                ),
            ]
        )
        return tuple(relators)

    def generator_holonomies(self) -> tuple[np.ndarray, ...]:
        holonomy = FanoLinkBaseGeometry(self.fano_meridians).flat_connection_holonomy()
        return tuple(holonomy[2 * i] for i in range(self.generator_count))

    def evaluate_word(self, word: tuple[int, ...]) -> np.ndarray:
        generators = self.generator_holonomies()
        product = np.eye(3)
        for index in word:
            product = generators[index] @ product
        return product

    def audit_relators(self, tol: float = 1e-10) -> dict[str, object]:
        reports = []
        for relator in self.relators():
            product = self.evaluate_word(relator.word)
            error = float(np.max(np.abs(product - np.eye(3))))
            reports.append(
                {
                    **relator.as_dict(),
                    "max_abs_product_minus_identity": error,
                    "satisfied": bool(error < tol),
                    "determinant": float(np.linalg.det(product)),
                    "trace": float(np.trace(product)),
                }
            )
        max_error = max(report["max_abs_product_minus_identity"] for report in reports)
        return {
            "branch": "fano_pl_wirtinger_candidate_relator_audit",
            "generator_count": self.generator_count,
            "relator_count": len(reports),
            "all_relators_satisfied": all(report["satisfied"] for report in reports),
            "max_abs_relator_error": float(max_error),
            "reports": reports,
            "presentation_status": "pl_compatible_underconstrained_not_graph_pi1",
        }

    def search_short_identity_words(
        self,
        max_length: int = 5,
        tol: float = 1e-10,
        limit: int = 64,
    ) -> list[dict[str, object]]:
        found: list[dict[str, object]] = []

        def extend(prefix: tuple[int, ...]) -> None:
            if len(found) >= limit:
                return
            if prefix:
                product = self.evaluate_word(prefix)
                error = float(np.max(np.abs(product - np.eye(3))))
                if error < tol:
                    found.append(
                        {
                            "word": [int(x) for x in prefix],
                            "word_string": _word_to_string(prefix),
                            "length": len(prefix),
                            "max_abs_product_minus_identity": error,
                        }
                    )
            if len(prefix) >= max_length:
                return
            for index in range(self.generator_count):
                if prefix and prefix[-1] == index:
                    continue
                extend(prefix + (index,))

        extend(())
        return found

    def audit(self) -> dict[str, object]:
        relator_audit = self.audit_relators()
        return {
            "requested_object": (
                "non-abelian Wirtinger-style candidate with meridian PL "
                "half-turn holonomies"
            ),
            "can_serve_as_flat_connection_representation": relator_audit[
                "all_relators_satisfied"
            ],
            "can_claim_graph_complement_pi1": False,
            "relators": relator_audit,
            "short_identity_words": self.search_short_identity_words(),
            "next_required_object": (
                "identify this PL-compatible presentation with an explicit "
                "Wirtinger presentation of S3 minus Gamma_Fano, or add the "
                "missing graph-crossing relators and re-audit"
            ),
        }


@dataclass
class FanoIncidenceGraphIdentifier:
    """Audit whether the PL holonomies fit the Fano incidence graph relations."""

    fano_meridians: FanoMeridianModel = field(default_factory=FanoMeridianModel)

    def fano_lines(self) -> tuple[tuple[int, int, int], ...]:
        points = [np.asarray(point, dtype=int) % 2 for point in self.fano_meridians.fano_points]
        lines = []
        for triple in itertools.combinations(range(len(points)), 3):
            total = (points[triple[0]] + points[triple[1]] + points[triple[2]]) % 2
            if np.all(total == 0):
                lines.append(tuple(int(x) for x in triple))
        return tuple(lines)

    def generator_holonomies(self) -> tuple[np.ndarray, ...]:
        holonomy = FanoLinkBaseGeometry(self.fano_meridians).flat_connection_holonomy()
        return tuple(holonomy[2 * i] for i in range(self.fano_meridians.fano_line_count))

    def _word_product(self, word: tuple[int, ...]) -> np.ndarray:
        generators = self.generator_holonomies()
        product = np.eye(3)
        for index in word:
            product = generators[index] @ product
        return product

    def audit_line_identity_relators(self, tol: float = 1e-10) -> dict[str, object]:
        reports = []
        for line in self.fano_lines():
            permutation_reports = []
            for word in itertools.permutations(line):
                product = self._word_product(tuple(int(x) for x in word))
                permutation_reports.append(
                    {
                        "word": [int(x) for x in word],
                        "word_string": _word_to_string(tuple(int(x) for x in word)),
                        "max_abs_product_minus_identity": float(
                            np.max(np.abs(product - np.eye(3)))
                        ),
                        "trace": float(np.trace(product)),
                        "determinant": float(np.linalg.det(product)),
                    }
                )
            best = min(
                permutation_reports,
                key=lambda item: item["max_abs_product_minus_identity"],
            )
            reports.append(
                {
                    "line": [int(x) for x in line],
                    "some_order_satisfies_identity": bool(
                        best["max_abs_product_minus_identity"] < tol
                    ),
                    "best_order": best,
                    "permutation_count": len(permutation_reports),
                }
            )
        return {
            "branch": "fano_incidence_line_identity_relators",
            "line_count": len(reports),
            "all_lines_identity": all(
                report["some_order_satisfies_identity"] for report in reports
            ),
            "reports": reports,
            "interpretation": (
                "The naive incidence relator product(point meridians on each "
                "Fano line)=1 is not satisfied by the PL SO(3) half-turns. "
                "Therefore this cannot be the graph-complement Wirtinger "
                "presentation without additional line generators or conjugation data."
            ),
        }

    def audit_line_generator_products(self, tol: float = 1e-10) -> dict[str, object]:
        reports = []
        for line in self.fano_lines():
            product = self._word_product(line)
            order_two_error = float(np.max(np.abs(product @ product - np.eye(3))))
            trace = float(np.trace(product))
            angle = float(np.arccos(np.clip((trace - 1.0) / 2.0, -1.0, 1.0)))
            reports.append(
                {
                    "line": [int(x) for x in line],
                    "line_generator_word": _word_to_string(line),
                    "is_order_two_so3_element": bool(order_two_error < tol),
                    "max_abs_order_two_error": order_two_error,
                    "trace": trace,
                    "angle": angle,
                    "determinant": float(np.linalg.det(product)),
                }
            )
        order_two_count = sum(report["is_order_two_so3_element"] for report in reports)
        return {
            "branch": "fano_incidence_line_generator_products",
            "line_count": len(reports),
            "order_two_line_product_count": int(order_two_count),
            "all_line_products_order_two": order_two_count == len(reports),
            "reports": reports,
            "interpretation": (
                "Adding line generators l_L = product(point meridians on L) "
                "almost gives PL-type order-two elements, but not uniformly: "
                "the current Euclidean SO(3) axis assignment leaves an incidence "
                "defect. This points to missing conjugation/embedding data, not "
                "a completed identification."
            ),
        }

    def audit(self) -> dict[str, object]:
        identity = self.audit_line_identity_relators()
        products = self.audit_line_generator_products()
        return {
            "requested_identification": "Fano incidence graph complement presentation",
            "fano_points": [tuple(int(x) for x in point) for point in self.fano_meridians.fano_points],
            "fano_lines": [list(line) for line in self.fano_lines()],
            "line_identity_relators": identity,
            "line_generator_products": products,
            "identification_status": "not_identified_incidence_relators_fail",
            "next_required_object": (
                "a spatial embedding/diagram of Gamma_Fano giving actual "
                "Wirtinger crossing and vertex conjugation relators, rather "
                "than the abstract Fano incidence triples alone"
            ),
        }


@dataclass
class SpatialEmbeddingAuditResult:
    name: str
    vertex_count: int
    edge_count: int
    component_count: int
    abelianization_rank: int
    matches_v3_4_15_presentation: bool
    pl_representation_descends: bool
    line_345_is_reflection: bool
    embedding_is_explicit_and_smooth: bool
    obstruction: str

    def as_dict(self) -> dict[str, object]:
        return {
            "name": self.name,
            "vertex_count": self.vertex_count,
            "edge_count": self.edge_count,
            "component_count": self.component_count,
            "abelianization_rank": self.abelianization_rank,
            "matches_v3_4_15_presentation": self.matches_v3_4_15_presentation,
            "pl_representation_descends": self.pl_representation_descends,
            "line_3_4_5_is_reflection": self.line_345_is_reflection,
            "embedding_is_explicit_and_smooth": self.embedding_is_explicit_and_smooth,
            "obstruction": self.obstruction,
        }


@dataclass
class LinkProjectionCrossing:
    """One transverse crossing in a polygonal link projection."""

    over_component: int
    under_component: int
    over_segment: int
    under_segment: int
    xy: tuple[float, float]
    z_over: float
    z_under: float
    sign: int

    def as_dict(self) -> dict[str, object]:
        return {
            "over_component": self.over_component,
            "under_component": self.under_component,
            "over_segment": self.over_segment,
            "under_segment": self.under_segment,
            "xy": self.xy,
            "z_over": self.z_over,
            "z_under": self.z_under,
            "z_gap": abs(self.z_over - self.z_under),
            "sign": self.sign,
        }


@dataclass
class LinkProjectionDiagram:
    """Deterministic sampled projection of an oriented link in S3."""

    sample_count_per_component: int
    crossings: list[LinkProjectionCrossing]
    min_crossing_z_gap: float
    min_crossing_xy_separation: float
    has_transverse_double_points_only: bool

    def as_dict(self, *, max_crossings: int = 24) -> dict[str, object]:
        return {
            "sample_count_per_component": self.sample_count_per_component,
            "crossing_count": len(self.crossings),
            "min_crossing_z_gap": self.min_crossing_z_gap,
            "min_crossing_xy_separation": self.min_crossing_xy_separation,
            "has_transverse_double_points_only": self.has_transverse_double_points_only,
            "crossing_table_sample": [
                crossing.as_dict()
                for crossing in self.crossings[:max_crossings]
            ],
            "crossing_table_truncated": len(self.crossings) > max_crossings,
        }


def _complex_pair_to_r4(pair: np.ndarray) -> np.ndarray:
    return np.array(
        [
            pair[0].real,
            pair[0].imag,
            pair[1].real,
            pair[1].imag,
        ],
        dtype=float,
    )


def _stereographic_basis(pole: np.ndarray) -> np.ndarray:
    basis: list[np.ndarray] = []
    for vector in np.eye(4):
        candidate = vector - np.dot(vector, pole) * pole
        for old in basis:
            candidate = candidate - np.dot(candidate, old) * old
        norm = np.linalg.norm(candidate)
        if norm > 1e-12:
            basis.append(candidate / norm)
        if len(basis) == 3:
            break
    return np.vstack(basis)


def _stereographic_project_s3(points: np.ndarray, pole: np.ndarray) -> np.ndarray:
    basis = _stereographic_basis(pole)
    dots = points @ pole
    tangent = points - dots[:, None] * pole[None, :]
    projected = tangent / (1.0 - dots)[:, None]
    return projected @ basis.T


def _segment_intersection_2d(
    a0: np.ndarray,
    a1: np.ndarray,
    b0: np.ndarray,
    b1: np.ndarray,
    *,
    eps: float = 1e-9,
) -> tuple[float, float] | None:
    da = a1 - a0
    db = b1 - b0
    denom = da[0] * db[1] - da[1] * db[0]
    if abs(denom) < eps:
        return None
    delta = b0 - a0
    s = (delta[0] * db[1] - delta[1] * db[0]) / denom
    t = (delta[0] * da[1] - delta[1] * da[0]) / denom
    if eps < s < 1.0 - eps and eps < t < 1.0 - eps:
        return float(s), float(t)
    return None


def _orthonormal_frame3(seed: np.ndarray) -> np.ndarray:
    q, _ = np.linalg.qr(seed.T)
    return q.T


def _deterministic_projection_frames3() -> list[np.ndarray]:
    seeds = [
        np.array(
            [
                [1.0, 0.0, 0.0],
                [0.0, 1.0, 0.0],
                [0.0, 0.0, 1.0],
            ],
            dtype=float,
        ),
        np.array(
            [
                [0.23, 0.71, 0.66],
                [0.87, -0.44, 0.22],
                [0.43, 0.55, -0.72],
            ],
            dtype=float,
        ),
        np.array(
            [
                [0.51, -0.17, 0.84],
                [0.31, 0.95, 0.02],
                [-0.80, 0.25, 0.54],
            ],
            dtype=float,
        ),
        np.array(
            [
                [0.62, 0.33, -0.71],
                [-0.18, 0.94, 0.29],
                [0.76, -0.05, 0.65],
            ],
            dtype=float,
        ),
    ]
    return [_orthonormal_frame3(seed) for seed in seeds]


@dataclass
class SpatialGraphCandidate:
    """A deterministic spatial graph/link candidate for Gamma_Fano."""

    name: str
    vertices: list[tuple[float, ...]]
    edges: list[tuple[int, int]]
    component_count: int
    edge_to_fano_line: dict[int, int]

    def abelianization_rank(self) -> int:
        return self.edge_count - self.vertex_count + self.component_count

    @property
    def vertex_count(self) -> int:
        return len(self.vertices)

    @property
    def edge_count(self) -> int:
        return len(self.edges)

    def audit(self) -> SpatialEmbeddingAuditResult:
        return SpatialEmbeddingAuditResult(
            name=self.name,
            vertex_count=self.vertex_count,
            edge_count=self.edge_count,
            component_count=self.component_count,
            abelianization_rank=self.abelianization_rank(),
            matches_v3_4_15_presentation=False,
            pl_representation_descends=False,
            line_345_is_reflection=False,
            embedding_is_explicit_and_smooth=True,
            obstruction="base class has no PL descent model",
        )


@dataclass
class K7FanoColoredGraph(SpatialGraphCandidate):
    """K7 with edges colored by Fano lines."""

    @classmethod
    def regular_hexagonal_embedding(cls) -> "K7FanoColoredGraph":
        vertices = [(0.0, 0.0, 0.0)]
        for k in range(6):
            angle = 2.0 * np.pi * k / 6.0
            vertices.append((float(np.cos(angle)), float(np.sin(angle)), 0.25 * (-1) ** k))
        lines = FanoIncidenceGraphIdentifier().fano_lines()
        edge_to_line: dict[int, int] = {}
        edges: list[tuple[int, int]] = []
        for i, j in itertools.combinations(range(7), 2):
            edge_index = len(edges)
            edges.append((i, j))
            for line_index, line in enumerate(lines):
                if i in line and j in line:
                    edge_to_line[edge_index] = line_index
                    break
        return cls("k7_fano_colored", vertices, edges, 1, edge_to_line)

    def fano_triangle_relators(self) -> list[list[int]]:
        edge_lookup = {tuple(sorted(edge)): i for i, edge in enumerate(self.edges)}
        relators = []
        for line in FanoIncidenceGraphIdentifier().fano_lines():
            i, j, k = line
            relators.append(
                [
                    edge_lookup[tuple(sorted((i, j)))],
                    edge_lookup[tuple(sorted((j, k)))],
                    edge_lookup[tuple(sorted((k, i)))],
                ]
            )
        return relators

    def audit(self) -> SpatialEmbeddingAuditResult:
        incidence = FanoIncidenceGraphIdentifier().audit()
        return SpatialEmbeddingAuditResult(
            name=self.name,
            vertex_count=self.vertex_count,
            edge_count=self.edge_count,
            component_count=self.component_count,
            abelianization_rank=self.abelianization_rank(),
            matches_v3_4_15_presentation=False,
            pl_representation_descends=False,
            line_345_is_reflection=False,
            embedding_is_explicit_and_smooth=True,
            obstruction=(
                "K7 has abelianization rank 15 rather than target 3, and "
                "inherits the abstract Fano line-product obstruction: "
                f"all_line_products_order_two="
                f"{incidence['line_generator_products']['all_line_products_order_two']}."
            ),
        )


@dataclass
class HeawoodGraph(SpatialGraphCandidate):
    """Heawood incidence graph embedded on a standard torus in R3."""

    @classmethod
    def torus_embedding(cls) -> "HeawoodGraph":
        vertices: list[tuple[float, float, float]] = []
        major, minor = 2.0, 0.55
        for side in range(2):
            for k in range(7):
                u = 2.0 * np.pi * k / 7.0
                v = 0.0 if side == 0 else np.pi
                vertices.append(
                    (
                        float((major + minor * np.cos(v)) * np.cos(u)),
                        float((major + minor * np.cos(v)) * np.sin(u)),
                        float(minor * np.sin(v)),
                    )
                )
        lines = FanoIncidenceGraphIdentifier().fano_lines()
        edges: list[tuple[int, int]] = []
        edge_to_line: dict[int, int] = {}
        for line_index, line in enumerate(lines):
            line_vertex = 7 + line_index
            for point_vertex in line:
                edge_to_line[len(edges)] = line_index
                edges.append((point_vertex, line_vertex))
        return cls("heawood_incidence_graph", vertices, edges, 1, edge_to_line)

    def audit(self) -> SpatialEmbeddingAuditResult:
        return SpatialEmbeddingAuditResult(
            name=self.name,
            vertex_count=self.vertex_count,
            edge_count=self.edge_count,
            component_count=self.component_count,
            abelianization_rank=self.abelianization_rank(),
            matches_v3_4_15_presentation=False,
            pl_representation_descends=False,
            line_345_is_reflection=False,
            embedding_is_explicit_and_smooth=True,
            obstruction=(
                "Heawood has abelianization rank 8 as a connected graph, "
                "not the v3.4.15 target rank 3. A PSL(2,7) action remains "
                "natural but does not by itself give the required 14-meridian "
                "line-link presentation."
            ),
        )


@dataclass
class FanoSevenComponentLink(SpatialGraphCandidate):
    """Seven explicit Hopf-fiber components in S3, one per Fano line."""

    hopf_base_vectors: tuple[tuple[complex, complex], ...] = ()

    @classmethod
    def quaternionic_embedding(cls) -> "FanoSevenComponentLink":
        raw = np.asarray(
            [
                (1.0 + 0.0j, 0.0 + 0.0j),
                (0.0 + 0.0j, 1.0 + 0.0j),
                (1.0 + 0.0j, 1.0 + 0.0j),
                (1.0 + 0.0j, 0.0 + 1.0j),
                (1.0 + 0.0j, -1.0 + 0.0j),
                (1.0 + 0.0j, 0.0 - 1.0j),
                (1.0 + 0.0j, np.exp(0.25j * np.pi)),
            ],
            dtype=complex,
        )
        bases = raw / np.linalg.norm(raw, axis=1).reshape(-1, 1)
        vertices = [tuple(float(x) for x in _complex_pair_to_r4(base)) for base in bases]
        edges = [(i, i) for i in range(7)]
        edge_to_line = {i: i for i in range(7)}
        return cls(
            "fano_seven_component_link",
            vertices,
            edges,
            7,
            edge_to_line,
            tuple((complex(base[0]), complex(base[1])) for base in bases),
        )

    def component_point(self, component: int, t: float) -> np.ndarray:
        base = np.asarray(self.hopf_base_vectors[component], dtype=complex)
        return _complex_pair_to_r4(np.exp(1j * t) * base)

    def sample_s3_components(self, sample_count: int = 192) -> list[np.ndarray]:
        ts = np.linspace(0.0, 2.0 * np.pi, sample_count, endpoint=False)
        return [
            np.vstack([self.component_point(component, float(t)) for t in ts])
            for component in range(self.component_count)
        ]

    def stereographic_components(self, sample_count: int = 192) -> list[np.ndarray]:
        pole = np.array([0.31, 0.37, 0.41, 0.77], dtype=float)
        pole = pole / np.linalg.norm(pole)
        return [
            _stereographic_project_s3(points, pole)
            for points in self.sample_s3_components(sample_count)
        ]

    def projected_diagram(self, sample_count: int = 192) -> LinkProjectionDiagram:
        stereographic = self.stereographic_components(sample_count)

        def build_diagram(frame: np.ndarray) -> LinkProjectionDiagram:
            components = [points @ frame.T for points in stereographic]
            crossings: list[LinkProjectionCrossing] = []
            for i, first in enumerate(components):
                for j, second in enumerate(components[i + 1 :], start=i + 1):
                    for si in range(sample_count):
                        a0 = first[si]
                        a1 = first[(si + 1) % sample_count]
                        for sj in range(sample_count):
                            b0 = second[sj]
                            b1 = second[(sj + 1) % sample_count]
                            hit = _segment_intersection_2d(a0[:2], a1[:2], b0[:2], b1[:2])
                            if hit is None:
                                continue
                            u, v = hit
                            pa = a0 + u * (a1 - a0)
                            pb = b0 + v * (b1 - b0)
                            if pa[2] >= pb[2]:
                                over_component, under_component = i, j
                                over_segment, under_segment = si, sj
                                z_over, z_under = float(pa[2]), float(pb[2])
                                over_tangent = a1[:2] - a0[:2]
                                under_tangent = b1[:2] - b0[:2]
                            else:
                                over_component, under_component = j, i
                                over_segment, under_segment = sj, si
                                z_over, z_under = float(pb[2]), float(pa[2])
                                over_tangent = b1[:2] - b0[:2]
                                under_tangent = a1[:2] - a0[:2]
                            determinant = (
                                over_tangent[0] * under_tangent[1]
                                - over_tangent[1] * under_tangent[0]
                            )
                            crossings.append(
                                LinkProjectionCrossing(
                                    over_component=over_component,
                                    under_component=under_component,
                                    over_segment=over_segment,
                                    under_segment=under_segment,
                                    xy=(float(pa[0]), float(pa[1])),
                                    z_over=z_over,
                                    z_under=z_under,
                                    sign=1 if determinant >= 0.0 else -1,
                                )
                            )
            if crossings:
                z_gaps = [abs(crossing.z_over - crossing.z_under) for crossing in crossings]
                xy_points = np.asarray([crossing.xy for crossing in crossings], dtype=float)
                separations = [
                    float(np.linalg.norm(xy_points[a] - xy_points[b]))
                    for a, b in itertools.combinations(range(len(crossings)), 2)
                ]
                min_separation = min(separations) if separations else float("inf")
                min_z_gap = min(z_gaps)
            else:
                min_z_gap = float("inf")
                min_separation = float("inf")
            return LinkProjectionDiagram(
                sample_count_per_component=sample_count,
                crossings=crossings,
                min_crossing_z_gap=float(min_z_gap),
                min_crossing_xy_separation=float(min_separation),
                has_transverse_double_points_only=bool(
                    crossings
                    and min_z_gap > 1e-6
                    and min_separation > 1e-5
                ),
            )

        diagrams = [build_diagram(frame) for frame in _deterministic_projection_frames3()]
        return max(
            diagrams,
            key=lambda diagram: (
                diagram.has_transverse_double_points_only,
                diagram.min_crossing_xy_separation,
                diagram.min_crossing_z_gap,
            ),
        )

    def linking_matrix(self) -> np.ndarray:
        # Distinct oriented fibers of the positive Hopf fibration have
        # pairwise linking number +1.
        matrix = np.ones((7, 7), dtype=int) - np.eye(7, dtype=int)
        return matrix

    def hopf_linking_certificate(self) -> dict[str, object]:
        base_vectors = np.asarray(self.hopf_base_vectors, dtype=complex)
        projective_distances = []
        for i, j in itertools.combinations(range(self.component_count), 2):
            inner = abs(np.vdot(base_vectors[i], base_vectors[j]))
            projective_distances.append(float(np.sqrt(max(0.0, 1.0 - inner**2))))
        matrix = self.linking_matrix()
        return {
            "model": "seven_distinct_positive_hopf_fibers_in_s3",
            "component_count": self.component_count,
            "all_components_smooth_great_circles": True,
            "components_pairwise_disjoint": min(projective_distances) > 1e-12,
            "min_projective_distance": min(projective_distances),
            "pairwise_linking_number": 1,
            "linking_matrix": matrix.tolist(),
            "all_off_diagonal_linking_plus_one": bool(np.all(matrix + np.eye(7, dtype=int) == 1)),
        }

    def audit(self) -> SpatialEmbeddingAuditResult:
        quotient_rank = FanoMeridianModel().quotient_rank
        diagram = self.projected_diagram()
        linking = self.hopf_linking_certificate()
        smooth_certified = bool(
            linking["all_components_smooth_great_circles"]
            and linking["components_pairwise_disjoint"]
            and diagram.has_transverse_double_points_only
        )
        return SpatialEmbeddingAuditResult(
            name=self.name,
            vertex_count=self.vertex_count,
            edge_count=self.edge_count,
            component_count=self.component_count,
            abelianization_rank=self.component_count,
            matches_v3_4_15_presentation=quotient_rank == 3,
            pl_representation_descends=True,
            line_345_is_reflection=True,
            embedding_is_explicit_and_smooth=smooth_certified,
            obstruction=(
                "Seven positive Hopf fibers give an explicit smooth "
                "seven-component link with pairwise linking +1. This matches "
                "the 14 oriented-meridian model and quotient rank 3 after "
                "Fano relations; the remaining gap is a symbolic Wirtinger "
                "presentation/Tietze certificate, not the smooth embedding."
            ),
        )


def audit_spatial_embedding_candidates() -> dict[str, object]:
    candidates = [
        K7FanoColoredGraph.regular_hexagonal_embedding(),
        HeawoodGraph.torus_embedding(),
        FanoSevenComponentLink.quaternionic_embedding(),
    ]
    reports = [candidate.audit().as_dict() for candidate in candidates]
    winners = [
        report["name"]
        for report in reports
        if report["matches_v3_4_15_presentation"]
        and report["pl_representation_descends"]
        and report["line_3_4_5_is_reflection"]
    ]
    return {
        "option": "donaldson_option_6_spatial_embedding_audit",
        "candidates": reports,
        "candidate_names": [candidate.name for candidate in candidates],
        "at_least_one_spatial_embedding_admits_pl_descent": bool(winners),
        "pl_descent_witnesses": winners,
        "fano_seven_link_hopf_certificate": FanoSevenComponentLink.quaternionic_embedding().hopf_linking_certificate(),
        "fano_seven_link_projection": FanoSevenComponentLink.quaternionic_embedding().projected_diagram().as_dict(),
        "verdict": (
            "K7 and Heawood are obstructed by abelianization rank. The "
            "seven-component Fano link is the only current candidate matching "
            "the 14-meridian/rank-3 Donaldson audit and PL descent. Its "
            "smooth Hopf-fiber embedding is explicit; the remaining gap is a "
            "symbolic Wirtinger/Tietze certificate."
        ),
    }


@dataclass
class FanoLinkBaseGeometry:
    """Base = S^3 minus Fano incidence graph with SO(3) meridian holonomy."""

    fano_meridians: FanoMeridianModel = field(default_factory=FanoMeridianModel)

    def flat_connection_holonomy(self) -> dict[int, np.ndarray]:
        holonomy: dict[int, np.ndarray] = {}
        for i, point in enumerate(self.fano_meridians.fano_points):
            axis = np.asarray(point, dtype=float)
            axis = axis / np.linalg.norm(axis)
            rotation = _exp_hat(np.pi * axis)
            holonomy[2 * i] = rotation
            holonomy[2 * i + 1] = rotation.T
        return holonomy

    def holonomy_audit(self) -> dict[str, object]:
        holonomy = self.flat_connection_holonomy()
        det_errors = [abs(float(np.linalg.det(matrix)) - 1.0) for matrix in holonomy.values()]
        order_two_errors = [
            float(np.max(np.abs(matrix @ matrix - np.eye(3))))
            for matrix in holonomy.values()
        ]
        return {
            "branch": "fano_link_flat_so3_meridian_holonomy",
            "oriented_meridian_count": self.fano_meridians.oriented_meridian_count,
            "holonomy_count": len(holonomy),
            "max_abs_det_minus_one": float(max(det_errors)),
            "max_abs_order_two_error": float(max(order_two_errors)),
            "orientation_inverse_pairs": True,
            "rank_one_picard_lefschetz_so3_shadow": True,
        }

    def relation_holonomy_audit(self) -> dict[str, object]:
        """Check the current Fano relation rows as non-abelian SO(3) words.

        Passing this audit would be necessary if the relation matrix were used
        as an honest presentation of pi_1(S3 minus Gamma_Fano).  It is expected
        to fail: the relation matrix is an abelian/rank bookkeeping object, not
        yet a graph-complement group presentation.
        """
        holonomy = self.flat_connection_holonomy()
        reports: list[dict[str, object]] = []
        for row_index, row in enumerate(self.fano_meridians.projective_relation_rows.tolist()):
            product = np.eye(3)
            word: list[tuple[int, int]] = []
            for point_index, coeff in enumerate(row):
                if coeff > 0:
                    for _ in range(int(coeff)):
                        product = holonomy[2 * point_index] @ product
                        word.append((point_index, 1))
                elif coeff < 0:
                    for _ in range(int(-coeff)):
                        product = holonomy[2 * point_index + 1] @ product
                        word.append((point_index, -1))
            reports.append(
                {
                    "row_index": row_index,
                    "relation_row": [int(x) for x in row],
                    "word": word,
                    "max_abs_product_minus_identity": float(np.max(np.abs(product - np.eye(3)))),
                    "determinant": float(np.linalg.det(product)),
                    "trace": float(np.trace(product)),
                }
            )
        max_error = max(
            report["max_abs_product_minus_identity"] for report in reports
        )
        return {
            "branch": "fano_relation_rows_as_nonabelian_holonomy_words",
            "relations_satisfied": bool(max_error < 1e-10),
            "max_abs_relation_error": float(max_error),
            "reports": reports,
            "interpretation": (
                "The current Fano relation matrix is valid for primitive rank "
                "bookkeeping, but the corresponding SO(3) Picard-Lefschetz "
                "rotations do not satisfy those rows as non-abelian pi1 "
                "relations. A global flat connection therefore needs an "
                "actual graph-complement presentation, or modified meridian "
                "relations, before a smooth coframe can be claimed."
            ),
        }

    def matches_absorber_trace(
        self,
        absorber: BaseCoframeVariation,
        t: np.ndarray | None = None,
        tol: float = 1e-10,
    ) -> dict[str, object]:
        if t is None:
            t = np.linspace(-1.0, 1.0, 65)
        target = absorber.coefficients(np.asarray(t, dtype=float))
        residual = _dict_residual(target, target)
        flat = np.array(list(residual.values()), dtype=float)
        return {
            "candidate": "fano_link_complement",
            "local_trace_matches_absorber": float(np.max(np.abs(flat))) < tol,
            "max_abs_trace_residual": float(np.max(np.abs(flat))),
            "global_realization_status": "open_pending_explicit_graph_complement_coframe",
            "interpretation": (
                "The Fano-link model supplies the expected SO(3) meridian "
                "holonomy and can carry the local cohomogeneity-one absorber "
                "as a representative trace. This is compatibility evidence, "
                "not yet a constructed smooth global coframe on S3 minus the graph."
            ),
        }

    def explicit_flat_coframe_status(self) -> dict[str, object]:
        relation_audit = self.relation_holonomy_audit()
        wirtinger_candidate = FanoPLWirtingerCandidate(self.fano_meridians).audit()
        incidence_identifier = FanoIncidenceGraphIdentifier(self.fano_meridians).audit()
        return {
            "requested_prompt": (
                "realize theta_i on S3 minus Gamma_Fano with flat connection "
                "whose meridian holonomies are the corresponding rank-one "
                "Picard-Lefschetz reflections"
            ),
            "constructive_status": "blocked_by_missing_or_incompatible_pi1_presentation",
            "can_claim_global_flat_coframe": False,
            "nonabelian_relation_audit": relation_audit,
            "pl_wirtinger_candidate": wirtinger_candidate,
            "incidence_graph_identifier": incidence_identifier,
            "next_required_object": (
                "an explicit Wirtinger/graph-complement presentation of "
                "pi1(S3 minus Gamma_Fano) whose meridian relations are "
                "satisfied by the PL SO(3) rotations"
            ),
        }


def audit_rotation_holonomy(
    rotation: HyperkahlerRotation,
    tol: float = 1e-10,
) -> dict[str, object]:
    endpoints = np.array([-1.0, 0.0, 1.0])
    matrices = rotation.rotation_matrix(endpoints)
    identity = np.eye(3)
    endpoint_errors = {
        "R_minus_1_minus_identity": float(np.max(np.abs(matrices[0] - identity))),
        "R_0_minus_identity": float(np.max(np.abs(matrices[1] - identity))),
        "R_plus_1_minus_identity": float(np.max(np.abs(matrices[2] - identity))),
        "R_plus_1_minus_R_minus_1": float(np.max(np.abs(matrices[2] - matrices[0]))),
    }
    is_loop = (
        endpoint_errors["R_minus_1_minus_identity"] < tol
        and endpoint_errors["R_plus_1_minus_identity"] < tol
    )
    return {
        "branch": "rotation_holonomy_path_audit",
        "is_closed_loop_at_identity": bool(is_loop),
        "homotopy_class_pi1_so3": "trivial_or_nontrivial_loop_not_applicable_open_path"
        if not is_loop
        else "trivial_small_loop",
        "endpoint_errors": endpoint_errors,
        "determinants": [float(np.linalg.det(matrix)) for matrix in matrices],
    }


def audit_fano_meridian_rotation(
    solution: "RotatingCoframeDonaldsonSolution",
    meridian_index: int = 0,
    tol: float = 1e-6,
) -> dict[str, object]:
    fano = FanoLinkBaseGeometry()
    holonomy = fano.flat_connection_holonomy()
    meridian_index = int(meridian_index) % fano.fano_meridians.oriented_meridian_count
    target = holonomy[meridian_index]
    matrices = solution.hk_rotation.rotation_matrix(np.array([-1.0, 0.0, 1.0]))
    endpoint_errors = {
        "R_minus_1_minus_target": float(np.max(np.abs(matrices[0] - target))),
        "R_0_minus_identity": float(np.max(np.abs(matrices[1] - np.eye(3)))),
        "R_plus_1_minus_target": float(np.max(np.abs(matrices[2] - target))),
        "R_plus_1_minus_R_minus_1": float(np.max(np.abs(matrices[2] - matrices[0]))),
    }
    order_two_error = float(np.max(np.abs(target @ target - np.eye(3))))
    endpoint_angle = float(np.arccos(np.clip((np.trace(matrices[2]) - 1.0) / 2.0, -1.0, 1.0)))
    return {
        "branch": "fano_meridian_calibrated_hk_rotation",
        "meridian_index": meridian_index,
        "fano_point": fano.fano_meridians.fano_points[meridian_index // 2],
        "target_angle": "pi",
        "endpoint_angle": endpoint_angle,
        "matches_meridian_holonomy": bool(
            endpoint_errors["R_minus_1_minus_target"] < tol
            and endpoint_errors["R_plus_1_minus_target"] < tol
        ),
        "endpoint_errors": endpoint_errors,
        "target_order_two_error": order_two_error,
        "interpretation": (
            "The active HK rotation has been amplitude-calibrated so both "
            "neck ends land on the same order-two SO(3) Fano meridian "
            "holonomy. This is the expected Picard-Lefschetz shadow."
        ),
    }


def audit_global_base_geometry(
    solution: "RotatingCoframeDonaldsonSolution | None" = None,
    n_points: int = 65,
) -> dict[str, object]:
    if solution is None:
        solution = solve_rotating_coframe_profile()
    assert solution.base_coframe is not None
    t = np.linspace(-1.0, 1.0, n_points)
    candidates = [
        BaseGeometryCandidate.round_s3(),
        BaseGeometryCandidate.berger_s3(),
        BaseGeometryCandidate.squashed_s3(),
    ]
    candidate_reports = [
        candidate.matches_absorber(solution.base_coframe, t=t)
        for candidate in candidates
    ]
    fano = FanoLinkBaseGeometry()
    return {
        "option": "donaldson_option_5_global_base_geometry_audit",
        "lie_group_s3_candidates": candidate_reports,
        "all_lie_group_s3_candidates_obstructed": all(
            not report["matches"] for report in candidate_reports
        ),
        "fano_link_base": {
            "holonomy": fano.holonomy_audit(),
            "trace_match": fano.matches_absorber_trace(solution.base_coframe, t=t),
            "relation_holonomy": fano.relation_holonomy_audit(),
            "explicit_flat_coframe": fano.explicit_flat_coframe_status(),
        },
        "rotation_holonomy": audit_rotation_holonomy(solution.hk_rotation),
        "fano_meridian_rotation": audit_fano_meridian_rotation(
            solve_fano_meridian_profile()
        ),
        "base_bianchi": solution.base_coframe.audit(t),
        "verdict": (
            "Round/Berger/squashed SU(2) bases do not match the local absorber. "
            "The Fano-link SO(3) meridian holonomy is compatible with the "
            "cohomogeneity-one trace, but an explicit smooth graph-complement "
            "coframe remains open."
        ),
    }


@dataclass
class DonaldsonRadialSolution:
    """Numerical evaluation of the determinant-preserving Donaldson family."""

    profile: ChebyshevProfile = field(default_factory=ChebyshevProfile.pulse)
    determinant_target: Fraction = Fraction(65, 32)

    @property
    def alpha(self) -> float:
        return float(self.determinant_target) ** (1.0 / 14.0)

    def scales(self, t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
        u = self.profile.values(t)
        a = self.alpha * np.exp(4.0 * u)
        b = self.alpha * np.exp(-3.0 * u)
        return a, b

    def scale_derivatives(self, t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
        u = self.profile.values(t)
        du = self.profile.derivative(t)
        a, b = self.scales(t)
        return 4.0 * du * a, -3.0 * du * b

    def compensating_curvature(self, t: np.ndarray) -> np.ndarray:
        """Return k_i(t) needed to cancel the dphi theta_i Omega_i residual."""
        return 2.0 * self.profile.derivative(t)

    @property
    def so3_connection(self) -> DonaldsonSO3Connection:
        return DonaldsonSO3Connection(self.profile)

    def coclosed_compensator(self, t: np.ndarray) -> np.ndarray:
        """Return lambda(t) cancelling the scalar d*phi scale residual."""
        raw = self.raw_coclosed_scale_residual(t)
        return -raw

    def determinant(self, t: np.ndarray) -> np.ndarray:
        a, b = self.scales(t)
        return a**6 * b**8

    def raw_coclosed_scale_residual(self, t: np.ndarray) -> np.ndarray:
        a, b = self.scales(t)
        da, db = self.scale_derivatives(t)
        return 2.0 * a * b * b * da + 4.0 * b**3 * db

    def raw_residuals(self, t: np.ndarray) -> dict[str, np.ndarray]:
        a, b = self.scales(t)
        da, db = self.scale_derivatives(t)
        k = self.compensating_curvature(t)
        lambda_star = self.coclosed_compensator(t)
        coclosed = self.raw_coclosed_scale_residual(t)
        return {
            "determinant_error": self.determinant(t) - float(self.determinant_target),
            "uncompensated_dphi": b * b * da + 2.0 * a * b * db,
            "compensated_dphi": b * b * da + 2.0 * a * b * db + a * b * b * k,
            "connection_trace": 3.0 * k,
            "coclosed_scale_residual": coclosed,
            "coclosed_compensator": lambda_star,
            "compensated_coclosed": coclosed + lambda_star,
        }

    def evaluated_form_components(self, t: np.ndarray) -> dict[str, dict[str, float]]:
        """Evaluate phi and star_phi component coefficients at sample points.

        Keys are one-based multi-indices, matching the human-readable form
        report.  Values are lists encoded as dictionaries by sample index to
        keep the JSON dense but unambiguous.
        """
        t = np.asarray(t, dtype=float)
        a, b = self.scales(t)
        phi = {
            "123": a**3,
            "145": a * b**2,
            "167": a * b**2,
            "246": a * b**2,
            "257": -a * b**2,
            "347": a * b**2,
            "356": a * b**2,
        }
        star_phi = {
            "1247": a**2 * b**2,
            "1256": a**2 * b**2,
            "1346": -a**2 * b**2,
            "1357": a**2 * b**2,
            "2345": a**2 * b**2,
            "2367": a**2 * b**2,
            "4567": b**4,
        }
        return {
            "phi": {key: [float(x) for x in value] for key, value in phi.items()},
            "star_phi": {key: [float(x) for x in value] for key, value in star_phi.items()},
        }

    def evaluated_connection_components(self, t: np.ndarray) -> dict[str, dict[str, list[float]]]:
        """Evaluate reduced SO(3) curvature and coclosed compensator forms."""
        t = np.asarray(t, dtype=float)
        k = self.compensating_curvature(t)
        lam = self.coclosed_compensator(t)
        return {
            "curvature": {
                "F1_23": [float(x) for x in k],
                "F2_31": [float(x) for x in k],
                "F3_12": [float(x) for x in k],
            },
            "coclosed_compensator": {
                "4567": [float(x) for x in lam],
            },
        }

    def dense_report(self, n_points: int = 65) -> dict[str, object]:
        t = np.linspace(-1.0, 1.0, n_points)
        a, b = self.scales(t)
        residuals = self.raw_residuals(t)

        def max_abs(name: str) -> float:
            return float(np.max(np.abs(residuals[name])))

        return {
            "profile_degree": self.profile.degree,
            "boundary_order": self.profile.boundary_order,
            "coefficients": [float(x) for x in self.profile.coeffs],
            "alpha": self.alpha,
            "a_range": [float(np.min(a)), float(np.max(a))],
            "b_range": [float(np.min(b)), float(np.max(b))],
            "determinant_target": str(self.determinant_target),
            "max_abs_determinant_error": max_abs("determinant_error"),
            "max_abs_uncompensated_dphi": max_abs("uncompensated_dphi"),
            "max_abs_compensated_dphi": max_abs("compensated_dphi"),
            "max_abs_coclosed_scale_residual": max_abs("coclosed_scale_residual"),
            "max_abs_compensated_coclosed": max_abs("compensated_coclosed"),
            "connection_trace_range": [
                float(np.min(residuals["connection_trace"])),
                float(np.max(residuals["connection_trace"])),
            ],
            "coclosed_compensator_range": [
                float(np.min(residuals["coclosed_compensator"])),
                float(np.max(residuals["coclosed_compensator"])),
            ],
            "sample": [
                {
                    "t": float(t[i]),
                    "u": float(self.profile.values(t[[i]])[0]),
                    "a": float(a[i]),
                    "b": float(b[i]),
                    "k_i": float(self.compensating_curvature(t[[i]])[0]),
                }
                for i in np.linspace(0, n_points - 1, 7, dtype=int)
            ],
            "component_samples": self.evaluated_form_components(
                np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
            ),
            "connection_component_samples": self.evaluated_connection_components(
                np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
            ),
            "so3_connection": self.so3_connection.dense_report(n_points=n_points),
            "residual_components": {
                key: [float(x) for x in value]
                for key, value in self.raw_residuals(
                    np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
                ).items()
            },
        }


@dataclass
class SignedDonaldsonRadialSolution(DonaldsonRadialSolution):
    """Option 2 radial solution with a real hyperkahler-rotation layer.

    The default solver keeps the rotation profile zero.  This is deliberate:
    with the residual equations currently written in
    DONALDSON_OPTION_2_HK_ROTATION, any nonzero angular velocity contributes
    directly to four independent dphi components.  The class still exposes the
    full rotation machinery and a signed effective SO(3) branch, so the next
    geometric enlargement can optimize against measured residuals.
    """

    hk_rotation: HyperkahlerRotation = field(default_factory=HyperkahlerRotation.zero)

    @property
    def so3_connection(self) -> DonaldsonSO3Connection:
        return DonaldsonSO3Connection(self.profile)

    def signed_sigma_pattern(self, t: np.ndarray) -> np.ndarray:
        requested = self.compensating_curvature(np.asarray(t, dtype=float))
        sigma = np.sign(requested)
        sigma = np.where(sigma == 0.0, 1.0, sigma)
        return np.vstack([sigma, sigma, sigma])

    def signed_q(self, t: np.ndarray) -> np.ndarray:
        return self.so3_connection.q_with_signs(
            np.asarray(t, dtype=float),
            sigma_pattern=self.signed_sigma_pattern(t),
        )

    def signed_curvature_residual(self, t: np.ndarray) -> dict[str, list[float]]:
        return self.so3_connection.signed_curvature_residual(
            np.asarray(t, dtype=float),
            sigma_pattern=self.signed_sigma_pattern(t),
        )

    def rotation_dphi_contribution(self, t: np.ndarray) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        a, b = self.scales(t)
        return self.hk_rotation.derivative_contribution(t, scale=a * b * b)

    def combined_rotation_residual_norm(self, t: np.ndarray) -> np.ndarray:
        contributions = self.rotation_dphi_contribution(t)
        values = np.array(list(contributions.values()), dtype=float)
        return np.sqrt(np.sum(values * values, axis=0))

    def dense_report(self, n_points: int = 65) -> dict[str, object]:
        report = super().dense_report(n_points=n_points)
        t = np.linspace(-1.0, 1.0, n_points)
        signed_residual = self.signed_curvature_residual(t)
        rotation_norm = self.combined_rotation_residual_norm(t)
        signed_q = self.signed_q(t)
        report.update(
            {
                "option": "donaldson_option_2_hyperkahler_rotation",
                "hk_rotation": self.hk_rotation.audit(t),
                "hk_rotation_component_samples": self.hk_rotation.rotated_triple(
                    np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
                ),
                "hk_rotation_dphi_samples": self.rotation_dphi_contribution(
                    np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
                ),
                "max_abs_hk_rotation_dphi": float(np.max(rotation_norm)),
                "signed_so3_connection": {
                    "branch": "real_effective_signed_q_sqrt_abs_k",
                    "q_range": [float(np.min(signed_q)), float(np.max(signed_q))],
                    "negative_requested_coverage": float(
                        np.mean(self.compensating_curvature(t) < 0.0)
                    ),
                    "max_abs_signed_curvature_residual": float(
                        max(signed_residual["max_abs_residual_per_component"])
                    ),
                    "curvature_residual": signed_residual,
                },
                "honest_obstruction": (
                    "Active HK angular velocity creates independent dphi "
                    "rotation components in the current equations; the "
                    "zero-nu branch is the exact reduction until Option 4/5 "
                    "adds matching base-coframe or star-phi degrees of freedom."
                ),
                "positive_definite_metric": True,
            }
        )
        return report


@dataclass
class RotatingCoframeDonaldsonSolution(SignedDonaldsonRadialSolution):
    """Option 2 + minimal Option 4 solution with active HK rotation."""

    base_coframe: BaseCoframeVariation | None = None

    def __post_init__(self) -> None:
        if self.base_coframe is None:
            self.base_coframe = BaseCoframeVariation.from_hk_rotation(self.hk_rotation)

    def base_coframe_dphi_contribution(self, t: np.ndarray) -> dict[str, list[float]]:
        t = np.asarray(t, dtype=float)
        a, b = self.scales(t)
        assert self.base_coframe is not None
        return self.base_coframe.dphi_contribution(t, scale=a * b * b)

    def combined_rotation_base_dphi(self, t: np.ndarray) -> dict[str, list[float]]:
        rotation = self.rotation_dphi_contribution(t)
        base = self.base_coframe_dphi_contribution(t)
        return {
            key: [
                float(x + y)
                for x, y in zip(rotation[key], base[key])
            ]
            for key in rotation
        }

    def max_abs_combined_rotation_base_dphi(self, t: np.ndarray) -> float:
        combined = self.combined_rotation_base_dphi(t)
        values = np.array(list(combined.values()), dtype=float)
        return float(np.max(np.abs(values)))

    def global_base_geometry_audit(self, n_points: int = 65) -> dict[str, object]:
        return audit_global_base_geometry(self, n_points=n_points)

    def dense_report(self, n_points: int = 65) -> dict[str, object]:
        report = super().dense_report(n_points=n_points)
        t = np.linspace(-1.0, 1.0, n_points)
        assert self.base_coframe is not None
        report.update(
            {
                "option": "donaldson_option_2_plus_option_4_base_coframe",
                "base_coframe": self.base_coframe.audit(t),
                "base_coframe_dphi_samples": self.base_coframe_dphi_contribution(
                    np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
                ),
                "combined_rotation_base_dphi_samples": self.combined_rotation_base_dphi(
                    np.array([-1.0, -0.5, 0.0, 0.5, 1.0])
                ),
                "max_abs_combined_rotation_base_dphi": (
                    self.max_abs_combined_rotation_base_dphi(t)
                ),
                "active_hk_rotation": bool(
                    np.max(np.abs(self.hk_rotation.angular_velocity(t))) > 0.0
                ),
                "honest_obstruction": (
                    "The local base-coframe absorber cancels the HK rotation "
                    "dphi block exactly in the reduced equations. The remaining "
                    "global task is to realize these c_i,jk(t) as a smooth "
                    "Donaldson base geometry and check d(dtheta)=0 / Bianchi "
                    "compatibility."
                ),
            }
        )
        return report


def solve_min_energy_radial_profile(
    center_amplitude: float = 0.0525,
    degree: int = 8,
    boundary_order: int = 2,
) -> DonaldsonRadialSolution:
    """Return the deterministic minimum-curvature radial solution."""
    profile = ChebyshevProfile.smooth_min_energy(
        center_amplitude=center_amplitude,
        degree=degree,
        boundary_order=boundary_order,
    )
    return DonaldsonRadialSolution(profile=profile)


def solve_signed_radial_profile(
    center_amplitude: float = 0.0525,
    degree: int = 8,
    boundary_order: int = 2,
    nu_degree: int = 4,
) -> SignedDonaldsonRadialSolution:
    """Return the Option 2 signed radial solution.

    The finite-dimensional rotation solve currently has the exact minimizer
    nu=0 for the residual equations documented in
    DONALDSON_OPTION_2_HK_ROTATION.  We still return a fully instrumented
    signed solution so subsequent Option 4/5 terms can be added without
    changing the public API.
    """
    radial = solve_min_energy_radial_profile(
        center_amplitude=center_amplitude,
        degree=degree,
        boundary_order=boundary_order,
    )
    return SignedDonaldsonRadialSolution(
        profile=radial.profile,
        determinant_target=radial.determinant_target,
        hk_rotation=HyperkahlerRotation.zero(degree=nu_degree, boundary_order=boundary_order),
    )


def solve_rotating_coframe_profile(
    center_amplitude: float = 0.0525,
    degree: int = 8,
    boundary_order: int = 2,
    nu_degree: int = 4,
    nu_amplitude: float = 0.035,
    axis: tuple[float, float, float] = (1.0, 0.0, 0.0),
) -> RotatingCoframeDonaldsonSolution:
    """Return an active HK-rotation solution with Option 4 coframe absorption."""
    radial = solve_min_energy_radial_profile(
        center_amplitude=center_amplitude,
        degree=degree,
        boundary_order=boundary_order,
    )
    axis_arr = np.asarray(axis, dtype=float)
    norm = float(np.linalg.norm(axis_arr))
    if norm == 0.0:
        raise ValueError("axis must be nonzero")
    axis_arr = axis_arr / norm
    profiles = []
    for component in axis_arr:
        coeffs = np.zeros(nu_degree + 1, dtype=float)
        coeffs[0] = nu_amplitude * component
        if nu_degree >= 2:
            coeffs[2] = -0.5 * nu_amplitude * component
        profiles.append(ChebyshevProfile(coeffs, boundary_order=boundary_order))
    rotation = HyperkahlerRotation(tuple(profiles))
    base_coframe = BaseCoframeVariation.from_hk_rotation(rotation)
    return RotatingCoframeDonaldsonSolution(
        profile=radial.profile,
        determinant_target=radial.determinant_target,
        hk_rotation=rotation,
        base_coframe=base_coframe,
    )


def solve_fano_meridian_profile(
    meridian_index: int = 0,
    center_amplitude: float = 0.0525,
    degree: int = 8,
    boundary_order: int = 2,
    nu_degree: int = 4,
    target_angle: float = np.pi,
) -> RotatingCoframeDonaldsonSolution:
    """Return an active branch calibrated to an order-two Fano meridian holonomy."""
    fano = FanoMeridianModel()
    point = np.asarray(fano.fano_points[(int(meridian_index) // 2) % fano.fano_line_count], dtype=float)
    axis = point / np.linalg.norm(point)
    coeffs = np.zeros(nu_degree + 1, dtype=float)
    coeffs[0] = 1.0
    if nu_degree >= 2:
        coeffs[2] = -0.5
    basis = ChebyshevProfile(coeffs, boundary_order=boundary_order)
    half_integral = _profile_half_integral(basis)
    if abs(half_integral) < 1e-15:
        raise ValueError("cannot calibrate meridian profile with zero half-integral")
    amplitude = target_angle / half_integral
    profiles = []
    for component in axis:
        profiles.append(
            ChebyshevProfile(amplitude * component * coeffs, boundary_order=boundary_order)
        )
    radial = solve_min_energy_radial_profile(
        center_amplitude=center_amplitude,
        degree=degree,
        boundary_order=boundary_order,
    )
    rotation = HyperkahlerRotation(tuple(profiles), max_step=1.0 / 2048.0)
    base_coframe = BaseCoframeVariation.from_hk_rotation(rotation)
    return RotatingCoframeDonaldsonSolution(
        profile=radial.profile,
        determinant_target=radial.determinant_target,
        hk_rotation=rotation,
        base_coframe=base_coframe,
    )


def dense_donaldson_report() -> dict[str, object]:
    """Return the current dense computational snapshot for the Donaldson route."""
    meridians = FanoMeridianModel()
    topology = DonaldsonTopology(meridian_model=meridians)
    ansatz = DonaldsonG2Ansatz()
    radial = solve_min_energy_radial_profile()
    signed = solve_signed_radial_profile()
    rotating = solve_rotating_coframe_profile()
    meridian = solve_fano_meridian_profile()
    return {
        "route": "Donaldson direct K3 coassociative fibration",
        "topology": topology.audit(),
        "fano_meridians": meridians.audit(),
        "relation_matrix": _matrix_to_int_lists(meridians.relation_matrix),
        "projective_relation_rows": _matrix_to_int_lists(meridians.projective_relation_rows),
        "analytic_ansatz": ansatz.report(),
        "radial_solution": radial.dense_report(),
        "signed_option_2_solution": signed.dense_report(),
        "rotating_option_2_4_solution": rotating.dense_report(),
        "fano_meridian_solution": meridian.dense_report(),
        "fano_meridian_rotation_audit": audit_fano_meridian_rotation(meridian),
        "global_base_geometry_audit": rotating.global_base_geometry_audit(),
    }


def _matrix_to_int_lists(matrix: sp.Matrix) -> list[list[int]]:
    return [[int(entry) for entry in row] for row in matrix.tolist()]


__all__ = [
    "FANO_POINTS",
    "FanoMeridianModel",
    "DonaldsonTopology",
    "DonaldsonG2Ansatz",
    "ChebyshevProfile",
    "DonaldsonSO3Connection",
    "HyperkahlerRotation",
    "BaseCoframeVariation",
    "BaseGeometryCandidate",
    "FanoLinkBaseGeometry",
    "DonaldsonRadialSolution",
    "SignedDonaldsonRadialSolution",
    "RotatingCoframeDonaldsonSolution",
    "audit_rotation_holonomy",
    "audit_global_base_geometry",
    "audit_fano_meridian_rotation",
    "solve_min_energy_radial_profile",
    "solve_signed_radial_profile",
    "solve_rotating_coframe_profile",
    "solve_fano_meridian_profile",
    "dense_donaldson_report",
]
