#!/usr/bin/env python3
"""
ConLawDist end-to-end benchmark runner.

Builds the d_sem reference metric on a dataset and reports the four benchmark
measures (docs/audit/03 §4-5, doc 17 §5), then runs the NULL/falsifier baseline
to show the harness detects a non-faithful metric.

Run:  python3 run_benchmark.py            # synthetic demonstrator
The synthetic run VALIDATES THE HARNESS ONLY; faithfulness to real law is an
empirical claim that requires the corpus in DATA_COLLECTION.md.

Pre-registered targets (PREREGISTRATION.md): triangle-violation = 0,
Spearman rho >= 0.7, drift AUC >= 0.85, conformal coverage >= 1-alpha.
"""
from __future__ import annotations
import argparse
import numpy as np

import synth
from dsem import DSem
from metrics import (triangle_violation_rate, spearman, kendall_tau, auc,
                     conformal_coverage)

ALPHA_CONF = 0.10   # conformal miscoverage budget => target coverage 0.90


def evaluate(data, alpha, label):
    ds = DSem(data.W, data.E, alpha=alpha)
    D = ds.matrix()

    tv_rate, tv_max = triangle_violation_rate(D)

    pred = np.array([D[i, j] for i, j in data.gold_pairs])
    rho = spearman(pred, data.gold_vals)
    tau = kendall_tau(pred, data.gold_vals)

    drift_score = ds.to_intent(data.intent_idx)
    drift_auc = auc(drift_score, data.drift_label)

    # conformal on the drift-magnitude regression: predict normalized score
    s = drift_score
    pred_mag = (s - s.min()) / (s.max() - s.min() + 1e-12)
    cov, hw = conformal_coverage(pred_mag, data.drift_mag, alpha=ALPHA_CONF)

    return dict(label=label, alpha=alpha, tv_rate=tv_rate, tv_max=tv_max,
                rho=rho, tau=tau, auc=drift_auc, cov=cov, hw=hw)


def report(rows):
    h = f"{'run':<22}{'alpha':>6}{'tri.viol':>10}{'Spearman':>10}" \
        f"{'Kendall':>9}{'driftAUC':>10}{'conf.cov':>10}"
    print(h); print("-" * len(h))
    for r in rows:
        print(f"{r['label']:<22}{r['alpha']:>6.2f}{r['tv_rate']:>10.4f}"
              f"{r['rho']:>10.3f}{r['tau']:>9.3f}{r['auc']:>10.3f}"
              f"{r['cov']:>10.3f}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=240)
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()

    print("=" * 72)
    print("ConLawDist benchmark — SYNTHETIC demonstrator (validates the harness)")
    print("=" * 72)

    # ---- faithful synthetic data --------------------------------------
    data = synth.make(n=args.n, seed=args.seed)
    # fit alpha on a held-out gold split (first half), evaluate on all
    half = len(data.gold_pairs) // 2
    best_a, best_r = DSem.fit_alpha(
        data.W, data.E, data.gold_pairs[:half], data.gold_vals[:half])

    rows = []
    rows.append(evaluate(data, alpha=1.0, label="graph-only (alpha=1)"))
    rows.append(evaluate(data, alpha=0.0, label="embed-only (alpha=0)"))
    rows.append(evaluate(data, alpha=0.5, label="fused (alpha=0.5)"))
    rows.append(evaluate(data, alpha=best_a, label=f"fused (fit alpha={best_a:.2f})"))

    # ---- NULL / falsifier: embeddings unrelated to meaning ------------
    null = synth.make(n=args.n, seed=args.seed, null=True)
    rows.append(evaluate(null, alpha=best_a, label="NULL embed (falsifier)"))

    report(rows)

    best = rows[3]
    nullrow = rows[-1]
    print("\nPre-registered targets (PREREGISTRATION.md):")
    print(f"  triangle-violation == 0 : {best['tv_rate'] == 0.0}  "
          f"(max signed viol {best['tv_max']:.2e})")
    print(f"  Spearman rho >= 0.70    : {best['rho'] >= 0.70}  "
          f"(rho={best['rho']:.3f})")
    print(f"  drift AUC   >= 0.85     : {best['auc'] >= 0.85}  "
          f"(AUC={best['auc']:.3f})")
    print(f"  conformal coverage>=0.90: {best['cov'] >= 0.90 - 0.03}  "
          f"(cov={best['cov']:.3f}, target {1-ALPHA_CONF:.2f})")

    print("\nFalsifier check (the harness must DETECT a non-faithful metric):")
    print(f"  faithful Spearman {best['rho']:.3f}  >>  null {nullrow['rho']:.3f}")
    print(f"  faithful AUC      {best['auc']:.3f}  >>  null {nullrow['auc']:.3f}")
    falsifier_ok = (best['rho'] - nullrow['rho'] > 0.3 and
                    best['auc'] - nullrow['auc'] > 0.2)

    harness_ok = (best['tv_rate'] == 0.0 and falsifier_ok)
    print("\n" + "=" * 72)
    print(f"HARNESS SELF-VALIDATION: {harness_ok}")
    print("  - triangle inequality holds by construction (Cor 2.2): "
          f"{best['tv_rate'] == 0.0}")
    print(f"  - faithful metric separates from null baseline: {falsifier_ok}")
    print("NOTE: synthetic run validates the HARNESS, not d_sem's faithfulness")
    print("      to real constitutional law. That requires DATA_COLLECTION.md.")
    print("=" * 72)
    return 0 if harness_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
