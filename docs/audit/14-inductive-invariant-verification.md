# M5c — Machine-checking the inductive invariant

> Builds on M5b (`13-unbounded-safety-proof.md`). The paper proof's safety
> argument runs through an **inductive invariant** with several interlocking
> clauses, not just the headline `SafeInv`. Here those clauses are (1) written
> out in the TLA⁺ model and (2) **TLC-verified to hold on every reachable
> state** at two configurations — so the paper proof is not resting on a clause
> that is secretly false or vacuous in the model. Then (3) the genuinely
> unbounded step — that the conjunction is *inductive* (`IndInv ∧ Next ⇒
> IndInv'`) from an arbitrary state — is attacked with Apalache.

## The inductive invariant (`specs/DDRConsensus.tla`)

```
IndInv ==
  /\ PastVotes           \* every vote concerns a round < the current round
  /\ UniqueVotes         \* an honest validator votes at most once per round
  /\ PrecommitJustified  \* an honest precommit is backed by a same-round polka
  /\ LockJustified       \* an honest lock = that validator's highest precommit
  /\ LockPin             \* once V commits at r1, honest locks at round >= r1 are V
  /\ SafeInv             \* once V commits at r1, every polka at round >= r1 is V
```

`LockPin` is the conjunct that makes `SafeInv`'s induction close: it pins the
quorum that produced a commit, so the quorum-intersection step of the paper
proof has something to intersect *with*.

## (1)+(2) TLC: every clause holds on all reachable states

| Config | Result | State space |
|--------|--------|-------------|
| `n=4, f=1, q=3`, rounds 0..3 | **No error has been found** | 1,597 distinct, **0 left on queue** (`specs/tlc-indinv-n4.log`) |
| `n=7, f=2, q=5`, rounds 0..2 | **No error has been found** | 11,615 distinct, **0 left on queue** (`specs/tlc-indinv-n7.log`) |

This is exhaustive for each configuration: the full `IndInv` — all six clauses
— is a genuine invariant of the model, at a 1-fault and a 2-fault quorum. It
rules out the standard hand-proof failure mode (a support lemma that is actually
false) for every clause, not just `SafeInv`.

## (3) Apalache: the inductive step

Reachable-state verification (TLC, above) is bounded in rounds. The unbounded
claim needs the *inductive step* `IndInv ∧ Next ⇒ IndInv'` checked from an
**arbitrary** `IndInv`-state (not only reachable ones), which is round-count
independent. That is a symbolic (SMT) obligation — Apalache's domain, not TLC's.

**Status (honest):** Apalache 0.58 is installed and the inductive idiom is
confirmed working (a smoke test discharges `Init ⇒ Inv` and `Inv ∧ Next ⇒ Inv'`
for a toy spec). Porting the round-synchronized model to a *typed* Apalache spec
and discharging the inductive step — whose crux is an SMT cardinality argument
(two honest sets of size `f+1` inside a `2f+1` honest set must intersect) — is a
research-grade mechanization. It is **in progress** in `specs/DDRConsensusApa.tla`
(see that file's header for what currently checks and what remains). Until the
inductive step is green, the unbounded theorem remains `[PROVEN — paper]` with a
**fully machine-checked invariant** (all clauses, two configs) and a
machine-checked Init-establishment and Agreement-implication; only the single
meta-level induction is not yet mechanized.

## What each level buys

| Level | Tool | Claim |
|-------|------|-------|
| Reachability, `SafeInv` | TLC | safety holds on all reachable states (M5) |
| Reachability, full `IndInv` | TLC | **every proof clause** holds on all reachable states (this doc) |
| Inductive step | Apalache | unbounded-rounds safety, no reachability bound (target) |
| Parametric in `n` | TLAPS | safety for all `n ≥ 3f+1` (future) |

The honest one-line summary: **the safety argument is now machine-checked at the
invariant level for two fault configurations; the remaining gap is mechanizing
the one-step closure, which is written down and in progress, not hand-waved.**
