# Task 3 — Open Problem Analysis

> **Hardest truth first:** OP#1 (`d_sem`) and OP#2 (κ<1) are not eight equal
> problems — they are *the* problem, twice. OP#3–#6, #8 are engineering or
> standard-math obligations that become tractable the instant OP#1/#2 are
> solved and meaningless until they are. OP#7 (observer fixed-point) is on a
> different epistemic tier: it may not be a well-posed mathematical question
> at all.

Difficulty is calibrated against named hard problems. Timelines are
person-year estimates for a focused 2–4 person team, with 80% confidence
intervals. "Collaborators" are real groups whose published work is adjacent;
*we are not asserting any of them have agreed to anything.*

---

## OP#1 — Semantic Metric Specification (`d_sem`)

- **Why it matters:** It *is* A0 (half). No `d_sem` ⇒ no metric space ⇒ no
  Banach ⇒ no T1/T2/T4/T7/T10. This is the make-or-break primitive (see Task 4).
- **Dependencies:** parent of OP#2, #4, #5, #6, #8. Child of nothing.
- **Difficulty:** **Hard, but not Clay-hard.** Comparable to *learning a
  provably faithful sentence embedding with metric guarantees* — harder than
  standard metric learning (because of the faithfulness/validation problem),
  easier than P vs NP. Calibration: ≈ difficulty of building a *certified*
  robustness metric for NLP, which is an active, partially-solved area.
- **Timeline:** first defensible domain-specific `d_sem` (e.g. statutory
  cross-references): **9–18 months** [CI: 6–30].
- **Pathways:** (1) graph/ontology metric on a legal knowledge graph
  (shortest-path / resistance distance on a curated statute–concept graph);
  (2) learned embedding with a *certified* Lipschitz head + conformal
  calibration; (3) hybrid: symbolic invariants as hard constraints, embedding
  distance for the residual.
- **Fields:** metric learning, formal semantics, legal informatics, conformal
  prediction.
- **Adjacent groups:** Stanford CodeX (legal informatics); MPI-SWS / Max Planck
  (formal methods + semantics); groups working on certified Lipschitz nets
  (e.g. EPFL, MIT CSAIL robustness lines); knowledge-graph embedding labs.
- **Publication:** a faithful, validated `d_sem` + benchmark is a strong
  **\*ACL / NeurIPS D&B / FAccT** paper on its own, independent of DDR.

## OP#2 — Contractivity Verification (κ<1)

- **Why it matters:** the other half of A0. Even with a metric, if `Φrec` is
  not a contraction there is no unique equilibrium and no convergence rate.
- **Dependencies:** child of OP#1 (κ is *defined* w.r.t. `d_sem`).
- **Difficulty:** **Medium-hard, and possibly impossible on a faithful
  metric.** Designing a κ<1 operator is easy (project + shrink); designing one
  that is *both* contractive *and* semantically meaningful (doesn't collapse
  distinctions you care about) is the tension. Calibration: ≈ stability
  analysis / Lipschitz-constant certification of a neural operator — a known,
  partially-solved control-theory/ML problem.
- **Timeline:** a *proven* κ<1 for a toy domain: **6–12 months** [CI: 4–24];
  for a realistic legal domain: **18–36 months** [CI: 12–48].
- **Pathways:** (1) construct `Φrec` as Γrep∘(averaging) and bound κ via the
  Banach–Picard structure of the projection; (2) spectral / Lipschitz
  certification of a learned operator (interval bound propagation, LipSDP);
  (3) accept *quasi*-contraction (κ<1 only outside a ball) → weaker local
  theorems.
- **Fields:** control theory, operator theory, certified ML.
- **Adjacent groups:** control-theory + ML stability groups; certified-Lipschitz
  community.
- **Publication:** combined with OP#1, a **CAV / HSCC** paper ("certified
  contraction toward a semantic invariant set").

## OP#3 — Lean 4 Full Mechanization

- **Why it matters:** it is the *credibility* deliverable — the difference
  between "we claim" and "Lean agrees." Currently only abstract Banach is
  mechanized.
- **Dependencies:** needs OP#1/#2 to mechanize anything *semantic*; enriched
  category theory (for T3) needs Mathlib support that is partial.
- **Difficulty:** **Medium (engineering-heavy).** Abstract parts are easy
  (Mathlib has Banach). The hard part is mechanizing the *constructed* `d_sem`
  and κ bound, plus enriched-category infrastructure.
- **Timeline:** mechanize the abstract layer + one constructed toy metric:
  **3–6 months** [CI: 2–10].
- **Pathways:** (1) stay in `MetricSpace`, avoid enriched CT entirely (drop
  the categorical theorems — recommended); (2) contribute enriched-category
  lemmas to Mathlib (slow, community-gated).
- **Fields:** interactive theorem proving.
- **Adjacent groups:** Lean/Mathlib community; ITP/CPP authors.
- **Publication:** **CPP / ITP** tool/artifact paper once a non-trivial
  semantic theorem is mechanized.

## OP#4 — Semantic Oracle Decidability

- **Why it matters:** on continuous `M`, "`d_sem(·,I) ≤ ε`?" may be
  undecidable / uncomputable; the runtime needs a terminating check.
- **Dependencies:** child of OP#1; sibling of OP#8.
- **Difficulty:** **Medium.** Finitization (discretize `M`) is standard but
  introduces approximation error that must be bounded and shown not to break
  the contraction.
- **Timeline:** decidable finite oracle + error bounds: **4–8 months** [CI: 3–14].
- **Pathways:** (1) discretize to a finite semantic lattice; (2) interval /
  abstract-interpretation bounds on `d_sem`; (3) conformal "abstain" region.
- **Fields:** abstract interpretation, computable analysis.
- **Adjacent groups:** abstract-interpretation labs; computable-analysis
  community.
- **Publication:** folds into the systems/PoC paper.

## OP#5 — Fixed-Point Uniqueness for Non-Convex Invariants

- **Why it matters:** if `Iintent` is non-convex, `Γrep` (nearest-point
  projection) is multi-valued and Banach uniqueness is lost → only *local*
  convergence.
- **Dependencies:** child of OP#1.
- **Difficulty:** **Hard (and partly classical-negative).** Nearest-point
  projection onto non-convex sets is genuinely multi-valued; global uniqueness
  is *false* in general. The honest result is a *local/basin* theorem.
- **Timeline:** a clean local theorem + basin characterization: **6–12 months**
  [CI: 4–20]. A *global* result: likely **never** (it's false as stated).
- **Pathways:** (1) prove local uniqueness on a neighborhood + estimate basin;
  (2) impose geodesic convexity on `Iintent` (restrictive but salvages global);
  (3) prox-regularity conditions from variational analysis.
- **Fields:** variational analysis, differential geometry, optimization.
- **Adjacent groups:** variational-analysis / prox-regularity researchers.
- **Publication:** a **SIAM-J-Optim / nonlinear-analysis** note (modest).

## OP#6 — Cross-Domain Semantic Compositionality

- **Why it matters:** the "two sovereigns / treaty computation" story; needed
  for the *civilization-scale* claim, not for a single-domain PoC.
- **Dependencies:** child of OP#1 (needs metrics on both substrates) + a
  theory of inter-substrate morphisms.
- **Difficulty:** **Hard, and currently under-specified** (no inter-substrate
  morphism is even defined).
- **Timeline:** **24–48 months** [CI: 18–72]; lowest near-term priority.
- **Pathways:** (1) pushout/pullback of metric spaces with a shared sub-ontology;
  (2) optimal-transport coupling between two `d_sem`s; (3) institutional-economics
  modeling (out of scope for formal guarantees).
- **Fields:** category theory, optimal transport.
- **Publication:** speculative; defer.

## OP#7 — Observer Fixed-Point Condition (`Π_C`)

- **Why it matters:** the document calls it "the deepest unresolved theoretical
  gap," inherited from the original CIIR monograph. It is the philosophical
  keystone (the "constrained observer" that makes CIIR *CIIR*).
- **Dependencies:** sits *under* the whole CIIR story; §21.2 admits the spec
  does **not** derive `d_sem`/κ from this constraint geometry.
- **Difficulty:** **Possibly ill-posed.** Until `Π_C` and "constraint geometry"
  are given precise definitions, this is **not yet a mathematical problem**
  (Task 5 treats it as such). Calibration: comparable in *risk* to formalizing
  "the observer" in foundations of QM — decades, contested, maybe undefinable.
- **Timeline:** to even *well-pose* it: **6–18 months** [CI: 4–36]. To *solve*
  a well-posed version: unknown.
- **Pathways:** category-theoretic (fixed point of an observation endofunctor),
  information-geometric, quantum-information, dynamical-systems (Task 5 ranks
  these and names the likely dead end).
- **Fields:** category theory, information geometry, theoretical CS.
- **Publication:** if well-posed and solved, a flagship theory paper; high
  variance.

## OP#8 — Semantic Proof System Completeness

- **Why it matters:** soundness is sketched (11.3); *completeness* (every valid
  transition has a verifiable `π_sem`) is unproven and depends on encoding the
  oracle as a SNARK circuit.
- **Dependencies:** child of OP#1 + OP#4 (need a decidable, arithmetizable
  oracle).
- **Difficulty:** **Medium (crypto-engineering).** Once the oracle is a finite
  decidable circuit, completeness is largely a circuit-construction +
  proof-system property; the folding (T9) is standard (Nova/Halo2/Plonky).
- **Timeline:** **6–12 months** [CI: 4–18] after OP#4.
- **Pathways:** (1) compile the finite oracle to R1CS/AIR; (2) recursive
  folding for O(1) verification; (3) lookup arguments for the metric table.
- **Fields:** zk-SNARKs, recursive proof systems.
- **Adjacent groups:** zkVM / folding-scheme teams (research community around
  Nova/Halo2/Plonky-style systems).
- **Publication:** a **systems-security / zk** paper, folds into the PoC.

---

## Strategic ranking

Score = **(impact if solved, 1–10) × (tractability, 0–1) ÷ (time, years)**.
Impact = how many headline theorems it unlocks. Tractability = P(a focused team
gets a defensible result). Time = median person-years to first defensible
result.

| OP | Impact | Tractability | Time (yr) | Score = I×T÷t | Rank |
|----|:------:|:------------:|:---------:|:-------------:|:----:|
| #1 `d_sem` | 10 | 0.55 | 1.1 | **5.00** | **1** |
| #2 κ<1 | 9 | 0.55 | 0.9 | **5.50** | **1 (tie)** |
| #4 oracle decidability | 6 | 0.75 | 0.5 | **9.00** | — see note |
| #3 Lean mechanization | 5 | 0.85 | 0.4 | **10.6** | — see note |
| #8 proof completeness | 5 | 0.70 | 0.8 | **4.38** | 4 |
| #5 non-convex uniqueness | 4 | 0.45 | 0.8 | **2.25** | 6 |
| #7 observer fixed-point | 9 | 0.15 | 1.5 | **0.90** | 7 |
| #6 cross-domain | 6 | 0.30 | 3.0 | **0.60** | 8 |

**Arithmetic caveat (important):** OP#3 and OP#4 score "highest" by the formula
*only because they are cheap and tractable* — but they are **worthless until
OP#1/#2 exist** (you cannot mechanize or arithmetize a metric you have not
built). So the formula's raw ranking is misleading for sequencing. The
**correct strategic order** is:

1. **OP#1 + OP#2 together** (they are one problem; do them as a unit) — *gates
   everything; the entire program's value is an option on these two.*
2. **OP#4** (decidable oracle) — immediately after, cheap, unlocks the PoC.
3. **OP#3** (mechanize the now-non-trivial theorem) — cheap credibility.
4. **OP#8** (completeness) — productionizes verifiability.
5. **OP#5** (local-uniqueness honesty) — fix the theorem statements.
6. **OP#7, OP#6** — research bets / defer.

> **The decision rule:** spend the first 6 months attacking OP#1/#2 on **one**
> narrow domain. If you cannot get a faithful `d_sem` with a *measured* κ<1
> there, the rest of the program does not begin. Everything else is downstream
> of that single experiment.
