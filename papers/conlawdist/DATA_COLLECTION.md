# ConLawDist — Data Collection Specification

> The corpus and labels a **real** ConLawDist release must contain. This is the
> "expensive, essential asset" (audit `03-semantic-metric-program.md` §2): it
> **cannot be synthesized** — the expert drift labels and pairwise judgments
> require human legal experts. Produce data in the `schema.py` format and the
> frozen harness consumes it unchanged.

## Domain (start narrow)

**U.S. Code Title 18 (Crimes and Criminal Procedure).** Closed corpus,
machine-readable, with genuine ground-truth "intent drift" events (cases where
courts explicitly ruled an application exceeded statutory intent). One Title is
enough for the PoC (audit 03 §2).

## Sources

| Layer | Source | Use |
|---|---|---|
| Statute text + versions | US Code XML (Office of Law Revision Counsel) | `states.jsonl` text + `as_of` |
| Amendment history | Statutes-at-Large diffs | `edges.jsonl` `amends`/`supersedes` |
| Cross-references | US Code internal citations | `edges.jsonl` `cross_ref`/`defines` |
| Legislative intent | Congressional Record statements | drift adjudication context |
| Drift ground truth | SCOTUS / circuit opinions ruling an application exceeded statutory intent | `drift.jsonl` labels |

## Deliverables (in `schema.py` format)

1. **`states.jsonl`** — one row per (statute provision, as-of date) application.
   Target: the full Title 18 provision set at a few amendment epochs (~10³ states).
2. **`edges.jsonl`** — the certified knowledge graph: `cross_ref`, `amends`,
   `exception`, `defines`, `supersedes`, positive weights. **Must be connected**
   (the validator checks; a disconnected graph gives `∞` graph-distances).
3. **`embeddings.npy`** — `[n, p]` from a **certified-Lipschitz** encoder
   (LipSDP / interval-bound propagation) so `‖E(x)−E(y)‖ ≤ L·δ_text` with known
   `L` (audit 03 §5). The encoder is pluggable; only the matrix is shipped.
4. **`intent.json`** — the in-intent anchor set: provisions in their
   originally-enacted, court-affirmed-as-faithful form (the `I_intent` anchors).
5. **`drift.jsonl`** — **the essential labels.** ≥ **200–500** expert-labeled
   `(state, drift∈{0,1}, magnitude∈[0,1])` rows, each with provenance (the ruling
   or expert id). Hold out the court-ruled cases as a clean test set.
6. **`pairs.jsonl`** — ≥ **500** expert pairwise distance judgments
   `(state_i, state_j, distance, n_raters)`. Include **paraphrase pairs**
   (same provision, reworded) as near-zero-distance anchors for the axiom audit.

## Labeling protocol (for ρ and AUC to mean anything)

- **Raters:** ≥ 3 per item (law students/attorneys); report **Krippendorff's α**
  inter-rater agreement. Targets are only meaningful above-chance agreement.
- **Pairwise distance:** raters judge "how far has the legal meaning moved?" on a
  fixed anchored scale; average across raters; record `n_raters`.
- **Drift:** for court-ruled cases, `drift=1` with the citation as `source`; for
  expert-judged, the magnitude is the averaged rating.
- **Blinding:** raters see provision text, **not** `d_sem` scores.

## Splits (pre-registered)

- Expert pairs → calibration (α-fit) and test (ρ/τ), disjoint by **provision**
  (no provision appears in both, to prevent leakage).
- Drift cases → court-ruled set held out entirely for the AUC test.

## Quantities that make the result publishable

Release the benchmark itself (`ConLawDist`) with: triangle-violation rate (≈0 by
construction — a structural check), Spearman ρ + Kendall τ vs experts, drift AUC,
conformal coverage, **and** the null-embedding and graph/embed-only baselines.
Per audit 03 §8, the benchmark is publishable **on its own** (NeurIPS D&B / FAccT)
independent of the rest of the program.

## What is and is not provided here

- **Provided (this repo):** the frozen harness, the `d_sem` reference
  implementation, the schema + validator, the synthetic self-test, and this spec.
- **Not provided (requires human experts + corpus engineering):** the actual
  Title 18 corpus, the certified encoder, and — critically — the expert drift
  labels and pairwise judgments. These are the gate; everything else is ready.
