"""GIFT visualizations (optional). Requires: pip install matplotlib numpy."""
from typing import Optional, Tuple, List
import math

# Check for matplotlib availability
try:
    import matplotlib.pyplot as plt
    import matplotlib.patches as patches
    from matplotlib.collections import LineCollection
    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False
    plt = None

try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    np = None


def _check_matplotlib():
    """Raise ImportError if matplotlib not available."""
    if not MATPLOTLIB_AVAILABLE:
        raise ImportError(
            "Visualization requires matplotlib. Install with: pip install matplotlib"
        )


def _check_numpy():
    """Raise ImportError if numpy not available."""
    if not NUMPY_AVAILABLE:
        raise ImportError(
            "Visualization requires numpy. Install with: pip install numpy"
        )


def plot_fano(
    figsize: Tuple[float, float] = (8, 8),
    show_labels: bool = True,
    title: str = "Fano Plane - Octonion Structure",
    save_path: Optional[str] = None
):
    """Plot the Fano plane (7 points, 7 lines). save_path saves the figure if given."""
    _check_matplotlib()

    fig, ax = plt.subplots(1, 1, figsize=figsize)
    ax.set_aspect('equal')
    ax.axis('off')

    # Point positions (hexagon + center)
    # Points 0-5 on hexagon, point 6 at center
    angles = [math.pi/2 + i * math.pi/3 for i in range(6)]
    radius = 1.5

    points = {}
    for i, angle in enumerate(angles):
        points[i] = (radius * math.cos(angle), radius * math.sin(angle))
    points[6] = (0, 0)  # Center point

    # Fano lines (using our standard ordering)
    lines = [
        (0, 1, 3),
        (1, 2, 4),
        (2, 3, 5),
        (3, 4, 6),
        (4, 5, 0),
        (5, 6, 1),
        (6, 0, 2),
    ]

    # Colors for lines
    colors = plt.cm.tab10(range(7))

    # Draw lines
    for idx, (a, b, c) in enumerate(lines):
        pts = [points[a], points[b], points[c]]

        # Check if line goes through center
        if 6 in (a, b, c):
            # Straight line through center
            other = [p for p in (a, b, c) if p != 6]
            x = [points[other[0]][0], points[6][0], points[other[1]][0]]
            y = [points[other[0]][1], points[6][1], points[other[1]][1]]
            ax.plot(x, y, '-', color=colors[idx], linewidth=2, alpha=0.7)
        else:
            # Draw as arc (for outer lines)
            # For simplicity, draw as straight lines connecting all 3 points
            for i in range(3):
                p1, p2 = pts[i], pts[(i + 1) % 3]
                ax.plot([p1[0], p2[0]], [p1[1], p2[1]],
                       '-', color=colors[idx], linewidth=2, alpha=0.7)

    # Draw the circle (for the curved line 0-1-3 which should be the outer circle)
    circle = plt.Circle((0, 0), radius, fill=False, color=colors[0],
                        linewidth=2, alpha=0.7, linestyle='--')
    ax.add_patch(circle)

    # Draw points
    for i, (x, y) in points.items():
        ax.plot(x, y, 'o', markersize=20, color='white',
               markeredgecolor='black', markeredgewidth=2)
        if show_labels:
            ax.text(x, y, f'e{i+1}', ha='center', va='center',
                   fontsize=12, fontweight='bold')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_title(title, fontsize=14, fontweight='bold')

    # Add info text
    info = "7 points, 7 lines\n|Aut| = PSL(2,7) = 168"
    ax.text(0, -2.2, info, ha='center', va='top', fontsize=10)

    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig, ax


def plot_e8_projection(
    projection: str = "random",
    figsize: Tuple[float, float] = (10, 10),
    point_size: int = 20,
    alpha: float = 0.6,
    title: str = "E8 Root System (2D Projection)",
    save_path: Optional[str] = None
):
    """Plot a 2D projection of the 240 E8 roots.

    Args:
        projection: Projection type ("random", "pca", or "fixed").
        save_path: If provided, save figure to this path.
    """
    _check_matplotlib()
    _check_numpy()

    from .roots import E8_ROOTS, D8_ROOTS, HALF_INTEGER_ROOTS

    # Convert to numpy array
    roots = np.array(E8_ROOTS)

    # Create projection matrix
    if projection == "random":
        np.random.seed(42)  # For reproducibility
        proj = np.random.randn(8, 2)
        proj = proj / np.linalg.norm(proj, axis=0)
    elif projection == "pca":
        # Simple PCA
        mean = roots.mean(axis=0)
        centered = roots - mean
        cov = centered.T @ centered
        _, vecs = np.linalg.eigh(cov)
        proj = vecs[:, -2:]  # Top 2 eigenvectors
    else:  # fixed - nice symmetric projection
        proj = np.array([
            [1, 0],
            [0.5, 0.866],
            [-0.5, 0.866],
            [-1, 0],
            [-0.5, -0.866],
            [0.5, -0.866],
            [0.3, 0.1],
            [-0.3, -0.1],
        ])

    # Project roots
    projected = roots @ proj

    fig, ax = plt.subplots(1, 1, figsize=figsize)
    ax.set_aspect('equal')

    # Separate D8 and half-integer for different colors
    d8_proj = np.array(D8_ROOTS) @ proj
    half_proj = np.array(HALF_INTEGER_ROOTS) @ proj

    ax.scatter(d8_proj[:, 0], d8_proj[:, 1],
              s=point_size, alpha=alpha, c='blue', label=f'D8 roots ({len(D8_ROOTS)})')
    ax.scatter(half_proj[:, 0], half_proj[:, 1],
              s=point_size, alpha=alpha, c='red', label=f'Half-integer ({len(HALF_INTEGER_ROOTS)})')

    ax.legend(loc='upper right')
    ax.set_title(title, fontsize=14, fontweight='bold')

    # Add info
    info = f"Total: 240 roots = 112 (D8) + 128 (half-int)\ndim(E8) = 240 + 8 = 248"
    ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=9,
           verticalalignment='bottom', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    ax.grid(True, alpha=0.3)

    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig, ax


def plot_dynkin_e8(
    figsize: Tuple[float, float] = (12, 4),
    title: str = "E8 Dynkin Diagram",
    save_path: Optional[str] = None
):
    """Plot the E8 Dynkin diagram (8 nodes, forked structure)."""
    _check_matplotlib()

    fig, ax = plt.subplots(1, 1, figsize=figsize)
    ax.set_aspect('equal')
    ax.axis('off')

    # Node positions (main branch + fork)
    positions = {
        1: (0, 0),
        2: (1, 0),
        3: (2, 0),
        4: (3, 0),
        5: (4, 0),
        6: (5, 0),
        7: (6, 0),
        8: (3, -1),  # Fork below node 4
    }

    # Edges
    edges = [
        (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7),
        (4, 8),  # Fork
    ]

    # Draw edges
    for (a, b) in edges:
        x = [positions[a][0], positions[b][0]]
        y = [positions[a][1], positions[b][1]]
        ax.plot(x, y, 'k-', linewidth=2)

    # Draw nodes
    for node, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.15, color='white',
                           ec='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, str(node), ha='center', va='center',
               fontsize=10, fontweight='bold')

    ax.set_xlim(-1, 7)
    ax.set_ylim(-2, 1)
    ax.set_title(title, fontsize=14, fontweight='bold')

    # Add labels
    ax.text(3, 0.8, "rank = 8, dim = 248, Coxeter = 30", ha='center', fontsize=10)

    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig, ax


def plot_gift_constants(
    figsize: Tuple[float, float] = (12, 6),
    title: str = "GIFT Framework Constants",
    save_path: Optional[str] = None
):
    """Plot a bar chart of key GIFT constants."""
    _check_matplotlib()

    from .constants import (
        DIM_E8, DIM_G2, DIM_K7, B2, B3, H_STAR,
        DIM_F4, DIM_E6, DIM_E7, DIM_J3O
    )

    constants = {
        'dim(K7)': DIM_K7,
        'dim(G2)': DIM_G2,
        'b₂': B2,
        'dim(J₃O)': DIM_J3O,
        'dim(F4)': DIM_F4,
        'dim(E6)': DIM_E6,
        'b₃': B3,
        'H*': H_STAR,
        'dim(E7)': DIM_E7,
        'dim(E8)': DIM_E8,
    }

    fig, ax = plt.subplots(1, 1, figsize=figsize)

    names = list(constants.keys())
    values = list(constants.values())

    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(names)))

    bars = ax.bar(names, values, color=colors)

    # Add value labels on bars
    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
               str(val), ha='center', va='bottom', fontsize=9)

    ax.set_ylabel('Value', fontsize=12)
    ax.set_title(title, fontsize=14, fontweight='bold')
    plt.xticks(rotation=45, ha='right')

    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')

    return fig, ax


def plot_all(save_dir: Optional[str] = None):
    """Generate all standard GIFT visualizations. save_dir saves all figures if given."""
    _check_matplotlib()

    import os

    figs = {}

    # Fano plane
    figs['fano'] = plot_fano(
        save_path=os.path.join(save_dir, 'fano.png') if save_dir else None
    )

    # E8 roots
    if NUMPY_AVAILABLE:
        figs['e8_roots'] = plot_e8_projection(
            save_path=os.path.join(save_dir, 'e8_roots.png') if save_dir else None
        )

    # Dynkin diagram
    figs['dynkin'] = plot_dynkin_e8(
        save_path=os.path.join(save_dir, 'dynkin_e8.png') if save_dir else None
    )

    # Constants bar chart
    if NUMPY_AVAILABLE:
        figs['constants'] = plot_gift_constants(
            save_path=os.path.join(save_dir, 'constants.png') if save_dir else None
        )

    plt.show()

    return figs
