#!/usr/bin/env bash
# Local CI runner for the GIFT core repo.
# Mirrors the GitHub Actions workflows so you can catch issues BEFORE pushing.
#
# Usage:
#   ./scripts/local_ci.sh                  # safe defaults: consistency + sorry + axioms + blueprint refs
#   ./scripts/local_ci.sh --with-build     # ALSO run `lake build` (slow, can stress laptop)
#   ./scripts/local_ci.sh consistency      # only the version/axiom consistency check
#   ./scripts/local_ci.sh sorry            # only the zero-sorry check
#   ./scripts/local_ci.sh axioms           # only the axiom-count check
#   ./scripts/local_ci.sh blueprint        # only the blueprint dead-namespace sync check
#   ./scripts/local_ci.sh build            # only `lake build` (this is the heavy one)
#   ./scripts/local_ci.sh all              # everything including build
#
# Exit code 0 = all selected checks pass, non-zero = at least one failed.
#
# Notes:
# - The GitHub Actions verify.yml runs `lake build` on a clean Ubuntu runner.
#   On a 12-core consumer laptop with other things running, lake build can
#   spike RAM and freeze the system (we've seen it). So `build` is OPT-IN
#   here, not part of the default run.
# - The blueprint full build (Jekyll + leanblueprint) is NOT mirrored locally
#   because it takes ~10 min and needs Ruby + bundle. We only check that the
#   blueprint .tex doesn't reference dead namespaces (matching what
#   check_blueprint_sync.sh does).

set -e
cd "$(dirname "$0")/.."

ROOT="$(pwd)"
FAIL=0
WITH_BUILD=0
TARGET="default"

# Parse args
for arg in "$@"; do
    case "$arg" in
        --with-build) WITH_BUILD=1 ;;
        consistency|sorry|axioms|blueprint|build|all|default) TARGET="$arg" ;;
        -h|--help)
            head -28 "$0"
            exit 0
            ;;
    esac
done

green() { printf '\033[32m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*"; }
blue()  { printf '\033[34m%s\033[0m\n' "$*"; }
yellow(){ printf '\033[33m%s\033[0m\n' "$*"; }

run_check() {
    local name="$1"
    shift
    blue ""
    blue "============================================================"
    blue " $name"
    blue "============================================================"
    if "$@"; then
        green "  ✓ $name PASSED"
    else
        red "  ✗ $name FAILED"
        FAIL=1
    fi
}

# ----------------------------------------------------------------------
# 1. Version consistency (README ↔ _version.py ↔ contrib/docs)
#    Mirrors verify-consistency.yml step "Check version consistency"
# ----------------------------------------------------------------------
consistency_check() {
    local VERSION
    VERSION=$(python3 -c "exec(open('contrib/python/gift_core/_version.py').read()); print(__version__)")
    echo "  Python _version.py: $VERSION"

    local ERRORS=0

    if ! grep -q "K₇-Lean v${VERSION}" README.md; then
        red "  ✗ README.md does NOT contain 'K₇-Lean v${VERSION}'"
        ERRORS=$((ERRORS+1))
    else
        echo "  ✓ README.md mentions v${VERSION}"
    fi

    for f in contrib/docs/index.md; do
        if [ ! -f "$f" ]; then
            yellow "  ⚠ ${f} missing — skipped"
            continue
        fi
        if ! grep -q "v${VERSION}" "$f"; then
            red "  ✗ ${f} does NOT mention v${VERSION}"
            ERRORS=$((ERRORS+1))
        else
            echo "  ✓ ${f} mentions v${VERSION}"
        fi
    done

    if [ $ERRORS -gt 0 ]; then
        red "  → ${ERRORS} mismatch(es). Fix: ./scripts/release.sh ${VERSION}"
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------
# 2. Zero sorry in Lean files
#    Mirrors verify-consistency.yml step "Check no sorry in Lean files"
# ----------------------------------------------------------------------
sorry_check() {
    python3 scripts/proof_inventory.py --check
}

# ----------------------------------------------------------------------
# 3. Axiom count consistency (grep matches README)
#    Mirrors verify-consistency.yml step "Check axiom count"
# ----------------------------------------------------------------------
axioms_check() {
    local ACTUAL
    ACTUAL=$(grep -rc "^axiom " GIFT/ --include="*.lean" | awk -F: '{s+=$2}END{print s}')
    local README_COUNT
    README_COUNT=$(grep -oP '\d+ axioms' README.md | head -1 | grep -oP '\d+')

    echo "  grep -r '^axiom ' → $ACTUAL"
    echo "  README claims    → $README_COUNT"
    if [ "$ACTUAL" != "$README_COUNT" ]; then
        red "  ✗ Mismatch (in CI this is a warning, but you should fix it)"
        return 1
    fi
    echo "  ✓ Axiom counts match"
    return 0
}

# ----------------------------------------------------------------------
# 4. Blueprint sync (no dead namespace refs)
#    Reuses the existing check_blueprint_sync.sh
# ----------------------------------------------------------------------
blueprint_check() {
    if [ -x ./scripts/check_blueprint_sync.sh ]; then
        ./scripts/check_blueprint_sync.sh
    else
        yellow "  ⚠ scripts/check_blueprint_sync.sh missing or not executable — skipped"
    fi
    return 0
}

# ----------------------------------------------------------------------
# 5. Lake build — the heavy one. Opt-in via --with-build or `build`/`all`.
#    Mirrors verify.yml main step.
# ----------------------------------------------------------------------
lake_build_check() {
    yellow "  ⚠ Running 'lake build'. This can take several minutes and"
    yellow "    may stress your laptop. Press Ctrl+C now to abort."
    lake build && lake build Verification
    return $?
}

# Dispatch
case "$TARGET" in
    default)
        run_check "Version Consistency" consistency_check
        run_check "Zero Sorry"          sorry_check
        run_check "Axiom Count"         axioms_check
        run_check "Blueprint Sync"      blueprint_check
        if [ "$WITH_BUILD" -eq 1 ]; then
            run_check "Lake Build"      lake_build_check
        else
            yellow ""
            yellow "  ℹ  'lake build' was NOT run (opt-in via --with-build or 'build')"
        fi
        ;;
    all)
        run_check "Version Consistency" consistency_check
        run_check "Zero Sorry"          sorry_check
        run_check "Axiom Count"         axioms_check
        run_check "Blueprint Sync"      blueprint_check
        run_check "Lake Build"          lake_build_check
        ;;
    consistency) run_check "Version Consistency" consistency_check ;;
    sorry)       run_check "Zero Sorry"          sorry_check ;;
    axioms)      run_check "Axiom Count"         axioms_check ;;
    blueprint)   run_check "Blueprint Sync"      blueprint_check ;;
    build)       run_check "Lake Build"          lake_build_check ;;
esac

echo ""
if [ $FAIL -eq 0 ]; then
    green "============================================================"
    green " ✅  All selected local CI checks passed. Safe to push."
    green "============================================================"
    exit 0
else
    red "============================================================"
    red " ❌  Local CI failed. Fix issues before pushing."
    red "============================================================"
    exit 1
fi
