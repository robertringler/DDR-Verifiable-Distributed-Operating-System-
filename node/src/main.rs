//! DDR demo node.
//!
//! Runs two things:
//!  1. A healthy simulated cluster reaching agreement, and reduces a tx log.
//!  2. The "lock is load-bearing" experiment: the same adversarial search with
//!     the lock on (safe) vs. off (a conflicting decision is found).

use std::collections::BTreeSet;

use ddr_consensus::{run, search_for_violation, Config};
use ddr_core::{reduce, StateRoot, Tx};

fn main() {
    println!("== DDR Milestone 1 ==\n");

    // 1. Deterministic state layer.
    let genesis = StateRoot::zero();
    let log: Vec<Tx> = (0..5).map(|i| Tx::new(format!("tx{i}").into_bytes())).collect();
    let root = reduce(genesis, &log);
    println!("[core] reduced {} txs -> state root {:?}", log.len(), root);
    println!("[core] replay yields same root: {}\n", reduce(genesis, &log) == root);

    // 2. Healthy cluster (synchronous, no Byzantine).
    let n = 7;
    let mut cfg = Config::bft(n);
    cfg.gst_round = 0;
    let out = run(cfg, &BTreeSet::new(), 42);
    let decided: Vec<_> = out.honest_decisions.iter().map(|(_, v)| *v).collect();
    println!("[consensus] n={n}, f={}: decisions = {:?}", cfg.f, decided);
    println!("[consensus] all decided: {}", out.all_decided());
    println!("[consensus] agreement (no conflicting decision): {}\n", out.safety_violation().is_none());

    // 3. The keystone experiment.
    println!("[keystone] cross-round safety under partitions + Byzantine equivocation:");
    let safe = search_for_violation(Config::bft(7), 40_000);
    println!(
        "  lock ON  : {}",
        match safe {
            None => "no violation in 40k adversarial schedules ✔".to_string(),
            Some((s, _)) => format!("VIOLATION at seed {s} (bug!)"),
        }
    );

    let mut unsafe_cfg = Config::bft(4);
    unsafe_cfg.enforce_lock = false;
    match search_for_violation(unsafe_cfg, 40_000) {
        Some((seed, o)) => {
            let v = o.safety_violation().unwrap();
            println!(
                "  lock OFF : VIOLATION found at seed {seed} — node {} decided {}, node {} decided {} ✔ (expected)",
                (v.0).0, (v.0).1, (v.1).0, (v.1).1
            );
            println!("\nConclusion: the lock rule is load-bearing — removing it breaks cross-round safety.");
        }
        None => println!("  lock OFF : no violation found (unexpected — search too weak)"),
    }
}
