//! `ddr-core` — the deterministic state layer of DDR.
//!
//! This crate implements the parts of DDR Vol. I that are pure functions:
//! the canonical state root (`reduce`, Def. 1.2), the incremental execution
//! kernel `K` (Ch. 6), and the log-monotonicity invariant (Inv. 1.8).
//!
//! The spec *asserts* that `reduce` is deterministic and that the fold form
//! (`K` applied sequentially) equals the batch form. Here those are **tests**
//! (`tests` module below), not assertions.

use sha2::{Digest, Sha256};
use std::fmt;

/// A 256-bit hash, used as both content id and canonical state root.
#[derive(Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
pub struct Hash32(pub [u8; 32]);

impl Hash32 {
    pub const fn zero() -> Self {
        Hash32([0u8; 32])
    }

    /// Hash a sequence of byte-slices (domain-separated by length prefix so
    /// that `["ab","c"]` and `["a","bc"]` do not collide).
    pub fn of(parts: &[&[u8]]) -> Self {
        let mut h = Sha256::new();
        for p in parts {
            h.update((p.len() as u64).to_le_bytes());
            h.update(p);
        }
        let mut out = [0u8; 32];
        out.copy_from_slice(&h.finalize());
        Hash32(out)
    }

    pub fn hex(&self) -> String {
        let mut s = String::with_capacity(64);
        for b in self.0 {
            s.push_str(&format!("{b:02x}"));
        }
        s
    }
}

impl fmt::Debug for Hash32 {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "0x{}…", &self.hex()[..8])
    }
}

/// Canonical state root.
pub type StateRoot = Hash32;

/// A transaction is an opaque, content-addressed byte string at this layer.
/// (Execution semantics — the `wasm_ddr` kernel — arrive in M2.)
#[derive(Clone, PartialEq, Eq, Debug)]
pub struct Tx(pub Vec<u8>);

impl Tx {
    pub fn new(bytes: impl Into<Vec<u8>>) -> Self {
        Tx(bytes.into())
    }
    pub fn id(&self) -> Hash32 {
        Hash32::of(&[b"tx", &self.0])
    }
}

/// The execution kernel `K : StateRoot × Tx -> StateRoot` (Ch. 6, Def. 6.1).
///
/// Pure: no ambient entropy, no architecture-specific branching. The new root
/// commits to the previous root and the transaction.
pub fn kernel_step(pre: StateRoot, tx: &Tx) -> StateRoot {
    Hash32::of(&[b"K", &pre.0, &tx.id().0])
}

/// `reduce(genesis, log)` (Def. 1.2): the canonical state root of an ordered
/// log, defined as the sequential fold of `kernel_step` from genesis.
///
/// This is the single source of truth for "what state does this history yield".
pub fn reduce(genesis: StateRoot, log: &[Tx]) -> StateRoot {
    log.iter().fold(genesis, |acc, tx| kernel_step(acc, tx))
}

/// A block: a batch of transactions extending a parent state.
#[derive(Clone, PartialEq, Eq, Debug)]
pub struct Block {
    pub height: u64,
    pub parent: StateRoot,
    pub txs: Vec<Tx>,
}

impl Block {
    /// The post-state of applying this block's txs to its parent.
    pub fn post_state(&self) -> StateRoot {
        reduce(self.parent, &self.txs)
    }

    /// The block's own content id (what a quorum certificate commits to).
    pub fn id(&self) -> Hash32 {
        let mut parts: Vec<Vec<u8>> = vec![
            b"block".to_vec(),
            self.height.to_le_bytes().to_vec(),
            self.parent.0.to_vec(),
        ];
        for tx in &self.txs {
            parts.push(tx.id().0.to_vec());
        }
        let refs: Vec<&[u8]> = parts.iter().map(|v| v.as_slice()).collect();
        Hash32::of(&refs)
    }
}

/// Invariant 1.8 (Log Monotonicity): `a` is a prefix of `b` (no rollbacks).
pub fn is_prefix(a: &[Tx], b: &[Tx]) -> bool {
    a.len() <= b.len() && a.iter().zip(b).all(|(x, y)| x == y)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn log(n: usize) -> Vec<Tx> {
        (0..n).map(|i| Tx::new(format!("tx{i}").into_bytes())).collect()
    }

    #[test]
    fn reduce_is_deterministic() {
        let g = StateRoot::zero();
        let l = log(50);
        assert_eq!(reduce(g, &l), reduce(g, &l), "reduce must be a pure function");
    }

    #[test]
    fn reduce_equals_sequential_kernel() {
        // Def 1.2 / Ch.6: batch reduce == sequential application of K.
        let g = StateRoot::zero();
        let l = log(64);
        let mut acc = g;
        for tx in &l {
            acc = kernel_step(acc, tx);
        }
        assert_eq!(acc, reduce(g, &l));
    }

    #[test]
    fn order_sensitivity() {
        // Reordering the log changes the root (history is ordered, not a set).
        let g = StateRoot::zero();
        let a = log(8);
        let mut b = a.clone();
        b.swap(2, 5);
        assert_ne!(reduce(g, &a), reduce(g, &b));
    }

    #[test]
    fn prefix_extension_is_consistent() {
        // Bit-perfect replay (Inv 9.2): replaying a prefix then extending
        // yields the same root as reducing the whole log.
        let g = StateRoot::zero();
        let full = log(20);
        let prefix_root = reduce(g, &full[..12]);
        let extended = reduce(prefix_root, &full[12..]);
        assert_eq!(extended, reduce(g, &full));
        assert!(is_prefix(&full[..12], &full));
    }

    #[test]
    fn block_post_state_matches_reduce() {
        let parent = StateRoot::zero();
        let b = Block { height: 1, parent, txs: log(5) };
        assert_eq!(b.post_state(), reduce(parent, &b.txs));
        assert_ne!(b.id(), Hash32::zero());
    }
}
