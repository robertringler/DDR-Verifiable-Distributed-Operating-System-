# Task 4 — Semantic Metric Program (`d_sem` for constitutional law)

> **Hardest truth first:** the strongest reason `d_sem` may not exist as a
> *true metric* is the **triangle inequality**, and it is not a technicality.
> Meaning-distance routinely violates it: A ("possess firearm") is close to B
> ("possess registered firearm"), B is close to C ("possess registered
> hunting rifle"), yet a faithful legal-intent distance can rate A↔C far apart
> because an exception chain has accumulated. If the triangle inequality
> fails, `M_intent` is **not a metric space**, Banach does **not** apply, and
> T1/T2/5.2/14.2 lose their proof *form*, not just their constants. Plan for
> the fallback from day one.

## 1. What kind of object `d_sem` actually is

The document assumes `(M_intent, d_sem)` is a **complete Riemannian/metric
space** with a Levi-Civita connection (Def 2.2). That is a very strong
commitment. Honest taxonomy of what we could actually build, strongest axioms
first:

| Candidate structure | Axioms it satisfies | Banach survives? | Downstream cost |
|---------------------|---------------------|:----------------:|-----------------|
| **True metric** (the assumption) | identity, symmetry, **triangle**, completeness | ✅ as written | none — but likely *unattainable* |
| **Pseudometric** (d(x,y)=0 ⇏ x=y) | drops identity-of-indiscernibles | ✅ (work in quotient `M/∼`) | equilibrium unique *up to semantic equivalence* — acceptable, arguably *desirable* |
| **Quasi-metric** (asymmetric) | drops symmetry | ⚠️ needs Banach-for-quasimetrics (exists, weaker) | convergence rate constants change; "drift toward intent" ≠ "intent toward state" |
| **Semimetric** (no triangle) | drops triangle | ❌ **Banach fails** | must replace Banach with a contraction principle that doesn't use △ (rare) or with a Lyapunov/energy argument |
| **Divergence** (e.g. KL, Bregman) | non-negative, =0 iff equal, **no symmetry, no △** | ❌ for Banach; ✅ for *information-geometric* fixed points | switch to mirror-descent / Bregman-proximal convergence theory (Task 5) |

**Recommendation:** target a **pseudometric** as the *honest best case* (the
quotient by semantic equivalence is a feature, not a bug — "intent" should not
distinguish synonyms). Architect the experiments to *measure triangle-inequality
violation* explicitly; treat its magnitude as the headline empirical result.

## 2. Corpus and data requirements

Pick **one** narrow, well-bounded domain first — **U.S. federal statutory
cross-reference + amendment history** is ideal (closed corpus, machine-readable,
ground-truth "intent drift" events exist: when courts/legislatures explicitly
say an interpretation drifted).

- **Corpus:** US Code (XML, via the Office of Law Revision Counsel) +
  Statutes-at-Large amendment diffs + Congressional Record intent statements +
  a labelled set of "interpretation-drift" cases (where SCOTUS/circuit courts
  ruled an application exceeded statutory intent).
- **Ground truth ("does this drift?"):** ~200–500 expert-labelled
  (statute, application, drift?∈{0,1}, magnitude∈[0,1]) triples. This is the
  expensive, essential asset. Without labels you cannot *validate* the metric,
  only assert it.
- **Scale to start:** one Title (e.g. Title 18, crimes) is enough for a PoC.

## 3. Knowledge-graph / embedding architecture

Hybrid, because pure embeddings cannot be certified and pure symbolic graphs
cannot generalize:

```
            statute text + amendment history
                        │
        ┌───────────────┴───────────────┐
        ▼                                ▼
  SYMBOLIC LAYER                   GEOMETRIC LAYER
  legal knowledge graph            certified-Lipschitz encoder
  (concepts, cross-refs,           E: text → R^d, ‖E(x)-E(y)‖ ≤ L·δ_text
   exception edges)                (LipSDP / interval-bound certified)
        │                                │
   d_graph = resistance/             d_embed = ‖·‖ in R^d
   shortest-path distance                │
        └───────────────┬────────────────┘
                        ▼
        d_sem(x,y) = α·d_graph(x,y) + (1−α)·d_embed(x,y)
        I_intent  = { x : g_constraints(x) all hold }  (hard symbolic gate)
        Γ_rep      = nearest x' ∈ I_intent under d_sem (proj. on the lattice)
```

- `d_graph` is a **true metric** by construction (graph distances are). This is
  the trick: anchor metricity in the symbolic layer so that triangle violations
  are confined to, and *measurable in*, the `d_embed` term.
- `Φrec` = repeated `Γrep`∘(local averaging over neighbors). κ is then the
  product of the projection's non-expansion and the averaging's spectral gap —
  this is where you *measure* κ (OP#2).

## 4. How you VERIFY the metric is faithful (the hard part)

Faithfulness = "small `d_sem` ⇔ humans judge meanings close, and large `d_sem`
⇔ humans judge intent has drifted." This is *the* validation and most projects
skip it. Concretely:

1. **Axiom audit (intrinsic):** sample triples (x,y,z); empirically estimate
   the **triangle-violation rate** `P[d(x,z) > d(x,y)+d(y,z)]` and the *max*
   violation. Report it. If max violation > threshold τ, you have a
   semimetric — declare it and invoke the fallback.
2. **Human-agreement (extrinsic):** correlate `d_sem` ranking with expert
   pairwise judgments → **Spearman ρ** and **Kendall τ**. Target ρ ≥ 0.7 to
   claim "faithful."
3. **Drift-detection ROC:** treat `d_sem(application, I_intent) > ε` as a drift
   classifier against the labelled court-ruled drift cases. Report **AUC**;
   target AUC ≥ 0.85.
4. **Conformal calibration:** wrap `d_sem` with a conformal predictor so the
   oracle can *abstain* with a guaranteed error rate (this also discharges part
   of OP#4 — decidable + calibrated).

## 5. Error bounds

- **Lipschitz certificate** on `E`: `‖E(x)−E(y)‖ ≤ L·δ_text(x,y)`, with `L`
  certified by LipSDP/interval-bound propagation → bounds how much paraphrase
  moves `d_embed`.
- **Discretization error** (OP#4): on a finite semantic lattice of resolution
  `h`, `|d_sem − d_sem^h| ≤ C·h`; pick `h` so `C·h < ε/2`.
- **Conformal coverage:** drift classifier error ≤ chosen α (e.g. 5%) with
  finite-sample guarantee.
- **Contraction-after-discretization:** show `κ_h = κ + O(h) < 1` so finitization
  doesn't break the contraction (this is the lemma that ties OP#2 and OP#4).

## 6. Benchmark design

Release **`ConLawDist`**: (statute, application, expert-drift-label, magnitude)
+ paraphrase pairs (for axiom audit) + held-out court-ruled drift cases. Metrics:
triangle-violation rate, Spearman ρ vs experts, drift AUC, conformal coverage.
This benchmark is publishable **on its own** (NeurIPS D&B / FAccT) regardless of
DDR — it de-risks the whole program.

## 7. The falsification experiment

> **Pre-register this:** "There exists a `d_sem` over Title 18 such that (a)
> triangle-violation max < τ, (b) Spearman ρ vs experts ≥ 0.7, and (c) drift
> AUC ≥ 0.85, *and* a `Φrec` with measured κ < 1 under it."
>
> **It is falsified if**, after the full architecture above, the best
> achievable `d_sem` has either (a) triangle violations so large that no
> quotient/repair restores metricity at useful resolution, **or** (b) every
> κ<1 operator destroys faithfulness (ρ collapses below ~0.4 — i.e. the only
> contractions are semantically trivial ones that map everything to one
> blob). Either outcome means **semantic regulation as Banach stabilization is
> the wrong mathematical model**, and the framework's central thesis is empirically
> dead in its current form.

This is the single experiment that yields a result that is *different if the
thesis is false* — it is the spine of the Task 6 PoC.

## 8. Path to a publishable result

- **Now / no dependency:** `ConLawDist` benchmark + the triangle-violation
  measurement → **NeurIPS D&B or FAccT** (≈60% accept with solid data).
- **+9–18 mo:** "A certified pseudometric for statutory intent drift" →
  **\*ACL / CAV** (≈40%).
- **+18 mo:** "Certified contraction toward a legal invariant set" (OP#1+#2
  together, mechanized in Lean) → **CAV / S&P** (≈25%).

## 9. The honest fallback and what it costs

If `d_sem` is only a **pseudometric**: cheapest fallback; equilibrium becomes
unique *up to semantic equivalence* — restate T1/T2/5.2 over `M/∼`. **Cost:
near-zero**, arguably an improvement.

If only a **divergence** (no symmetry/triangle): abandon Banach; move to
**Bregman/mirror-descent fixed-point theory** (information geometry, Task 5).
T1 becomes "Bregman-divergence decreases monotonically to a unique projection"
(true for Bregman projections onto convex sets). **Cost:** every categorical
theorem (3.x, 10.x) is void; convergence is to a *Bregman* fixed point, not a
metric one; "no semantic fork" (T3) is *not* recoverable without convexity of
`I_intent`, colliding with OP#5. This is survivable as *science* but it is a
**different paper and a weaker claim** — and it must be stated as such.
