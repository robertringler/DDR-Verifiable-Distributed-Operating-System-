# CIIR — A Corrected Monograph (rebuild)

`monograph.md` — a rigorous, corrected rebuild of the 22-chapter CIIR monograph,
in five parts (Foundations · Dynamics · Semantic layer · Categorical structure ·
Verification & empirics) plus three appendices.

## What it is — and is not

- **Is:** a coherent 22-chapter monograph that keeps CIIR's genuinely correct core
  (operator algebra, GKLS dynamics, the honest Banach result), **constructs** the
  semantic objects the original only asserted (`d_sem`, `Φ_rec`, `Π_C`), **replaces**
  the refuted strict-contraction keystone with a damped-projection mechanism,
  **fixes** all six audit-found proof errors, and **retires** the cross-domain /
  astrology "theory of everything" reach via a demarcation theorem. Every result
  carries a status tag; Appendix B is the full ledger.
- **Is not:** the original monograph's text. The original LaTeX is in a different,
  out-of-scope repository; chapter *contents* here are reconstructed from the
  adversarial audit (`docs/audit/00–11`), and the *mathematics* is the verified work
  of `docs/audit/17`, `papers/theorem-k/`, `papers/conlawdist/`, and the
  machine-checked DDR substrate (`docs/audit/12–16`). This provenance is stated in
  the monograph's preamble and is not hidden.

## The four substantive repairs

1. **Theorem K** (Ch. 12) refutes the keystone: `ρ^β/Tr(ρ^β)` is not a strict
   contraction (fixes both `I/d` and every pure state). Replaced by damped projection.
2. The semantic objects are **constructed** (Ch. 13–15), not asserted; `κ_contr = 1−δ`
   is **proven**.
3. The six errors are **corrected** (Ch. 16–18): drift `δ/(1−κ)`, equivocation `2ε`,
   the non-functor → Kleisli repair, colimit ≠ limit, canonical (not unique) realizer.
4. The "everything" claim is **retired** (Ch. 19, Scope Theorem): a framework that
   models everything (incl. astrology) forbids nothing.

## Honest standing (Ch. 22)

Not a leading scientific theory; value is bimodal — a *verified* engineering floor
(DDR, ~5.4) and a *constructed, now-falsifiable* semantic agenda (~3.1), with a
correct-but-standard physical core (~2.9, keystone refuted & repaired) and a discarded
universalist overreach. Future standing turns on **O1**: running ConLawDist on real
labeled data.
