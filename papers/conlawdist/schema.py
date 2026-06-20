"""
ConLawDist on-disk schema + validation.

Defines the exact format a REAL ConLawDist release must provide, so a legal
team can produce it and the harness (run_benchmark.py) can consume it without
modification. The synthetic generator emits the same in-memory structures.

A release is a directory with:
  states.jsonl       one row per semantic state (statute application)
  edges.jsonl        certified semantic-relation edges (the knowledge graph)
  embeddings.npy     [n, p] float matrix, row i = E(state_i) (Lipschitz encoder)
  intent.json        {"intent_state_ids": [...]}   the in-intent anchor set
  drift.jsonl        per-state expert drift labels + magnitudes
  pairs.jsonl        expert pairwise distance judgments (for Spearman/Kendall)

Each row schema below. ids are stable strings; the harness maps them to indices.
"""
from __future__ import annotations
from dataclasses import dataclass, field
from typing import Any
import json
import numpy as np


# ---- row schemas (documented; validated by `validate`) --------------------
STATE_FIELDS = {
    "id": str,            # stable unique id, e.g. "18USC922(g)#2016"
    "text": str,          # the statutory application text (for the encoder)
    "citation": str,      # e.g. "18 U.S.C. 922(g)"
    "as_of": str,         # ISO date of this version (amendment history anchor)
}
EDGE_FIELDS = {
    "src": str, "dst": str,
    "rel": str,           # one of: cross_ref | amends | exception | defines | supersedes
    "weight": float,      # > 0 ; semantic cost of the relation
}
DRIFT_FIELDS = {
    "id": str,            # state id this label applies to
    "drift": int,         # {0,1} expert judgment: has intent drifted?
    "magnitude": float,   # [0,1] expert-judged drift magnitude
    "source": str,        # provenance, e.g. "SCOTUS 2014 <case>" or "expert#3"
}
PAIR_FIELDS = {
    "i": str, "j": str,   # two state ids
    "distance": float,    # expert-judged semantic distance (any positive scale)
    "n_raters": int,      # how many experts contributed (for weighting/CI)
}


@dataclass
class ConLawDataset:
    ids: list                       # state ids, defining the index order
    text: list                      # parallel state texts
    W: np.ndarray                   # [n,n] adjacency (np.inf off-graph)
    E: np.ndarray                   # [n,p] embeddings
    intent_idx: np.ndarray          # indices of in-intent states
    drift_label: np.ndarray         # [n] {0,1} (NaN where unlabeled)
    drift_mag: np.ndarray           # [n] [0,1] (NaN where unlabeled)
    gold_pairs: list                # [(i_idx, j_idx), ...]
    gold_vals: np.ndarray           # [len(pairs)] expert distances
    meta: dict = field(default_factory=dict)


def _read_jsonl(path):
    with open(path) as f:
        return [json.loads(line) for line in f if line.strip()]


def load(dirpath: str) -> ConLawDataset:
    import os
    states = _read_jsonl(os.path.join(dirpath, "states.jsonl"))
    edges = _read_jsonl(os.path.join(dirpath, "edges.jsonl"))
    drift = _read_jsonl(os.path.join(dirpath, "drift.jsonl"))
    pairs = _read_jsonl(os.path.join(dirpath, "pairs.jsonl"))
    with open(os.path.join(dirpath, "intent.json")) as f:
        intent = json.load(f)
    E = np.load(os.path.join(dirpath, "embeddings.npy"))

    ids = [s["id"] for s in states]
    idx = {sid: i for i, sid in enumerate(ids)}
    n = len(ids)

    W = np.full((n, n), np.inf)
    np.fill_diagonal(W, 0.0)
    for e in edges:
        a, b, w = idx[e["src"]], idx[e["dst"]], float(e["weight"])
        W[a, b] = min(W[a, b], w)
        W[b, a] = min(W[b, a], w)   # treat relations as symmetric costs

    drift_label = np.full(n, np.nan)
    drift_mag = np.full(n, np.nan)
    for d in drift:
        i = idx[d["id"]]
        drift_label[i] = d["drift"]
        drift_mag[i] = d["magnitude"]

    gold_pairs = [(idx[p["i"]], idx[p["j"]]) for p in pairs]
    gold_vals = np.array([float(p["distance"]) for p in pairs])
    intent_idx = np.array([idx[s] for s in intent["intent_state_ids"]])

    return ConLawDataset(ids=ids, text=[s["text"] for s in states], W=W, E=E,
                         intent_idx=intent_idx, drift_label=drift_label,
                         drift_mag=drift_mag, gold_pairs=gold_pairs,
                         gold_vals=gold_vals, meta={"n": n, "n_edges": len(edges)})


def validate(ds: ConLawDataset) -> list[str]:
    """Return a list of problems; empty list == valid."""
    p = []
    n = len(ds.ids)
    if ds.E.shape[0] != n:
        p.append(f"embeddings rows {ds.E.shape[0]} != n states {n}")
    if ds.W.shape != (n, n):
        p.append(f"adjacency shape {ds.W.shape} != ({n},{n})")
    if len(set(ds.ids)) != n:
        p.append("duplicate state ids")
    labeled = np.isfinite(ds.drift_label).sum()
    if labeled < 50:
        p.append(f"only {labeled} drift labels; >=200 recommended (audit 03 §2)")
    if len(ds.gold_pairs) < 100:
        p.append(f"only {len(ds.gold_pairs)} expert pairs; >=500 recommended")
    # graph connectivity (else d_graph has inf entries)
    from dsem import all_pairs_shortest_path
    D = all_pairs_shortest_path(ds.W)
    if not np.isfinite(D).all():
        p.append("knowledge graph is disconnected (d_graph has inf entries)")
    return p
