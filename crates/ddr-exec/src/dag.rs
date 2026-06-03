//! DAG-scheduled parallel execution with deterministic results (DDR Vol. I
//! Ch. 8, Thm. 8.2 "Parallel Determinism").
//!
//! Transactions declare read/write sets over a keyed world-state. Two
//! transactions *conflict* if one writes a key the other reads or writes
//! (read–read does not conflict). The dependency DAG orders conflicting
//! transactions by their position in the log. **Theorem 8.2:** every
//! serialization that respects the DAG (every valid topological order) yields
//! the same final state — so the scheduler may run independent transactions in
//! any order / in parallel without changing the result.
//!
//! The tests below *verify* this: over random workloads, all valid topological
//! orders agree (and produce the same `world_root`), while an order that
//! violates a dependency can diverge — i.e. respecting the DAG is load-bearing.

use std::collections::BTreeMap;

use ddr_core::Hash32;

pub type Key = u32;
pub type Value = u64;
pub type World = BTreeMap<Key, Value>;

/// A keyed transaction: `world[write] = (Σ world[reads]) + delta`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct KeyedTx {
    pub reads: Vec<Key>,
    pub write: Key,
    pub delta: u64,
}

impl KeyedTx {
    fn apply(&self, world: &mut World) {
        let sum: u64 = self
            .reads
            .iter()
            .map(|k| world.get(k).copied().unwrap_or(0))
            .fold(0u64, |a, b| a.wrapping_add(b));
        world.insert(self.write, sum.wrapping_add(self.delta));
    }
}

/// Do transactions `a` and `b` conflict? (write–write, write–read, read–write;
/// read–read does not conflict.)
pub fn conflict(a: &KeyedTx, b: &KeyedTx) -> bool {
    a.write == b.write || b.reads.contains(&a.write) || a.reads.contains(&b.write)
}

/// Commitment to a world-state: hash of its sorted (key,value) entries.
pub fn world_root(world: &World) -> Hash32 {
    let mut parts: Vec<Vec<u8>> = vec![b"world".to_vec()];
    for (k, v) in world {
        parts.push(k.to_le_bytes().to_vec());
        parts.push(v.to_le_bytes().to_vec());
    }
    let refs: Vec<&[u8]> = parts.iter().map(|v| v.as_slice()).collect();
    Hash32::of(&refs)
}

/// Apply transactions in the given `order` (a permutation of `0..txs.len()`).
pub fn execute(genesis: &World, txs: &[KeyedTx], order: &[usize]) -> World {
    let mut world = genesis.clone();
    for &i in order {
        txs[i].apply(&mut world);
    }
    world
}

/// Sequential (canonical) execution = the identity order `0,1,2,...`.
pub fn execute_sequential(genesis: &World, txs: &[KeyedTx]) -> World {
    execute(genesis, txs, &(0..txs.len()).collect::<Vec<_>>())
}

/// Is `order` a valid topological order of the dependency DAG? (Conflicting
/// transactions must keep their original relative order.)
pub fn is_valid_topo(txs: &[KeyedTx], order: &[usize]) -> bool {
    let mut pos = vec![0usize; txs.len()];
    for (p, &i) in order.iter().enumerate() {
        pos[i] = p;
    }
    for i in 0..txs.len() {
        for j in (i + 1)..txs.len() {
            if conflict(&txs[i], &txs[j]) && pos[i] > pos[j] {
                return false;
            }
        }
    }
    true
}

/// The DAG scheduler: execute in dependency "waves". Transactions in a wave are
/// mutually independent (no conflicts), so they may run in parallel; we apply
/// them and move on. The result equals `execute_sequential` (Thm. 8.2).
pub fn execute_parallel(genesis: &World, txs: &[KeyedTx]) -> World {
    let n = txs.len();
    let mut done = vec![false; n];
    let mut world = genesis.clone();
    let mut remaining = n;
    while remaining > 0 {
        // A tx is ready if every earlier conflicting tx is already done.
        let wave: Vec<usize> = (0..n)
            .filter(|&i| !done[i])
            .filter(|&i| (0..i).all(|j| done[j] || !conflict(&txs[j], &txs[i])))
            .collect();
        debug_assert!(!wave.is_empty(), "DAG is acyclic ⇒ a wave always exists");
        // Independent within the wave ⇒ order-free; apply all.
        for &i in &wave {
            txs[i].apply(&mut world);
            done[i] = true;
        }
        remaining -= wave.len();
    }
    world
}

#[cfg(test)]
mod tests {
    use super::*;

    // tiny deterministic RNG (splitmix64)
    struct Rng(u64);
    impl Rng {
        fn n(&mut self, m: u64) -> u64 {
            self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
            let mut z = self.0;
            z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
            z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
            (z ^ (z >> 31)) % m
        }
    }

    fn rand_txs(rng: &mut Rng, count: usize, keyspace: u32) -> Vec<KeyedTx> {
        (0..count)
            .map(|_| {
                let nr = rng.n(3) as usize; // 0..2 reads
                let reads = (0..nr).map(|_| rng.n(keyspace as u64) as Key).collect();
                KeyedTx {
                    reads,
                    write: rng.n(keyspace as u64) as Key,
                    delta: rng.n(10),
                }
            })
            .collect()
    }

    // A random *valid* topological order via randomized Kahn's algorithm.
    fn random_topo(rng: &mut Rng, txs: &[KeyedTx]) -> Vec<usize> {
        let n = txs.len();
        let mut placed = vec![false; n];
        let mut order = Vec::with_capacity(n);
        while order.len() < n {
            let ready: Vec<usize> = (0..n)
                .filter(|&i| !placed[i])
                .filter(|&i| (0..i).all(|j| placed[j] || !conflict(&txs[j], &txs[i])))
                .collect();
            let pick = ready[rng.n(ready.len() as u64) as usize];
            placed[pick] = true;
            order.push(pick);
        }
        order
    }

    #[test]
    fn all_valid_topological_orders_agree() {
        // Thm 8.2: any DAG-respecting order yields the same world + root.
        let mut rng = Rng(0xDD12_3451_u64);
        for _ in 0..3000 {
            let txs = rand_txs(&mut rng, 8, 4);
            let base = execute_sequential(&World::new(), &txs);
            let base_root = world_root(&base);
            // parallel scheduler agrees
            assert_eq!(world_root(&execute_parallel(&World::new(), &txs)), base_root);
            // many random valid topo orders agree
            for _ in 0..8 {
                let order = random_topo(&mut rng, &txs);
                assert!(is_valid_topo(&txs, &order));
                assert_eq!(world_root(&execute(&World::new(), &txs, &order)), base_root);
            }
        }
    }

    #[test]
    fn independent_transactions_commute() {
        // Disjoint read/write sets ⇒ order does not matter.
        let txs = vec![
            KeyedTx { reads: vec![1], write: 10, delta: 1 },
            KeyedTx { reads: vec![2], write: 20, delta: 2 },
        ];
        let a = execute(&World::new(), &txs, &[0, 1]);
        let b = execute(&World::new(), &txs, &[1, 0]);
        assert_eq!(a, b);
        assert!(is_valid_topo(&txs, &[1, 0]), "no conflict ⇒ either order is valid");
    }

    #[test]
    fn respecting_the_dag_is_load_bearing() {
        // Conflicting txs in the wrong order diverge — so the DAG is not
        // decorative. Search for a workload where swapping a conflicting pair
        // changes the result.
        let mut rng = Rng(0xC0FFEE);
        let mut found = false;
        for _ in 0..5000 {
            let txs = rand_txs(&mut rng, 6, 3);
            let base = world_root(&execute_sequential(&World::new(), &txs));
            // find a conflicting adjacent pair (i, i+1) and swap it (invalid order)
            for i in 0..txs.len() - 1 {
                if conflict(&txs[i], &txs[i + 1]) {
                    let mut order: Vec<usize> = (0..txs.len()).collect();
                    order.swap(i, i + 1);
                    assert!(!is_valid_topo(&txs, &order));
                    if world_root(&execute(&World::new(), &txs, &order)) != base {
                        found = true;
                    }
                    break;
                }
            }
            if found {
                break;
            }
        }
        assert!(found, "violating a dependency must be able to change the result");
    }
}
