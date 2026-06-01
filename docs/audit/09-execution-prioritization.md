# Task 10 — Execution Prioritization

> **Hardest truth first:** almost every action in Tasks 6–9 is *downstream of a
> single experiment* — can you build a faithful `d_sem` on one domain with a
> measured κ<1? Until that verdict exists, spending on consensus, zk, multi-node,
> or fundraising is buying options on a foundation you haven't tested. Prioritize
> the experiment that can *kill the thesis cheapest*.

## Priority matrix

Impact, leverage, risk-reduction: 1–5 (5 best). Time: weeks. Capital: relative.

| Action | Impact | Time (wk) | Capital | Strategic leverage | Risk reduction | Verdict |
|--------|:------:|:---------:|:-------:|:------------------:|:--------------:|---------|
| **Build PoC measurement loop (Task 6, Wk1–2)** | 4 | 2 | $ | 5 | 5 | **DO FIRST** |
| **`d_sem` + κ̂ experiment on Title 18 (Task 4/6, Wk3–11)** | 5 | 9 | $$ | 5 | 5 | **THE crux** |
| Fix theorem statements (T7 δ/(1−κ), 15.2, delete 3.3/3.8/10.3) | 3 | 1 | $ | 4 | 5 | **DO NOW (cheap credibility)** |
| Publish honest SoK + open-problems paper | 3 | 6 | $ | 4 | 3 | Do in parallel |
| Release `ConLawDist` benchmark | 4 | 8 | $$ | 4 | 4 | High value, standalone |
| Well-pose OP#7 as closure operator (Task 5 M1–M2) | 3 | 8 | $ | 3 | 3 | Research bet, parallelizable |
| Mechanize abstract Banach in Lean (already ~done) | 2 | 2 | $ | 2 | 2 | Quick win, low novelty |
| Build zk semantic prover | 3 | 12+ | $$$ | 3 | 1 | **Defer** until d_sem verdict |
| Build HotStuff / consensus integration | 1 | 12+ | $$$ | 1 | 1 | **Defer** (re-proves known) |
| Cross-domain compositionality (OP#6) | 2 | 24+ | $$$ | 2 | 1 | **Defer / drop** |
| Fundraise a priced equity round | 2 | 8 | — | 2 | 1 | **Wait for the verdict** |

## Single highest-value action by horizon

### 7-day horizon
**Action:** Ship the PoC *measurement harness* (`cargo run -p ciir-eval` on a
synthetic corpus, Task 6 Wk-2 contract) **and** fix the four broken/erroneous
theorem statements in the spec (delete 3.3/3.8/10.3 as unproven; correct T7 to
the `δ/(1−κ)` ball; restate 15.2 as bounded, not eliminated, equivocation).
**Reasoning:** both are days of work, both raise credibility immediately, and
the harness is the instrument every later experiment plugs into — you cannot
get a thesis verdict without it.
**Opportunity cost:** a week not spent on the real `d_sem`; acceptable because
the harness *is* the prerequisite for that work and the theorem fixes prevent a
reviewer from dismissing everything on first contact.

### 30-day horizon
**Action:** Stand up the **real-corpus `d_sem` pipeline** — Title 18 loader,
legal KG + shortest-path `d_graph` (the true-metric anchor), and the
**triangle-violation audit**. Produce the first empirical answer to "is
meaning-distance even a (pseudo)metric here?"
**Reasoning:** this is the cheapest test that can *kill the thesis*. A large,
irreducible triangle violation at month 1 saves you 23 months. A small one
green-lights the whole program.
**Opportunity cost:** you are not yet building the embedding layer, the
oracle, or any paper beyond the SoK; if the triangle audit passes you'll be a
few weeks "behind" on those — a trivial cost against the information gained.

### 90-day horizon
**Action:** Complete the **full PoC decision rule** (Task 6 §1): faithful
hybrid `d_sem` (ρ≥0.7, AUC≥0.85) **with a measured κ̂<1**, run head-to-head
against the syntactic baseline, and publish the verdict — *including if it
contradicts the thesis*.
**Reasoning:** this is the go/no-go for the entire venture and academic program.
A pass justifies the seed round, the CAV/S&P paper track, and the sovereign
briefing's go recommendation. A fail redirects the whole effort to the
computational layer (or returns capital) — which is a *successful* 90 days,
because it's the truth, found cheaply.
**Opportunity cost:** 90 days not spent building consensus/zk/multi-node
infrastructure or raising a large round. That is precisely the right thing to
forgo: all of it is worthless if the 90-day verdict is negative, and all of it
is well-funded and easy to start if the verdict is positive.

## The one-sentence strategy

Spend the next quarter trying to **falsify your own central thesis on one narrow
domain as cheaply as possible**; everything else — proofs, crypto, consensus,
fundraising, "civilization scale" — is an option that only pays off if that
single experiment survives, and is wasted effort if it doesn't.
