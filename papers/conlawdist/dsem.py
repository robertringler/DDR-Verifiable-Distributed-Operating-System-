"""
d_sem reference implementation — the construction of docs/audit/17 §2.1.

    d_sem(x,y) = alpha * d_graph(x,y) + (1-alpha) * d_embed(x,y)

  * d_graph : shortest-path metric on a certified semantic knowledge graph
              (a GENUINE metric by construction; anchors metricity in the
              symbolic layer, per audit 03 §3).
  * d_embed : ||E(x) - E(y)||_2, the pullback of a norm under a (Lipschitz)
              encoder E (a pseudometric; triangle inequality is automatic).

Because both layers satisfy the triangle inequality, any nonnegative
combination does too: d_sem is a pseudometric, and a genuine metric once the
graph separates points (Prop 2.1). The harness verifies the triangle-violation
rate is exactly 0 (Cor 2.2) as a unit test on the construction.

The encoder E is supplied as a precomputed embedding matrix, so the harness is
model-agnostic: any certified-Lipschitz encoder (LipSDP, interval-bound) can be
plugged in for the real corpus.
"""
from __future__ import annotations
import numpy as np


def all_pairs_shortest_path(W: np.ndarray) -> np.ndarray:
    """Floyd-Warshall all-pairs shortest paths on a weighted adjacency matrix
    W (np.inf for absent edges, 0 on the diagonal). Returns the graph metric.
    O(n^3); fine for benchmark-scale n. The result satisfies the triangle
    inequality exactly (it is the metric closure of W)."""
    D = W.astype(float).copy()
    n = D.shape[0]
    np.fill_diagonal(D, 0.0)
    for k in range(n):
        D = np.minimum(D, D[:, k][:, None] + D[k, :][None, :])
    return D


def _components(W: np.ndarray):
    """Connected components of the graph with finite-weight edges (BFS)."""
    n = W.shape[0]
    seen = np.zeros(n, bool)
    comps = []
    for s in range(n):
        if seen[s]:
            continue
        stack, comp = [s], []
        seen[s] = True
        while stack:
            u = stack.pop(); comp.append(u)
            for v in np.where(np.isfinite(W[u]) & (np.arange(n) != u))[0]:
                if not seen[v]:
                    seen[v] = True; stack.append(v)
        comps.append(comp)
    return comps


def knn_graph(Z: np.ndarray, k: int = 8, ensure_connected: bool = True) -> np.ndarray:
    """Build a symmetric k-nearest-neighbour weighted adjacency from points Z
    (rows). Edge weight = Euclidean distance. Returns W with np.inf off-graph.
    If ensure_connected, add minimum cross-component edges so d_graph is finite
    everywhere (a disconnected graph yields infinite distances; the real corpus
    layer must also guarantee connectivity). This is the 'certified semantic
    relations' layer for the synthetic demo; for the real corpus, replace with
    the curated legal knowledge graph."""
    n = Z.shape[0]
    d = np.linalg.norm(Z[:, None, :] - Z[None, :, :], axis=-1)
    W = np.full((n, n), np.inf)
    np.fill_diagonal(W, 0.0)
    for i in range(n):
        nbr = np.argsort(d[i])[1:k + 1]
        for j in nbr:
            W[i, j] = d[i, j]
            W[j, i] = d[i, j]          # symmetrize
    if ensure_connected:
        comps = _components(W)
        # greedily merge components by their globally-nearest cross pair
        while len(comps) > 1:
            c0 = comps[0]
            best = (np.inf, -1, -1, -1)
            for ci in range(1, len(comps)):
                sub = d[np.ix_(c0, comps[ci])]
                a, b = np.unravel_index(np.argmin(sub), sub.shape)
                if sub[a, b] < best[0]:
                    best = (sub[a, b], c0[a], comps[ci][b], ci)
            _, u, v, ci = best
            W[u, v] = W[v, u] = d[u, v]
            comps[0] = c0 + comps[ci]
            comps.pop(ci)
    return W


def _normalize(D: np.ndarray) -> np.ndarray:
    """Scale a distance matrix to unit mean off-diagonal, so the graph and
    embedding terms are commensurable before fusion."""
    n = D.shape[0]
    off = D[~np.eye(n, dtype=bool)]
    finite = off[np.isfinite(off)]
    m = finite.mean() if finite.size and finite.mean() > 0 else 1.0
    Dn = D / m
    Dn[~np.isfinite(Dn)] = finite.max() / m * 2 if finite.size else 1.0
    np.fill_diagonal(Dn, 0.0)
    return Dn


class DSem:
    """The fused semantic metric d_sem = alpha*d_graph + (1-alpha)*d_embed."""

    def __init__(self, W: np.ndarray, E: np.ndarray, alpha: float = 0.5):
        self.alpha = float(alpha)
        self.d_graph = _normalize(all_pairs_shortest_path(W))
        emb = np.linalg.norm(E[:, None, :] - E[None, :, :], axis=-1)
        self.d_embed = _normalize(emb)
        self.D = self.alpha * self.d_graph + (1 - self.alpha) * self.d_embed

    def matrix(self) -> np.ndarray:
        return self.D

    def to_intent(self, intent_idx: np.ndarray) -> np.ndarray:
        """Distance of each state to the intent set I_intent (min over the
        in-intent anchor states). This is the drift score d_sem(x, I_intent)."""
        return self.D[:, intent_idx].min(axis=1)

    @staticmethod
    def fit_alpha(W, E, gold_pairs, gold_vals, grid=None):
        """Pick alpha maximizing Spearman vs expert pairwise judgments on a
        held-out pair set. Returns (best_alpha, best_rho)."""
        from metrics import spearman
        if grid is None:
            grid = np.linspace(0.0, 1.0, 21)
        best_a, best_r = 0.5, -2.0
        for a in grid:
            ds = DSem(W, E, alpha=a)
            pred = np.array([ds.D[i, j] for i, j in gold_pairs])
            r = spearman(pred, gold_vals)
            if r > best_r:
                best_a, best_r = float(a), r
        return best_a, best_r
