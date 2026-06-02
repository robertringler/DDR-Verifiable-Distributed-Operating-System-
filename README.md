# DDR — Deterministic Distributed Runtime (reference implementation)

A from-scratch, test-driven implementation of the DDR computational substrate,
built in response to the audit in [`docs/audit/`](docs/audit/). This is the
part of the program the audit found *buildable today* — and it is built here to
the standard the audit asked for: **proven-by-test where the spec only asserted.**

## Why this exists

The audit (`docs/audit/10-ddr-computational-substrate-audit.md`) found that the
DDR spec's headline safety theorem (BFT Agreement) was **proved only for the
single-round case** — the hard cross-round *locked-QC* argument, which is the
actual core of HotStuff/Tendermint-style safety, was missing. This repo closes
that gap empirically: it implements the lock rule and ships a randomized
adversarial test that **detects a safety violation when the lock is removed.**

## Workspace

| Crate | Role | Status |
|-------|------|--------|
| `ddr-core` | Deterministic state: canonical state root `reduce`, kernel step `K`, invariants | M1 ✅ |
| `ddr-consensus` | BFT consensus with the lock/unlock rule; deterministic adversarial simulator; safety + liveness tests | M1 ✅ |
| `ddr-chain` | Multi-height chaining + epoch transitions (validator rotation); cross-epoch No-Fork: anchoring, anti-rollback, quorum-gated hand-off, handoff uniqueness | M3 ✅ |
| `node` | Runnable demo: cluster + "lock is load-bearing" experiment + multi-epoch rotation | M1/M3 ✅ |

## Build & test

```bash
cargo test          # all crates; includes the adversarial safety search
cargo run -p node   # demo: runs a cluster, then shows the lock keystone experiment
```

## What is proven here vs. asserted in the spec

- **Determinism of `reduce`** — proved by test (fold == sequential kernel; order/replay).
- **Cross-round Agreement under the lock rule** — supported by a randomized search
  over thousands of adversarial schedules (partitions + Byzantine equivocation,
  `f < n/3`); **zero** violations found with the lock on.
- **The lock is load-bearing** — the *same* search with the lock disabled **finds**
  a conflicting-decision violation. This is the falsifiable result: the test
  behaves differently if the safety mechanism is absent.
- **Cross-epoch No-Fork** (M3) — validator-set rotation is anchored to the
  finalized state root, epoch-monotonic (anti-rollback), and quorum-gated; a
  Byzantine minority cannot forge a hand-off, and *handoff uniqueness* is shown
  by computation over all `f` (a conflicting quorum needs `2f+1` signers but at
  most `2f` are available without reusing an honest signer).

## Roadmap (next milestones)

- **M2** — Deterministic WASM execution subset (`wasm_ddr`) + replay engine.
- ~~**M3** — epoch transitions (validator rotation), cross-epoch No-Fork~~ ✅ **done**.
- **M4** — Recursive proof accumulator (zk attestation interface).
- **M5** — TLA+ model + a *proven* (not just tested) cross-round safety argument.

See `docs/audit/05-poc-system.md` for the CIIR/semantic PoC — deliberately
separate, because that program depends on unbuilt objects (`d_sem`, `κ<1`).
This DDR build depends on none of them.
