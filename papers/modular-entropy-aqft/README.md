# Implementing "Modular Entropy Geometry and Spectral Rigidity in Type III von Neumann Algebras, Part IV — AQFT Applications"

A numerical implementation of the paper's **computable core**, following its own
finite-volume / lattice-truncation prescription (Sec. 7.1), via the Gaussian
covariance (Casini–Huerta / Peschel) method for a free scalar field on the
Rindler-wedge testbed (Ch. 6).

`implement_modular_spectral.py` — numpy only. Run: `python3 implement_modular_spectral.py`

## What it computes, and the paper claim each item addresses

| Paper object | Code | Status reproduced |
|---|---|---|
| Modular Hamiltonian `K = 2π·boost` (BW, Ch. 1) for a wedge/interval | single-particle modular spectrum `{ε_l}` of the half-lattice region | **MEASURED** |
| State-weighted spectral mass `N_Ω(λ) = ⟨Ω, E_{K²}([0,λ]) Ω⟩` (Def. 3.2) | `spectral_mass_d`, assembled over transverse momenta with DOS `k_⊥^{d-1}` | **PROGRAMMATIC** + Prop-8 properties verified |
| Prop. 8 (`N_Ω(λ)>0`, nondecreasing, `≤1`) | asserted & checked in code | **VERIFIED (properties)** |
| Prop. 15 (`N_Ω(λ) ~ C λ^d`, α = d) | small-λ exponent fit, `α(d)` trend | **PROGRAMMATIC** (finite-size; trend only) |
| Thm. 9 (spectral exponent ⇒ entropy scaling, 3 regimes) | mass sweep: critical→log (α=1), gapped→area-law | **VERIFIED (regime transition)** |
| Remark 16 (α>2 ⇒ finite cubic invariant, d≥3) | exponent threshold readout | **PROGRAMMATIC** |

## The correctness anchor

Before any modular-spectral measurement, the covariance machinery is certified
against the **exact** free-boson result: the 1+1 interval entanglement entropy
`S(ℓ) = (c/3) log[(N/π) sin(πℓ/N)] + const` with central charge `c = 1`. The fit
returns `c_eff ≈ 0.99`. This is also the **α = d = 1 instance of Thm 9** (the log
regime), so the anchor and the theorem's regime structure are the same physics.

## Honest grading (mirrors the paper's labels)

- **ANCHOR / VERIFIED** — exact or robust: the c=1 law, and the Thm-9 regime
  transition (log ⇄ area-law) driven by the modular/correlation length. These are
  the implementation's solid results.
- **PROGRAMMATIC** — the absolute exponent `α = d` of Prop. 15 is an *indicative*
  finite-lattice estimate, not a clean verification. `α` increases with `d` (as the
  transverse-DOS `k_⊥^{d-1}` mechanism predicts), but extracting `α = d` precisely
  needs larger lattices and continuum control — exactly the delicacy the paper flags
  in Sec. 7.2 ("type III nature implies continuum trace limits fail; use vacuum
  expectations and controlled regulated sequences"). We do not overclaim it.

## Method notes

- 1D building block: massive free scalar on a ring, ground-state correlators
  `X=⟨φφ⟩=½K^{-1/2}`, `P=⟨ππ⟩=½K^{1/2}`; region = half-lattice (Rindler-like wedge).
- Symplectic eigenvalues `ν_l = √eig(X_A P_A)`; modular energies
  `ε_l = log((ν_l+½)/(ν_l-½))`; entropy `S = Σ[(ν+½)log(ν+½) − (ν−½)log(ν−½)]`.
- Higher `d` via transverse-momentum decomposition: each `k_⊥` gives an effective
  1D mass `m_eff = √(m²+k_⊥²)`, integrated against `k_⊥^{d-1}` (the Prop-15 mechanism).
- Type III caveat: there is no trace; everything is vacuum-state-weighted, as the
  paper requires.
