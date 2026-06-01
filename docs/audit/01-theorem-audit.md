# Task 2 — Theorem Audit

> **Hardest truth first:** of the ~22 named results, **0 are [PROVEN] and
> non-trivial as stated.** The non-vacuous ones are [CONDITIONAL] on objects
> (`d_sem`, `κ<1`, the Sem–Ont adjunction) that are unbuilt; the trivial ones
> are [VACUOUS]; and four contain outright errors. The single most-cited proof
> phrase in the document is *"By the Banach fixed-point theorem."*

Each row is **our** classification, produced by reading the proof, not the
theorem environment. "Load-bearing assumption" names the thing that, if false,
voids the row. "Breaks downstream" names what else falls.

## Master table

| # | Theorem | Claim (1 line) | Class | Load-bearing assumption | Breaks downstream if false |
|---|---------|----------------|-------|--------------------------|----------------------------|
| 2.4 | Def: Φrec contractive | An endofunctor with Lipschitz κ<1 under d_sem exists | **[ASSERTED]** (definition asserting existence) | `d_sem` is a metric; κ<1 achievable | Everything below |
| 3.3 | CIIR Functor Well-Definedness | Frec = Γrep∘Φrec∘(–) is a functor preserving comp. | **[ASSERTED — likely FALSE]** | Γrep∘Φrec composes through F | 3.8, T6 |
| 3.6 | Epistemic Convergence as Colimit | Metric limit of Φrec-chain *is* the categorical colimit | **[ASSERTED — category error]** | ω-colimit = Cauchy limit | T2, T3 |
| 3.8 | Naturality of Repair | η̂ is a natural transformation | **[ASSERTED — likely FALSE]** | Γrep, Φrec natural in Sem | T6 |
| 3.10 | Invariant Propagation | Finv is a (lax) monoidal functor | **[SKETCH]** | ⊗sem well-defined; Λsem monoidal | T5 |
| 3.12 | Semantic Replay Determinism | det∘det = det on traces | **[VACUOUS]** (tautology) | Fsem, Γrep computable | — |
| 5.2 | Unique Semantic Equilibrium | ∃! fixed point σ\* ; κ^k convergence | **[CONDITIONAL]** (= Banach, re-labeled) | Mintent complete; κ<1; d_sem metric | T1,T2,T4,T7,14.2 |
| 5.4 | Semantic Consensus Safety | Committed blocks lie in Iintent | **[VACUOUS]** ("by construction" of the check) + **[CONDITIONAL]** on oracle decidability | Oracle check terminates (OP#4) | — |
| 7.2 | Constitutional Semantic Continuity (T4) | Gov trajectory stays within εconst, →Iintent | **[CONDITIONAL]** | κ<1; Psem decidable | T4 implications |
| 8.2 | Semantic AI Correctness (5-way) | 5 checks jointly satisfiable, non-contradictory | **[ASSERTED — non-sequitur]** | "independent ⇒ jointly satisfiable" | 5-way fabric claim |
| 9.2 | Recursive Governance Coherence (T5) | Composed gov transitions preserve all invariants | **[CONDITIONAL]** on 3.10 | Finv monoidal; Fsem functorial | T5 implications |
| 10.2 | Semantic Colimit Preservation (T3) | Fsem preserves the consensus colimit | **[CONDITIONAL]** on 10.3 | Fsem is a left adjoint | T3, T10 |
| 10.3 | Sem–Ont Adjunction | Fsem ⊣ Font, Font gives *unique* realization | **[ASSERTED — "unique" likely FALSE]** | Each semantic state has a unique DDR realizer | 10.2, T3 |
| 11.3 | Semantic Proof Soundness | zk-verify ⇒ invariants held w.h.p. | **[CONDITIONAL]** | Circuit faithfully encodes d_sem≤ε | T9, T10 |
| 12.2 | Semantic Deterministic Replay (T8) | Nodes replay identical semantic traces | **[VACUOUS]** (tautology) + CONDITIONAL on WASM-determinism of oracle | Oracle is a deterministic WASM module | — |
| 13.1 | T1 Semantic Stability | d_sem(Σ^k, I) ≤ κ^k·C | **[CONDITIONAL]** (= Banach) | κ<1; d_sem metric | T4, T7 |
| 13.2 | T2 Recursive Epistemic Convergence | All trajectories reach unique σ\* | **[CONDITIONAL]** (= Banach via 3.6) | κ<1; 3.6 valid | T10 |
| 13.6 | T6 Intent Preservation under Refinement | Refinement preserves intent | **[VACUOUS]** until `IntentPreserving` defined; CONDITIONAL on DDR ⊑ (unseen) | 3.8 naturality; DDR refinement | — |
| 13.7 | T7 Adversarial Drift Containment | Drift detected/repaired to within ε | **[SKETCH — arithmetic ERROR]** | δ/(1−κ) ≤ ε (not stated) | T7 implications, 15.1 |
| 13.9 | T9 Recursive Semantic Compression | Whole semantic history → O(λ) proof | **[SKETCH]** (= Nova/Halo folding, re-labeled) | Oracle expressible as SNARK circuit (OP#8) | T10 |
| 13.10 | T10 Global Epistemic Verifiability | External verifier checks all in O(λ²) | **[CONDITIONAL]** on T9 + DDR Vol III | everything above + unseen DDR thm | top-level claim |
| 14.2 | Distributed Epistemic Stability | Nodes converge in ⌈log_κ⌉ rounds post-GST | **[CONDITIONAL]** (= Banach + GST) | κ<1; partial synchrony | — |
| 15.1 | Semantic Drift Resistance | f<n/3 cannot cause permanent drift | **[CONDITIONAL]** inherits T7's error | δ/(1−κ) ≤ εconst | — |
| 15.2 | Semantic Equivocation Resistance | Two valid outputs ⇒ *identical* equilibria | **[ASSERTED — FALSE as stated]** | non-expansion ⇒ equality (it doesn't) | equivocation claim |
| 16.2 | O(1) Semantic Civilization Verification | Recursive semantic proof is O(λ) | **[SKETCH]** (= recursive SNARK, re-labeled) | OP#8 completeness; in-circuit d_sem | T10 |

## Errors found by reading the proofs (not just the gaps)

1. **3.3 / 3.8 — the functor is not a functor.** `Frec(F) = Γrep∘Φrec∘F`.
   Functoriality demands `Frec(G∘F) = Frec(G)∘Frec(F)`, i.e.
   `Γrep∘Φrec∘G∘F = (Γrep∘Φrec∘G)∘(Γrep∘Φrec∘F)`. That requires inserting an
   extra `Γrep∘Φrec` in the middle "for free," which holds only if `Γrep∘Φrec`
   is the identity on the relevant image — it is not (Φrec is a *strict*
   contraction, κ<1, so `Φrec ≠ id` unless the space is a point). The "proof"
   waves at "both are retractions"; Φrec is **not** a retraction. *Category
   Theorist: this is the clearest defect in the manuscript and it needs no
   `d_sem`.* **[ASSERTED — likely FALSE]**

2. **3.6 — colimit ≠ metric limit.** A contraction's Cauchy limit is a
   completion/limit phenomenon; the categorical colimit of the ω-chain
   `Σ⁰→Σ¹→…` in `Sem` is a different universal object and generally does **not**
   coincide with `lim_k Φ^k`. The "universal property" argument conflates the
   two. Even calling the metric limit a colimit requires `Sem` to be set up so
   that sequential colimits compute as completions — never established.

3. **10.3 — "unique realization" is false.** `Font` is claimed to send each
   semantic state to *the unique* DDR state realizing it. Semantic
   abstraction is many-to-one by design (that is the point of an *ontology*);
   a right adjoint need not be a section. The adjunction `Fsem ⊣ Font` is
   asserted with no unit/counit, no triangle identities. T3 (colimit
   preservation) inherits this.

4. **T7 — the geometric series does not go to zero.** The sketch: adversary
   injects ≤δ per round, repair contracts by κ; "net drift after n rounds:
   δ(1−κ)⁻¹κⁿ → 0." The standing drift of *continuously re-injected* error is
   `δ·Σ_{i=0}^{n} κ^i → δ/(1−κ)`, a **positive constant**, not 0. The system
   is stable to a *ball of radius δ/(1−κ)*, which is the correct and useful
   claim — but the theorem as written ("repaired to within ε") is only true
   under the unstated side condition `δ/(1−κ) ≤ ε`. Same error propagates to
   15.1.

5. **15.2 — "identical" should read "within 2κ·εAI".** Non-expansion gives
   `d(Γrep y, Γrep y') ≤ d(y,y') ≤ 2εAI`. That bounds the gap; it does not make
   the equilibria equal. Equivocation is *bounded*, not *eliminated*. The
   security claim is overstated by exactly the radius of the ball.

6. **8.2 — independence ⇏ joint satisfiability.** Two checks on disjoint
   domains can both *reject* the same object; "they cannot conflict" does not
   imply a witness satisfying both exists. The theorem is a non-sequitur; the
   true (weaker) statement is "the conjunction is well-defined," which is
   vacuous.

## What is *legitimately* fine

- **T8 / 3.12 (determinism):** correct, but tautological — composition of
  deterministic maps is deterministic. Not a contribution.
- **5.2 (Banach):** mathematically correct **given** the hypotheses. It is the
  1922 Banach contraction theorem in new notation. Honest novelty: ~0.
- **The Lean skeleton (17.1):** `unique_semantic_equilibrium` and
  `semantic_stability` are real, will compile against Mathlib's
  `contraction_mapping_fixed_point` — because they *are* Banach. They prove
  nothing about semantics; they prove Banach for an abstract `RecursiveStabilizer`
  whose `kappa<1` is a *hypothesis*, not a constructed fact.

## Dependency graph of the 5 most load-bearing results

```
            ┌─────────────────────────────────────────────┐
            │  ASSUMPTION A0:  d_sem is a genuine metric on │
            │  Mintent  AND  Φrec has κ<1 under d_sem       │   ← Open Problems #1, #2
            └───────────────┬─────────────────────────────┘
                            │ (Banach)
              ┌─────────────┼──────────────────────────┐
              ▼             ▼                           ▼
        5.2 Unique     T1 Stability               T2 Convergence
        Equilibrium    (13.1)                     (13.2, via 3.6)
              │             │                           │
              ▼             ▼                           ▼
        T4 Const.      T7 Drift                   T3 Colimit Preserv.
        Continuity     Containment                (10.2, needs 10.3 adjunction)
        (7.2)          (13.7, has error)               │
              │             │                           ▼
              └─────────────┴───────────► T10 Global Epistemic Verifiability
                                          (13.10, also needs T9 + DDR Vol III)
```

The **five most load-bearing**: A0 (d_sem + κ), 5.2, T1, T3, T10.

## The single assumption whose failure collapses the most

> **A0: that `d_sem` exists as a genuine metric on `M_intent` and that `Φ_rec`
> is a contraction (κ<1) under it.**

If A0 fails (and it is *unconstructed and open*), the following become
vacuous or false simultaneously: 2.4, 5.2, 5.4, 7.2 (T4), 13.1 (T1), 13.2
(T2), 13.7 (T7), 14.2, 15.1, 16.2, 10.2 (T3, also via the adjunction), and
13.10 (T10). That is **every non-trivial semantic theorem in the document.**
The category-theory defects (3.3, 3.8, 3.6, 10.3) are an *additional*,
independent failure mode that survives even if A0 is someday discharged.

**Bottom line for a program committee:** this is, today, a *definitional
framework plus the Banach theorem*. The interesting science — building `d_sem`
and proving κ<1 — has not yet been done, and the document says so.
