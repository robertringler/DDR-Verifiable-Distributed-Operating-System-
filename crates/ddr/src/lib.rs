//! `ddr` — umbrella facade for the Deterministic Distributed Runtime.
//!
//! Re-exports the runtime layers under one roof and hosts the end-to-end
//! lifecycle test (`tests/lifecycle.rs`). The layers:
//!
//! | module | crate | role |
//! |--------|-------|------|
//! | [`core`] | `ddr-core` | deterministic state, canonical state root |
//! | [`consensus`] | `ddr-consensus` | BFT consensus with the lock rule |
//! | [`chain`] | `ddr-chain` | chaining + epoch rotation, cross-epoch No-Fork |
//! | [`exec`] | `ddr-exec` | `wasm_ddr` deterministic execution + replay |
//! | [`attest`] | `ddr-attest` | recursive attestation (verifiable history) |
//!
//! The lifecycle test wires them into one flow — consensus agrees, execution
//! computes state, the chain commits and rotates validators, attestation makes
//! the whole history externally verifiable — and checks the composition is
//! consistent, deterministic on replay, and tamper-evident. That is the
//! concrete answer to "do the typed interfaces actually compose?": yes, and
//! here is a runnable proof.

pub use ddr_attest as attest;
pub use ddr_chain as chain;
pub use ddr_consensus as consensus;
pub use ddr_core as core;
pub use ddr_exec as exec;
