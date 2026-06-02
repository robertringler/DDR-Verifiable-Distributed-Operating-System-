# M5b — Unbounded safety: the inductive-invariant proof

> **What this adds over M5.** M5 used TLC to *exhaustively* check Agreement for
> fixed configurations (`n=4`, and now `n=7,f=2`) up to a round bound. That is a
> proof for those instances, not for all of them. M5b removes both bounds with a
> **paper proof** of an inductive invariant, valid for **every `n ≥ 3f+1`, every
> Byzantine set of size `≤ f`, and unboundedly many rounds**. The invariant
> (`SafeInv`) is also stated in the TLA⁺ model and machine-confirmed by TLC to
> hold on every reachable state of the bounded model (`specs/tlc-safeinv.log`),
> which de-risks the hand proof.
>
> **Honest status:** the *theorem* is a paper proof — `[PROVEN — paper]`. Its
> mechanization (an Apalache/TLAPS discharge of the inductive step, removing the
> "by hand" caveat) is scoped as **M5c**; Apalache 0.58 is installed and the
> invariant below is written to be the mechanization target.

## Model (the abstraction the proof is about)

`n` validators; a Byzantine set `F` with `|F| ≤ f` and `n ≥ 3f+1`; honest set
`C = V∖F`, so `|C| ≥ 2f+1 = q` (the quorum). Validators emit **prevotes** and
**precommits**, each tagged `(round, value, sender)`. Honest validators obey:

- **(P1) one vote per round** — at most one prevote and one precommit per round.
- **(P2) precommit ⇒ polka** — an honest node precommits `v` at round `r` only
  after observing a *polka* for `v` at `r` (≥ `q` prevotes for `(r,v)`); doing so
  sets its lock to `(r, v)`.
- **(P3) lock monotone** — the lock round never decreases; the lock changes only
  via (P2).
- **(P4) prevote rule** — an honest node with lock `(lr, lv)` prevotes a value
  `v` at round `r > lr` only if `v = lv`, **or** it has observed a polka for `v`
  at some round `vr` with `lr ≤ vr < r`. (Unlocked nodes may prevote the proposal.)

Derived predicates over the global vote history:
`Polka(r,v) ≡ |{senders of prevotes (r,v)}| ≥ q`;
`Commit(r,v) ≡ |{senders of precommits (r,v)}| ≥ q`.
An honest node **decides** `v` upon observing `Commit(r,v)` for some `r`.

This is exactly the round-synchronized model implemented in `ddr-consensus`
(Rust) and `specs/DDRConsensus.tla` (TLA⁺); Byzantine nodes are unconstrained
(they may equivocate, voting both values every round).

## Lemmas

**Lemma 1 (quorum ⇒ honest support).** `Polka(r,v) ⇒` at least `f+1` *honest*
validators prevoted `(r,v)`. *Proof.* `q` distinct senders, at most `f` Byzantine,
so `≥ q−f = f+1` honest. (Identically for `Commit`.) ∎

**Lemma 2 (one value per round).** For each round `r`, at most one value has a
polka. *Proof.* If `Polka(r,v)` and `Polka(r,v')` with `v≠v'`, Lemma 1 gives two
honest sets of size `≥ f+1`; by (P1) honest nodes prevote once per round, so the
sets are disjoint, totalling `≥ 2f+2 > 2f+1 ≥ |C|` honest nodes — impossible.
(Identically, at most one value commits per round.) ∎

**Lemma 3 (lock pinning).** Fix `r1, V` with `Commit(r1,V)`. Then every honest
node whose lock round is `≥ r1` is locked on `V`. *(Proved jointly with the
theorem, below.)*

## Theorem (Agreement — all `n ≥ 3f+1`, unbounded rounds)

> No two correct validators ever decide different values.

Define the **inductive invariant**
```
SafeInv ≡ ∀ r1, V, ∀ r2 ≥ r1, ∀ W :  ( Commit(r1,V) ∧ Polka(r2,W) ) ⇒ W = V.
```

**Claim: `SafeInv` (and Lemma 3) hold at every step of every execution.**
We argue by strong induction on `r2`.

*Base / same round (`r2 = r1`).* `Commit(r1,V)` ⇒ `Polka(r1,V)` (Lemma 1: the
honest precommitters of `V` first prevoted `V`). With `Polka(r1,W)`, Lemma 2
forces `W = V`.

*Step (`r2 > r1`).* Assume `SafeInv` and Lemma 3 for all polkas at rounds `< r2`.
Suppose, for contradiction, `Commit(r1,V)`, `Polka(r2,W)`, `W ≠ V`.

1. By Lemma 1, `Commit(r1,V)` ⇒ a set `H_V` of `≥ f+1` honest nodes precommitted
   `V` at `r1`; by (P2)/(P3) each has lock round `≥ r1`. By Lemma 3 (induction:
   their lock rounds are `≥ r1`, and any lock update before `r2` came from a polka
   at a round in `[r1, r2)`, which by the inductive `SafeInv` is for `V`), every
   node in `H_V` is **locked on `V`** throughout `[r1, r2)`.
2. By Lemma 1, `Polka(r2,W)` ⇒ a set `H_W` of `≥ f+1` honest nodes prevoted `W`
   at `r2`.
3. `|H_V| + |H_W| ≥ 2f+2 > 2f+1 ≥ |C|`, so `H_V ∩ H_W ≠ ∅`: some honest `u`
   precommitted `V` at `r1` (hence locked on `V`, round `≥ r1`) **and** prevoted
   `W ≠ V` at `r2`.
4. By (P4), `u` (locked on `V` at round `≥ r1`, voting at `r2 > r1`) prevotes
   `W ≠ V` only if it observed `Polka(vr, W)` for some `vr` with `r1 ≤ vr < r2`.
5. That polka has round `vr ∈ [r1, r2)`; by the inductive hypothesis (`SafeInv`
   at rounds `< r2`, with `Commit(r1,V)`), `W = V` — contradicting `W ≠ V`.

So no such violating polka exists; `SafeInv` is preserved. Lemma 3 follows in the
same induction: a lock on round `≥ r1` is set by precommitting (P2), which needs
a polka at that round `≥ r1`, which by `SafeInv` is for `V`. ∎

**Agreement from `SafeInv`.** Suppose correct `u` decides `V` (saw `Commit(r1,V)`)
and correct `w` decides `W` (saw `Commit(r2,W)`), WLOG `r1 ≤ r2`. By Lemma 1,
`Commit(r2,W) ⇒ Polka(r2,W)`. Then `Commit(r1,V) ∧ Polka(r2,W) ∧ r2 ≥ r1` gives
`W = V` by `SafeInv`. ∎

## Why the bound `n ≥ 3f+1` is exactly what is used

The proof invokes the supermajority arithmetic in exactly two places — Lemma 2
and step 3 — both of the form *two quorums of `≥ f+1` honest nodes must
intersect*, i.e. `2(f+1) > |C| ≥ 2f+1`. This is the sole place the `n/3`
threshold enters, matching the classical BFT bound. With `n = 3f` (one fewer)
the intersection argument fails and the lock can be circumvented — consistent
with the `UseLock = FALSE` counterexample TLC produces, which is morally "the
lock removed" rather than "`f` too large," but illustrates the same fragility.

## Machine-checked support

- `SafeInv` is stated in `specs/DDRConsensus.tla` and TLC confirms it holds on
  **every reachable state** of the bounded model (`n=4`: 1,597 states, 0 left on
  queue — `specs/tlc-safeinv.log`). This rules out the embarrassing failure mode
  of a hand proof: an invariant that is false or vacuous in the actual model.
- Agreement itself is exhaustively checked at `n=4,f=1` and `n=7,f=2`
  (`specs/tlc-lock-on.log`, `specs/tlc-n7.log`).

## Remaining step (M5c)

Mechanize the *inductive step* (`SafeInv ∧ Next ⇒ SafeInv'`) with Apalache
(symbolic, no state enumeration) or TLAPS (parameterized in `n`). That converts
the `[PROVEN — paper]` theorem above into `[PROVEN — machine-checked]` with no
"by hand" caveat. The invariant is already written in the form Apalache needs;
the work is the type annotations and discharging the resulting SMT obligations
(and likely strengthening `SafeInv` with the explicit Lemma-3 conjunct so the
single-step check goes through without the meta-level induction used above).
