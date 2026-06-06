# M5c++ — Parametric safety proof (all n=3f+1, TLAPS)

> **Result:** the `n = 3f+1` quorum-intersection arithmetic at the heart of DDR
> consensus safety — **parametric in `f`**, not fixed to `n=4` — is now
> **machine-checked by TLAPS** (the TLA+ Proof System). This formalizes the M5b
> paper argument's load-bearing counting step (`ActiveHVLower`) and discharges
> `Init ⇒ IndInv`; the protocol-level inductive step is given as a complete TLAPS
> proof structure with its remaining glue marked `OMITTED`.
>
> **Status (machine-checked):** run with `tlapm` 1.5.0 (Z3 4.8.9 / Zenon /
> Isabelle) — **143 obligations, 0 failed**, 14 `OMITTED` leaves. The
> parametric **quorum-intersection counting core** and `Init ⇒ IndInv` are
> **fully machine-checked, parametric in `f`**:
>
> | Object | Verdict |
> |--------|---------|
> | `LEMMA CorrectCard` (`\|Correct\| = 2f+1`) | ✅ machine-checked |
> | `LEMMA QuorumIntersect` (two `(f+1)`-subsets of `Correct` intersect) | ✅ machine-checked |
> | `LEMMA ActiveHVLower` (the counting core, `k+t ≥ f+1`) | ✅ machine-checked |
> | `THEOREM Init_IndInv` (`Init ⇒ IndInv`) | ✅ machine-checked |
> | `THEOREM IndInv_Agreement` | structured; 1 `OMITTED` protocol leaf |
> | `THEOREM IndInv_Step` | structured; 13 `OMITTED` protocol leaves |
>
> The key counting argument — `ActiveHVLower`, the lemma that bounds
> conflicting-polka votes to `≤ q−1` — is now **machine-checked**, not merely
> asserted: TLAPS discharges its inclusion-exclusion derivation against the
> `FiniteSetTheorems` library (`FS_MajoritiesIntersect`, `FS_Union`,
> `FS_Difference`, `FS_CardinalityType`).
>
> Spec: `specs/DDRConsensusTLAPS.tla`. Log: `specs/tlaps-parametric.log`.
> Reproduce: `specs/fetch-tlaps.sh` then `specs/check-parametric.sh`.

## What M5c++ adds over M5c+

| | `n` | round magnitude | Vote-set cardinality |
|---|---|---|---|
| M5c (`DDRConsensusApa.tla`) | **concrete** (`n=4`) | bounded (`0..MaxRound`) | bounded |
| M5c+ (`DDRConsensusUnbounded.tla`) | **concrete** (`n=4`) | free `Int` — unbounded | bounded by `Gen(5)` |
| **M5c++ (`DDRConsensusTLAPS.tla`)** | **parametric** (`all n=3f+1`) | free `Int` — unbounded | unbounded (TLAPS universally quantifies) |

M5c+ discharged the inductive step from an arbitrary `IndInv`-state with free
integer rounds, but still for the concrete `n=4` configuration. M5c++
re-states the model parametrically — `Validators`, `f`, `q` are abstract
constants — and carries the proof through for *any* `n = 3f+1`, `f ≥ 1`.
Both cardinality *and* round-magnitude are now unbounded.

## The parametric configuration

The module `DDRConsensusTLAPS.tla` assumes:

```tla
ASSUME A_ValCount    == Cardinality(Validators) = 3*f + 1   (* n = 3f+1 *)
ASSUME A_FaultCount  == Cardinality(Faulty) = f              (* exactly f faulty *)
ASSUME A_QuorumDef   == q = 2*f + 1                          (* quorum *)
ASSUME A_FPos        == f >= 1                               (* at least one fault *)
```

From these, `|Correct| = 2f+1 = q` (derived in `LEMMA CorrectCard`). The
parametric tight-BFT configuration is the canonical DDR family: `n=4,f=1,q=3`
(M5c/M5c+), `n=7,f=2,q=5` (M5 TLC at `n=7`), etc. The constraints are *exact*
(`=`, not `≥`) for the tight BFT bound; with `n > 3f+1` at the same `q=2f+1`
the quorum intersection fails (see note below).

## The `ActiveHVLower` lemma — the key new contribution

The M5b paper proof sketches quorum intersection at a high level ("two sets of
size ≥ f+1 must intersect"). M5c++ gives the precise counting argument for
*why no conflicting polka can form in a post-transition state*. This is the
core of the `IndInv_Step` / `SafeInv'` proof.

**Lemma `ActiveHVLower`:**

> For any `Active` set (size `q`), and any `HV ⊆ Correct` with `|HV| ≥ f+1`,
>
> `|Active ∩ HV| + |Active ∩ Faulty| ≥ f+1`.

*Proof sketch.* Let `t = |Active ∩ Faulty|` and `k = |Active ∩ HV|`.
`Active ∩ Correct` has size `q − t`. By inclusion-exclusion inside `Correct`
(which has size `2f+1 = q`):

```
k = |Active ∩ HV| ≥ |Active ∩ Correct| + |HV| − |Correct|
                   = (q−t) + (f+1) − (2f+1) = f+1−t.
```

So `k + t ≥ f+1`. □

**Application to `SafeInv'` (Case B — new prevote polka vs. old commit):**

Suppose `Commit(r1, V)` exists (a precommit polka for `V` at round `r1`) in the
pre-state, and a prevote polka for `W` might form at the new round `r > r1` in
the post-state. Let:

- `HV` = {honest validators who precommitted `V` at `r1`}: `|HV| ≥ f+1` (Lemma 1).
- By `LockPin` (pre-state): every validator in `HV` is locked on `V`.
- By `SafeInv` (pre-state induction): no prevote polka for `W ≠ V` exists at
  any round in `[r1, r)`, so the lock-rule unlock path for `W` is also blocked.
- Therefore every validator in `Active ∩ HV` casts a vote for `V` (or `Nil`),
  **not** `W`.

Now count the maximum prevotes for `W` at round `r`:

```
W-votes = |Faulty|   (all Faulty equivocate: f votes)
        + |{v ∈ Active ∩ Correct : PrevoteVal(v,prop) = W}|
       ≤ f + (|Active ∩ Correct| − k)    (* k members of Active ∩ HV vote V *)
        = f + (q − t) − k
       ≤ f + (q − t) − (f+1−t)           (* k ≥ f+1−t from ActiveHVLower *)
        = q − 1.
```

Since `q − 1 < q`, no polka for `W ≠ V` forms at round `r`. `SafeInv'` holds
for Case B. □

## The three proof obligations

| # | Obligation | Theorem | Verdict | Proof strategy |
|---|------------|---------|---------|---------------|
| 1 | `Init ⇒ IndInv` | `Init_IndInv` | ✅ machine-checked | Empty vote sets, `locked.has = FALSE`, `decided.has = FALSE`; all quantified conjuncts vacuously hold (`Values ≠ {}` for the `CHOOSE`) |
| 2 | `IndInv ⇒ Agreement` | `IndInv_Agreement` | structured (1 omitted leaf) | WLOG `r1 ≤ r2`; `Commit(r1,V)` ⇒ `Polka(r1,V)` (via `PrecommitJustified`); with `Polka(r2,W)`, `SafeInv` at `r2 ≥ r1` gives `W=V` |
| 3 | `IndInv ∧ Next ⇒ IndInv'` | `IndInv_Step` | structured (13 omitted leaves) | Per-conjunct; `SafeInv'` uses `ActiveHVLower` (case B) + uniqueness of `QuorumVal` (case C) + old `SafeInv` (case A) |

The standalone counting lemmas `CorrectCard`, `QuorumIntersect`, and
`ActiveHVLower` — which carry the entire `n = 3f+1` quorum-arithmetic content —
are machine-checked outright (no omitted leaves). What remains `OMITTED` is the
*protocol-level* glue: unfolding the large `DoRound` action and connecting it to
the counting lemmas. Those leaves are stated as explicit TLAPS proof goals with
their mathematical arguments in comments, so the obligation each one represents
is precisely delimited.

## Why `n = 3f+1` exactly, not `n ≥ 3f+1`

The `ActiveHVLower` derivation produces `k ≥ f+1−t`, which in turn gives
`W-votes ≤ q−1`, precisely because `|Correct| = q = 2f+1` (equality, not just
`≥`). If `n > 3f+1` with the same `q = 2f+1`, then `|Correct| > 2f+1` and the
inclusion-exclusion bound degrades:

```
k ≥ (q−t) + (f+1) − |Correct|  < f+1−t   when |Correct| > 2f+1.
```

The bound on W-votes no longer drops below `q`. For `n > 3f+1` at the same
quorum, the quorum intersection argument fails — safety requires raising `q`
proportionally (e.g., `q = ⌈2n/3⌉ + 1`). The DDR protocol is specified for
the tight family `n = 3f+1, q = 2f+1`, which is the standard BFT minimum.

## Proof structure in TLAPS syntax

The proof module `DDRConsensusTLAPS.tla` follows standard TLAPS conventions:

- `EXTENDS Integers, FiniteSets, FiniteSetTheorems, TLAPS` — `FiniteSetTheorems`
  provides the proved cardinality lemmas the counting core cites:
  `FS_MajoritiesIntersect` (two subsets whose sizes sum past the universe must
  intersect — exactly quorum intersection), `FS_Union`/`FS_Difference`
  (inclusion-exclusion), `FS_CardinalityType` (`Cardinality(S) ∈ Nat`),
  `FS_EmptySet`, `FS_Subset`.
- `LEMMA ... PROOF <1>1. ... <1>n. QED BY ...` — hierarchical proof structure.
- `BY DEF Foo, Bar` — definitional unfolding for the selected backend.
- `BY <lemma-name>` — cites a previously proved lemma.
- The cardinality lemmas needed the scalar `f` typed (`ASSUME f ∈ Nat`) and the
  set-arithmetic steps broken finely enough for Z3 — e.g. `ActiveHVLower`
  threads `|AH|+|AF| = q`, the inclusion-exclusion bound, and the final
  `|Active ∩ HV| + |AF| ≥ f+1` as separate sub-goals so each is a small
  linear-arithmetic obligation.

The proof of `IndInv_Step` is decomposed into 10 sub-goals (`<1>1`–`<1>10`),
one per conjunct of `IndInv`. The hard conjunct `<1>9` (`SafeInv'`) is itself
split into the cases (A–C, plus an exhaustiveness QED) matching the possible
provenance of the two polkas; these protocol-level leaves are the `OMITTED`
ones, with `ActiveHVLower` cited where case (B) needs it.

## Status and the remaining gap

**What M5c++ provides (machine-checked by TLAPS):**
- The full `n = 3f+1` quorum-intersection arithmetic, **parametric in `f`**:
  `CorrectCard`, `QuorumIntersect`, and the new `ActiveHVLower` counting lemma
  are discharged outright by TLAPS (Z3 + the `FiniteSetTheorems` library).
- `Init ⇒ IndInv`, machine-checked.
- A complete TLAPS proof *structure* for `IndInv ⇒ Agreement` and the inductive
  step `IndInv ∧ Next ⇒ IndInv'`, with the SafeInv' case analysis (the place
  `ActiveHVLower` plugs in) laid out explicitly.
- A reproducible run: `specs/check-parametric.sh` reports **143 obligations,
  0 failed** (log: `specs/tlaps-parametric.log`).

**What remains (the 14 `OMITTED` leaves):**
- **Protocol-level glue in `IndInv_Agreement` (1 leaf) and `IndInv_Step`
  (13 leaves).** These require unfolding the large `DoRound` action and a few
  supporting lemmas (e.g. "a precommit-polka implies a same-round prevote-polka",
  the message-count ↔ sender-count bridge via `UniqueVotes`). The mathematics is
  the M5b paper proof plus the now-machine-checked `ActiveHVLower`; what is not
  yet mechanized is the bookkeeping that threads `DoRound`'s `LET`-bindings into
  those lemmas. This is a tractable but laborious continuation (TLAPS consensus
  proofs of this depth typically run to hundreds of lines per conjunct).

The substantive *mathematical* gap of M5b — "is the `n ≥ 3f+1` counting actually
valid, parametrically?" — is now closed by machine: `ActiveHVLower` is the lemma
that argument turns on, and it checks.

## Reproduce

```bash
specs/fetch-tlaps.sh         # one-time: install tlapm to /opt/tlaps
export PATH=/opt/tlaps/bin:$PATH
specs/check-parametric.sh    # 143 obligations, 0 failed; lists the 14 omitted leaves
```

## Verification ladder

```
TLC reachability (M5)
  → full-invariant reachability, n=4 & n=7 (M5c pt.1)
  → machine-checked inductive step, fixed MaxRound=3, corroborated at 6 (M5c)
  → machine-checked inductive step, FREE-INTEGER rounds (M5c+)
  → TLAPS: parametric n=3f+1 counting core + Init machine-checked,           ← here
    inductive-step structure with 14 omitted protocol leaves (M5c++)
  → [discharge the 14 protocol leaves in TLAPS]                              ← remaining
```
