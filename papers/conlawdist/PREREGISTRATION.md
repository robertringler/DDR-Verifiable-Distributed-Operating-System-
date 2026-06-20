# ConLawDist — Pre-registration

> A pre-registered hypothesis with a stated falsifier. This is the empirical
> spine of the semantic-metric program (audit `03-semantic-metric-program.md`
> §7) and the test that discharges Open Obligation **O1** of the CIIR formal
> implementation (`docs/audit/17` §2.1). Filling it requires the corpus and
> expert labels of `DATA_COLLECTION.md`; the harness (`run_benchmark.py`) and
> metrics (`metrics.py`) are frozen here in advance.

## Object under test

The fused metric of `docs/audit/17` §2.1,
`d_sem(x,y) = α·d_graph(x,y) + (1−α)·d_embed(x,y)`,
on **one** narrow legal domain (U.S. Code **Title 18**, crimes — see
`DATA_COLLECTION.md`).

## Frozen-in-advance analysis

- **Harness:** `run_benchmark.py`, commit-pinned. No metric may be changed after
  data is seen.
- **`α` selection:** fit on a **calibration split** of expert pairs only;
  evaluate on a disjoint **test split**. `α ∈ {0.0, 0.05, …, 1.0}` (21 values).
- **Metrics:** `metrics.py` (triangle-violation rate, Spearman ρ, Kendall τ,
  drift AUC, split-conformal coverage at miscoverage `α_conf = 0.10`).

## Hypothesis (pre-registered)

> **H1.** There exists `α ∈ [0,1]` such that, on Title 18, the fused `d_sem`
> achieves on the held-out test split:
> 1. **triangle-violation rate = 0** (structural; guaranteed by Prop 2.1 — this
>    is a unit test on the implementation, not an empirical bet);
> 2. **Spearman ρ ≥ 0.70** vs expert pairwise distance judgments;
> 3. **drift detection AUC ≥ 0.85** vs court-ruled / expert-labeled drift cases;
> 4. **conformal coverage ≥ 0.90** (= `1 − α_conf`) on the drift-magnitude target.

## Falsifier (pre-registered)

> **H1 is falsified if**, after the full architecture (`DATA_COLLECTION.md`), the
> best achievable `d_sem` over Title 18 has **either**
> - (a) **triangle violations** so large that no quotient/repair restores
>   metricity at useful resolution — *note: impossible for the constructed
>   `d_sem`, so a nonzero rate here means an implementation bug, and is itself an
>   informative failure*; **or**
> - (b) **every `α` that reaches the faithfulness bar (ρ ≥ 0.7) destroys drift
>   detection**, or every `α` with AUC ≥ 0.85 collapses `ρ < 0.4` — i.e. the only
>   contractive/faithful regimes are semantically trivial.
>
> Either outcome means **"semantic regulation as metric stabilization" is the
> wrong mathematical model**, and the CIIR governance thesis is empirically dead
> *in its current form* on this domain.

## Sanity controls (must pass for the result to count)

- **Null control.** Building `d_sem` from data **unrelated** to the gold
  judgments must collapse Spearman and AUC to chance (the harness demonstrates
  this: synthetic faithful ρ≈0.97/AUC≈1.0 vs null ρ≈0.0/AUC≈0.5). If the null
  control does *not* drop to chance, the metric is reading an artifact (e.g. a
  leak between graph construction and labels), not meaning, and the result is void.
- **Graph-only and embed-only baselines** (`α=1`, `α=0`) reported alongside the
  fused metric, so any gain from fusion is visible and not assumed.
- **Inter-rater agreement** on expert pairs reported (Krippendorff's α);
  ρ-targets are meaningful only if raters agree above chance.

## Decision rule

| Outcome | Reading |
|---|---|
| H1 met, controls pass | `d_sem` is **faithful on Title 18**; O1 discharged for this domain; proceed to a second domain to test generality. |
| H1 (2) or (3) fails, controls pass | metric structure is sound but **not faithful**; the thesis needs a different `d_sem` or a non-metric model (Bregman fallback, audit 03 §9). |
| Null control fails | result is **void** (artifact); fix leakage and re-run. |

## Status

- Harness + metrics + synthetic self-validation: **complete and passing**
  (`run_benchmark.py`).
- Corpus + expert labels: **`[OPEN]`** — requires the data collection in
  `DATA_COLLECTION.md` (the expensive, essential asset; cannot be synthesized).
