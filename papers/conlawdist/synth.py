"""
SYNTHETIC ConLawDist generator.

  *** THIS IS SYNTHETIC DATA. IT CONTAINS NO REAL LAW AND NO REAL EXPERT
      LABELS. ITS ONLY PURPOSE IS TO VALIDATE THE HARNESS AND DEMONSTRATE
      THE FALSIFIER. ***

It builds a hidden latent metric space with KNOWN ground-truth distances,
drift labels, and expert judgments, then emits the OBSERVABLE inputs the d_sem
implementation consumes (a knowledge graph + an embedding matrix). Because the
graph and embeddings are both derived from the same latent space, a faithful
d_sem should recover the latent distances (high Spearman, high drift-AUC) -
showing the *pipeline* works. A 'null' variant randomizes the embeddings so
the falsifier (collapse of Spearman/AUC) can be exercised.

The real benchmark replaces this module with the corpus + expert labels
specified in DATA_COLLECTION.md.
"""
from __future__ import annotations
from dataclasses import dataclass
import numpy as np


@dataclass
class SynthData:
    Z: np.ndarray            # latent vectors (ground truth) [n, m]
    W: np.ndarray            # observable kNN graph adjacency [n, n]
    E: np.ndarray            # observable embeddings [n, p]
    intent_idx: np.ndarray   # indices of in-intent ("constitutional") states
    drift_label: np.ndarray  # {0,1} per state: did intent drift?
    drift_mag: np.ndarray    # [0,1] true drift magnitude per state
    gold_pairs: list         # list of (i,j) pairs with expert judgments
    gold_vals: np.ndarray    # expert-judged distance per gold pair
    d_true: np.ndarray       # ground-truth latent distance matrix [n,n]


def make(n=240, m=6, n_topics=5, k=8, emb_dim=16, emb_noise=0.15,
         graph_noise=0.10, n_gold_pairs=600, expert_noise=0.20,
         drift_quantile=0.75, null=False, seed=0) -> SynthData:
    from dsem import knn_graph
    rng = np.random.default_rng(seed)

    # latent space: a few "legal topics" (clusters) in R^m
    centers = rng.normal(0, 1.0, size=(n_topics, m)) * 2.5
    topic = rng.integers(0, n_topics, n)
    Z = centers[topic] + rng.normal(0, 0.6, size=(n, m))

    # ground-truth latent distance
    d_true = np.linalg.norm(Z[:, None, :] - Z[None, :, :], axis=-1)

    # constitutional anchor c*: the centroid of topic 0; I_intent = states near it
    c_star = centers[0]
    dist_to_intent = np.linalg.norm(Z - c_star, axis=1)
    intent_idx = np.argsort(dist_to_intent)[: max(5, n // 20)]

    # drift: a state has "drifted" if it is far from the intent region
    thr = np.quantile(dist_to_intent, drift_quantile)
    drift_label = (dist_to_intent > thr).astype(int)
    mag = (dist_to_intent - dist_to_intent.min())
    drift_mag = mag / mag.max()

    # In NULL/falsifier mode, the OBSERVABLE layers (graph + embeddings) are
    # built from an INDEPENDENT latent space, so d_sem is still a valid metric
    # (triangle = 0) but bears no relation to the true semantics that generated
    # the drift labels and expert judgments. A faithful harness must then see
    # Spearman -> ~0 and drift AUC -> ~0.5. (Randomizing only the embeddings is
    # insufficient here: the graph layer alone is faithful by construction.)
    Z_obs = rng.normal(0, 1.0, size=Z.shape) * 2.5 if null else Z

    # observable graph: kNN on noisy latent (edge weights ~ distances)
    Zg = Z_obs + rng.normal(0, graph_noise, size=Z.shape)
    W = knn_graph(Zg, k=k)

    # observable embeddings: a random linear lift of latent + noise
    P = rng.normal(0, 1.0, size=(m, emb_dim))
    E = Z_obs @ P + rng.normal(0, emb_noise, size=(n, emb_dim))

    # expert pairwise judgments: ground-truth distance + noise
    pairs = []
    seen = set()
    while len(pairs) < n_gold_pairs:
        i, j = int(rng.integers(0, n)), int(rng.integers(0, n))
        if i != j and (i, j) not in seen:
            seen.add((i, j)); pairs.append((i, j))
    gold_vals = np.array([d_true[i, j] for i, j in pairs])
    gold_vals = gold_vals + rng.normal(0, expert_noise * gold_vals.std(),
                                       size=gold_vals.shape)

    return SynthData(Z=Z, W=W, E=E, intent_idx=intent_idx,
                     drift_label=drift_label, drift_mag=drift_mag,
                     gold_pairs=pairs, gold_vals=gold_vals, d_true=d_true)
