//! `ddr-attest` — recursive attestation accumulator (DDR Vol. III Ch. 9, the
//! "recursive Merkle civilization ledger", and the external-verifiability story
//! T10/20.2).
//!
//! This is the **"Verifiable"** in the project name, built honestly. It is a
//! **Merkle Mountain Range** (MMR): an append-only accumulator that commits an
//! unbounded history of attestations (per-epoch state/civilization roots) into a
//! single root, and lets *any* external party verify that a given attestation is
//! in the canonical history with an **O(log n) inclusion proof** — without
//! trusting the node and without replaying the whole history.
//!
//! ### Honest scope (audit `docs/audit/10-...`, `13-...`)
//!
//! The DDR spec claims **O(1)** civilization verification via *recursive
//! SNARKs* (T9/T10). That succinctness is a separate, standard cryptographic
//! component (Nova/Halo-style folding) and is **not** implemented here — it is
//! the pluggable backend behind [`SuccinctBackend`]. What *is* implemented and
//! tested is the sound accumulator underneath: append-only commitment +
//! logarithmic inclusion proofs + tamper evidence. So the verifiable claim made
//! here is **O(log n)**, not O(1); the gap to O(1) is exactly "add the SNARK,"
//! which the audit correctly notes is re-labeled standard work.

use ddr_core::Hash32;

fn leaf_hash(data: &Hash32) -> Hash32 {
    Hash32::of(&[b"mmr:leaf", &data.0])
}
fn node_hash(l: &Hash32, r: &Hash32) -> Hash32 {
    Hash32::of(&[b"mmr:node", &l.0, &r.0])
}
/// Bag the peaks (right fold) into the single MMR root.
fn bag(peaks: &[Hash32]) -> Hash32 {
    match peaks.split_last() {
        None => Hash32::zero(),
        Some((last, rest)) => rest
            .iter()
            .rev()
            .fold(*last, |acc, p| Hash32::of(&[b"mmr:bag", &p.0, &acc.0])),
    }
}

/// Sizes of the perfect binary trees composing an MMR of `n` leaves
/// (the set bits of `n`, largest first). E.g. 11 -> [8, 2, 1].
fn tree_sizes(n: usize) -> Vec<usize> {
    let mut v = Vec::new();
    if n == 0 {
        return v;
    }
    let mut b = usize::BITS - 1;
    loop {
        let s = 1usize << b;
        if n & s != 0 {
            v.push(s);
        }
        if b == 0 {
            break;
        }
        b -= 1;
    }
    v
}

/// Root of a perfect binary tree over `leaves` (already leaf-hashed; len is a
/// power of two).
fn perfect_root(leaves: &[Hash32]) -> Hash32 {
    if leaves.len() == 1 {
        return leaves[0];
    }
    let h = leaves.len() / 2;
    node_hash(&perfect_root(&leaves[..h]), &perfect_root(&leaves[h..]))
}

/// Authentication path of `idx` within a perfect tree: `(sibling, sibling_is_left)`.
fn perfect_path(leaves: &[Hash32], idx: usize) -> Vec<(Hash32, bool)> {
    if leaves.len() == 1 {
        return Vec::new();
    }
    let h = leaves.len() / 2;
    if idx < h {
        let sib = perfect_root(&leaves[h..]);
        let mut p = perfect_path(&leaves[..h], idx);
        p.push((sib, false)); // sibling on the right
        p
    } else {
        let sib = perfect_root(&leaves[..h]);
        let mut p = perfect_path(&leaves[h..], idx - h);
        p.push((sib, true)); // sibling on the left
        p
    }
}

fn apply_path(leaf: Hash32, path: &[(Hash32, bool)]) -> Hash32 {
    path.iter().fold(leaf, |acc, (sib, is_left)| {
        if *is_left {
            node_hash(sib, &acc)
        } else {
            node_hash(&acc, sib)
        }
    })
}

/// An inclusion proof for one attestation. Verifiable against the MMR root by a
/// party that holds only the root. Size is O(log n).
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct InclusionProof {
    pub n_leaves: usize,
    pub leaf_index: usize,
    /// Merkle path from the leaf to its peak.
    pub path: Vec<(Hash32, bool)>,
    /// The other peaks, in order, to the left and right of the target peak.
    pub peaks_left: Vec<Hash32>,
    pub peaks_right: Vec<Hash32>,
}

/// The append-only attestation accumulator.
#[derive(Clone, Debug, Default)]
pub struct Mmr {
    leaves: Vec<Hash32>, // leaf hashes, in append order
}

impl Mmr {
    pub fn new() -> Self {
        Mmr { leaves: Vec::new() }
    }

    pub fn len(&self) -> usize {
        self.leaves.len()
    }
    pub fn is_empty(&self) -> bool {
        self.leaves.is_empty()
    }

    /// Append an attestation (e.g. an epoch's civilization/state root). Returns
    /// its index in the history.
    pub fn append(&mut self, attestation: Hash32) -> usize {
        let idx = self.leaves.len();
        self.leaves.push(leaf_hash(&attestation));
        idx
    }

    fn peaks(&self) -> Vec<Hash32> {
        let mut off = 0;
        tree_sizes(self.leaves.len())
            .into_iter()
            .map(|s| {
                let pk = perfect_root(&self.leaves[off..off + s]);
                off += s;
                pk
            })
            .collect()
    }

    /// The single commitment to the entire attested history.
    pub fn root(&self) -> Hash32 {
        bag(&self.peaks())
    }

    /// Produce an O(log n) inclusion proof for the attestation at `index`.
    pub fn prove(&self, index: usize) -> Option<InclusionProof> {
        if index >= self.leaves.len() {
            return None;
        }
        let sizes = tree_sizes(self.leaves.len());
        let mut off = 0;
        let mut tree = 0;
        let mut local = index;
        for (t, &s) in sizes.iter().enumerate() {
            if index < off + s {
                tree = t;
                local = index - off;
                break;
            }
            off += s;
        }
        // peaks for all trees
        let mut o = 0;
        let peaks: Vec<Hash32> = sizes
            .iter()
            .map(|&s| {
                let pk = perfect_root(&self.leaves[o..o + s]);
                o += s;
                pk
            })
            .collect();
        let path = perfect_path(&self.leaves[off..off + sizes[tree]], local);
        Some(InclusionProof {
            n_leaves: self.leaves.len(),
            leaf_index: index,
            path,
            peaks_left: peaks[..tree].to_vec(),
            peaks_right: peaks[tree + 1..].to_vec(),
        })
    }
}

/// Stateless external verification: given only the committed `root`, the claimed
/// `attestation`, and an [`InclusionProof`], decide whether the attestation is
/// in the canonical history. No node trust, no history replay.
pub fn verify_inclusion(root: Hash32, attestation: Hash32, proof: &InclusionProof) -> bool {
    let leaf = leaf_hash(&attestation);
    let peak = apply_path(leaf, &proof.path);
    let mut peaks = proof.peaks_left.clone();
    peaks.push(peak);
    peaks.extend(proof.peaks_right.iter().copied());
    bag(&peaks) == root
}

/// The succinct backend the DDR spec's O(1) claim (T9/T10) would slot in: a
/// recursive-SNARK prover/verifier over the MMR transition. **Not implemented**
/// — defining the seam so the O(1) upgrade is explicit, not pretended.
pub trait SuccinctBackend {
    /// Fold the previous proof + a new attestation into a constant-size proof.
    fn fold(&self, prev: &[u8], attestation: Hash32, new_root: Hash32) -> Vec<u8>;
    /// Verify the constant-size proof against the committed root in O(1).
    fn verify(&self, proof: &[u8], root: Hash32) -> bool;
}

#[cfg(test)]
mod tests {
    use super::*;

    fn att(i: u64) -> Hash32 {
        Hash32::of(&[b"epoch-root", &i.to_le_bytes()])
    }

    #[test]
    fn root_is_deterministic_and_changes_on_append() {
        let mut a = Mmr::new();
        let mut b = Mmr::new();
        for i in 0..10 {
            a.append(att(i));
            b.append(att(i));
        }
        assert_eq!(a.root(), b.root(), "same history ⇒ same root");
        let before = a.root();
        a.append(att(99));
        assert_ne!(before, a.root(), "append must change the commitment");
    }

    #[test]
    fn inclusion_proofs_verify_for_all_indices_and_sizes() {
        // Exhaustive over sizes 1..=33 and every index: the core correctness.
        for n in 1..=33usize {
            let mut m = Mmr::new();
            for i in 0..n {
                m.append(att(i as u64));
            }
            let root = m.root();
            for i in 0..n {
                let proof = m.prove(i).expect("index in range");
                assert!(
                    verify_inclusion(root, att(i as u64), &proof),
                    "n={n} i={i}: valid proof must verify"
                );
            }
        }
    }

    #[test]
    fn rejects_wrong_attestation_and_tampered_proof() {
        let mut m = Mmr::new();
        for i in 0..20 {
            m.append(att(i));
        }
        let root = m.root();
        let proof = m.prove(7).unwrap();
        // Wrong attestation value at a valid position → reject.
        assert!(!verify_inclusion(root, att(999), &proof));
        // Tampered sibling in the path → reject.
        let mut bad = proof.clone();
        if let Some(first) = bad.path.first_mut() {
            first.0 = Hash32::of(&[b"forged"]);
        }
        assert!(!verify_inclusion(root, att(7), &bad));
        // Correct proof still verifies.
        assert!(verify_inclusion(root, att(7), &m.prove(7).unwrap()));
    }

    #[test]
    fn tampering_history_is_evident_in_the_root() {
        // Append-only / tamper evidence: altering any past attestation changes
        // the single commitment, so anyone holding the old root detects it.
        let mut honest = Mmr::new();
        let mut forged = Mmr::new();
        for i in 0..16 {
            honest.append(att(i));
            forged.append(if i == 5 { att(1000) } else { att(i) });
        }
        assert_ne!(honest.root(), forged.root());
        // A proof from the forged tree does not verify against the honest root.
        let p = forged.prove(5).unwrap();
        assert!(!verify_inclusion(honest.root(), att(1000), &p));
    }

    #[test]
    fn old_proof_verifies_against_the_root_it_was_made_for() {
        // An external auditor who recorded root@m can later re-verify any
        // attestation it proved, independent of further appends.
        let mut m = Mmr::new();
        for i in 0..8 {
            m.append(att(i));
        }
        let root8 = m.root();
        let p3 = m.prove(3).unwrap();
        for i in 8..40 {
            m.append(att(i));
        }
        // Proof made at size 8 still verifies against the size-8 root.
        assert!(verify_inclusion(root8, att(3), &p3));
    }
}
