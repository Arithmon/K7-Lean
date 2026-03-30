#!/bin/bash
# GIFT Core release script — updates version across all files
# Usage: ./scripts/release.sh 3.4.5
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version> (e.g., 3.4.5)"
  exit 1
fi

VERSION="$1"
DATE=$(date +%Y-%m-%d)

echo "=== GIFT Core Release v${VERSION} (${DATE}) ==="

# 1. Python version
sed -i "s/__version__ = \".*\"/__version__ = \"${VERSION}\"/" \
  contrib/python/gift_core/_version.py
echo "  ✓ _version.py"

# 2. README version
sed -i "s/GIFT Core v[0-9]\+\.[0-9]\+\.[0-9]\+/GIFT Core v${VERSION}/g" README.md
echo "  ✓ README.md"

# 3. contrib docs
sed -i "s/GIFT Core v[0-9]\+\.[0-9]\+\.[0-9]\+/GIFT Core v${VERSION}/g" \
  contrib/docs/index.md
sed -i "s/^.*Version.*: [0-9]\+\.[0-9]\+\.[0-9]\+/**Version**: ${VERSION}/" \
  contrib/docs/GIFT_STATUS.md
sed -i "s/^.*Date.*: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/**Date**: ${DATE}/" \
  contrib/docs/GIFT_STATUS.md
sed -i "s/giftpy.*Python package (v[0-9.]*)/giftpy\` Python package (v${VERSION})/" \
  contrib/docs/USAGE.md
echo "  ✓ contrib/docs/"

# 4. Python package docstrings
sed -i "s/v[0-9]\+\.[0-9]\+\.[0-9]\+ Features/v${VERSION} Features/" \
  contrib/python/gift_core/__init__.py
sed -i "s/GIFT Constants Package (v[0-9.]*)/GIFT Constants Package (v${VERSION})/" \
  contrib/python/gift_core/constants/__init__.py
echo "  ✓ contrib/python/"

# 5. Axiom count check
AXIOM_COUNT=$(grep -c "^axiom " GIFT/Spectral/*.lean GIFT/Algebraic/*.lean GIFT/Foundations/Analysis/*.lean 2>/dev/null || echo 0)
echo ""
echo "=== Sanity checks ==="
echo "  Axiom count (grep): ${AXIOM_COUNT}"
echo "  README says: $(grep -o '[0-9]* axioms' README.md | head -1)"

# 6. Check for dead namespace references in blueprint
DEAD_REFS=""
for ns in GIFT.Moonshine GIFT.MollifiedSum GIFT.YangMillsBridge; do
  if grep -q "$ns" blueprint/src/content.tex 2>/dev/null; then
    DEAD_REFS="${DEAD_REFS} ${ns}"
  fi
done
if [ -n "$DEAD_REFS" ]; then
  echo "  ⚠ Dead namespace refs in blueprint:${DEAD_REFS}"
else
  echo "  ✓ No dead namespace refs in blueprint"
fi

echo ""
echo "=== Done. Now: ==="
echo "  1. Write CHANGELOG entry in contrib/CHANGELOG.md"
echo "  2. git add -A && git commit -m 'release: v${VERSION} — ...'"
echo "  3. git tag v${VERSION} && git push origin main --tags"
echo "  4. Create GitHub Release from tag (triggers PyPI publish)"
