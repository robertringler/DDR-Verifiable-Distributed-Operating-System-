# Task 6 — Proof-of-Concept System

> **Hardest truth first:** a PoC that merely *implements* the framework proves
> nothing — you can always build a contraction toward an invariant set and
> watch it converge; that just re-demonstrates Banach. The only PoC worth
> building is one whose **measured output differs if the thesis is false.** The
> thesis is: *"semantic regulation catches intent-drift that syntactic/computational
> checks miss, using a faithful `d_sem` with a real κ<1."* So the PoC must
> compare, on the **same** trace, a semantic oracle against a syntactic-only
> baseline, on a corpus with **ground-truth drift labels**, and report whether
> the semantic layer adds true detections without drowning in false positives.

## 1. The falsifiable claim and its metric

| | Thesis TRUE | Thesis FALSE |
|---|---|---|
| Semantic oracle on labelled drift cases | **AUC ≥ 0.85**, and catches drift cases that pass all syntactic checks (non-empty "semantic-only catches") | AUC ≈ 0.5–0.6, or every semantic catch is also a syntactic catch (the layer is redundant) |
| Measured κ on `Φrec` | `κ̂ < 1` with faithfulness preserved (Spearman ρ ≥ 0.7) | no κ<1 operator keeps ρ above ~0.4 (only trivial contractions) |
| Triangle violations | max violation < τ (pseudometric salvageable) | violations so large the space isn't even a pseudometric at useful resolution |

**Decision rule:** PoC supports the thesis iff `semantic-only true-catches > 0`
**and** `AUC ≥ 0.85` **and** `κ̂ < 1 at ρ ≥ 0.7`. Any one failing → evidence
**against** the semantic-regulation claim (in this domain), reported as such.

## 2. Architecture

```
            labelled corpus (ConLawDist: statute, application, drift?)
                              │
        ┌─────────────────────┼─────────────────────────┐
        ▼                     ▼                          ▼
  ddr-trace            ciir-metric (d_sem)        baseline-syntactic
  (replay a            graph+embed distance       (WASM predicate /
   sequence of         + triangle audit            regex/keyword gate)
   gov actions)              │                          │
        │                    ▼                          │
        │             ciir-oracle ──► Γrep, Φrec, κ̂      │
        │                    │                          │
        └──────────►  ciir-eval  ◄──────────────────────┘
                      (compare semantic vs syntactic detections
                       against ground truth; emit metrics JSON)
                              │
                              ▼
                      report: AUC, semantic-only catches,
                      κ̂, triangle-violation rate, ρ
```

Deliberately **out of scope for the PoC** (they re-demonstrate known results,
not the thesis): HotStuff consensus, zk recursive proofs, multi-node networking.
Add `ciir-prover` only after the core claim is validated.

## 3. Rust workspace / crate structure

```
ciir-poc/
├─ Cargo.toml                      # workspace
├─ crates/
│  ├─ ciir-core/                   # shared types: SemanticState, Distance, DriftLabel
│  ├─ ciir-metric/                 # d_sem: graph distance + certified-Lipschitz embed
│  ├─ ciir-oracle/                 # Γrep (projection), Φrec (stabilizer), κ̂ estimator
│  ├─ ciir-corpus/                 # ConLawDist loader + synthetic-drift generator
│  ├─ baseline-syntactic/          # syntactic-only predicate baseline
│  ├─ ciir-eval/                   # harness: ROC/AUC, semantic-only catches, triangle audit
│  └─ ciir-prover/                 # (phase 2) arithmetize oracle → zk circuit; stub first
└─ xtask/                          # `cargo xtask bench`, `cargo xtask audit-triangle`
```

## 4. Core trait signatures (API)

```rust
// ciir-core
pub struct SemanticState { pub vec: Vec<f64>, pub concept_id: ConceptId }
pub struct Distance(pub f64);
pub enum DriftLabel { Coherent, Drifted { magnitude: f64 } }

/// A (pseudo)metric on semantic states. `triangle_residual` is what makes
/// the falsification measurable — we DO NOT assume it is zero.
pub trait SemanticMetric {
    fn dist(&self, a: &SemanticState, b: &SemanticState) -> Distance;
    /// max over sampled triples of  d(x,z) - d(x,y) - d(y,z)  (>0 ⇒ violation)
    fn triangle_residual(&self, samples: &[(SemanticState,SemanticState,SemanticState)]) -> f64;
    fn is_metric_within(&self, tau: f64, samples: &[ /*triples*/ ]) -> bool;
}

/// Projection onto the invariant set (Γrep) and the stabilizer (Φrec).
pub trait RepairOperator {
    fn project(&self, s: &SemanticState) -> SemanticState;           // Γrep
    fn is_idempotent_within(&self, eps: f64, xs: &[SemanticState]) -> bool;
}
pub trait Stabilizer {
    fn step(&self, s: &SemanticState) -> SemanticState;              // Φrec single step
    fn stabilize(&self, s0: &SemanticState, tol: f64, max_iter: usize) -> (SemanticState, usize);
    /// EMPIRICAL contraction constant: max_{a≠b} d(step a, step b)/d(a,b)
    fn estimate_kappa(&self, pairs: &[(SemanticState,SemanticState)], m: &dyn SemanticMetric) -> f64;
}

/// The oracle answers the one question the thesis lives or dies on.
pub trait SemanticOracle {
    fn distance_to_invariant(&self, s: &SemanticState) -> Distance;
    fn flags_drift(&self, s: &SemanticState, eps: f64) -> bool;      // d(s, I) > eps ?
}

// baseline-syntactic
pub trait SyntacticPredicate { fn permits(&self, action: &GovAction) -> bool; }
```

## 5. State machine (per trace element)

```
load(action) → apply DDR transition (replay) → s = Fsem(post)
   → syntactic_flag = !baseline.permits(action)
   → semantic_flag  = oracle.flags_drift(&s, eps)
   → record (ground_truth, syntactic_flag, semantic_flag)
   → if semantic_flag: s' = Γrep(s); s* = Φrec.stabilize(s'); log κ̂ sample
repeat → ciir-eval aggregates → metrics.json
```

## 6. Test plan

- **Unit:** metric axiom probes (symmetry exact; triangle *measured* not
  asserted); `Γrep` idempotence within ε; `Φrec` κ̂ estimation on random pairs.
- **Property (proptest):** `d(a,b) == d(b,a)`; `d(a,a) == 0`; `project(project x) ≈ project x`;
  `d(step a, step b) ≤ κ̂·d(a,b)` for the *estimated* κ̂ (regression guard).
- **Golden:** fixed corpus slice → deterministic metrics.json (replay determinism, the one true T8).
- **Falsification harness:** the §1 decision rule, exit code 0 = thesis-supported, 2 = thesis-contradicted.

## 7. Security model

PoC is a measurement instrument, not a production system. Threats in scope:
**metric gaming** (adversarial paraphrase that lowers `d_sem` while drifting
intent — directly tests T7/15.2 honestly) and **label leakage** (held-out drift
cases never seen by metric fitting). Out of scope: network/Byzantine (no
consensus in PoC), key management (no zk yet).

## 8. Failure modes (and what each would teach)

| Failure | Likely cause | What it means |
|---------|--------------|---------------|
| AUC ≈ 0.5 | `d_sem` not faithful | semantic layer adds nothing → thesis unsupported in domain |
| semantic catches ⊆ syntactic catches | oracle is a slow regex | layer is redundant → no contribution |
| no κ̂<1 at ρ≥0.7 | faithful operators aren't contractions | Banach model is wrong (→ Task 4 fallback) |
| huge triangle residual | meaning ≠ metric | not even a pseudometric → semimetric/divergence theory needed |
| adversarial paraphrase defeats oracle | metric gameable | T7/15.2 overstated (as Task 2 predicts) |

## 9. 90-day schedule (weekly)

| Wk | Milestone | Crate(s) |
|----|-----------|----------|
| 1 | Workspace + `ciir-core` types compile; CI green | core, xtask |
| **2** | **`cargo run -p ciir-eval` runs end-to-end on a 20-row synthetic corpus with a *toy* d_sem (Euclidean on random embeddings) and prints metrics.json — the first runnable milestone** | corpus, metric(toy), oracle(toy), eval |
| 3–4 | Real corpus loader (`ConLawDist` Title 18 slice); expert-label ingestion | corpus |
| 5–6 | Graph layer: legal KG + shortest-path `d_graph` (true metric anchor) | metric |
| 7–8 | Embedding layer + certified Lipschitz `L`; hybrid `d_sem`; **triangle audit** | metric |
| 9 | `Γrep` projection onto symbolic invariant gate; idempotence tests | oracle |
| 10 | `Φrec` + **κ̂ estimation**; faithfulness ρ vs experts | oracle, eval |
| 11 | Syntactic baseline + head-to-head ROC/AUC; **run §1 decision rule** | baseline, eval |
| 12 | Adversarial-paraphrase stress test (T7/15.2 honesty); write up | eval |
| 13 | `ciir-prover` *stub* (arithmetize toy oracle, prove one transition) | prover |

**Critical path:** Wk 5→8 (graph + certified embedding + triangle audit). The
entire thesis verdict depends on whether the hybrid `d_sem` is faithful *and*
near-metric. Everything after Wk 8 is measurement.

**Two milestones most likely to slip:** (1) **Wk 3–4 expert labels** — getting
real, defensible drift labels is a data-acquisition/legal-expert bottleneck, not
a coding one (mitigate: start label collection in Wk 1, in parallel; bootstrap
with synthetic drift). (2) **Wk 7–8 certified Lipschitz bound** — LipSDP on a
real text encoder can blow up or yield a vacuous `L`; mitigate by capping
embedding dim and using interval-bound propagation as a fallback.

## 10. First runnable artifact (Week-2 contract for Claude Code)

`cargo run -p ciir-eval -- --corpus synthetic --n 20` must:
1. generate 20 (state, drift-label) rows with a planted drift signal,
2. score them with the toy `d_sem` oracle and the syntactic baseline,
3. emit `metrics.json` = `{auc, semantic_only_catches, kappa_hat,
   triangle_residual, spearman_rho}`,
4. exit 0/2 per the §1 decision rule.

This proves the *measurement loop* end-to-end before any real ML lands — so the
expensive Wk 5–8 work plugs into a harness that already tells you, in one
command, whether the thesis survived.
