#!/usr/bin/env python3
"""Post-process leanblueprint HTML: dark theme, uniform shapes, compact layout.

Run after `leanblueprint web` to apply GIFT visual customizations to the
dependency graph. The extra_styles.css is auto-injected by leanblueprint,
but DOT graph attributes (node shapes, colors, layout) require this script.

Usage:
    python3 blueprint/src/postprocess.py
    # or via the wrapper:
    bash blueprint/build.sh
"""
import re
import sys
from pathlib import Path

HTML_PATH = Path(__file__).parent.parent / "web" / "dep_graph_document.html"


def transform_dot(dot: str) -> str:
    """Transform DOT string for dark theme + uniform shapes + compact layout."""

    # --- Graph attributes: dark bg, compact square layout ---
    dot = dot.replace(
        "graph [bgcolor=transparent]",
        'graph [bgcolor="#0f172a", ratio=compress, ranksep=0.25, '
        "nodesep=0.12, concentrate=true, pad=0.3]",
    )

    # --- Node defaults: rounded boxes, dark fill, light text ---
    dot = dot.replace(
        'node [label="\\N",\t\tpenwidth=1.8\t]',
        'node [label="\\N", penwidth=1.6, shape=box, style="rounded,filled", '
        'fillcolor="#1e293b", fontcolor="#e2e8f0", '
        'fontname="Inter,Helvetica,sans-serif", '
        'fontsize=9, width=1.4, height=0.35, margin="0.18,0.08"]',
    )

    # --- Edge defaults: visible on dark background ---
    dot = dot.replace(
        "edge [arrowhead=vee]",
        'edge [arrowhead=vee, color="#94a3b8", penwidth=1.3]',
    )

    # --- Standardize shapes: all ellipses → boxes ---
    dot = re.sub(r"shape=ellipse", "shape=box", dot)

    # --- Brighten border colors for dark bg ---
    dot = re.sub(r"\bcolor=green\b", 'color="#4ade80"', dot)
    dot = re.sub(r"\bcolor=blue\b", 'color="#60a5fa"', dot)

    # --- Adjust fill colors for dark bg ---
    dot = dot.replace('fillcolor="#B0ECA3"', 'fillcolor="#166534"')
    dot = dot.replace('fillcolor="#A3D6FF"', 'fillcolor="#1e3a5f"')

    # --- Ensure all filled nodes also get rounded ---
    dot = re.sub(r"style=filled\b", 'style="rounded,filled"', dot)

    # --- Dashed edges: match default edge color ---
    dot = re.sub(
        r"\[style=dashed\]",
        '[style=dashed, color="#94a3b8"]',
        dot,
    )

    return dot


def main():
    if not HTML_PATH.exists():
        print(f"Error: {HTML_PATH} not found. Run `leanblueprint web` first.")
        sys.exit(1)

    html = HTML_PATH.read_text()

    dot_marker = ".renderDot(`"
    dot_start = html.find(dot_marker)
    if dot_start == -1:
        print("Error: Could not find DOT string in HTML.")
        sys.exit(1)
    dot_start += len(dot_marker)
    dot_end = html.find("`)", dot_start)

    dot = html[dot_start:dot_end]
    original_len = len(dot)

    dot = transform_dot(dot)

    new_html = html[:dot_start] + dot + html[dot_end:]
    HTML_PATH.write_text(new_html)

    # Stats
    boxes = dot.count("shape=box")
    ellipses = dot.count("shape=ellipse")
    green = dot.count("#4ade80")
    blue = dot.count("#60a5fa")
    print(f"Postprocessed {HTML_PATH.name}:")
    print(f"  Nodes: {boxes} boxes, {ellipses} ellipses")
    print(f"  Colors: {green} green, {blue} blue")
    print(f"  DOT: {original_len} -> {len(dot)} chars")


if __name__ == "__main__":
    main()
