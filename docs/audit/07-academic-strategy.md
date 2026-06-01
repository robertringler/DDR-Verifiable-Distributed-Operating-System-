# Task 8 — Academic Strategy

> **Hardest truth first:** there is **no flagship paper here today** — not
> because the work is bad but because the only proven theorem is Banach and the
> interesting theorems are conditional on unbuilt objects. The publishable
> units *now* are (1) a vision/SoK paper that is honest about being a program,
> and (2) the `d_sem` benchmark, which stands alone. Everything strong is gated
> on OP#1/#2. Pretending otherwise gets you desk-rejected and remembered.

## Minimum publishable units — NOW (no open-problem dependency)

| MPU | Core claim | Venue tier | Accept prob. | Why it doesn't depend on OPs |
|-----|-----------|------------|:------------:|------------------------------|
| **A. SoK / vision** | "Semantic intent-drift as a verifiable property: a framework and its open problems" | workshop / SoK track (e.g. a security or PL workshop, or arXiv + FAccT-adjacent) | **55–70%** | It *is* the framework + honest open list; reviewers reward the honesty if novelty of *framing* is argued well |
| **B. Benchmark** | `ConLawDist`: a dataset + metric-axiom audit for statutory intent-drift | NeurIPS/ICLR Datasets & Benchmarks, or FAccT | **50–65%** | Pure data + measurement; no theorem needed |
| **C. Determinism note** | Deterministic semantic replay as a corollary of functorial determinism | short paper / workshop | **40%** | True but tautological (T8); only publishable as a small systems note |

## MPUs gated on open problems

| MPU | Core claim | Venue | Gated on | Accept prob. (post-gate) |
|-----|-----------|-------|----------|:------------------------:|
| **D. Certified pseudometric** | "A faithful, certified-Lipschitz `d_sem` for legal intent" | *ACL / CAV | OP#1 | 40% |
| **E. Certified contraction** | "Provable κ<1 stabilization toward a legal invariant set" | CAV / HSCC | OP#1+#2 | 30% |
| **F. Mechanized semantic theorem** | "A Lean-verified semantic-stability theorem (not abstract Banach)" | CPP / ITP | OP#1+#2+#3 | 35% |
| **G. zk semantic proofs** | "Recursive zk proofs of semantic-invariant preservation" | S&P / CCS / USENIX Sec | OP#1+#4+#8 | 20–30% |
| **H. Observer fixed-point** | "Well-posing CIIR's observer fixed-point as a closure operator" | LICS / theory venue | OP#7 | 15% (high variance) |
| **I. Flagship** | "Verifiable semantic regulation of distributed governance" (the whole thesis, validated) | S&P / PODC | OP#1,#2,#3,#4,#8 + PoC pass | 10–15% |

## 24-month roadmap

| Mo | Paper (title) | Core claim | Venue | OP dependency | Accept prob. |
|----|---------------|-----------|-------|---------------|:------------:|
| 0–4 | *"Semantic Intent-Drift as a Verifiable Property: A Framework and Eight Open Problems"* | the framing is a useful research program; here is the honest theorem ledger | arXiv → SoK/workshop | none | 55–70% |
| 4–9 | *"ConLawDist: Benchmarking Statutory Intent-Drift Distance"* | a dataset + the triangle-violation measurement for `d_sem` | NeurIPS D&B / FAccT | none | 50–65% |
| 9–15 | *"A Certified Pseudometric for Legal Intent"* | hybrid graph+Lipschitz `d_sem`, validated ρ≥0.7, AUC≥0.85 | *ACL / CAV | OP#1 | 40% |
| 12–18 | *"Certified Contraction Toward a Semantic Invariant Set"* | measured/proven κ<1 + Lean-mechanized abstract core | CAV / HSCC | OP#1+#2(+#3) | 30% |
| 18–24 | *"Recursive zk Proofs of Semantic-Invariant Preservation"* | arithmetized oracle + folding, O(λ) verification | CCS / USENIX Sec | OP#1+#4+#8 | 20–30% |
| 18–24 (stretch) | *"Well-Posing the CIIR Observer Fixed-Point"* | closure-operator formulation (Task 5) | LICS / arXiv | OP#7 | 15% |

**Sequencing logic:** lead with honesty (papers 1–2 need no OP solved and build
credibility + the benchmark asset), then convert OP#1/#2 into the two
mid-program papers, then the crypto and theory bets. Paper 1 must *cite its own
audit* — a program committee that sees the authors already know the gaps is far
more likely to accept the framing.

**What to NOT submit:** the current spec as a "ten theorems" results paper to
CAV/S&P. It will be rejected on the Task 2 findings (Banach re-labeling +
broken category theory) and burn referee goodwill you will want later.
