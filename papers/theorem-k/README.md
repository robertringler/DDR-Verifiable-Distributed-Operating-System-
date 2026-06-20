# Theorem K — the normalized power map is not a strict contraction

A standalone, submission-track note (math-ph / quant-ph) plus a reproducible
numerical verification. It resolves — negatively — the CIIR monograph's own open
problem OP#10 (the strict-contraction step of ch13 Thm 13.2), and is the fastest
credible publication carved out of the DDR+CIIR program (see `../../docs/audit/17`).

## Result (one line)

`N_β(ρ) = ρ^β/Tr(ρ^β)`, `β∈(0,1)`, on `d×d` density matrices (`d≥2`) is **not** a
strict contraction: it fixes both `I/d` and every pure state (≥2 fixed points), is
locally a `β`-contraction at `I/d`, and is unboundedly expansive near pure states.
Therefore Banach-style uniqueness — and the CIIR "fixed points are pure / inner
product emerges" chain that depends on it — fails.

## Contents

- `theorem-K-note.md` — the note: abstract, full proof, numerical corroboration,
  CIIR consequences, a valid replacement mechanism, and a Lean mechanization plan.
- `verify_theorem_k.py` — reproducible verification (numpy only).

## Reproduce

```bash
pip install numpy
python3 verify_theorem_k.py     # prints the §3 tables; exits 0 on full confirmation
```

Expected: all four checks pass — (1) two fixed points at machine zero, (2) local
ratio → β, (3) expansion ratio ~ ε^(β−1) → ∞, (4) full-rank starts → I/d while pure
starts stay pure. `THEOREM K NUMERICALLY CONFIRMED: True`.
