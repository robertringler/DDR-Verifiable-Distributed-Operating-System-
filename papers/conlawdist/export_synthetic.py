#!/usr/bin/env python3
"""
Export a SYNTHETIC dataset to the on-disk ConLawDist schema (schema.py), then
load it back and validate. Serves two purposes:
  (1) a concrete, inspectable example of the exact file format a real release
      must provide (see DATA_COLLECTION.md);
  (2) a round-trip test that schema.load + schema.validate accept the format.

Run:  python3 export_synthetic.py [outdir] [n]
Default writes a small n=12 example to data/example/ (committed as a format
reference). Larger generated data should be left untracked.
"""
from __future__ import annotations
import json
import os
import sys
import numpy as np

import synth
import schema


def export(outdir: str, n: int = 12, seed: int = 7):
    os.makedirs(outdir, exist_ok=True)
    d = synth.make(n=n, seed=seed, k=min(6, n - 1), n_gold_pairs=min(40, n * 3))
    nn = len(d.Z)

    with open(os.path.join(outdir, "states.jsonl"), "w") as f:
        for i in range(nn):
            f.write(json.dumps({
                "id": f"s{i}", "text": f"SYNTHETIC state {i} (not real law)",
                "citation": "SYNTH", "as_of": "2020-01-01"}) + "\n")

    with open(os.path.join(outdir, "edges.jsonl"), "w") as f:
        for i in range(nn):
            for j in range(i + 1, nn):
                if np.isfinite(d.W[i, j]):
                    f.write(json.dumps({
                        "src": f"s{i}", "dst": f"s{j}", "rel": "cross_ref",
                        "weight": round(float(d.W[i, j]), 6)}) + "\n")

    np.save(os.path.join(outdir, "embeddings.npy"), d.E.astype(np.float32))

    with open(os.path.join(outdir, "intent.json"), "w") as f:
        json.dump({"intent_state_ids": [f"s{i}" for i in d.intent_idx]}, f, indent=2)

    with open(os.path.join(outdir, "drift.jsonl"), "w") as f:
        for i in range(nn):
            f.write(json.dumps({
                "id": f"s{i}", "drift": int(d.drift_label[i]),
                "magnitude": round(float(d.drift_mag[i]), 4),
                "source": "synthetic"}) + "\n")

    with open(os.path.join(outdir, "pairs.jsonl"), "w") as f:
        for (i, j), v in zip(d.gold_pairs, d.gold_vals):
            f.write(json.dumps({
                "i": f"s{i}", "j": f"s{j}", "distance": round(float(v), 6),
                "n_raters": 3}) + "\n")

    ds = schema.load(outdir)
    problems = schema.validate(ds)
    print(f"wrote {outdir}: n={ds.meta['n']} edges={ds.meta['n_edges']}")
    # the tiny example may trip the >=200-label / >=500-pair size advisories;
    # those are recommendations, not format errors — report them, don't fail.
    fmt_errors = [p for p in problems if "recommended" not in p]
    print("format errors:", fmt_errors if fmt_errors else "NONE")
    print("size advisories:", [p for p in problems if "recommended" in p] or "none")
    return 0 if not fmt_errors else 1


if __name__ == "__main__":
    outdir = sys.argv[1] if len(sys.argv) > 1 else "data/example"
    n = int(sys.argv[2]) if len(sys.argv) > 2 else 12
    raise SystemExit(export(outdir, n))
