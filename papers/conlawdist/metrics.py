"""
ConLawDist metrics — numpy-only implementations of the four benchmark measures
from the semantic-metric program (docs/audit/03 §4-5) and doc 17 §5:

  1. triangle_violation_rate   — intrinsic axiom audit (must be 0 for a metric)
  2. spearman                  — extrinsic faithfulness vs expert judgments
  3. auc                       — drift-detection ROC-AUC vs labeled drift cases
  4. conformal_coverage        — split-conformal calibration coverage

All implemented from scratch (no scipy/sklearn) for a clean, auditable harness.
"""
from __future__ import annotations
import numpy as np


# ---------------------------------------------------------------------------
# 1. Triangle-inequality audit
# ---------------------------------------------------------------------------
def triangle_violation_rate(D: np.ndarray, tol: float = 1e-9,
                            max_triples: int = 200_000,
                            rng: np.random.Generator | None = None):
    """Fraction of triples (i,j,k) with D[i,k] > D[i,j] + D[j,k] + tol, and the
    maximum signed violation. For a genuine metric both are 0/<=0 exactly
    (doc 17 Prop 2.1 / Cor 2.2). Samples triples when N^3 is large."""
    n = D.shape[0]
    if rng is None:
        rng = np.random.default_rng(0)
    if n * n * n <= max_triples:
        ii, jj, kk = np.meshgrid(np.arange(n), np.arange(n), np.arange(n),
                                 indexing="ij")
        i, j, k = ii.ravel(), jj.ravel(), kk.ravel()
    else:
        i = rng.integers(0, n, max_triples)
        j = rng.integers(0, n, max_triples)
        k = rng.integers(0, n, max_triples)
    viol = D[i, k] - (D[i, j] + D[j, k])
    rate = float(np.mean(viol > tol))
    return rate, float(np.max(viol))


# ---------------------------------------------------------------------------
# rank utilities + correlations
# ---------------------------------------------------------------------------
def _rankdata(a: np.ndarray) -> np.ndarray:
    """Average ranks (ties shared), like scipy.stats.rankdata."""
    a = np.asarray(a, float)
    order = np.argsort(a, kind="mergesort")
    ranks = np.empty(len(a), float)
    sa = a[order]
    i = 0
    while i < len(a):
        j = i
        while j + 1 < len(a) and sa[j + 1] == sa[i]:
            j += 1
        ranks[order[i:j + 1]] = (i + j) / 2.0 + 1.0
        i = j + 1
    return ranks


def _pearson(x: np.ndarray, y: np.ndarray) -> float:
    x = np.asarray(x, float); y = np.asarray(y, float)
    x = x - x.mean(); y = y - y.mean()
    denom = np.sqrt((x * x).sum() * (y * y).sum())
    return float((x * y).sum() / denom) if denom > 0 else 0.0


def spearman(pred: np.ndarray, gold: np.ndarray) -> float:
    """Spearman rank correlation between predicted and gold distances."""
    return _pearson(_rankdata(pred), _rankdata(gold))


def kendall_tau(pred: np.ndarray, gold: np.ndarray, max_pairs: int = 50_000,
                rng: np.random.Generator | None = None) -> float:
    """Kendall tau-a (sampled for large inputs)."""
    pred = np.asarray(pred, float); gold = np.asarray(gold, float)
    n = len(pred)
    if rng is None:
        rng = np.random.default_rng(0)
    idx = [(a, b) for a in range(n) for b in range(a + 1, n)]
    if len(idx) > max_pairs:
        sel = rng.choice(len(idx), max_pairs, replace=False)
        idx = [idx[s] for s in sel]
    conc = disc = 0
    for a, b in idx:
        sp = np.sign(pred[a] - pred[b]); sg = np.sign(gold[a] - gold[b])
        if sp * sg > 0:
            conc += 1
        elif sp * sg < 0:
            disc += 1
    tot = conc + disc
    return (conc - disc) / tot if tot else 0.0


# ---------------------------------------------------------------------------
# 3. Drift-detection AUC (Mann-Whitney U / rank formula)
# ---------------------------------------------------------------------------
def auc(scores: np.ndarray, labels: np.ndarray) -> float:
    """ROC-AUC = P(score(pos) > score(neg)) via the rank-sum identity.
    labels in {0,1}; higher score should mean 'more drift' (positive)."""
    scores = np.asarray(scores, float)
    labels = np.asarray(labels, int)
    pos = labels == 1
    n_pos = int(pos.sum()); n_neg = int((~pos).sum())
    if n_pos == 0 or n_neg == 0:
        return float("nan")
    r = _rankdata(scores)
    auc_val = (r[pos].sum() - n_pos * (n_pos + 1) / 2.0) / (n_pos * n_neg)
    return float(auc_val)


# ---------------------------------------------------------------------------
# 4. Split-conformal coverage (regression on drift magnitude)
# ---------------------------------------------------------------------------
def conformal_coverage(pred: np.ndarray, true: np.ndarray,
                       calib_frac: float = 0.5, alpha: float = 0.1,
                       rng: np.random.Generator | None = None):
    """Split-conformal: nonconformity = |pred-true| on a calibration split;
    threshold = the ceil((n+1)(1-alpha))/n empirical quantile; report the
    empirical coverage on the test split (target >= 1-alpha) and the interval
    half-width. A correctly calibrated metric covers at ~1-alpha."""
    pred = np.asarray(pred, float); true = np.asarray(true, float)
    n = len(pred)
    if rng is None:
        rng = np.random.default_rng(0)
    perm = rng.permutation(n)
    n_cal = int(calib_frac * n)
    cal, test = perm[:n_cal], perm[n_cal:]
    scores = np.abs(pred[cal] - true[cal])
    # finite-sample conformal quantile
    level = np.ceil((n_cal + 1) * (1 - alpha)) / n_cal
    level = min(level, 1.0)
    q = float(np.quantile(scores, level, method="higher"))
    covered = np.abs(pred[test] - true[test]) <= q
    return float(np.mean(covered)), q
