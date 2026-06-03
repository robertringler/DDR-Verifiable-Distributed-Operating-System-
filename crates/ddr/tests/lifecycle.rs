//! End-to-end lifecycle: the layers composed into a running, verifiable system.
//!
//! Flow per epoch: consensus must *agree*; each block's transactions are
//! *executed* by the deterministic kernel; the executed state is *committed* to
//! the chain; at the epoch boundary the chain *rotates* validators and the
//! epoch's root is *attested* into the accumulator. Finally an external party
//! verifies the whole history from the attestation root alone, a second replica
//! reproduces it bit-for-bit, and tampering is rejected.

use std::collections::BTreeSet;

use ddr_attest::{verify_inclusion, Mmr};
use ddr_chain::{Chain, HandoffQc, ValidatorSet};
use ddr_consensus::{run, Config};
use ddr_core::{StateRoot, Tx};
use ddr_exec::{ExecTx, WasmKernel};

// world-state transition: state' = state*2 + tx
const KERNEL_WAT: &str = r#"(module (func (export "apply") (param i64 i64) (result i64)
    local.get 0 i64.const 2 i64.mul local.get 1 i64.add))"#;

#[derive(Clone)]
enum Event {
    Block(Vec<Tx>),
    Handoff(HandoffQc),
}

fn epoch_set(e: u64) -> ValidatorSet {
    // 4-validator sets, rotating two members out each epoch.
    let base = e as u32 * 2;
    ValidatorSet::new(e, [base, base + 1, base + 2, base + 3])
}

#[test]
fn full_lifecycle_is_consistent_verifiable_and_tamper_evident() {
    let kernel = WasmKernel::from_wasm(&wat::parse_str(KERNEL_WAT).unwrap()).unwrap();
    let genesis_root = StateRoot::zero();

    let mut chain = Chain::genesis(epoch_set(0), genesis_root);
    let mut mmr = Mmr::new();
    let mut exec_state: u64 = 0;
    let mut journal: Vec<Event> = Vec::new();
    let mut epoch_attestations: Vec<StateRoot> = Vec::new();

    const EPOCHS: u64 = 3;
    const BLOCKS_PER_EPOCH: u64 = 2;

    for e in 0..EPOCHS {
        let set = epoch_set(e);

        // 1. Consensus must agree for this validator set (no Byzantine, sync).
        let out = run(Config::bft(set.n() as u32), &BTreeSet::new(), 1234 + e);
        assert!(out.all_decided(), "epoch {e}: consensus must reach a decision");
        assert!(out.safety_violation().is_none(), "epoch {e}: consensus must agree");

        // 2. Per block: execute txs, commit the executed state to the chain.
        for h in 0..BLOCKS_PER_EPOCH {
            let exec_txs = vec![ExecTx(e + 1), ExecTx(h + 1)];
            let (new_state, _eroot, receipts) =
                kernel.run(StateRoot::zero(), exec_state, &exec_txs).unwrap();
            // execution is replayable (Inv 9.2)
            assert!(ddr_exec::verify_trace(&kernel, StateRoot::zero(), exec_state, &receipts).unwrap());
            exec_state = new_state;

            // The chain commits a tx that binds to the executed world-state.
            let block_txs = vec![Tx::new(new_state.to_le_bytes().to_vec())];
            chain.commit(block_txs.clone());
            journal.push(Event::Block(block_txs));
        }

        // 3. Attest the epoch's committed root into the accumulator.
        let attestation = chain.committed_root;
        let idx = mmr.append(attestation);
        assert_eq!(idx as u64, e, "attestation index tracks epoch");
        epoch_attestations.push(attestation);

        // 4. Rotate validators via a quorum-signed hand-off (except after last).
        if e + 1 < EPOCHS {
            let next = epoch_set(e + 1);
            let signers: BTreeSet<u32> =
                set.members.iter().take(set.quorum()).copied().collect();
            let handoff = HandoffQc {
                epoch: e,
                finalized_root: chain.committed_root,
                next_set: next,
                signers,
            };
            chain.apply_handoff(&handoff).expect("valid hand-off");
            journal.push(Event::Handoff(handoff));
        }
    }

    let commitment = mmr.root();
    assert_eq!(chain.epoch(), EPOCHS - 1);
    assert_eq!(chain.height, EPOCHS * BLOCKS_PER_EPOCH);

    // --- External verification: from the commitment alone, each epoch's
    //     attestation is provably in the canonical history. ---
    for (e, att) in epoch_attestations.iter().enumerate() {
        let proof = mmr.prove(e).unwrap();
        assert!(
            verify_inclusion(commitment, *att, &proof),
            "epoch {e}: external inclusion proof must verify"
        );
    }

    // --- Determinism / No-Fork: a fresh replica replays the journal and
    //     derives the identical chain head and validator set. ---
    let mut replica = Chain::genesis(epoch_set(0), genesis_root);
    for ev in &journal {
        match ev {
            Event::Block(txs) => {
                replica.commit(txs.clone());
            }
            Event::Handoff(h) => replica.apply_handoff(h).unwrap(),
        }
    }
    assert_eq!(replica.committed_root, chain.committed_root, "replica head must match");
    assert_eq!(replica.current_set, chain.current_set, "replica validator set must match");

    // --- Tamper evidence: a forged epoch-1 attestation is rejected by the
    //     external verifier against the honest commitment. ---
    let forged = StateRoot::of(&[b"forged-epoch-1"]);
    let proof1 = mmr.prove(1).unwrap();
    assert!(
        !verify_inclusion(commitment, forged, &proof1),
        "a forged attestation must not verify"
    );
}

#[test]
fn execution_state_threads_through_blocks_deterministically() {
    // The executed world-state is a pure function of the block sequence:
    // two independent runs of the same lifecycle yield the same final state.
    let kernel = WasmKernel::from_wasm(&wat::parse_str(KERNEL_WAT).unwrap()).unwrap();
    let runlife = || {
        let mut s: u64 = 0;
        for e in 0..3u64 {
            for h in 0..2u64 {
                let (ns, _, _) = kernel
                    .run(StateRoot::zero(), s, &[ExecTx(e + 1), ExecTx(h + 1)])
                    .unwrap();
                s = ns;
            }
        }
        s
    };
    assert_eq!(runlife(), runlife(), "lifecycle execution must be deterministic");
}
