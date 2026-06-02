//! The safety keystone, as executable tests.
//!
//! These three tests are the whole point of Milestone 1. They turn the spec's
//! *asserted* cross-round Agreement into something measured:
//!
//!  1. `liveness_under_synchrony` — progress actually happens.
//!  2. `safety_under_adversary_with_lock` — no conflicting decisions, ever,
//!      across thousands of partitioned + Byzantine schedules.
//!  3. `lock_is_load_bearing` — the SAME search WITHOUT the lock finds a
//!      violation. This proves the test is meaningful: its verdict changes
//!      when the safety mechanism is removed.

use std::collections::BTreeSet;

use ddr_consensus::{run, search_for_violation, Config, NodeId};

#[test]
fn liveness_under_synchrony() {
    // No Byzantine nodes, fully synchronous (gst=0): everyone must decide,
    // and on the same value.
    for &n in &[4u32, 7, 10] {
        let mut cfg = Config::bft(n);
        cfg.gst_round = 0;
        let out = run(cfg, &BTreeSet::new(), 12345);
        assert!(out.all_decided(), "n={n}: all honest nodes must decide under synchrony");
        assert!(
            out.safety_violation().is_none(),
            "n={n}: synchronous run must agree"
        );
    }
}

#[test]
fn safety_under_adversary_with_lock() {
    // Lock ON. Permanent partitions + f Byzantine equivocators. Search a large
    // number of schedules; there must be ZERO conflicting decisions.
    for &n in &[4u32, 7, 10] {
        let cfg = Config::bft(n); // enforce_lock = true
        let found = search_for_violation(cfg, 40_000);
        assert!(
            found.is_none(),
            "n={n}: safety violated with the lock ON (seed {:?}) — this would be a real bug",
            found.map(|(s, _)| s)
        );
    }
}

#[test]
fn lock_is_load_bearing() {
    // Lock OFF. The same adversarial search MUST find a conflicting decision.
    // If it does not, the safety test above proves nothing.
    let mut cfg = Config::bft(4);
    cfg.enforce_lock = false;
    let found = search_for_violation(cfg, 40_000);
    assert!(
        found.is_some(),
        "without the lock rule the search should expose a cross-round safety violation"
    );
    let (seed, out) = found.unwrap();
    let v = out.safety_violation().unwrap();
    eprintln!(
        "lock-off violation at seed {seed}: node {} decided {}, node {} decided {}",
        (v.0).0, (v.0).1, (v.1).0, (v.1).1
    );
}

#[test]
fn rejects_too_many_byzantine() {
    // Sanity: the model enforces n >= 3f+1 and |byz| <= f.
    let cfg = Config::bft(4); // f = 1
    let byz: BTreeSet<NodeId> = [0u32, 1].into_iter().collect(); // 2 > f
    let r = std::panic::catch_unwind(|| run(cfg, &byz, 0));
    assert!(r.is_err(), "more than f Byzantine nodes must be rejected");
}
