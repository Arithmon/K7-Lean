"""Print the current dense Donaldson-direct G2 ansatz report."""

from __future__ import annotations

import json
import argparse

from gift_core.geometry.donaldson import (
    FanoPLWirtingerCandidate,
    FanoIncidenceGraphIdentifier,
    audit_fano_meridian_rotation,
    audit_global_base_geometry,
    dense_donaldson_report,
    solve_fano_meridian_profile,
    solve_min_energy_radial_profile,
    solve_rotating_coframe_profile,
    solve_signed_radial_profile,
)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--solve", action="store_true", help="print only the solved radial profile report")
    parser.add_argument("--amplitude", type=float, default=0.0525)
    parser.add_argument("--degree", type=int, default=8)
    parser.add_argument("--boundary-order", type=int, default=2)
    parser.add_argument("--hk-rotation", action="store_true", help="enable the Option 2 signed HK-rotation report")
    parser.add_argument("--base-coframe", action="store_true", help="enable active HK rotation with the Option 4 base-coframe absorber")
    parser.add_argument("--audit-base-geometry", action="store_true", help="audit Option 5 global base geometry candidates")
    parser.add_argument("--realize-fano-coframe", action="store_true", help="audit the explicit flat Fano coframe realization prompt")
    parser.add_argument("--pl-wirtinger", action="store_true", help="print the PL-compatible non-abelian Fano Wirtinger candidate")
    parser.add_argument("--identify-fano-incidence", action="store_true", help="audit the abstract Fano incidence graph relators")
    parser.add_argument("--fano-meridian", action="store_true", help="calibrate active HK rotation to a Fano SO(3) meridian holonomy")
    parser.add_argument("--meridian-index", type=int, default=0)
    parser.add_argument("--nu-degree", type=int, default=4)
    parser.add_argument("--nu-amplitude", type=float, default=0.035)
    args = parser.parse_args()

    if args.identify_fano_incidence:
        payload = FanoIncidenceGraphIdentifier().audit()
    elif args.pl_wirtinger:
        payload = FanoPLWirtingerCandidate().audit()
    elif args.realize_fano_coframe:
        payload = audit_global_base_geometry()["fano_link_base"]["explicit_flat_coframe"]
    elif args.fano_meridian:
        solution = solve_fano_meridian_profile(
            meridian_index=args.meridian_index,
            center_amplitude=args.amplitude,
            degree=args.degree,
            boundary_order=args.boundary_order,
            nu_degree=args.nu_degree,
        )
        payload = {
            "solution": solution.dense_report(),
            "fano_meridian_rotation": audit_fano_meridian_rotation(
                solution,
                meridian_index=args.meridian_index,
            ),
        }
    elif args.audit_base_geometry:
        solution = solve_rotating_coframe_profile(
            center_amplitude=args.amplitude,
            degree=args.degree,
            boundary_order=args.boundary_order,
            nu_degree=args.nu_degree,
            nu_amplitude=args.nu_amplitude,
        )
        payload = audit_global_base_geometry(solution)
    elif args.base_coframe:
        solution = solve_rotating_coframe_profile(
            center_amplitude=args.amplitude,
            degree=args.degree,
            boundary_order=args.boundary_order,
            nu_degree=args.nu_degree,
            nu_amplitude=args.nu_amplitude,
        )
        payload = solution.dense_report()
    elif args.hk_rotation:
        solution = solve_signed_radial_profile(
            center_amplitude=args.amplitude,
            degree=args.degree,
            boundary_order=args.boundary_order,
            nu_degree=args.nu_degree,
        )
        payload = solution.dense_report()
    elif args.solve:
        solution = solve_min_energy_radial_profile(
            center_amplitude=args.amplitude,
            degree=args.degree,
            boundary_order=args.boundary_order,
        )
        payload = solution.dense_report()
    else:
        payload = dense_donaldson_report()

    print(json.dumps(payload, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
