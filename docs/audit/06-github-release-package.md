# Task 7 — GitHub Release Package

> **Hardest truth first:** the worst thing this project could publish is a repo
> that *looks* like a finished verifiable OS. The current scaffold (empty
> crates + a TLA+ `Next` that holds state constant) plus "civilization-scale"
> framing reads as vaporware to exactly the experts you want. The release must
> foreground the open problems and ship *one thing that runs and measures
> something*. Credibility comes from the falsification harness, not the manifold.

## Repository structure

```
ddr-ciir/
├─ README.md                  # research-program register (below); open problems up top
├─ docs/
│  ├─ spec/                   # the unified spec (this PDF), versioned
│  ├─ audit/                  # this review (kept in-tree, adversarial by design)
│  ├─ open-problems/          # one file per OP#1..#8, status-tracked
│  └─ adr/                    # architecture decision records
├─ ciir-poc/                  # the Task 6 workspace (the part that RUNS)
├─ proofs/
│  ├─ lean/                   # Mathlib-backed; abstract Banach today, semantic later
│  └─ tla/                    # honest TLA+ (no theorems asserted without proof)
├─ benchmarks/
│  └─ conlawdist/             # the d_sem benchmark (Task 4) — the real asset
├─ CITATION.cff
├─ CONTRIBUTING.md
└─ STATUS.md                  # PROVEN / SKETCH / CONDITIONAL / ASSERTED / OPEN ledger
```

## Docs hierarchy

- **`STATUS.md`** is the centerpiece: a living table mirroring the Task 2
  classification. Every theorem links to its proof artifact or to the open
  problem it is conditional on. No claim ships without a status.
- **`docs/open-problems/`**: each OP gets owner, difficulty, current best
  result, and the falsification criterion.
- **`docs/audit/`**: this report stays in-tree. A project that hosts its own
  red-team is more credible than one that hides it.

## Release & versioning plan

- **SemVer for code** (`ciir-poc`), **CalVer for the spec** (`spec-2026.06`).
- Pre-1.0 until a *non-trivial semantic* theorem is mechanized **and** the PoC
  decision rule passes on a real domain. Tagging 1.0 before that is the
  cardinal sin.
- Each release ships `STATUS.md` diffs ("T7 reclassified SKETCH→CONDITIONAL
  after fixing the δ/(1−κ) bound").

## Citation policy

- `CITATION.cff` cites the spec as a **preprint / working specification**, not a
  result. Distinguish "framework (definitions)" from "theorems (mostly
  conditional)" in the abstract.
- Require that downstream citations of any `[CONDITIONAL]`/`[ASSERTED]` theorem
  carry its status tag (enforced socially via the README).

## Contribution model

- Apache-2.0 / MIT dual (math + standards posture).
- **Proof-gated merges:** a PR claiming a theorem must add a Lean proof or move
  it to `open-problems/` — CI rejects new `[ASSERTED]` rows in `STATUS.md`.
- Benchmark contributions (new `d_sem` domains, new drift labels) are the
  highest-value external contributions; lower the bar for those.

---

## The README (≈500 words)

```markdown
# DDR + CIIR — A Research Program on Verifiable Semantic Regulation

**Status: early research. Most central theorems are conditional on two
unsolved problems. This README states them before anything else.**

## What is unsolved (read this first)

DDR+CIIR proposes that a distributed system can verify not only that its
transitions are *computationally* correct (the DDR layer) but that they remain
*semantically* faithful to the intent that specified them (the CIIR layer).
The semantic layer is built on two objects we have **not yet constructed**:

1. **A semantic metric `d_sem`** on the space of "intents." Every convergence
   and stability theorem assumes this is a genuine metric. We do not yet know
   that meaning-distance satisfies the triangle inequality; it may only be a
   pseudometric or a divergence. (Open Problem #1.)
2. **A contraction constant `κ < 1`** for the stabilization operator under
   `d_sem`. Without it there is no unique equilibrium and no convergence rate.
   (Open Problem #2.)

Until #1 and #2 are solved, our headline theorems (semantic stability,
epistemic convergence, drift containment, global verifiability) are **corollaries
of the Banach fixed-point theorem applied to objects that do not yet exist.**
We say this plainly because the alternative — implying they are proven — would
waste your time. Six further open problems (#3–#8) are tracked in
`docs/open-problems/` and `STATUS.md`.

## What is actually here

- **A formal specification** (`docs/spec/`) defining the semantic layer as an
  interface over the DDR substrate. It is a *framework*, not a body of proven
  results. See `STATUS.md` for the per-theorem PROVEN/CONDITIONAL/ASSERTED
  ledger and `docs/audit/` for an in-tree adversarial review of our own claims.
- **A proof-of-concept** (`ciir-poc/`) that does the one thing that matters: it
  builds a candidate `d_sem` on a bounded legal corpus and **measures whether a
  semantic oracle detects intent-drift that syntactic checks miss** — and
  whether a faithful operator can actually be a contraction. `cargo run -p
  ciir-eval` prints a metrics report and a single verdict: does the evidence
  support the semantic-regulation thesis, or contradict it?
- **A benchmark** (`benchmarks/conlawdist/`) of statutory intent-drift cases —
  useful independently of the rest of the program.
- **Lean proofs** (`proofs/lean/`) of the abstract layer (the Banach core,
  honestly labeled as such) and the mechanization targets for the rest.

## How to read our claims

Every theorem carries a status. `[CONDITIONAL]` means "true *if* an unsolved
problem is solved." `[ASSERTED]` means "stated but not proven." Cite
accordingly. If you find a theorem mislabeled — especially one we have marked
PROVEN — open an issue; the audit in `docs/audit/` exists because we expect to
be wrong in places.

## Contributing

The most valuable contributions are: (a) a faithful `d_sem` for any concrete
domain with a measured triangle-violation rate, (b) a proven or measured `κ<1`,
(c) Lean mechanizations that move a row out of `[CONDITIONAL]`. CI rejects new
unproven theorem claims. See `CONTRIBUTING.md`.

## License

Apache-2.0 / MIT.
```
