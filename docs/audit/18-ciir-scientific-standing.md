# 18 — Where CIIR stacks up against the leading theories in science

> **Task.** A calibrated, evidence-based placement of the CIIR program against the
> actual frontier of science — a league table with CIIR located in it, not a verdict
> by adjective. Scores are on a fixed 0–10 ruler where **10 = the best work in the
> history/frontier of science**, the same calibration used in
> `00-executive-evaluation.md`.
>
> **Sources.** All CIIR facts are cited to the primary-source-derived audit
> (`docs/audit/00–11`) and this session's results — the formal implementation
> (`docs/audit/17`), Theorem K (`papers/theorem-k/`), and ConLawDist
> (`papers/conlawdist/`). No CIIR achievement is invented.
>
> **Tags.** `[E]` established from cited facts · `[J]` defensible expert judgment ·
> `[C]` contested (dissent recorded).

---

## 0. The ruler — dimensions and rubrics

A scientific theory is judged on operationalizable dimensions, not on ambition.
Each is scored 0–10; **10** is anchored to the single best example in science.

| # | Dimension | What 10 looks like | What 0–2 looks like |
|---|-----------|--------------------|---------------------|
| D1 | **Empirical confirmation** | confirmed novel predictions to many digits (QED `g−2`) | no empirical test ever run |
| D2 | **Predictive novelty** | predicted unknown phenomena later observed (Higgs, GW) | "predicts" only its own simulation outputs |
| D3 | **Falsifiability** | a single clean experiment could kill it | compatible with any observation |
| D4 | **Mathematical depth** | births new mathematics (mirror symmetry) | re-skins standard textbook results |
| D5 | **Scope / unification** | many phenomena from few principles | one phenomenon, or "everything" by vacuity |
| D6 | **Parsimony** | few assumptions, no ad hoc parts | freely tunable to fit anything |
| D7 | **Internal consistency** | no known errors in decades | contains false theorems / sign errors |
| D8 | **Originality (net of re-labels)** | a genuinely new idea | renamed standard results |
| D9 | **Fruitfulness** | spawns fields, tools, instruments | generates little beyond itself |
| D10 | **Maturity** | stress-tested by a global community for decades | single-author, unreviewed |

---

## 1. Anchor scorecard — the calibration (real leading theories)

Scoring the anchors first fixes the ruler so CIIR is graded on the same scale. `[J]`
throughout (these are textbook-consensus calls; precise to ±1).

| Theory | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | ~avg |
|--------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Standard Model (QFT)** | 10 | 10 | 10 | 9 | 9 | 6 | 9 | 10 | 10 | 10 | **9.3** |
| **General Relativity** | 10 | 10 | 10 | 9 | 9 | 9 | 10 | 10 | 9 | 10 | **9.6** |
| **Quantum mechanics** | 10 | 10 | 9 | 9 | 9 | 7 | 9 | 10 | 10 | 10 | **9.3** |
| **Statistical mechanics** | 10 | 9 | 9 | 8 | 9 | 8 | 9 | 9 | 9 | 10 | **9.0** |
| **Darwinian evolution** | 9 | 9 | 8 | 5 | 10 | 8 | 8 | 10 | 10 | 10 | **8.7** |
| **Shannon information theory** | 9 | 8 | 8 | 9 | 8 | 9 | 10 | 10 | 10 | 10 | **9.1** |
| **Lindblad / open quantum systems** | 8 | 6 | 7 | 7 | 6 | 7 | 9 | 7 | 8 | 9 | **7.4** |
| **Information geometry** | 6 | 5 | 5 | 8 | 6 | 7 | 9 | 8 | 7 | 8 | **6.9** |
| **BFT consensus theory (CS)** | 8 | 6 | 8 | 7 | 5 | 7 | 9 | 8 | 9 | 9 | **7.6** |
| **String theory** | 0 | 1 | 2 | 10 | 8 | 4 | 8 | 9 | 9 | 8 | **5.9** |
| **Loop quantum gravity** | 0 | 1 | 2 | 8 | 5 | 5 | 7 | 7 | 6 | 6 | **4.7** |

Two calibration lessons fall out, and both bear on CIIR:
- **Empirical confirmation dominates.** String theory has top-tier *mathematics*
  (D4=10) yet sits at 5.9 overall because D1–D3 are near zero. *Math depth does not
  substitute for confirmation.*
- **Engineering theories score well by being checkable.** BFT consensus (7.6) is not
  fundamental physics but earns its place through falsifiable, deployed, machine-
  checkable guarantees — the lane the DDR substrate actually competes in.

---

## 2. CIIR scorecard — disaggregated into four layers

CIIR is not one object; a single score would be a lie. Four layers, scored separately.

### Layer (i) — DDR computational substrate (BFT consensus + deterministic exec + attestation)

| D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | ~avg |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 7 | 4 | 8 | 6 | 4 | 7 | 9 | 4 | 6 | 5 | **5.4** `[E]` |

*Justification.* This is the part that legitimately competes. The lock-rule safety is
**machine-checked** — TLC exhaustive, Apalache inductive, and a TLAPS-verified
parametric `n=3f+1` quorum-intersection core (`docs/audit/12–16`). D7=9 (verified, not
asserted), D3=8 (the "lock off ⇒ counterexample" test is a real falsifier). D8 is low
(4): it re-derives HotStuff/Tendermint-class safety, not new consensus. *Nearest peer:
a solid formal-methods/PODC engineering result* — below the field's best (which prove
liveness + parametric safety end-to-end with no omitted leaves) but real.

### Layer (ii) — CIIR operator-algebra / physics core (Polish space, GKLS dynamics, C\* decomposition)

| D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | ~avg |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | 1 | 3 | 4 | 3 | 4 | 4 | 3 | 4 | 2 | **2.9** `[E]` |

*Justification.* Competent but standard: Polish reality space, CP/TP interface map,
finite-dim C\* block decomposition, GKLS/Lindblad semigroup — all **correct, all
textbook** (`docs/audit/11` §1, §4). D4=4 and D8=3: *zero novel proven theorems*; the
results are classical theorems re-applied. D7=4 is dragged down hard: the monograph's
**own red-team rates its novel dynamics "fatal if physical"** (non-CP matrix-log
generator, `docs/audit/11` §4), and its strict-contraction keystone is **false** —
Theorem K proves the observer map `ρ^β/Tr(ρ^β)` fixes both `I/d` and every pure state,
so it is not a strict contraction (`papers/theorem-k/`). *Nearest peer: a competent
applied-open-quantum-systems paper* — except one with a refuted central lemma.

### Layer (iii) — CIIR semantic-governance thesis (`d_sem`, `Φ_rec` contraction toward `I_intent`)

| D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | ~avg |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 0 | 1 | 4 | 3 | 4 | 4 | 5 | 4 | 4 | 2 | **3.1** `[E]/[J]` |

*Justification.* D1=0: **no empirical test has ever been run** — the central objects
(`d_sem`, `κ<1` on intents) were *unconstructed* (`docs/audit/00`, dim 8). This session
moved it: `d_sem` is now a *constructed* complete metric and `Φ_rec` a *proven* `κ=1−δ`
contraction (`docs/audit/17` §2.1–2.2), and ConLawDist gives it a **real falsifier**
(`papers/conlawdist/`), lifting D3 to 4. But faithfulness to actual legal intent —
the thing that would make it science — remains untested. D8=4: the *framing*
(intent-drift as contraction toward an invariant set) is the one genuinely novel idea,
but it is a research agenda, not a result (`docs/audit/00`, Finding 1, **conceded**).

### Layer (iv) — the cross-domain "theory of everything" claim

| D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | D10 | ~avg |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 0 | 0 | 1 | 2 | 2 | 2 | 2 | 2 | 1 | 1 | **1.3** `[E]` |

*Justification.* This is the weakest layer and must not be confused with the others.
The Scope Theorem (`docs/audit/17` §10) proves a framework permissive enough to model
**every** domain — the monograph formalizes **astrology** (ch19, `docs/audit/11` §4) —
has **no falsifiable content** (D3≈1): breadth bought at the price of forbidding
nothing. D5 looks like it should be high ("everything") but unification-by-vacuity
scores ~2, not 10: it explains nothing *because* it excludes nothing. *Nearest peer:
not a scientific theory at all, but a modeling meta-language.*

---

## 3. The league table

Ranked by the ruler. CIIR's four layers placed among the anchors.

| Rank | Theory / layer | ~avg | Tier |
|:--:|----------------|:--:|------|
| 1 | General Relativity | 9.6 | **Confirmed frontier** |
| 2 | Standard Model | 9.3 | Confirmed frontier |
| 2 | Quantum mechanics | 9.3 | Confirmed frontier |
| 4 | Shannon information theory | 9.1 | Confirmed frontier |
| 5 | Statistical mechanics | 9.0 | Confirmed frontier |
| 6 | Darwinian evolution | 8.7 | Confirmed frontier |
| 7 | BFT consensus theory | 7.6 | **Confirmed engineering** |
| 8 | Lindblad / open quantum systems | 7.4 | Confirmed applied |
| 9 | Information geometry | 6.9 | Confirmed applied |
| 10 | String theory | 5.9 | **Unconfirmed, math-rich** |
| 11 | Loop quantum gravity | 4.7 | Unconfirmed |
| — | **DDR substrate (CIIR layer i)** | **5.4** | **Young engineering** |
| — | **CIIR semantic thesis (layer iii)** | **3.1** | **Nascent agenda** |
| — | **CIIR physics core (layer ii)** | **2.9** | Competent-but-standard, keystone refuted |
| — | **CIIR "TOE" claim (layer iv)** | **1.3** | **Not yet science** |

---

## 4. Where CIIR competes — and where it does not compete at all

**Competes legitimately:**
- **DDR substrate (5.4)** sits credibly among *young engineering theory*, just below
  deployed BFT consensus (7.6). It is **machine-checked**, which most academic
  consensus papers are not — a genuine, if narrow, strength. `[E]`

**Competes weakly but honestly:**
- **The semantic thesis (3.1)** is a *legitimate early research agenda* — comparable to
  a pre-empirical modeling program in computational social science. It is in the same
  epistemic position as string theory in *one* respect only (no confirmation), but
  **far below** it on the dimension string theory earns its keep on (mathematical
  depth: CIIR D4≈3 vs string D4=10). It does **not** compete with any confirmed theory. `[J]`

**Does not compete at all:**
- **The physics core (2.9)** is correct but unoriginal, and its one novel dynamical
  claim is self-rated "fatal if physical" and its uniqueness keystone is *refuted*
  (Theorem K). It is not a contender against Lindblad theory; it is *an application of
  it with a broken lemma*. `[E]`
- **The "theory of everything" claim (1.3)** is not on the scientific table. By the
  Scope Theorem it forbids no observation; a theory of everything that is consistent
  with *anything* (including astrology) explains nothing. This layer should be
  **retired**, not defended. `[E]`

---

## 5. Verdict, and the shortest path up a tier

**Verdict `[J]`.** Measured on the ruler the frontier is actually judged by, CIIR as a
*unified scientific theory* does not stack up against the leading theories of science —
it is **1–3 tiers below**, and its grand "theory of everything" framing is below the
threshold of science entirely. The honest, defensible reading is the audit's, now
reinforced by formal work: **CIIR is not one theory but a stack**, and the stack's
value is *bimodal*. The **DDR engineering substrate is real and verified** and competes
in its lane; the **semantic-governance thesis is a worthwhile but pre-empirical
agenda**; the **physics core is competent but unoriginal with a refuted keystone**; and
the **cross-domain TOE claim is vacuous and should be dropped**. The single most
important fact is calibration: *no amount of operator-algebra packaging substitutes for
a confirmed novel prediction*, and CIIR currently has **zero** (D1=0 on the layers that
carry the grand claim) — the same wall that holds string theory at 5.9 despite
world-class mathematics holds CIIR far lower, because CIIR lacks the mathematics too.

**Shortest path up a tier (each is concrete and already scaffolded):**
1. **Run ConLawDist on real data.** A measured `d_sem` with Spearman ρ≥0.7 and drift
   AUC≥0.85 on one statutory Title moves the semantic thesis D1 from 0 → ~5 and lifts
   layer (iii) from *nascent agenda* toward *confirmed applied* — the biggest single
   jump available. (`papers/conlawdist/`, gated only on expert labels.)
2. **Publish Theorem K.** A clean, mechanized refutation of the monograph's own keystone
   raises the *program's* D7/D9 (it is real, checkable science) even though it is
   negative — and establishes the work as rigorous rather than overclaiming.
3. **Retire layer (iv).** Deleting the cross-domain/astrology "everything" claim removes
   the largest D3/D7 drag on the whole stack; a smaller, falsifiable theory scores
   higher than a universal, vacuous one.
4. **Finish the DDR proof.** Discharging the 14 omitted TLAPS protocol leaves
   (`docs/audit/16`) takes layer (i) from 5.4 toward the 7s of deployed consensus —
   the only layer with a short path into a *confirmed* tier.

The arithmetic is shown; the placement is defensible to ±1 per cell; and the path up is
empirical, not rhetorical. `[E]/[J]`
