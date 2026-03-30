#!/usr/bin/env bash
# check_blueprint_sync.sh — Verify blueprint stays in sync with Lean codebase
#
# Checks:
#   1. Every \lean{} declaration in content.tex appears in lean_decls
#   2. Every declaration in lean_decls appears in content.tex
#   3. Every declaration in lean_decls exists in the Lean codebase
#
# Exit code: 0 if clean, 1 if any mismatches found.

set -euo pipefail

# Resolve repo root (script lives in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONTENT_TEX="$REPO_ROOT/blueprint/src/content.tex"
LEAN_DECLS="$REPO_ROOT/blueprint/lean_decls"
LEAN_DIR="$REPO_ROOT/GIFT"

ERRORS=0

# ---------------------------------------------------------------------------
# Sanity: required files exist
# ---------------------------------------------------------------------------
for f in "$CONTENT_TEX" "$LEAN_DECLS"; do
    if [[ ! -f "$f" ]]; then
        echo "ERROR: Required file not found: $f"
        exit 1
    fi
done

if [[ ! -d "$LEAN_DIR" ]]; then
    echo "ERROR: Lean source directory not found: $LEAN_DIR"
    exit 1
fi

# ---------------------------------------------------------------------------
# Step 1: Extract \lean{...} declarations from content.tex
#   Handles tags that might span multiple lines by collapsing continuations.
# ---------------------------------------------------------------------------
echo "=== Blueprint Sync Check ==="
echo ""
echo "--- Step 1: Extracting \\lean{} declarations from content.tex ---"

# Use perl to handle potential multi-line \lean{...} (collapse lines, then extract)
TEX_DECLS=$(perl -0777 -ne '
    # Collapse newlines inside \lean{...} so multi-line tags become single-line
    while (/\\lean\{([^}]+)\}/g) {
        my $decl = $1;
        $decl =~ s/\s+//g;   # strip any whitespace from multi-line
        print "$decl\n";
    }
' "$CONTENT_TEX" | sort -u)

TEX_COUNT=$(echo "$TEX_DECLS" | wc -l)
echo "  Found $TEX_COUNT unique declarations in content.tex"

# ---------------------------------------------------------------------------
# Step 2: Extract declarations from lean_decls
# ---------------------------------------------------------------------------
echo ""
echo "--- Step 2: Extracting declarations from lean_decls ---"

# Remove blank lines, sort, deduplicate
DECL_LIST=$(grep -v '^\s*$' "$LEAN_DECLS" | sed 's/[[:space:]]*$//' | sort -u)

DECL_COUNT=$(echo "$DECL_LIST" | wc -l)
echo "  Found $DECL_COUNT unique declarations in lean_decls"

# ---------------------------------------------------------------------------
# Step 3: Cross-check content.tex vs lean_decls
# ---------------------------------------------------------------------------
echo ""
echo "--- Step 3: Cross-checking content.tex <-> lean_decls ---"

# Declarations in content.tex but not in lean_decls
MISSING_FROM_DECLS=$(comm -23 <(echo "$TEX_DECLS") <(echo "$DECL_LIST") || true)
if [[ -n "$MISSING_FROM_DECLS" ]]; then
    COUNT=$(echo "$MISSING_FROM_DECLS" | wc -l)
    echo ""
    echo "  ERROR: $COUNT declaration(s) in content.tex but NOT in lean_decls:"
    echo "$MISSING_FROM_DECLS" | sed 's/^/    - /'
    ERRORS=$((ERRORS + COUNT))
else
    echo "  OK: All content.tex declarations found in lean_decls"
fi

# Declarations in lean_decls but not in content.tex
MISSING_FROM_TEX=$(comm -13 <(echo "$TEX_DECLS") <(echo "$DECL_LIST") || true)
if [[ -n "$MISSING_FROM_TEX" ]]; then
    COUNT=$(echo "$MISSING_FROM_TEX" | wc -l)
    echo ""
    echo "  ERROR: $COUNT declaration(s) in lean_decls but NOT in content.tex:"
    echo "$MISSING_FROM_TEX" | sed 's/^/    - /'
    ERRORS=$((ERRORS + COUNT))
else
    echo "  OK: All lean_decls declarations found in content.tex"
fi

# ---------------------------------------------------------------------------
# Step 4: Verify each lean_decls entry exists in the Lean codebase
# ---------------------------------------------------------------------------
echo ""
echo "--- Step 4: Verifying lean_decls entries exist in Lean codebase ---"

MISSING_LEAN=()

while IFS= read -r decl; do
    [[ -z "$decl" ]] && continue

    # Extract short name (last component after final dot)
    short_name="${decl##*.}"

    # Search for the short name as a declaration in any .lean file under GIFT/
    # Match common Lean declaration keywords followed by the short name
    if ! grep -rqE "(def|theorem|lemma|axiom|structure|class|instance|abbrev|noncomputable def|noncomputable instance)\s+${short_name}\b" "$LEAN_DIR" --include='*.lean'; then
        MISSING_LEAN+=("$decl")
    fi
done <<< "$DECL_LIST"

if [[ ${#MISSING_LEAN[@]} -gt 0 ]]; then
    echo ""
    echo "  ERROR: ${#MISSING_LEAN[@]} declaration(s) in lean_decls not found in GIFT/**/*.lean:"
    for d in "${MISSING_LEAN[@]}"; do
        echo "    - $d"
    done
    ERRORS=$((ERRORS + ${#MISSING_LEAN[@]}))
else
    echo "  OK: All lean_decls declarations found in Lean codebase"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Summary ==="
echo "  content.tex declarations:  $TEX_COUNT"
echo "  lean_decls declarations:   $DECL_COUNT"
echo "  Errors found:              $ERRORS"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo "FAILED: $ERRORS sync issue(s) detected."
    exit 1
else
    echo "PASSED: Blueprint is in sync with Lean codebase."
    exit 0
fi
