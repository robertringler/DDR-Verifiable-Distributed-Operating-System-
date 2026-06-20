# ConLawDist — a benchmark for semantic-intent distance (`d_sem`)

The empirical spine of the CIIR governance thesis: a frozen, falsifiable
benchmark that tests whether the constructed metric `d_sem` (docs/audit/17 §2.1)
is **faithful** to legal intent on one narrow domain. Passing it discharges Open
Obligation **O1**; failing it is a clean refutation of "semantic regulation as
metric stabilization." Per audit `03-semantic-metric-program.md` §8 the benchmark
is publishable on its own (NeurIPS D&B / FAccT) independent of the rest of DDR+CIIR.

## What this is — and the one thing it is not

**Built here, complete and tested:**
- **`dsem.py`** — the reference `d_sem = α·d_graph + (1−α)·d_embed` (graph metric +
  encoder pullback). Triangle inequality holds **by construction** (doc 17 Prop 2.1).
- **`metrics.py`** — the four measures, numpy-only, from scratch: triangle-violation
  rate, Spearman ρ, Kendall τ, drift ROC-AUC, split-conformal coverage.
- **`schema.py`** — the on-disk dataset format + a validator (connectivity,
  label/pair counts, shapes). `data/example/` is a tiny synthetic instance of it.
- **`synth.py` / `export_synthetic.py`** — a transparently-synthetic generator with
  **known ground truth**, used to validate the harness and exercise the falsifier.
- **`run_benchmark.py`** — end-to-end: build `d_sem`, fit α, report all metrics,
  and run the null/falsifier baseline.
- **`PREREGISTRATION.md`** — the frozen hypothesis + falsifier (the science).
- **`DATA_COLLECTION.md`** — the corpus + labeling spec a legal team fills.

**Not built here (the gate, by nature):** the **real** Title 18 corpus, a
certified-Lipschitz encoder, and — the expensive, essential asset — **expert drift
labels and pairwise judgments**. These require human legal experts and cannot be
synthesized. Fabricating them would defeat the benchmark's entire purpose. The
harness is ready the moment that data exists, in the `schema.py` format.

## Reproduce

```bash
pip install numpy
python3 run_benchmark.py        # synthetic self-validation of the harness
python3 export_synthetic.py     # write + validate the on-disk format example
```

### What the synthetic run shows (and what it does not)

```
run                    alpha  tri.viol  Spearman  Kendall  driftAUC  conf.cov
fused (fit alpha=0.30)  0.30    0.0000     0.968    0.837     0.997     0.925
NULL embed (falsifier)  0.30    0.0000    -0.033   -0.020     0.509     0.942
```

- **triangle-violation = 0** for every α — an empirical confirmation of doc 17
  Cor 2.2 (a unit test on the construction, not a bet).
- On **faithful** synthetic data the metric recovers the latent semantics
  (ρ≈0.97, AUC≈1.0); on a **null** built from data unrelated to the labels it
  collapses to chance (ρ≈0, AUC≈0.5). **The harness detects a non-faithful
  metric** — which is exactly what makes the benchmark a falsifier.

> The synthetic run validates **the harness**, *not* `d_sem`'s faithfulness to
> real constitutional law. Faithfulness is the empirical question the
> pre-registration poses, answerable only with the `DATA_COLLECTION.md` corpus.

## Pre-registered targets (PREREGISTRATION.md)

triangle-violation = 0 · Spearman ρ ≥ 0.70 · drift AUC ≥ 0.85 · conformal
coverage ≥ 0.90. Falsified if no α reaches the faithfulness bar without destroying
drift detection (then the metric model is wrong and the thesis is dead on this domain).
