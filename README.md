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
| `ddr-exec` | `wasm_ddr` subset validator + deterministic execution kernel `K` (pure-Rust `wasmi`) + bit-perfect replay; `dag`: DAG-scheduled parallel execution = sequential (Thm 8.2) | M2/M2b ✅ |
| `ddr-attest` | Recursive attestation accumulator (Merkle Mountain Range): single history commitment + external O(log n) inclusion proofs + tamper evidence | M4 ✅ |
| `ddr` | Umbrella facade re-exporting the layers + the **end-to-end lifecycle test** (consensus → execution → chain/epochs → attestation, externally verified, replay-deterministic, tamper-evident) | ✅ |
| `node` | Runnable demo: cluster + "lock is load-bearing" experiment + multi-epoch rotation | M1/M3 ✅ |
| `specs/` | TLA⁺ model of the lock-rule consensus, **discharged by TLC** (exhaustive at `n=4,f=1` and `n=7,f=2`; counterexample without the lock) + **machine-checked inductive-invariant proof in Apalache**, at fixed `MaxRound` (M5c) and over **free-integer / unbounded rounds** (M5c+) + **TLAPS-machine-checked parametric `n=3f+1` quorum-intersection core** (M5c++) | M5/M5c/M5c+/M5c++ ✅ |

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

- ~~**M2** — `wasm_ddr` validator + deterministic execution kernel + replay~~ ✅ **done**.
- ~~**M3** — epoch transitions (validator rotation), cross-epoch No-Fork~~ ✅ **done**.
- ~~**M4** — recursive attestation accumulator (MMR) + external inclusion proofs~~ ✅ **done**
  (O(log n); O(1) succinct verification is the `SuccinctBackend` SNARK seam, not yet implemented).
- ~~**M2b** — multi-key world-state + DAG parallel-execution determinism (Thm 8.2)~~ ✅ **done**.
- ~~**M5** — TLA⁺ model + TLC-discharged cross-round safety (n=4,f=1 and n=7,f=2)~~ ✅;
  see [`docs/audit/12-verification-tlc.md`](docs/audit/12-verification-tlc.md).
- ~~**M5b** — *unbounded* safety: inductive-invariant paper proof for all `n≥3f+1`,
  unbounded rounds~~ ✅ `[PROVEN — paper]`; invariant `SafeInv` machine-confirmed by
  TLC. See [`docs/audit/13-unbounded-safety-proof.md`](docs/audit/13-unbounded-safety-proof.md).
- ~~**M5c** — mechanize the inductive step (Apalache)~~ ✅ **done** — Apalache discharges
  `Init⇒IndInv`, `IndInv∧Next⇒IndInv'`, `IndInv⇒Agreement` for n=4 (and *found* a
  missing conjunct, `LockComplete`). See [`docs/audit/14-inductive-invariant-verification.md`](docs/audit/14-inductive-invariant-verification.md).
- ~~**M5c+** — lift the inductive proof to *unbounded rounds*~~ ✅ **done** — Apalache
  discharges all three obligations with round numbers as **free integers** (no
  `MaxRound`; `Gen`-bounded vote configuration), closing the round-magnitude gap
  left by M5c. See [`docs/audit/15-unbounded-rounds-verification.md`](docs/audit/15-unbounded-rounds-verification.md).
- ~~**M5c++** — *parametric n=3f+1* (TLAPS)~~ ✅ **counting core machine-checked** —
  `DDRConsensusTLAPS.tla` is parametric in `f` (abstract `Validators/Faulty/Values`).
  TLAPS (`tlapm` 1.5.0 + Z3) discharges **143 obligations, 0 failed**: the `n=3f+1`
  quorum-intersection arithmetic (`CorrectCard`, `QuorumIntersect`, and the new
  `ActiveHVLower` counting lemma — the load-bearing step of M5b's safety argument)
  and `Init ⇒ IndInv` are **fully machine-checked**; the protocol-level inductive step
  is a complete proof structure with 14 `OMITTED` glue leaves. See
  [`docs/audit/16-parametric-safety-tlaps.md`](docs/audit/16-parametric-safety-tlaps.md).
- **M5c++ (remaining)** — discharge the 14 `OMITTED` protocol leaves (unfold `DoRound`
  and the precommit-polka⇒prevote-polka bridge) to retire the last "by hand" glue.

## Verify the safety theorem

```bash
cd specs && ./check.sh             # TLC: lock ON ⇒ no error (exhaustive); lock OFF ⇒ counterexample
cd specs && ./check-induction.sh   # Apalache: inductive-invariant proof at fixed MaxRound (M5c)
cd specs && ./check-unbounded.sh   # Apalache: inductive step over FREE-INTEGER rounds (M5c+)
cd specs && ./fetch-tlaps.sh && ./check-parametric.sh  # TLAPS: parametric n=3f+1 counting core, 143 obligations 0 failed (M5c++)
```

See `docs/audit/05-poc-system.md` for the CIIR/semantic PoC — deliberately
separate, because that program depends on unbuilt objects (`d_sem`, `κ<1`).
This DDR build depends on none of them.
