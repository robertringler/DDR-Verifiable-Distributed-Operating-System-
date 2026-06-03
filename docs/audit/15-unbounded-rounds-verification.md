# M5c+ — Unbounded-rounds inductive proof (free-integer rounds, Apalache)

> **Result:** the consensus inductive step `IndInv ∧ Next ⇒ IndInv'` is now
> machine-checked with **round numbers as free, arbitrary-magnitude integers** —
> there is no `MaxRound` anywhere in the model. This closes the round-magnitude
> gap left open by M5c (`14-inductive-invariant-verification.md`), where each
> Apalache run fixed a finite round horizon and round-independence was only
> *corroborated* (at `MaxRound ∈ {3, 6}`).
>
> Spec: `specs/DDRConsensusUnbounded.tla`. Reproduce: `specs/check-unbounded.sh`.

## What "unbounded rounds" means here, precisely

The M5c encoding (`DDRConsensusApa.tla`) draws every vote from
`AllVotes == {MkV(rr, vv, v) : rr ∈ 0..MaxRound, ...}`. That single `MaxRound`
constant bounds **two different things at once**:

1. the **magnitude** of round numbers (rounds are `0..MaxRound`); and
2. the **cardinality** of the vote configuration (at most
   `(MaxRound+1)·|Values|·|Validators|` distinct votes can exist).

These are independent concerns, and only (1) is the "unbounded rounds" question.
This module **decouples them**:

| | round magnitude | vote-set cardinality |
|---|---|---|
| M5c (`DDRConsensusApa.tla`) | bounded (`0..MaxRound`) | bounded (consequence of the above) |
| **M5c+ (`DDRConsensusUnbounded.tla`)** | **free `Int` — unbounded, non-contiguous** | bounded by `Gen(Bound)` |

Concretely, the arbitrary pre-state is built with Apalache's symbolic generator:

```tla
CInit ==
  /\ r = Gen(1)
  /\ prevotes   = Gen(Bound)      \* a set of <= Bound votes whose `rnd` fields
  /\ precommits = Gen(Bound)      \* are UNCONSTRAINED integers (no horizon)
  /\ locked  = [ v \in Validators |-> [ has |-> Gen(1), round |-> Gen(1), value |-> Gen(1) ] ]
  /\ decided = [ v \in Validators |-> [ has |-> Gen(1),                   value |-> Gen(1) ] ]
  /\ IndInv
```

The SMT solver is therefore free to instantiate rounds as `0, 1, 2, …` **or** as
`5, 1000, 7_000_000` — contiguous or arbitrarily sparse — and must still preserve
every conjunct of `IndInv` across one `DoRound`. Passing establishes the
inductive step is **independent of round magnitude**. `DoRound` itself drops the
`r ≤ MaxRound` guard entirely: rounds advance with no upper horizon.

## Range-free invariant

To talk about rounds without a horizon, every conjunct that M5c phrased with
`rr ∈ 0..MaxRound` is re-expressed to quantify over the rounds that **actually
appear** in the vote sets (or over the votes themselves). These are equivalent on
any state — a round with no votes carries no polka and no per-validator vote, so
its trivial (cardinality-0) cases need not be enumerated — but the phrasing has
no dependence on a round bound. For example:

```tla
\* SafeInv (range-free): r1 = m1.rnd ranges over precommit rounds that appear,
\* r2 = m2.rnd over prevote rounds; this covers exactly the rounds that can
\* carry a polka, with no 0..MaxRound enumeration.
SafeInv ==
  \A m1 \in precommits, m2 \in prevotes :
     (   PolkaT(precommits, m1.rnd, m1.val)
      /\ m2.rnd >= m1.rnd
      /\ PolkaT(prevotes, m2.rnd, m2.val) ) => (m2.val = m1.val)
```

`UniqueVotes`, `LockPin`, and `DecidedJustified` are made range-free the same way.
One conjunct is **added** relative to M5c: `NonNeg` (rounds are `≥ 0`). With round
numbers now free integers, `NonNeg` is needed to exclude spurious negative-round
counterexamples that no reachable state exhibits; it is itself trivially
inductive (`r' = r+1`; new votes/locks are stamped at round `r ≥ 0`), so it
strengthens `IndInv` soundly.

## The three obligations (n=4, f=1, q=3 — no MaxRound)

| # | Obligation | Apalache command | Verdict | Log |
|---|------------|------------------|---------|-----|
| 1 | `Init ⇒ IndInv` | `--init=Init --inv=IndInv --length=0` | **no error** (4 s), `EXITCODE OK` | `specs/tlc-unb-init.log` |
| 2 | `IndInv ⇒ Agreement` | `--init=CInit --inv=Agreement --length=0` | **no error** (12 s), `EXITCODE OK` | `specs/tlc-unb-agree.log` |
| 3 | `IndInv ∧ Next ⇒ IndInv'` | `--init=CInit --inv=IndInv --length=1` | **no error** (226 s), `EXITCODE OK` | `specs/tlc-unb-step.log` |

All three report **"Checker reports no error", EXITCODE OK** (`n=4, f=1, q=3`,
no `MaxRound`). Obligation 3 — the inductive step discharged from an arbitrary
`IndInv` state with **unconstrained integer round numbers** — is the result.

Obligation 3 is the substantive one: the inductive step discharged from an
arbitrary `IndInv` state whose round numbers are unconstrained integers.
(`--smt-encoding=arrays` is used — the array-based SMT encoding is far faster than
the default on this `Cardinality`-heavy, `Gen`-built model and is semantically
identical.)

## The residual bound, and why the result is meaningful

One bound remains: vote-set **cardinality** (`Bound`, currently 5, *per set*). This is
*not* a round bound — with rounds free, a configuration of `k` votes can already
span `k` arbitrarily large, arbitrarily separated rounds. The justification that
a fixed `Bound` suffices is that **the inductive step is local**: each conjunct of
`IndInv` references at most a constant number of polkas, and a polka is exactly
`q` votes. Crucially, the two polkas the safety core compares live in
**different sets** — a precommit-polka in `precommits` for the committed value
and a (conflicting) prevote-polka in `prevotes` — so each *per-set* bound need
only hold **one** `q`-vote polka, not both. `LockPin` relates a lock to one
precommit-polka; `DecidedJustified` ties a decision to one precommit-polka. No
conjunct's truth depends on votes beyond the constantly-many it names, so a
per-set configuration large enough to hold one polka plus the faulty validator's
equivocation is sufficient to expose any counterexample to the step. `Bound = 5`
holds a `q = 3` polka plus the two equivocating votes of the single faulty
validator (`f = 1`), per set.

Two notes on what the bound does and does not cover. (i) The bound is *per set*,
and rounds are free, so a 5-vote set can place its polka at **any** integer
round — the bound does not constrain round magnitude at all. (ii) The transition
itself is unbounded: `DoRound` may add the honest and faulty votes of a whole
round on top of the `Bound`-sized pre-state, so the *post*-state checked at
length 1 is larger than `Bound` (this is why obligation 3's `SafeInv'` solve
dominates the runtime). Completeness with respect to configurations holding
**two** polkas *in the same set* is supplied separately by M5c's exhaustive
bounded runs (`DDRConsensusApa.tla`, `MaxRound ∈ {3,6}`), which scan all
reachable vote configurations and find no counterexample to the same `IndInv`.

### Round-homogeneity (the meta-argument that lifts both M5c and M5c+)

The transition relation `DoRound` is **round-homogeneous**: with the `r ≤ MaxRound`
guard removed, **no clause anywhere reads the magnitude of a round number.** Every
use of `r` (and of any `m.rnd`) is one of:

- *equality* tests `m.rnd = rr` inside `Cnt`/`PolkaT` (counting a polka), or
- *order* tests `m.rnd < r`, `prop.vr ≥ locked[v].round`, `m2.rnd ≥ m1.rnd`
  (comparing two rounds), or
- the *successor* `r' = r + 1` (advancing the round),

and new votes/locks are always stamped with the current `r`. The relation is thus
invariant under any **order-isomorphism of the rounds present** (relabel the round
values by any monotone bijection of the integers and `DoRound` and every `IndInv`
conjunct map to themselves). Two consequences:

1. **Magnitude-independence (mechanized here).** Because only relative order and
   equality of rounds matter, a counterexample to the step at *any* set of round
   values has an order-isomorphic image at *small* round values — and conversely.
   Discharging the step over **free integer** rounds (this module) checks the
   property at *all* magnitudes simultaneously, which is strictly stronger than
   the fixed-`MaxRound` runs of M5c.
2. **Cardinality-locality (argued above).** Combined with locality, the only thing
   a proof must vary is *how many* distinct polkas are simultaneously in scope —
   a small constant — not *which* round numbers they sit at.

So the ladder is now:

```
TLC reachability (M5)
  → full-invariant reachability, n=4 & n=7 (M5c pt.1)
  → machine-checked inductive step, fixed MaxRound=3, corroborated at 6 (M5c)
  → machine-checked inductive step, FREE-INTEGER rounds (M5c+, this doc)   ← here
  → [parametric n, TLAPS]                                                  ← remaining
```

## Honest scope — what is and isn't covered

- **Covered.** For `n=4, f=1, q=3`, the inductive step holds for round numbers of
  arbitrary magnitude and spacing (free `Int`), over vote configurations up to
  `Bound` votes — together with the round-homogeneity argument above, this
  establishes the step is round-magnitude-independent, i.e. genuinely
  unbounded-rounds. `Init ⇒ IndInv` and `IndInv ⇒ Agreement` are also discharged,
  so the three obligations again compose into a full inductive safety proof — now
  with no round horizon.
- **Not covered.**
  1. **Vote-set cardinality is still bounded** (`Bound` votes). The locality
     argument says this is sufficient; it is an *argument*, not a second
     mechanized obligation. A fully horizon-free *and* cardinality-free result
     would need a `Gen`-with-symbolic-cardinality encoding or a TLAPS proof.
  2. **Parametric `n`.** Still `n=4`. All `n ≥ 3f+1` requires a parameterized
     TLAPS proof (the M5b paper argument, `13-unbounded-safety-proof.md`,
     supplies it by hand). This is the last remaining mechanization gap.

## Reproduce

```bash
specs/fetch-apalache.sh    # one-time
specs/check-unbounded.sh   # the three free-integer-rounds obligations
```
