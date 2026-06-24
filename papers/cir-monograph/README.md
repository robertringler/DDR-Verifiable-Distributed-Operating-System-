# Constrained-Interface Information Regulation — full monograph (LaTeX)

`monograph.tex` — the full 22-chapter formal monograph (report class, amsthm),
in five parts plus three appendices:

- **I Foundations** (Ch. 1–6): reality space, constraint geometry, interface map,
  operator-algebra structure, representation.
- **II Dynamics** (Ch. 7–12): GKLS master equation, data-processing
  (non-expansiveness) theorem, physical admissibility, spectral gap, Banach
  template, and the sharpening-map fixed-point structure theorem.
- **III Semantic stabilization** (Ch. 13–17): complete semantic metric, observer
  closure operator, strictly contractive recursive stabilizer (κ = 1−δ),
  stability/drift, equivocation.
- **IV Compositional structure & scope** (Ch. 18–19): Kleisli functoriality,
  canonical realization, the demarcation (scope) theorem.
- **V Verification & falsification** (Ch. 20–22): machine-checked agreement
  substrate, the pre-registered falsification protocol, standing & open problems.
- **Appendices**: notation, status ledger, summary of principal results.

Every nontrivial claim is status-tagged; standard results are labelled as such.

## Build
```bash
pdflatex monograph.tex
pdflatex monograph.tex   # second pass for TOC/refs
```
Compiles cleanly with TeX Live (report class; no exotic packages). 36 pages.
