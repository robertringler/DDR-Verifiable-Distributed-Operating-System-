//! `ddr-consensus` — BFT consensus with the **lock/unlock safety rule**, plus a
//! deterministic adversarial simulator.
//!
//! ## What this closes
//!
//! The DDR spec's Agreement theorem (Vol. I Thm. 3.1) was proved only for the
//! *single-round* case (audit finding `docs/audit/10-...`). The real difficulty
//! — and the real content of HotStuff/Tendermint safety — is **cross-round**:
//! once a value is decided, no later round may decide a conflicting value, even
//! under network partitions and Byzantine equivocation. The mechanism that
//! enforces this is the **lock** (Tendermint) / **locked-QC** (HotStuff) rule.
//!
//! This module implements a single-height BFT decision over multiple rounds
//! with a rotating leader, the lock/unlock rule, and a deterministic simulator
//! whose scheduler controls partitions and Byzantine behavior. The accompanying
//! tests (`tests/safety.rs`) search thousands of adversarial schedules and show:
//!
//!  * with the lock **on**: no two honest nodes ever decide differently;
//!  * with the lock **off**: a conflicting decision is found.
//!
//! The two-value model (`A`, `B`) is deliberate: it is the smallest model in
//! which a cross-round safety violation can occur, so the search is sharp.

use std::collections::{BTreeMap, BTreeSet};

pub type NodeId = u32;
pub type Round = u64;

/// A proposable value. Single height, so the contended object is just a value;
/// in the full system this is a `Block` id. `A`/`B` are the only honest
/// proposals (smallest model exhibiting cross-round conflict).
pub type Value = u8;
pub const A: Value = 1;
pub const B: Value = 2;

/// Quorum threshold `2f + 1`.
fn quorum(f: u32) -> usize {
    (2 * f + 1) as usize
}

/// Deterministic splitmix64 RNG — no external dependency, fully reproducible
/// from a seed so every adversarial schedule is replayable.
#[derive(Clone)]
pub struct Rng(u64);
impl Rng {
    pub fn new(seed: u64) -> Self {
        Rng(seed)
    }
    fn next_u64(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }
    fn below(&mut self, n: u64) -> u64 {
        if n == 0 {
            0
        } else {
            self.next_u64() % n
        }
    }
    fn pick_subset(&mut self, n: u32, k: usize) -> Vec<NodeId> {
        // Fisher–Yates partial shuffle → uniform k-subset.
        let mut ids: Vec<NodeId> = (0..n).collect();
        for i in 0..k.min(n as usize) {
            let j = i + self.below((n as usize - i) as u64) as usize;
            ids.swap(i, j);
        }
        ids.truncate(k);
        ids
    }
}

#[derive(Clone, Copy, Debug)]
pub struct Config {
    pub n: u32,
    pub f: u32,
    /// If false, honest nodes ignore the lock rule (used to demonstrate that
    /// the lock is load-bearing). Production = true.
    pub enforce_lock: bool,
    /// Rounds `>= gst_round` are fully synchronous (all nodes active). Set very
    /// high to keep the network adversarially partitioned forever (safety must
    /// still hold); set to 0 for the liveness scenario.
    pub gst_round: Round,
    pub max_rounds: Round,
}

impl Config {
    pub fn bft(n: u32) -> Self {
        Config {
            n,
            f: (n - 1) / 3,
            enforce_lock: true,
            gst_round: 0,
            max_rounds: 24,
        }
    }
}

#[derive(Clone)]
struct Validator {
    id: NodeId,
    byzantine: bool,
    /// `(round, value)` the node is locked on (Tendermint lock).
    locked: Option<(Round, Value)>,
    decided: Option<Value>,
}

/// A proposal carries the value and, if the leader was locked, the `valid_round`
/// of the polka that justifies re-proposing it (the unlock evidence).
#[derive(Clone, Copy)]
struct Proposal {
    value: Value,
    valid_round: Option<Round>,
}

/// The simulator: holds validators plus the global vote record used to detect
/// polkas (≥quorum prevotes) and commits (≥quorum precommits).
pub struct Sim {
    cfg: Config,
    vals: Vec<Validator>,
    prevotes: BTreeMap<(Round, Value), BTreeSet<NodeId>>,
    precommits: BTreeMap<(Round, Value), BTreeSet<NodeId>>,
}

/// Result of a run: the decided value of each honest node (None = undecided).
#[derive(Debug, Clone)]
pub struct Outcome {
    pub honest_decisions: Vec<(NodeId, Option<Value>)>,
}

impl Outcome {
    /// A safety violation: two honest nodes decided distinct values.
    pub fn safety_violation(&self) -> Option<((NodeId, Value), (NodeId, Value))> {
        let decided: Vec<(NodeId, Value)> = self
            .honest_decisions
            .iter()
            .filter_map(|(id, v)| v.map(|v| (*id, v)))
            .collect();
        for i in 0..decided.len() {
            for j in (i + 1)..decided.len() {
                if decided[i].1 != decided[j].1 {
                    return Some((decided[i], decided[j]));
                }
            }
        }
        None
    }

    /// Liveness: every honest node decided.
    pub fn all_decided(&self) -> bool {
        self.honest_decisions.iter().all(|(_, v)| v.is_some())
    }
}

impl Sim {
    fn new(cfg: Config, byz: &BTreeSet<NodeId>) -> Self {
        let vals = (0..cfg.n)
            .map(|id| Validator {
                id,
                byzantine: byz.contains(&id),
                locked: None,
                decided: None,
            })
            .collect();
        Sim {
            cfg,
            vals,
            prevotes: BTreeMap::new(),
            precommits: BTreeMap::new(),
        }
    }

    fn q(&self) -> usize {
        quorum(self.cfg.f)
    }

    fn polka(&self, r: Round, v: Value) -> bool {
        self.prevotes.get(&(r, v)).map_or(0, |s| s.len()) >= self.q()
    }

    /// At most one value can have a polka in a given round (honest nodes prevote
    /// one value or nil, so two values cannot each reach `f+1` honest prevotes).
    fn polka_value(&self, r: Round) -> Option<Value> {
        for v in [A, B] {
            if self.polka(r, v) {
                return Some(v);
            }
        }
        None
    }

    fn commit_value(&self, r: Round) -> Option<Value> {
        for v in [A, B] {
            if self.precommits.get(&(r, v)).map_or(0, |s| s.len()) >= self.q() {
                return Some(v);
            }
        }
        None
    }

    fn leader_proposal(&mut self, leader: NodeId, r: Round, rng: &mut Rng) -> Proposal {
        let v = &self.vals[leader as usize];
        if v.byzantine {
            // Byzantine leader: propose either value, with no valid_round
            // evidence (a fabricated valid_round would be rejected because no
            // real polka backs it).
            return Proposal {
                value: if rng.below(2) == 0 { A } else { B },
                valid_round: None,
            };
        }
        match v.locked {
            // Locked honest leader must re-propose its locked value, carrying
            // the round of the polka that justifies it.
            Some((lr, lv)) => Proposal { value: lv, valid_round: Some(lr) },
            // Unlocked honest leader proposes the round-parity value.
            None => Proposal {
                value: if r % 2 == 0 { A } else { B },
                valid_round: None,
            },
        }
    }

    /// Honest prevote rule (the safety-critical predicate).
    fn honest_prevote(&self, node: &Validator, r: Round, p: Proposal) -> Option<Value> {
        if !self.cfg.enforce_lock {
            // UNSAFE mode: prevote whatever the leader proposed. Used to show
            // the lock is load-bearing.
            return Some(p.value);
        }
        match node.locked {
            None => Some(p.value),
            Some((lr, lv)) => {
                if p.value == lv {
                    Some(p.value) // consistent with our lock
                } else if let Some(vr) = p.valid_round {
                    // Unlock only on genuine evidence: a polka for the proposed
                    // value at a round >= our lock round (and before now).
                    if vr >= lr && vr < r && self.polka(vr, p.value) {
                        Some(p.value)
                    } else {
                        None // prevote nil
                    }
                } else {
                    None // locked on a different value, no evidence → nil
                }
            }
        }
    }

    fn step_round(&mut self, r: Round, rng: &mut Rng) {
        let n = self.cfg.n;
        // Active (communicating) honest set this round. Before GST the network
        // is partitioned to exactly a quorum (sharpest setting for finding
        // cross-round violations); after GST everyone is active.
        let active: BTreeSet<NodeId> = if r >= self.cfg.gst_round {
            (0..n).collect()
        } else {
            rng.pick_subset(n, self.q()).into_iter().collect()
        };

        let leader = (r % n as Round) as NodeId;
        let proposal = self.leader_proposal(leader, r, rng);

        // --- Prevote phase ---
        // Honest active nodes prevote per the rule.
        let mut honest_prevotes: Vec<(NodeId, Value)> = Vec::new();
        for id in &active {
            let node = &self.vals[*id as usize];
            if node.byzantine {
                continue;
            }
            if let Some(v) = self.honest_prevote(node, r, proposal) {
                honest_prevotes.push((*id, v));
            }
        }
        for (id, v) in honest_prevotes {
            self.prevotes.entry((r, v)).or_default().insert(id);
        }
        // Byzantine nodes equivocate: prevote BOTH values (max adversary power).
        for v in &self.vals {
            if v.byzantine {
                self.prevotes.entry((r, A)).or_default().insert(v.id);
                self.prevotes.entry((r, B)).or_default().insert(v.id);
            }
        }

        // --- Precommit phase ---
        // Honest active nodes precommit (and LOCK) the polka value, if any.
        let polka_v = self.polka_value(r);
        let mut honest_precommits: Vec<(NodeId, Value)> = Vec::new();
        for id in &active {
            let node = &mut self.vals[*id as usize];
            if node.byzantine {
                continue;
            }
            if let Some(v) = polka_v {
                node.locked = Some((r, v)); // lock on what we precommit
                honest_precommits.push((*id, v));
            }
        }
        for (id, v) in honest_precommits {
            self.precommits.entry((r, v)).or_default().insert(id);
        }
        for v in &self.vals {
            if v.byzantine {
                self.precommits.entry((r, A)).or_default().insert(v.id);
                self.precommits.entry((r, B)).or_default().insert(v.id);
            }
        }

        // --- Decide phase ---
        let commit_v = self.commit_value(r);
        if let Some(v) = commit_v {
            for id in &active {
                let node = &mut self.vals[*id as usize];
                if !node.byzantine && node.decided.is_none() {
                    node.decided = Some(v);
                }
            }
        }
    }

    fn outcome(&self) -> Outcome {
        Outcome {
            honest_decisions: self
                .vals
                .iter()
                .filter(|v| !v.byzantine)
                .map(|v| (v.id, v.decided))
                .collect(),
        }
    }
}

/// Run one simulation to completion and return the honest decisions.
pub fn run(cfg: Config, byz: &BTreeSet<NodeId>, seed: u64) -> Outcome {
    assert!(cfg.n >= 3 * cfg.f + 1, "BFT requires n >= 3f+1");
    assert!(byz.len() as u32 <= cfg.f, "at most f Byzantine nodes");
    let mut rng = Rng::new(seed);
    let mut sim = Sim::new(cfg, byz);
    for r in 0..cfg.max_rounds {
        sim.step_round(r, &mut rng);
    }
    sim.outcome()
}

/// Search `trials` adversarial schedules (random Byzantine set + random
/// partition schedule) for a safety violation. Returns the first seed that
/// violates safety, or `None` if all schedules were safe.
pub fn search_for_violation(mut cfg: Config, trials: u64) -> Option<(u64, Outcome)> {
    // Keep the network partitioned for the whole run so safety is tested under
    // permanent asynchrony.
    cfg.gst_round = cfg.max_rounds + 1;
    for seed in 0..trials {
        let mut rng = Rng::new(seed ^ 0xD1B5_4A32_D192_ED03);
        // Random Byzantine set of size exactly f.
        let byz: BTreeSet<NodeId> = rng.pick_subset(cfg.n, cfg.f as usize).into_iter().collect();
        let out = run(cfg, &byz, seed);
        if out.safety_violation().is_some() {
            return Some((seed, out));
        }
    }
    None
}

#[cfg(test)]
mod unit {
    use super::*;

    #[test]
    fn quorum_intersection_holds() {
        // Two quorums of size 2f+1 in n=3f+1 intersect in >= f+1 nodes.
        for f in 1..20u32 {
            let n = 3 * f + 1;
            let q = quorum(f) as u32;
            assert!(2 * q > n + f, "quorum intersection must exceed Byzantine count");
        }
    }
}
