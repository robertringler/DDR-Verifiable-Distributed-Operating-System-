# M5 — Discharging the safety theorem with TLC

> **What this answers.** The audit
> (`10-ddr-computational-substrate-audit.md`) found that the DDR spec's TLA⁺
> `THEOREM Spec ⇒ []SafetyInvariant` was **declared but not discharged** — "no
> TLC config, no state counts, no proof; modules abridged" — and that the
> Agreement proof only covered the single-round case. This milestone supplies
> the missing artifact: a runnable TLA⁺ model of the lock-rule consensus and a
> **TLC model-checking report** that exhaustively verifies cross-round
> Agreement for a concrete configuration, plus a counterexample run proving the
> lock is load-bearing.

## Artifacts

- [`specs/DDRConsensus.tla`](../../specs/DDRConsensus.tla) — the model. Mirrors
  the Rust `ddr-consensus` crate: round-synchronized BFT, an active quorum per
  round (= network partition), Byzantine validators that equivocate, and the
  Tendermint lock/unlock rule gated by the `UseLock` constant.
- [`specs/DDRConsensus.cfg`](../../specs/DDRConsensus.cfg) — `UseLock = TRUE`.
- [`specs/DDRConsensus_nolock.cfg`](../../specs/DDRConsensus_nolock.cfg) — `UseLock = FALSE`.
- [`specs/check.sh`](../../specs/check.sh) — runs both; `fetch-tools.sh` gets TLC.
- `specs/tlc-lock-on.log`, `specs/tlc-lock-off.log` — the captured reports.

## Configuration checked

`n = 4` validators, `f = 1` Byzantine (`v4`), quorum `q = 2f+1 = 3`,
`Values = {a, b}`, rounds `0..3`. The adversary nondeterministically chooses,
each round: the active quorum (partition), the leader, and the proposed value
(for a Byzantine or unlocked-honest leader). TLC explores **all** such choices.

## Result

| Run | Constant | TLC verdict | State space |
|-----|----------|-------------|-------------|
| Safety | `UseLock = TRUE` | **No error has been found** — `[]Agreement` holds | 11,639 generated, **1,597 distinct, 0 left on queue** (complete graph, depth 5) |
| Load-bearing | `UseLock = FALSE` | **Invariant Agreement is violated** (counterexample) | 678 generated, 167 distinct |

"0 states left on queue" means the bounded state graph was searched **to
exhaustion** — for this configuration the lock-rule Agreement is not sampled
(as in the randomized Rust test) but *proved* over every reachable state.

### The counterexample (lock off)

TLC's trace ends in:

```
decided = ( v1 :> [has |-> TRUE, value |-> a]
          , v2 :> [has |-> TRUE, value |-> a]
          , v3 :> [has |-> TRUE, value |-> b]   \* conflicting decision
          , v4 :> [has |-> FALSE, ...] )
```

A round-0 partition `{v1,v2,v4}` commits `a` (v1,v2 lock and decide `a`); a
round-1 partition `{v1,v2,v3,v4}` then forms a quorum for `b` because, without
the lock, v1/v2 prevote `b` despite being committed to `a`. Two correct
validators decide differently — the exact cross-round fork the audit said the
spec never ruled out. With `UseLock = TRUE`, v1/v2 prevote nil for `b` (no
unlock evidence) and the fork is impossible, as the exhaustive run confirms.

## Reproduce

```bash
cd specs && ./check.sh      # fetches TLC if needed, runs both configs
```

## Honest scope — what this is and isn't

- **Is:** an exhaustive, machine-checked proof of cross-round + cross-partition
  Agreement *for `n=4, f=1, ≤4 rounds, 2 values`*. This is a genuine discharge,
  the same evidentiary standard a CAV/PODC reviewer expects from a TLC report,
  and it strictly dominates the randomized Rust search (which only *samples*).
- **Is not (yet):** an *unbounded* proof. TLC verifies a finite instance; it
  does not by itself establish safety for all `n`, all `f<n/3`, and unbounded
  rounds. That requires either (a) a TLAPS / Apalache inductive-invariant proof,
  or (b) a paper proof of an inductive invariant (the standard "locked value is
  supported by a quorum, and quorums intersect in an honest node" argument).
  That is the remaining step to claim *verified* without qualification.

## Next (M5b)

State and check an **inductive invariant** `Inv` with Apalache (`Init ⇒ Inv`,
`Inv ∧ Next ⇒ Inv'`, `Inv ⇒ Agreement`) to lift the result from "bounded
exhaustive" to "unbounded," removing the `n=4`/round bound entirely.
