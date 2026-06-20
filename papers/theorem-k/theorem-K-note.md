# The normalized power map is not a strict contraction: a non-contraction theorem for observer-sharpening dynamics

**Draft note (math-ph / quant-ph).** Self-contained; analytic proof + reproducible
numerical corroboration (`verify_theorem_k.py`).

---

## Abstract

Several recent "constraint/observer" frameworks model an information-sharpening
step by the **normalized power map**
`N_β(ρ) = ρ^β / Tr(ρ^β)`, `β ∈ (0,1)`,
acting on the density matrices `D(H)` of a finite-dimensional Hilbert space, and
assert that this map is a *strict* contraction in trace norm — typically by appeal
to the Powers–Størmer inequality — so that Banach's theorem yields a unique fixed
point. We show this is false. For every `β ∈ (0,1)` and every `d = dim H ≥ 2`,
`N_β` fixes **both** the maximally mixed state `I/d` **and** every pure state, so it
has at least two distinct fixed points and therefore cannot be a strict contraction
in any norm. We further characterize the local behaviour: `N_β` is a strict
contraction with exact constant `β` in a neighbourhood of `I/d` (its Fréchet
derivative there is `β·id` on the trace-zero tangent space), while near every pure
state it is **expansive**, with local expansion ratio `∼ ε^{β-1} → ∞`. Thus `I/d`
is an attracting fixed point and the pure-state manifold is repelling; the
sharpening dynamics drive full-rank states *toward* the maximally mixed state, the
opposite of the intended "purification." A four-line argument suffices for the main
claim. We give the proof, a complete numerical verification, and discuss the
consequence for frameworks (e.g. the CIIR program) whose uniqueness and
"emergence-of-an-inner-product" results rest on this map.

---

## 1. Setting and the claim under examination

Let `H` be a complex Hilbert space with `dim H = d ≥ 2`, and let
`D(H) = {ρ : ρ = ρ^†, ρ ⪰ 0, Tr ρ = 1}` be the set of density operators, a compact
convex subset of the real vector space of Hermitian operators, complete in every
unitarily-invariant norm (in particular the **trace norm** `‖X‖₁ = Tr|X|`).

**Definition 1.1 (normalized power / observer-sharpening map).** For `β ∈ (0,1)`,
```
N_β : D(H) → D(H),     N_β(ρ) = ρ^β / Tr(ρ^β),
```
where `ρ^β` is the Hermitian functional-calculus power (`0^β := 0`). The map is the
"sharpening" or "observer" step in constraint-dynamics models: raising to a power
`β<1` is intended to redistribute spectral weight and, by iteration, to converge to
a distinguished pure state.

**The asserted property (the target of this note).** It is claimed in such models
that `N_β` is a **strict contraction** in trace norm — there exists `c<1` with
`‖N_β(ρ) − N_β(σ)‖₁ ≤ c‖ρ−σ‖₁` for all `ρ,σ` — usually justified "by the
Powers–Størmer inequality," and that Banach's fixed-point theorem then gives a
**unique** fixed point which is **pure**. (This is exactly Step 2 of Theorem 13.2
in the CIIR monograph; see §5.)

We prove the assertion is false, in a strong and quantitative form.

---

## 2. Theorem K and its proof

**Theorem K.** *For every `β ∈ (0,1)` and every `d ≥ 2`, the map `N_β` is not a
strict contraction in any unitarily-invariant norm on `D(H)`. Precisely:*

1. *(Two fixed points.) `N_β(I/d) = I/d`, and `N_β(P) = P` for every rank-one
   projector `P = |ψ⟩⟨ψ|`. Since `d ≥ 2`, `I/d` is not pure, so `N_β` has at least
   two distinct fixed points.*
2. *(Local contraction at `I/d`.) The Fréchet derivative of `N_β` at `I/d`,
   restricted to the trace-zero tangent space `T = {X = X^† : Tr X = 0}`, is
   `DN_β|_{I/d} = β·id_T`. Hence for unit `X ∈ T`,
   `‖N_β(I/d + εX) − I/d‖ = β·ε + o(ε)` — a strict `β`-contraction locally.*
3. *(Expansion near pure states.) For orthonormal `|ψ⟩,|φ⟩` and
   `ρ_ε = (1−ε)|ψ⟩⟨ψ| + ε|φ⟩⟨φ|`, `ε ∈ (0,½)`,*
   ```
   ‖N_β(ρ_ε) − |ψ⟩⟨ψ|‖₁ / ‖ρ_ε − |ψ⟩⟨ψ|‖₁  =  ε^{β-1} / ((1−ε)^β + ε^β)  →  ∞   (ε→0⁺).
   ```
   *So `N_β` is unboundedly expansive in every neighbourhood of every pure state.*

**Proof.**

*Part 1.* For a pure `P = |ψ⟩⟨ψ|` the spectrum is `{1, 0, …, 0}`; since `1^β = 1`
and `0^β = 0` for `β>0`, `P^β = P` and `Tr(P^β) = 1`, whence `N_β(P) = P`. For
`I/d`, `(I/d)^β = d^{-β} I` and `Tr((I/d)^β) = d·d^{-β} = d^{1-β}`, so
`N_β(I/d) = d^{-β}I / d^{1-β} = I/d`. With `d ≥ 2`, `I/d ≠ P`.

A strict contraction on a nonempty complete metric space has a **unique** fixed
point (Banach). `D(H)` is complete in any unitarily-invariant norm. Two distinct
fixed points therefore preclude strict contraction in *every* such norm. ∎(1)

*Part 2.* Write `f(x) = x^β`. The Fréchet derivative of the operator map `ρ ↦ ρ^β`
at a point with spectral decomposition `ρ = Σ λ_i Π_i` is given by the
Daleckiĭ–Kreĭn formula,
`D(ρ^β)[X] = Σ_{i,j} f^{[1]}(λ_i,λ_j)\, Π_i X Π_j`, where `f^{[1]}` is the
first divided difference (`f^{[1]}(λ,λ) = f'(λ)`). At `ρ = I/d` all eigenvalues
equal `1/d`, so every divided difference collapses to the derivative
`f'(1/d) = β (1/d)^{β-1} = β d^{1-β}`, and the unnormalized derivative is the scalar
`D(ρ^β)|_{I/d}[X] = β d^{1-β} X`. Differentiating the quotient
`N_β = ρ^β / Tr(ρ^β)` and evaluating on a trace-zero direction `X` (so the
denominator's first-order variation `Tr(D(ρ^β)[X]) = β d^{1-β} Tr X = 0` drops out):
```
DN_β|_{I/d}[X] = D(ρ^β)|_{I/d}[X] / Tr((I/d)^β) − (I/d)·(d/dt)Tr(...)|₀
              = (β d^{1-β} X) / d^{1-β} − 0 = β X.
```
Thus `DN_β|_{I/d} = β·id` on `T`, and the local Lipschitz ratio at `I/d` is `β`. ∎(2)

*Part 3.* The spectrum of `ρ_ε` is `{1−ε, ε}` (on `span{ψ,φ}`, with `0`'s
elsewhere), so `‖ρ_ε − |ψ⟩⟨ψ|‖₁ = |{-ε}| + |{ε}| = 2ε` (the perturbation
`ρ_ε − |ψ⟩⟨ψ|` has eigenvalues `±ε`). After the map, the spectrum is
`{(1−ε)^β/Z, ε^β/Z}` with `Z = (1−ε)^β + ε^β`, and
`‖N_β(ρ_ε) − |ψ⟩⟨ψ|‖₁ = 2·ε^β/Z`. The ratio is
`(ε^β/Z)/ε = ε^{β-1}/Z`. As `ε→0⁺`, `Z→1` and `ε^{β-1}→∞` because `β-1<0`. ∎(3)

**Remark 2.1 (why Powers–Størmer cannot rescue the claim).** The Powers–Størmer
inequality `½‖ρ−σ‖₁ ≤ ‖√ρ − √σ‖₂` (and its fidelity corollary) bounds trace
distance *above* by a square-root/fidelity quantity; it provides **no** Lipschitz
constant `< 1` for the nonlinear map `N_β`, and Part 3 exhibits explicit pairs on
which any putative constant exceeds 1. The invocation conflates an inequality
*between distance measures at fixed states* with a *Lipschitz bound on a map*.

**Remark 2.2 (the dynamics).** Parts 2–3 say `I/d` is attracting and the pure-state
manifold repelling. Indeed for two eigenvalues `p > q` in `(0,1)`, one step sends
the ratio `p/q ↦ (p/q)^β < p/q` (since `β<1`): spectra **flatten** toward uniform.
Hence iterating `N_β` drives every full-rank state to `I/d`, the *opposite* of the
intended purification. Pure states are fixed only because `0^β = 0` exactly; any
rank perturbation grows (Part 3).

---

## 3. Numerical corroboration

`verify_theorem_k.py` (reproducible, `numpy` only) confirms all parts for
`d ∈ {2,3,4}`, `β ∈ {0.60, 0.75, 0.90}`. Representative output:

**(1) Two fixed points** — residual `‖N_β(x)−x‖₁` is at machine zero (`≤ 1.7×10⁻¹⁶`)
at both `I/d` and a pure state, for all `d, β`.

**(2) Local contraction at `I/d`** — the measured ratio
`‖N_β(I/d+εX)−I/d‖ / ‖εX‖` equals `β` to four decimals as `ε→0`:

| β | ε=10⁻² | ε=10⁻⁴ | ε=10⁻⁶ | target |
|---|---|---|---|---|
| 0.60 | 0.6000 | 0.6000 | 0.6000 | 0.60 |
| 0.75 | 0.7500 | 0.7500 | 0.7500 | 0.75 |
| 0.90 | 0.9000 | 0.9000 | 0.9000 | 0.90 |

**(3) Expansion near a pure state** — the ratio grows like `ε^{β-1}` (for `β=0.75`,
exactly the powers of `10^{0.25}`: 3.16, 10, 31.6, 100):

| β | ε=10⁻² | ε=10⁻⁴ | ε=10⁻⁶ | ε=10⁻⁸ |
|---|---|---|---|---|
| 0.60 | 5.97 | 39.66 | 251.1 | 1584.9 |
| 0.75 | 3.09 | 9.99 | 31.62 | 100.0 |
| 0.90 | 1.57 | 2.51 | 3.98 | 6.31 |

**(4) Basins** — from 5 random full-rank starts, the 400-step iterate lands within
`10⁻¹⁶` of `I/d`; a pure-state start stays pure to `10⁻⁹`. Two basins, two fixed
points.

All checks pass: `THEOREM K NUMERICALLY CONFIRMED: True`.

---

## 4. Scope and sharpness

- **Sharp in `β`.** The local rate at `I/d` is *exactly* `β` (Part 2), so `N_β` is
  as contractive as possible *there* — the failure is global, caused entirely by the
  second fixed-point family, not by weak local behaviour.
- **Norm-independent.** Part 1 rules out strict contraction in *every*
  unitarily-invariant norm, since the obstruction (two fixed points) is metric-free.
- **Dimension-robust.** Holds for all `d ≥ 2` and (a fortiori) in infinite
  dimensions, where the pure-state manifold is larger.
- **What is *not* claimed.** `N_β` is a perfectly good *map*; it is even locally
  contractive at `I/d`. The result is solely that it is **not globally strictly
  contractive**, hence Banach-style **uniqueness fails**.

---

## 5. Consequence for the CIIR program

In the CIIR monograph, Theorem 13.2 ("Contractivity of the Loop", `α_loop < 1`)
derives strictness **entirely** from Step 2, the claim that `N_β`
(`β ∈ (½,1)`) is a strict trace-norm contraction by Powers–Størmer; the other steps
yield only the generic non-expansive bound `≤ 1` of CPTP maps. Theorem K shows Step 2
is false. The downstream chain therefore loses its support:

- **Thm 13.2 (unique loop fixed point):** uniqueness was to come from Banach via the
  strict bound — unavailable. In fact `Fix(N_β)` contains `I/d` *and* the entire
  pure-state manifold.
- **Thm 13.5 ("fixed points are pure"):** **false as stated** — `I/d` is a fixed
  point and is maximally mixed.
- **Thm 13.3 ("an inner product emerges at *the* fixed point"):** `[CONDITIONAL]` on
  a uniqueness that does not hold; the definite article has no referent.

**A correct route to the intended conclusion exists** (and should replace Step 2):
obtain strictness from a *damped projection* onto the decoherence-free / code
subalgebra,
`Φ(ρ) = P_𝒜((1−δ)ρ + δρ_0)`, `δ ∈ (0,1]`,
where `P_𝒜` is the trace-norm projection onto the (closed, convex) block-diagonal
states and `ρ_0` a fixed anchor. Since CPTP/contractive projections are
non-expansive (trace-distance monotonicity), `Φ` is a genuine `(1−δ)`-contraction
with a **unique** fixed point — recovering uniqueness by a valid mechanism, at the
cost of the specific `ρ^β` map that Theorem K rules out.

---

## 6. Mechanization

Theorem K is a finite-dimensional linear-algebra statement and is a clean target for
a proof assistant. In Lean 4 / Mathlib, Part 1 is the strongest single obligation and
the most economical: encode `N_β` via `Matrix.IsHermitian.eigenvalues` functional
calculus, prove `N_β (1/d • 1) = 1/d • 1` and `N_β P = P` for a projector `P`, then
invoke that `ContractingWith c f → Function.Injective (Function.fixedPoints f)`-style
uniqueness to derive `¬ ∃ c < 1, ContractingWith c N_β`. Parts 2–3 add the
Daleckiĭ–Kreĭn derivative and the explicit `2×2` ratio. The two-fixed-point core
needs no analysis beyond evaluation and is recommended as the first lemma to discharge.

---

## 7. Statements

- **Reproducibility.** `python3 verify_theorem_k.py` (numpy only) regenerates §3.
- **Status.** Part 1 and Part 3: `[PROVEN]` (elementary, complete above). Part 2:
  `[PROVEN]` modulo the standard Daleckiĭ–Kreĭn formula, cited. The CIIR consequences
  (§5) are `[DERIVED]` from Theorem K plus the monograph's own proof structure (audit
  trail `docs/audit/11`, `docs/audit/17`).
- **Relation to prior work.** The result resolves, negatively, the open problem
  recorded as OP#10 in the DDR+CIIR audit (`docs/audit/11-ciir-monograph-reaudit.md`).

## References (to fill for submission)

- Bhatia, *Matrix Analysis* — Daleckiĭ–Kreĭn derivative formula (Thm V.3.3).
- Powers, Størmer, *Free states of the canonical anticommutation relations*,
  Comm. Math. Phys. 16 (1970) — the inequality misapplied in the target claim.
- Banach, *Sur les opérations dans les ensembles abstraits...*, Fund. Math. 3 (1922).
- Ruskai, *Beyond strong subadditivity...* — trace-distance monotonicity under CPTP
  (for the §5 repair).
