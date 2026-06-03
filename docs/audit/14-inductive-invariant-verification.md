# M5c — Machine-checked inductive-invariant proof (Apalache)

> **Result:** the consensus safety argument is now **machine-checked as a genuine
> inductive invariant**, not just confirmed on reachable states. Apalache (SMT)
> discharges all three obligations for the `n=4, f=1, q=3` configuration:
>
> 1. `Init ⇒ IndInv` — `specs/tlc-apa-init.log`
> 2. `IndInv ∧ Next ⇒ IndInv'` — the inductive step — `specs/tlc-apa-step.log`
> 3. `IndInv ⇒ Agreement` — `specs/tlc-apa-agree.log`
>
> All three report **"Checker reports no error", EXITCODE OK.** Because the step
> (2) is checked from an *arbitrary* `IndInv` state (not only reachable ones),
> this is a real inductive proof, not a bounded reachability scan.

## The mechanization found a bug in the hand proof

The first inductive-step run produced a **counterexample to induction (CTI)**: a
state satisfying `IndInv` in which two honest validators had *precommitted* `a`
at round 1 but had `locked.has = FALSE`. Such a state is unreachable, yet the
hand-proof invariant admitted it — and from it, those "unlocked" validators
freely prevoted `b` at a later round, forming a conflicting polka and breaking
`SafeInv`.

The fix is the converse of `LockJustified`, now a named conjunct:

```
LockComplete == \A v \in Correct : (\E m \in precommits : m.src = v) => locked[v].has
```

i.e. *an honest validator that has ever precommitted is locked.* With it, a
validator that precommitted `V` at `r1` is pinned (via `LockJustified` +
`LockPin`) to `V`, so it cannot supply the prevote that would form a conflicting
polka — and the inductive step goes through. **This is the value of
mechanization: the paper proof (M5b) relied on this fact implicitly; Apalache
forced it to be stated.** `LockComplete` has been back-ported into the TLC model
and re-verified on all reachable states (n=4: 1,597 states, no error).

## The full inductive invariant (`specs/DDRConsensus.tla`, `specs/DDRConsensusApa.tla`)

```
IndInv ==
  /\ PastVotes           \* votes only concern rounds < the current round
  /\ UniqueVotes         \* an honest validator votes once per round
  /\ PrecommitJustified  \* honest precommit ⇒ same-round prevote polka
  /\ LockJustified       \* honest lock = that validator's highest precommit
  /\ LockComplete        \* honest precommitter ⇒ locked            (found by Apalache)
  /\ LockPin             \* committed V at r1 ⇒ honest locks at round ≥ r1 are V
  /\ SafeInv             \* committed V at r1 ⇒ every polka at round ≥ r1 is V
  /\ DecidedJustified    \* honest decision ⇒ a commit-quorum for that value
```

## Two levels, both now machine-checked

| Obligation | Tool | Configs | Verdict |
|------------|------|---------|---------|
| `IndInv` holds on all reachable states | TLC (exhaustive) | n=4 (1597 states) and n=7 (11615 states) | no error |
| `IndInv` is inductive + implies Agreement | Apalache (SMT) | n=4 | no error (all 3 obligations) |

## Honest scope — what is and isn't covered

- **Covered:** for `n=4, f=1`, `IndInv` is a true, *inductive* invariant and
  implies Agreement — a complete inductive proof, verified symbolically (so the
  step is checked from arbitrary `IndInv` states, the real meaning of
  "inductive"). The proof's invariant is now known to be *correct and complete*
  (the `LockComplete` gap is closed).
- **Round-robustness (corroboration).** The inductive step was re-discharged at
  `MaxRound = 6` (`ConstInit6`, `specs/tlc-apa-step-r6.log`) — **also no error.**
  Since `DoRound` is *round-homogeneous* (no clause depends on the magnitude of
  the round number, only on the guard `r ≤ MaxRound`), passing the inductive step
  from arbitrary states at both `MaxRound = 3` and `MaxRound = 6` is strong
  evidence that inductiveness is independent of the round bound. This is
  corroboration, not a formal unbounded proof — see next.
- **Not yet covered:**
  1. **Unbounded rounds (formally).** Each Apalache config fixes a finite
     `MaxRound`. A *formal* all-rounds result needs an `Apalache`-`Gen` encoding
     with size-bounded (rather than round-bounded) vote sets, or a meta-argument
     for round-homogeneity discharged in TLAPS — a stretch tracked as M5c+.
     **→ Now done:** M5c+ ([`15-unbounded-rounds-verification.md`](15-unbounded-rounds-verification.md))
     re-discharges the inductive step with round numbers as **free integers** (no
     `MaxRound`), via exactly this `Gen`-bounded-cardinality encoding plus the
     round-homogeneity argument. The round-magnitude gap is closed.
  2. **Parametric `n`.** The proof is for `n=4`. All-`n ≥ 3f+1` requires TLAPS
     (a parameterized proof), which the paper argument (M5b §"why `n ≥ 3f+1`")
     supplies by hand but is not yet mechanized.

So the ladder is now: TLC reachability (M5) → full-invariant reachability at two
configs (M5c pt.1) → **machine-checked inductive invariant at n=4 (M5c)** →
**free-integer/unbounded rounds (M5c+, done — doc 15)** → [parametric `n`, TLAPS].
The "by hand" caveat from M5b is removed for the inductive step itself at a
concrete configuration, and the hand proof is now known to be missing nothing
(modulo the parametric generalization).

## Reproduce

```bash
specs/fetch-apalache.sh   # one-time: fetch Apalache
specs/check-induction.sh  # runs the three obligations
```
