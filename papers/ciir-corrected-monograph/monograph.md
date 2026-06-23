# CIIR — A Corrected Monograph (full edition)

### Constrained-Interface Information Regulation: foundations, dynamics, the semantic layer, and its honest scope

---

### Front matter — provenance, method, and how to read this book

**What this document is.** A complete, rigorous, corrected rebuild of the 22-chapter
CIIR monograph. It is *not* a transcription of the original. The original monograph's
source is in a repository outside this working environment's access scope; the
*contents* of each chapter are reconstructed faithfully from the adversarial audit that
read the original as primary source (`docs/audit/00–11`, which cites the original's own
labels — D3.x, Thm 11.2, Thm 13.x, ch22 — verified against source by that audit), and
the *mathematics* is the verified work of this programme: the formal implementation
(`docs/audit/17`), the keystone refutation with machine-confirmed numerics
(`papers/theorem-k/`), the falsification harness (`papers/conlawdist/`), and the
machine-checked DDR substrate (`docs/audit/12–16`). Where a chapter's reconstruction is
load-bearing, the dependence on the audit (rather than the verbatim original) is stated
in the chapter. This is a *corrected edition built on verified mathematics*, and it is
honest about which sentences are which.

**The relationship to the original, in one paragraph.** The original monograph is, on
the audit's reading, a competent open-quantum-systems and operator-algebra construction
carrying *zero novel proven theorems* and one *false* keystone, wrapped in a
cross-domain "theory of everything" narrative that reaches as far as a formalization of
astrology. This edition does four things the original did not: it **refutes** the false
keystone with a clean no-go theorem and **replaces** it with a mechanism that actually
works (Part II); it **constructs** the semantic objects the original only asserted
(Part III); it **corrects** the six proof errors the audit found by reading the proofs
(Part IV); and it **retires** the universalist overreach with a demarcation theorem that
explains precisely why "modeling everything" is a defect, not an achievement (Ch. 19).
What it keeps is the genuinely correct core — and labels it, honestly, as standard.

**Status tags (used on every nontrivial claim).**
`[PROVEN]` — a complete, gap-free proof is given or cited to a complete proof in this
programme. `[DERIVED]` — a full proof from axioms stated here. `[CONSTRUCTED]` — an
object is exhibited and its defining properties verified. `[CONDITIONAL]` — valid under
a named hypothesis. `[STANDARD]` — a correct application of a classical theorem, claimed
with *no* novelty. `[SKETCH]` — a proof strategy with a named gap and an attack plan.
`[OPEN]` — an unresolved obligation, stated precisely, with what would close it. An
unlabeled assertion is a defect; Appendix B audits that there are none.

**Notation discipline — the symbol collisions, resolved once and for all.** The original
used single Greek letters for distinct objects, and the apparent "grounding" of the
governance layer in the physics layer was, the audit found, largely this homonymy. We
fix:
- `κ_curv : M → ℝ≥0` — the *constraint-curvature* scalar field on the constraint
  manifold (Ch. 3); dimension `[length]⁻²`.
- `κ_contr ∈ [0,1)` — a dimensionless *Lipschitz contraction* constant (Ch. 15).
- These two are dimensionally incompatible (Appendix A) and are **never** identified.
- `Φ_iface` — the CP/TP interface map (a quantum channel, Ch. 4).
- `Φ_rec` — the recursive stabilizer (a metric-space contraction, Ch. 15).
- `Π_C` — the observer closure operator / fixed-point projector (Ch. 14).
- `d_ℛ` — the (primitive, posited) reality-space metric (Ch. 2).
- `d_sem` — the (constructed) semantic metric (Ch. 13).

**How to read it.** Part I builds the physical/operator foundations (correct, standard).
Part II develops the dynamics and contains the book's central correction, Theorem K.
Part III constructs the semantic-governance layer — the part the integration actually
needs, and the part the original never built. Part IV repairs the categorical apparatus
and demarcates the scope. Part V grounds the whole thing in machine-checked verification
and a real falsification programme. The reader who wants the single most important new
result should read **Chapter 12**.

---

# Part I — Foundations

## Chapter 1 — The CIIR programme and its honest scope

### 1.1 The thesis

CIIR (Constrained-Interface Information Regulation) is built on one intuition: *what a
system is, operationally, is what is accessible through its constraints.* A cognitive or
governance system does not present its full internal state to the world; it presents the
image of that state under a formally specified observation interface. CIIR formalizes
three claims about such systems.

1. **(Constrained observation.)** Observation is a completely-positive, trace-preserving
   map — a quantum channel `Φ_iface` — parameterized by a constraint algebra. The
   "effective state" is the state modulo what the interface can resolve.
2. **(Observer fixed points.)** The legitimate states are the fixed points of the
   round-trip *observe-then-reconstruct*. A state is "really there" iff observing it and
   reconstructing it returns it unchanged. This is the observer fixed-point condition
   `Π_C(s) = s`.
3. **(Regulated drift.)** Departure from the legitimate set is corrected by a dynamics
   that contracts toward it. Over time, a regulated system converges to an invariant
   set of intent-preserving states.

Claims (1)–(2) are *physical/structural* and live on Hilbert space; claim (3) is the
*governance* content and lives on a metric space of meanings. The original monograph
ran both on shared notation and treated them as one theory. They are not, and this
edition keeps them apart.

### 1.2 Scope, stated before any theorem (and proved in Ch. 19)

It is intellectually fatal to leave the scope of a "theory of everything" implicit, so
we fix it at the outset.

> **CIIR is a compositional *modeling* framework, not a fundamental theory of physics.**
> Formally (Ch. 19) it is a lax monoidal functor `U : ConstrDom → CPTP` from constrained
> domains to quantum channels. It has no action principle; it does not derive the
> Standard Model or general relativity; it predicts no new particle, force, or
> cosmological observable. Its universality is *modeling* universality.

And — this is the part the original got exactly backwards — modeling universality is not
a virtue to be maximized:

> **(Scope Theorem, Ch. 19.)** A modeling framework that admits a model of *every*
> domain forbids *no* observation, and therefore has no falsifiable content. Breadth
> without restriction is a defect. The scientifically meaningful CIIR is `U` *restricted*
> to domains with a genuine data-generating process.

Everything below respects this scope. The cross-domain chapters of the original — which
reached as far as astrology — are not extended here; they are demarcated out (Ch. 19),
and the reason is a theorem, not taste.

### 1.3 The two layers, and why homonymy is not grounding

The audit's sharpest structural finding is that the governance layer's apparent
foundation in the physics layer is mostly *shared letters*: `Φ, κ, M, Π` denote
operator-algebraic objects in the physics core and entirely different governance objects
in the integration. A semantic metric is not a curvature; a contraction constant is not a
curvature field; a governance predicate is not a constraint operator `Ĉ_i`. This edition
treats the physics layer (Part II) and the semantic layer (Part III) as *analogically
related but formally independent*, and says, at each bridge, whether the relation is
identity (rare), construction (Part III), or analogy (flagged as such). `[E]`

---

## Chapter 2 — The reality space

### 2.1 The primitive

The physical layer begins with a space of "realities" — full internal configurations,
before any constraint is applied.

> **Definition 2.1 (reality space).** A *reality space* is a triple `(ℛ, d_ℛ, τ)` where
> `(ℛ, d_ℛ)` is a complete separable metric space (a *Polish* space) and `τ` is its
> Borel σ-algebra. `[STANDARD]` (Original D3.1.)

The Polish assumption is the right level of generality: it is strong enough to carry a
well-behaved probability theory and weak enough to include essentially every state space
of practical interest (separable Banach spaces, manifolds, countable products).

> **Proposition 2.2.** Every Polish space is standard Borel; reality spaces admit regular
> conditional probabilities and support the disintegration theorem. `[STANDARD —
> Kuratowski, Kechris, *Classical Descriptive Set Theory*]`

### 2.2 What is posited, and what is not

`d_ℛ` is a *primitive*. Its metric axioms — identity, symmetry, triangle — are *assumed*,
which is entirely legitimate for a foundational distance on physical configurations: the
ambient configuration space of a physical system genuinely is a metric space.

The crucial honesty, which the original elided: **`d_ℛ` is not a semantic metric.** The
governance thesis needs a distance on *meanings/intents*, and that distance is *not*
inherited from `d_ℛ` — it is constructed separately, and the hard question of whether a
faithful semantic distance can even satisfy the triangle inequality is confronted in
Chapter 13, not assumed away here. Conflating `d_ℛ` (posited, physical) with `d_sem`
(constructed, semantic) is the first homonymy this edition refuses. `[E]`

---

## Chapter 3 — Constraint geometry

### 3.1 The constraint manifold

Constraints are not all-or-nothing; they have local stiffness, and the geometry of that
stiffness is the subject of this chapter.

> **Definition 3.1 (constraint manifold).** A *constraint manifold* is a smooth
> Riemannian manifold `(M, g)` equipped with a smooth, nonnegative scalar field
> `κ_curv : M → ℝ≥0`, the *constraint curvature*, measuring local constraint stiffness;
> together with the Levi-Civita connection `∇` of `g`. `[STANDARD — assumed structure]`
> (Original D3.4, D3.7–3.8.)

The curvature field is a genuine geometric object: regions of high `κ_curv` are regions
where the constraints bend the admissible configurations sharply.

### 3.2 The symbol-collision warning (load-bearing)

> **Warning 3.2.** `κ_curv` has physical dimension `[length]⁻²` (a curvature). The
> contraction constant `κ_contr` of Chapter 15 is dimensionless and lies in `[0,1)`. By
> dimensional analysis alone they cannot be the same object (Appendix A). The original
> monograph's notation invited exactly this conflation, and the integration's claim to
> "inherit a contraction from the constraint geometry" trades on it. We forbid the
> identification. `[PROVEN — dimensional analysis]`

### 3.3 What constraint geometry gives — and what it defers

The constraint manifold grounds "constraint geometry" *as geometry*. It does **not**, by
itself, produce the observer projector `Π_C` of Chapter 14. The original aspired to
*derive* `Π_C` from `(M, g, κ_curv)` and, by its own admission (its ch22), did not — it
computed a fixed point *numerically* and assumed the projector. This edition inherits
that gap honestly: `Π_C` is *well-posed* in Chapter 14 (a real advance), but its
derivation from constraint geometry remains `[OPEN]`, with the attack plan stated there.

---

## Chapter 4 — Constraint operators and the interface map

### 4.1 Constraint operators

> **Definition 4.1.** A *constraint system* on a finite-dimensional Hilbert space `H` is
> a finite family `{Ĉ_i}` of self-adjoint operators, the *constraint operators*, encoding
> the admissible observations. The *constraint algebra* `A` is the unital `*`-algebra they
> generate. `[STANDARD]`

The `Ĉ_i` are the genuinely CIIR-specific objects of the physics layer: they say *what
can be asked* of the system.

### 4.2 The interface map

Constrained observation is the action of looking at `ℛ` through `A`. Formally:

> **Definition 4.2 (interface map).** The *interface map* is a completely-positive,
> trace-preserving linear map `Φ_iface : B(ℛ_op) → B(H)`, with Stinespring dilation
> `Φ_iface(X) = V^†(X ⊗ I_E)V` for an isometry `V : H → ℛ_op ⊗ H_E` into an environment
> `H_E`; equivalently a Kraus form `Φ_iface(X) = Σ_a K_a^† X K_a`, `Σ_a K_a^†K_a = I`.
> `[STANDARD — Stinespring, Kraus]` (Original D3.15–3.16.)

> **Theorem 4.3.** `Φ_iface` is a quantum channel: it is positive, completely positive,
> and trace-preserving, and it is the most general physical map consistent with the
> constraints. `[STANDARD]`

### 4.3 Honest status of the interface map in the integration

This is real and correct. It is also, the audit notes, *orphaned* by the governance
integration, which used boolean governance predicates (`SemanticInvariant` checks)
rather than the operators `Ĉ_i`. The shared word "constraint" is the only link. This
edition does not pretend the governance constraints *are* the `Ĉ_i`; Chapter 19 states
precisely that the relation is analogical, and Chapter 13 builds the governance-side
constraint structure (`I_intent`) on its own terms.

---

## Chapter 5 — Operator-algebra structure

### 5.1 Block decomposition

Finite-dimensional constraint algebras have a completely understood structure, and CIIR
uses it.

> **Theorem 5.1 (block decomposition).** A finite-dimensional `*`-algebra `A ⊆ B(H)` is
> `*`-isomorphic to a finite direct sum of full matrix algebras,
> `A ≅ ⊕_{j=1}^{r} M_{k_j}(ℂ)`, and `H` decomposes compatibly as
> `H ≅ ⊕_j (ℂ^{k_j} ⊗ ℂ^{m_j})`. `[STANDARD — Artin–Wedderburn / finite-dim C\*-algebra
> structure]` (Original ch05.)

### 5.2 Superselection sectors

> **Corollary 5.2.** The centre `Z(A)` is spanned by the sector projections `{P_α}`, and
> the dynamics (Part II) preserves the sector decomposition. The `P_α` are the
> physics-layer "invariant content." `[STANDARD]`

The sectors are the operator-algebraic ancestor of the governance "invariant set"
`I_intent` (Ch. 14) — *by analogy*: a steady, observation-stable substructure. The
analogy is suggestive and is the honest reason the governance layer borrows the
fixed-point/invariant-set vocabulary; it is not an identity, and Chapter 14 builds
`I_intent` from governance primitives.

---

## Chapter 6 — Representation

> **Definition 6.1 (representation functor).** Let `CogSys` be the category of constrained
> cognitive systems (objects: systems with constraint algebras; morphisms:
> constraint-preserving maps). The *representation functor* `F : CogSys → Hilb_CIIR` sends
> a system to its Hilbert representation and a system morphism to the induced channel.
> `[SKETCH — standard]` (Original ch06.)

> **Proposition 6.2.** `F` is well-defined and functorial on *finite* systems: identity
> and composition are preserved because constraint-preserving maps induce CP/TP maps
> (Stinespring functoriality). `[STANDARD for finite systems]`

The general (infinite, or non-CP-preserving morphism) case is `[OPEN]`; the attack plan
is the naturality of the Stinespring dilation under the relevant morphism class. The
original presented `F` at a `[SKETCH]` level; this edition keeps that honest grade.

---

# Part II — Dynamics

## Chapter 7 — The CIIR master equation

### 7.1 What CIIR's dynamics actually are

The audit's most clarifying physics finding: stripped of narrative, CIIR's dynamics are
those of an *open quantum system in the weak-coupling (Davies) limit* — a standard, and
standardly correct, object. We state it as such.

> **Definition 7.1 (GKLS generator).** The CIIR dynamical semigroup is `Φ_t = e^{tL}`
> with generator of Gorini–Kossakowski–Sudarshan–Lindblad form
> `L(ρ) = −i[H, ρ] + Σ_k γ_k ( A_k ρ A_k^† − ½{A_k^†A_k, ρ} )`, `γ_k ≥ 0`,
> for a Hamiltonian `H = H^†` and jump operators `{A_k}`. `[STANDARD]` (Original ch07/ch12.)

> **Theorem 7.2 (generation).** A generator of GKLS form generates a strongly-continuous
> one-parameter semigroup `{Φ_t}_{t≥0}` of completely-positive, trace-preserving maps;
> conversely (in finite dimension) every such semigroup has a GKLS generator. `[STANDARD —
> Lindblad; Gorini–Kossakowski–Sudarshan; Hille–Yosida]`

### 7.2 Why this matters for the novelty ledger

CIIR's dynamics being *standard* is not a criticism of their correctness — they are
correct — but it caps their novelty at zero (Appendix C). The genuine novelty of the
programme is not in the master equation; it is in the corrections and constructions of
Parts II–IV.

---

## Chapter 8 — The contraction semigroup

The single most important *correct* inequality in the physics layer is that channels do
not increase distinguishability. We state and prove it, because the original's keystone
mistake was to claim more than this.

> **Theorem 8.1 (CPTP maps are trace-norm non-expansive).** For any CP/TP map `Φ` and any
> states `ρ, σ`, `‖Φ(ρ) − Φ(σ)‖₁ ≤ ‖ρ − σ‖₁`. Hence the CIIR semigroup `{Φ_t}` is a
> family of trace-norm contractions (non-strict, constant `≤ 1`). `[PROVEN]`

*Proof.* Write the Hermitian traceless `ρ − σ` in its Jordan decomposition
`ρ − σ = Δ₊ − Δ₋` with `Δ₊, Δ₋ ≥ 0` of orthogonal support, so
`‖ρ − σ‖₁ = Tr Δ₊ + Tr Δ₋`. Use the variational form
`‖X‖₁ = sup_{−I ⪯ M ⪯ I} Tr(MX)`. For any admissible `M` (`−I ⪯ M ⪯ I`),
`Tr(M(Φ(Δ₊) − Φ(Δ₋))) ≤ Tr Φ(Δ₊) + Tr Φ(Δ₋) = Tr Δ₊ + Tr Δ₋ = ‖ρ − σ‖₁`,
using positivity of `Φ(Δ_±)` (so `Tr(MΦ(Δ_±)) ≤ Tr Φ(Δ_±)`) and trace preservation
(`Tr Φ(Δ_±) = Tr Δ_±`). Taking the sup over `M` gives
`‖Φ(ρ) − Φ(σ)‖₁ ≤ ‖ρ − σ‖₁`. ∎

> **Remark 8.2.** This is *exactly* the bound the original's Steps 1, 3, 4 deliver. The
> original claimed *strict* contraction; that claim rested entirely on a fifth step,
> refuted in Chapter 12. Strictness, when it genuinely holds, comes from a spectral gap
> (Ch. 10) or from a damped projection (Ch. 12, 15) — never from the bare semigroup.

---

## Chapter 9 — Physical admissibility and the red-team

### 9.1 The original's self-indictment

To its credit, the original monograph's own red-team (its ch09) rated its *novel*
dynamical proposals **"fatal if interpreted as physical dynamics."** This edition treats
that verdict as data and resolves it rather than burying it.

### 9.2 Diagnosis

The flagged constructions used a generator built from a matrix logarithm and a gradient
flow on density operators. Such a generator is generically **not** of GKLS form; its
Kossakowski matrix has negative eigenvalues; the resulting map is not completely
positive; and a non-CP "channel" violates no-signaling and can map states to
non-states. As physics, it is inadmissible. `[E]`

### 9.3 The admissibility theorem and the repair

> **Theorem 9.1 (GKLS admissibility / quarantine).** A generator `L` produces
> completely-positive dynamics `e^{tL}` for all `t ≥ 0` **iff** `L` has GKLS form,
> equivalently iff its Kossakowski matrix is positive semidefinite. `[STANDARD]`

> **Construction 9.2 (the repair).** Given a proposed non-GKLS generator `L₀`, project
> its Kossakowski matrix `K₀` onto the positive-semidefinite cone (clip negative
> eigenvalues to 0) to obtain `K ⪰ 0`, and reassemble the nearest GKLS generator `L`. The
> resulting `e^{tL}` is a legitimate CIIR semigroup. `[CONSTRUCTED]`

> **Consequence 9.3.** CIIR is retained as a *standard* open quantum system (Davies
> limit); its claim to *novel* dynamics is withdrawn. Everything kept is physical. This is
> a downgrade in novelty and an upgrade in correctness — the correct trade. `[E]`

---

## Chapter 10 — Spectral gap and convergence

When a Lindbladian has a gap, it contracts strictly toward a unique steady state — the
*legitimate* origin of a physical contraction constant.

> **Theorem 10.1 (gapped convergence).** Suppose `L` has a unique steady state `ρ_ss`
> (`L(ρ_ss)=0`) and a spectral gap `Δ := −sup{ Re λ : λ ∈ spec(L), λ ≠ 0 } > 0`. Then
> for all states `ρ`, `‖Φ_t(ρ) − ρ_ss‖₁ ≤ C e^{−Δ t} ‖ρ − ρ_ss‖₁` for some `C ≥ 1`
> (`C = 1` when `L` is normal). `[DERIVED — under the gap and uniqueness hypotheses]`

*Proof sketch.* Decompose `ρ − ρ_ss` in the eigenbasis (or Jordan basis) of `L`
restricted to the traceless subspace; each mode decays as `e^{Re(λ)t}`; the slowest is
`e^{−Δt}`; trace-norm equivalence of norms on the finite-dimensional traceless space
supplies `C`. ∎

> **Remark 10.2 (the measured gap).** The original reported a numerical spectral gap
> `Δ ≈ 0.013` (its ch22). With Theorem 10.1 this is a genuine, falsifiable physical
> prediction *of the model*: convergence is single-exponential at rate `Δ`. The per-step
> contraction constant is `κ_contr = e^{−Δτ}`. The *analytic* determination of `Δ` from
> `(M, g, κ_curv)` is `[OPEN]`; the numerical value is exhibitable.

---

## Chapter 11 — Fixed points of contractive cellular updates (the honest Banach)

The original contains exactly one *honest* contraction result, and it is correct. We
keep it.

> **Theorem 11.1 (CRS fixed point).** Let a constraint-reality-system state live in
> `ℝ^{|V|×d}` (complete). Suppose the local update `T` is `c`-Lipschitz with `c < 1`
> (an exponential decay rule with rate `δ ∈ (0,1)` provides this). Then `T` has a unique
> fixed point `x*`, reached from any start at geometric rate: `‖T^k x − x*‖ ≤ c^k ‖x −
> x*‖`. `[PROVEN — Banach 1922]` (Original ch11 Thm 11.2.)

*Proof.* The Banach contraction principle: `(T^k x)` is Cauchy because
`‖T^{k+1}x − T^k x‖ ≤ c^k ‖Tx − x‖` and `Σ c^k < ∞`; completeness gives a limit `x*`;
continuity gives `Tx* = x*`; and if `Tx*=x*, Ty*=y*` then `‖x*−y*‖ = ‖Tx*−Ty*‖ ≤
c‖x*−y*‖` forces `x*=y*`. ∎

> **Remark 11.2.** Novelty zero, correctness total. This theorem is the *template* the
> governance layer instantiates in Chapter 15 — there, with a *constructed* contraction
> rather than an assumed one.

---

## Chapter 12 — The observer-sharpening map: a no-go (Theorem K)

This is the pivotal chapter. The original's central uniqueness result derived *strict*
contraction of its stabilization loop from a single lemma: that the normalized power map
is a strict trace-norm contraction "by the Powers–Størmer inequality." That lemma is
false, and its failure removes the support from the original's emergence narrative.

### 12.1 The map and the disputed claim

> **Definition 12.1.** For `β ∈ (0,1)`, the *observer/sharpening map* is
> `N_β(ρ) = ρ^β / Tr(ρ^β)` on density operators `D(H)`, `d = dim H ≥ 2`
> (`ρ^β` by Hermitian functional calculus, `0^β := 0`).

The original (its ch13 Thm 13.2, Step 2) asserted: `N_β` with `β ∈ (½,1)` is a strict
trace-norm contraction; Steps 1, 3, 4 give only `≤ 1`; so the loop's strictness — and
hence Banach uniqueness, and hence "the fixed point is a *unique pure* state at which an
inner product emerges" — rests on this single step.

### 12.2 The theorem

> **Theorem K (no-go).** For every `β ∈ (0,1)` and every `d ≥ 2`, `N_β` is **not** a
> strict contraction in any unitarily-invariant norm on `D(H)`. Specifically:
> 1. *(Two fixed points.)* `N_β(I/d) = I/d`, and `N_β(P) = P` for every rank-one
>    projector `P`. As `d ≥ 2`, these are distinct.
> 2. *(Local contraction at `I/d`.)* The Fréchet derivative of `N_β` at `I/d`, restricted
>    to the trace-zero tangent space, equals `β·id`.
> 3. *(Expansion near pure states.)* For `ρ_ε = (1−ε)|ψ⟩⟨ψ| + ε|φ⟩⟨φ|` (`⟨ψ|φ⟩=0`),
>    `‖N_β(ρ_ε) − |ψ⟩⟨ψ|‖₁ / ‖ρ_ε − |ψ⟩⟨ψ|‖₁ = ε^{β−1}/((1−ε)^β + ε^β) → ∞` as `ε→0⁺`.
> `[PROVEN]`

*Proof.*

*(1).* For a projector `P` (eigenvalues `1,0,…,0`): `1^β=1`, `0^β=0`, so `P^β=P`,
`Tr P^β = 1`, `N_β(P)=P`. For `I/d`: `(I/d)^β = d^{−β}I`, `Tr = d^{1−β}`, so
`N_β(I/d) = d^{−β}I/d^{1−β} = I/d`. A strict contraction on a complete metric space has a
*unique* fixed point (Banach); `D(H)` is complete in every unitarily-invariant norm; two
distinct fixed points therefore preclude strict contraction in all of them. ∎(1)

*(2).* By the Daleckiĭ–Kreĭn formula, the Fréchet derivative of `ρ ↦ ρ^β` at a multiple
of the identity `cI` is the scalar `f'(c) = βc^{β−1}` (all eigenvalue gaps vanish, so the
divided differences collapse to the derivative). At `c=1/d` the unnormalized derivative
is `β d^{1−β}·X`; differentiating the normalization and using `Tr X = 0` on the tangent
space cancels the denominator's variation, leaving `DN_β|_{I/d}[X] = β X`. ∎(2)

*(3).* `ρ_ε` has spectrum `{1−ε, ε}`, so `‖ρ_ε − |ψ⟩⟨ψ|‖₁ = 2ε`. Then `N_β(ρ_ε)` has
spectrum `{(1−ε)^β/Z, ε^β/Z}`, `Z=(1−ε)^β+ε^β`, giving `‖N_β(ρ_ε)−|ψ⟩⟨ψ|‖₁ = 2ε^β/Z`.
The ratio is `ε^{β−1}/Z → ∞` since `β−1<0`, `Z→1`. ∎(3)

> **Remark 12.2 (why Powers–Størmer cannot help).** Powers–Størmer bounds trace distance
> by a fidelity quantity *between fixed states*; it yields no Lipschitz constant for the
> nonlinear map `N_β`, and part (3) exhibits pairs forcing any constant above 1. The
> original conflated an inequality between distance measures with a Lipschitz bound on a
> map. `[E]`

> **Numerical confirmation.** `papers/theorem-k/verify_theorem_k.py` confirms all three
> parts for `d ∈ {2,3,4}`, `β ∈ {0.6,0.75,0.9}`: the local ratio equals `β` to four
> decimals; the expansion ratio equals `ε^{β−1}` on the nose (for `β=0.75`: 3.16, 10,
> 31.6, 100 across `ε = 10^{−2..−8}`); and iteration drives full-rank states to `I/d`
> while pure states stay fixed (two basins). `[PROVEN — machine-confirmed]`

### 12.3 What collapses, and the repair

> **Corollary 12.3.** The original's ch13 Thm 13.2 (strict loop contraction) fails; Thm
> 13.5 ("fixed points are pure") is *false* (`I/d` is a mixed fixed point); Thm 13.3 ("an
> inner product emerges at *the* fixed point") loses its unique referent. `[DERIVED]`

> **Construction 12.4 (the working replacement).** Replace `N_β` by a *damped projection*
> onto the decoherence-free / code subalgebra `𝒜`:
> `Φ_loop(ρ) = P_𝒜( (1−δ)ρ + δ ρ_0 )`, `δ ∈ (0,1]`,
> with `P_𝒜` the trace-norm projection onto the closed convex set of `𝒜`-block-diagonal
> states and `ρ_0` a fixed anchor. Since contractive/CPTP projections are non-expansive
> (Ch. 8), `‖Φ_loop(ρ) − Φ_loop(σ)‖₁ ≤ (1−δ)‖ρ − σ‖₁`: a genuine `(1−δ)`-contraction with
> a *unique* fixed point by Banach. `[CONSTRUCTED]` This recovers the original's intended
> conclusion — a unique stabilized state — by a valid mechanism. The same device drives
> the entire semantic layer (Ch. 15).

---

# Part III — The semantic layer

> The governance objects the integration needs — `d_sem`, `I_intent`, `Φ_rec`, `Π_C` —
> were *asserted* in the original (its Open Problems #1, #2, #7). Here they are *built*.
> The development follows `docs/audit/17` §2 and is self-contained.

## Chapter 13 — The semantic metric `d_sem`

### 13.1 The obstruction, taken seriously

The hardest objection to a semantic distance is the triangle inequality: meaning-distance
can violate it (A close to B, B close to C, A far from C via an accumulated exception
chain). If triangle fails, the space is not metric, Banach does not apply, and the entire
stability story loses its *form*. The original simply assumed M1–M3. We instead construct
`d_sem` so that triangle holds *by construction*, and relocate the empirical risk to
faithfulness.

### 13.2 The construction

> **Construction 13.1.** On a finite semantic carrier `S` (e.g. the legal applications of
> one statutory Title), build two layers and fuse them.
> - *Symbolic layer.* A connected weighted knowledge graph `G=(S,E,w)`, `w>0`, of
>   certified semantic relations (cross-reference, amendment, exception). Define
>   `d_graph(x,y) =` the shortest-path distance in `G`.
> - *Geometric layer.* A Lipschitz encoder `E:S→ℝ^n` with certificate `L`
>   (`‖E(x)−E(y)‖ ≤ L·δ_text(x,y)`, via LipSDP/interval bounds). Define
>   `d_embed(x,y) = ‖E(x)−E(y)‖₂`.
> - *Fusion.* `d_sem(x,y) = α·d_graph(x,y) + (1−α)·d_embed(x,y)`, `α ∈ (0,1]`.

### 13.3 Metric structure

> **Proposition 13.2.** `d_sem` is a pseudometric; a genuine metric for `α>0`; and on the
> quotient `S/∼` (by `x∼y ⇔ d_sem(x,y)=0`) it is a *complete* metric space. `[PROVEN]`

*Proof.* `d_graph` is a shortest-path metric (triangle is the min-over-paths property).
`d_embed` is the pullback of the Euclidean norm under `E`, hence symmetric, nonnegative,
and triangle-satisfying (`‖E(x)−E(z)‖ ≤ ‖E(x)−E(y)‖+‖E(y)−E(z)‖`). A nonnegative
combination of pseudometrics is a pseudometric (each axiom, being an equality or an
inequality, is preserved under nonnegative linear combination). For `α>0`,
`d_sem(x,y)=0 ⇒ d_graph(x,y)=0 ⇒ x=y`, so it is a metric; on `S/∼` it is always a metric;
`S` finite ⇒ `S/∼` finite ⇒ complete. ∎

> **Corollary 13.3 (the triangle worry dissolved structurally).** The triangle-violation
> rate of `d_sem` is *exactly 0*. `[PROVEN]` Confirmed as a unit test for every `α` in
> `papers/conlawdist/` (rate `= 0`, max signed violation `= 0`).

### 13.4 What remains genuinely open

The structural question is settled; the *scientific* question is not. *Faithfulness* —
that small `d_sem` tracks human judgment of closeness, and large `d_sem` tracks intent
drift — is empirical. `[OPEN — faithfulness, Ch. 21]` The honest reframing: by
*constructing* a metric rather than *learning* a similarity, the question "does triangle
hold?" (settled: yes) becomes "does this metric correlate with intent?" (open, testable).

---

## Chapter 14 — The intent set and the observer fixed point `Π_C`

### 14.1 Well-posing before proving

The original's `Π_C` was, by its own admission (ch22), *assumed not derived* — it
computed a numerical fixed point and posited the projector. One cannot prove a
fixed-point theorem about an undefined operator. Step zero is *well-posing*, achieved
here by recognizing `Π_C` as a closure operator.

> **Theorem 14.1 (well-posed observer fixed point).** Let `(L,≤)` be a complete lattice of
> semantic states (ordered by information refinement), and let `O_C, R : L → L` be
> observation and reconstruction maps with `Π_C := R∘O_C`. If `Π_C` is *monotone*
> (`x≤y ⇒ Π_C x ≤ Π_C y`), *extensive* (`x ≤ Π_C x`), and *idempotent* (`Π_C∘Π_C=Π_C`),
> then `Π_C` is a **closure operator**, its fixed-point set
> `I_intent := Fix(Π_C) = {x : Π_C x = x}` is **nonempty** and is a **complete lattice**
> under `≤`, and `Γ_rep := Π_C` is the unique idempotent monotone reflector onto
> `I_intent`. `[PROVEN — closure-operator theory; Tarski]`

*Proof.* Fixed-point sets of closure operators are closed under arbitrary meets (a meet of
closed elements is closed by monotonicity + extensiveness), hence form a complete lattice
by the Knaster–Tarski structure; the top element is closed, so `I_intent ≠ ∅`; idempotency
makes `Γ_rep` a retraction onto `I_intent`, and monotone idempotent retractions onto a
fixed set are unique. ∎

This makes three identifications the original never made and the audit demanded:
`I_intent = Fix(Π_C)`, `Γ_rep = Π_C` (repair *is* closure — no longer ad hoc), and
"observer fixed point" = "constraint closure." Equivalently, via the adjunction
`O_C ⊣ R`, `Π_C` is the induced idempotent monad and `I_intent` its algebras.

### 14.2 A concrete `(O_C, R)`

> **Construction 14.2 (toy `C`).** Let `S = {0,1}^k` (k boolean features), `C` a set of
> Horn clauses. Let `O_C(x)` be the set of clauses `x` satisfies, and `R(o)` the
> `≤`-least assignment forward-chained to satisfy `o`. Then `Π_C` is the constraint
> closure: monotone, extensive, idempotent; `Fix(Π_C)` is the set of constraint-closed
> assignments. Verified by exhaustive check for `k ≤ 4`. `[CONSTRUCTED]`

### 14.3 The deep gap, named

Deriving *this* `Π_C` from the constraint geometry `(M,g,κ_curv)` of Chapter 3 — the
original's actual aspiration — is `[OPEN]`. Attack plan (`docs/audit/04`, L1–L5): build
`(O_C,R)` from the Lindbladian measurement channel and decoherence-free subalgebra; prove
the subcategory `I_intent` reflective (⇒ idempotency); prove `R` firmly non-expansive
(⇒ inherited `κ<1`, the bridge to Ch. 15). Calibrated success: ~30% in 12 months. The
*well-posing* above is the high-value part now delivered.

---

## Chapter 15 — Recursive stabilization `Φ_rec` and `κ_contr < 1`

The original asserted the existence of a contraction `κ_contr < 1` (Open Problem #2). Here
it is a theorem for a concrete, well-motivated operator.

### 15.1 The anchored stabilizer

> **Definition 15.1.** In the Hilbert realization of `S/∼` (via the geometric component of
> Ch. 13), with `I_intent ⊆ H_S` nonempty closed convex and anchor `c ∈ H_S` (the
> constitutional reference text's embedding), and damping `δ ∈ (0,1]`:
> `Φ_rec(x) := P_{I_intent}( (1−δ)x + δ c )`, where `P_{I_intent}` is the metric
> projection onto `I_intent`.

### 15.2 Strict contraction

> **Theorem 15.2.** `P_{I_intent}` is firmly non-expansive, and `Φ_rec` is a strict
> contraction with constant `κ_contr = 1−δ < 1`:
> `‖Φ_rec(x) − Φ_rec(y)‖ ≤ (1−δ)‖x − y‖`. Hence (Banach, `H_S` complete) `Φ_rec` has a
> *unique* fixed point `σ* ∈ I_intent`, with `‖Φ_rec^k(x) − σ*‖ ≤ (1−δ)^k‖x − σ*‖`.
> `[DERIVED]`

*Proof.* Projection onto a nonempty closed convex set in Hilbert space is firmly
non-expansive: the variational inequality `⟨u−Pu, w−Pu⟩ ≤ 0 ∀w∈I_intent` gives
`‖Pu−Pv‖² ≤ ⟨u−v, Pu−Pv⟩ ≤ ‖u−v‖‖Pu−Pv‖`, so `‖Pu−Pv‖ ≤ ‖u−v‖`. The two arguments of
`Φ_rec` differ by `(1−δ)(x−y)` (the `δc` cancels), so
`‖Φ_rec(x)−Φ_rec(y)‖ ≤ ‖(1−δ)(x−y)‖ = (1−δ)‖x−y‖ < ‖x−y‖`. Banach applies. ∎

### 15.3 Interpretation and the honest caveat

`δ` is "constitutional gravity": the per-step pull toward founding intent `c`. The model
*assumes* governance dynamics are anchored projection — a modeling choice, logged as
`[OPEN — modeling adequacy, Ch. 21]`. But *given* the model, `κ_contr<1` is **proved, not
asserted** — the precise upgrade Open Problem #2 required. And `δ` is *measurable*:
`δ = 1 − (observed per-step contraction ratio)`. For a non-Hilbert `d_sem`, the same
non-expansiveness holds under a CAT(0) hypothesis on `(S/∼, d_sem)`; that case is
`[CONDITIONAL]`, with Bačák's metric convex analysis as the attack plan.

---

## Chapter 16 — Stability, convergence, and drift

### 16.1 The Banach-family results, now discharged

> **Theorem 16.1 (unique equilibrium, stability, convergence — corrected 5.2/T1/T2).**
> Under Chapter 15, `σ*` is the unique semantic equilibrium, and for every initial `x`,
> `d_sem(Φ_rec^k(x), σ*) ≤ (1−δ)^k d_sem(x, σ*) → 0`. Every trajectory converges to `σ*`.
> `[DERIVED]`

The original's 5.2/T1/T2 were "Banach re-labeled" and `[CONDITIONAL]` on an unbuilt `κ`.
With the *constructed* `Φ_rec` they are discharged. Novelty of the theorem: zero (it is
Banach); novelty of the achievement: the hypotheses are now real.

### 16.2 Drift containment, corrected

The original's T7 claimed adversarial drift decays to 0. It does not.

> **Theorem 16.2 (standing drift — corrected T7).** Suppose each round
> `x_{k+1} = Φ_rec(x_k) + e_k` with `‖e_k‖ ≤ δ_adv` and `Φ_rec` a `κ_contr`-contraction
> with fixed point `σ*`. Then `‖x_k − σ*‖ ≤ κ_contr^k‖x_0 − σ*‖ + δ_adv/(1−κ_contr)`, and
> `limsup_k ‖x_k − σ*‖ = δ_adv/(1−κ_contr)` — a **positive constant**, not 0. The system
> is stable to a *ball* of that radius; "repaired to within `ε`" holds **iff**
> `δ_adv/(1−κ_contr) ≤ ε`. `[PROVEN]`

*Proof.* The perturbed-contraction recursion gives
`‖x_{k+1}−σ*‖ ≤ κ_contr‖x_k−σ*‖ + δ_adv`; unrolling and summing the geometric series
`Σ_{i<k} κ_contr^i ≤ 1/(1−κ_contr)` gives the bound; tightness follows by taking
`e_k ≡ δ_adv·u` aligned with the error direction, which drives `x_k` to the point at
distance `δ_adv/(1−κ_contr)` from `σ*`. ∎

The same correction propagates to the original's 15.1 (drift resistance under `f<n/3`):
contained to the *same* ball, not to `σ*`.

---

## Chapter 17 — Adversarial bounds and equivocation

> **Theorem 17.1 (equivocation is bounded, not eliminated — corrected 15.2).** For two
> `ε_AI`-valid AI outputs `y, y'` (each within `ε_AI` of the valid set),
> `d_sem(Γ_rep y, Γ_rep y') ≤ d_sem(y, y') ≤ 2ε_AI`. The two equilibria lie within
> `2ε_AI`, not at the same point. `[PROVEN]`

*Proof.* Triangle through a common valid `v`: `d(y,y') ≤ d(y,v)+d(v,y') ≤ 2ε_AI`;
non-expansiveness of `Γ_rep` transports the bound. Equality would require `Γ_rep` constant
on the `ε_AI`-ball, contradicting its injectivity on `I_intent`. ∎

The original claimed *identical* equilibria; non-expansion bounds the gap but never closes
it. The security guarantee is **bounded equivocation** — overstated in the original by
exactly the radius of the ball.

> **Theorem 17.2 (Byzantine containment).** A Byzantine minority `f < n/3` running on the
> verified DDR substrate (Ch. 20) cannot move the honest equilibrium outside the
> `δ_adv/(1−κ_contr)` ball of Theorem 16.2. `[DERIVED]` (Composes consensus safety, Ch. 20,
> with the contraction, Ch. 15 — the one place the two layers genuinely connect, through
> the agreement guarantee.)

---

# Part IV — Categorical and compositional structure

## Chapter 18 — Functoriality, done correctly

The original's categorical apparatus contained three results the audit found false by
reading the proofs. Each is proved false here, and each is repaired.

### 18.1 The recursive functor is not a functor

> **Theorem 18.1 (corrected 3.3/3.8).** `F_rec(F) := Γ_rep∘Φ_rec∘F` does **not** preserve
> composition. `[PROVEN]`

*Proof.* `F_rec(G)∘F_rec(F) = Γ_rep Φ_rec G Γ_rep Φ_rec F`, while
`F_rec(G∘F) = Γ_rep Φ_rec G F`; equality for all `F,G` forces `Γ_rep Φ_rec = id` on the
relevant image. But `Φ_rec` is a strict contraction (Ch. 15), so `Φ_rec ≠ id` unless the
space is a point. Counterexample on `H_S=ℝ`, `I_intent={0}`, `c=0`: `Φ_rec(x)=(1−δ)x`,
`F_rec(id)=Φ_rec`, yet `F_rec(id∘id)=Φ_rec ≠ Φ_rec∘Φ_rec` since `(1−δ)x≠(1−δ)²x`. ∎

> **Repair (Construction 18.2).** `Γ_rep∘Φ_rec` is the underlying map of the monad `Π_C`
> (Ch. 14). `F_rec` *is* a functor on the **Kleisli/Eilenberg–Moore category** of that
> monad, where the monad multiplication `μ : Π_C∘Π_C ⇒ Π_C` legitimately supplies the
> "extra `Γ_rep Φ_rec`" the broken proof needed. Naturality of repair (3.8) is then the
> monad unit's naturality. `[CONSTRUCTED]`

### 18.2 Colimit ≠ metric limit

> **Theorem 18.3 (corrected 3.6).** The Cauchy/metric limit of a contraction's orbit and
> the categorical ω-colimit of the chain `Σ⁰→Σ¹→⋯` are different universal constructions
> and do not coincide in **Met** in general. `[PROVEN]`

*Proof / counterexample.* In **Met** (1-Lipschitz maps), the sequential colimit is
computed on *objects* (a quotient of the disjoint union), not as a metric limit of
*points*. For the chain `[0,1] →^{x/2} [0,1] →^{x/2} ⋯`, every point's orbit converges
metrically to `0`, but the categorical colimit object is not the one-point space. The
original's "universal property" argument conflates the universal property of the *limit
point* (a completion) with that of the *colimit object*. ∎

> **Corrected statement.** They coincide only in a Cauchy-complete enrichment, where the
> contraction's fixed point is the initial algebra / final coalgebra — an
> America–Rutten algebraic-compactness *theorem with hypotheses*, not a free corollary.
> `[SKETCH — corrected version; attack plan: America–Rutten reflexive-object theorem]`

### 18.3 "Unique realization" is false

> **Theorem 18.4 (corrected 10.3).** A right adjoint `F_ont` to abstraction `F_sem` need
> not be a section; "*the* unique DDR realizer" does not exist when abstraction is
> many-to-one (its purpose). `[PROVEN]`

*Proof.* If `F_sem` identifies distinct realizers `r ≠ r'` of the same semantic state `s`,
no `F_ont(s)` equals both; a right adjoint gives a *universal* (terminal) realizer, not a
unique one, and `F_sem∘F_ont ≅ id` fails whenever fibers are nontrivial. ∎

> **Repair.** Define `F_ont(s)` as the *canonical* realizer — the maximal-entropy
> (least-committed) element of the fiber `F_sem^{-1}(s)`, unique when the fiber is closed
> convex (the Ch. 14 reflector). Then `F_sem ⊣ F_ont` holds with honest unit/counit, and
> 10.2 (`F_sem` preserves the consensus colimit, as a left adjoint) follows legitimately.
> "Unique realization" becomes "canonical realization." `[CONSTRUCTED]`

---

## Chapter 19 — Demarcation: where the framework forbids something

This chapter replaces the original's cross-domain "unification" (its ch16–19), which
extended to a formalization of astrology, with a theorem explaining why such breadth is
self-defeating.

### 19.1 The Scope Theorem

> **Theorem 19.1.** CIIR is a lax monoidal functor `U : ConstrDom → CPTP` from constrained
> domains to quantum channels (a genuine compositional modeling framework,
> `[CONSTRUCTED]`). Then:
> 1. `U` outputs CP/TP channels on finite Hilbert spaces — a strictly smaller target than
>    fundamental physics; it produces no action principle, no Standard Model gauge group
>    or spectrum, and no general relativity. So "theory of everything" in the physics
>    sense is *false of `U`*. `[PROVEN — by inspection of the codomain]`
> 2. If `U` is *total* on `ConstrDom` — every domain, including non-predictive ones such
>    as the astrology domain, admits a model — then `U` has **no falsifiable content**.
>    `[PROVEN]`

*Proof of (2).* A theory is falsifiable only if some possible observation is inconsistent
with it (Popper). If every domain `D` (every consistent state+constraint structure) has a
model `U(D)`, then every observation `o` is realized by some domain and accommodated by
its model; no `o` is excluded; no falsifier exists. The astrology domain is an explicit
witness that `U`'s domain is unrestricted, so the antecedent holds. ∎

### 19.2 The honest framework

> **Corollary 19.2.** The scientifically meaningful CIIR is `U` *restricted* to domains
> with a genuine data-generating process (governance/legal — Part V), with its uniqueness
> claim rebuilt by damped projection (Ch. 12, 15). Breadth is traded for falsifiability,
> which is the correct trade. The astrology domain is not repaired; it is *excluded by
> construction*, because including it is precisely what rendered the theory vacuous. `[E]`

This is the chapter that most changes the original's character: from a framework that
prided itself on modeling everything to a theory that earns its keep by forbidding
something.

---

# Part V — Verification and empirics

## Chapter 20 — The DDR computational substrate (the verified floor)

The semantic layer presupposes that distributed nodes agree on the same stabilized state.
That agreement is the one part of the entire stack whose safety is *machine-checked*.

### 20.1 The guarantee

> **Theorem 20.1 (cross-round BFT Agreement, machine-checked).** Under the lock/unlock
> rule, no two correct validators ever decide conflicting values, for `n = 3f+1`. This is
> discharged at three levels: (a) **TLC** exhaustive model-checking (`n=4,f=1`: 1,597
> states; `n=7,f=2`: 11,615 states; zero violations); (b) **Apalache** symbolic induction
> of a full inductive invariant, at fixed and at *free-integer* (unbounded) rounds; (c) a
> **TLAPS**-verified *parametric* `n=3f+1` quorum-intersection core (`CorrectCard`,
> `QuorumIntersect`, the counting lemma `ActiveHVLower`, and `Init⇒IndInv`; 143
> obligations, 0 failed). `[PROVEN — machine-checked]` (`docs/audit/12–16`.)

### 20.2 The built-in falsifier

> **Proposition 20.2.** With the lock rule *removed*, the same randomized adversarial
> search **finds** a conflicting-decision violation. `[PROVEN]` The result differs if the
> safety mechanism is absent — the falsifiable property a verified system should have.

### 20.3 Honest residue

Fourteen protocol-level leaves of the parametric inductive step remain `[OPEN]` (TLAPS
omitted leaves, `docs/audit/16`), and liveness is tested rather than proved. This is the
honest boundary of the verified floor; it is the highest-scoring layer of the whole
programme precisely because the boundary is drawn explicitly.

---

## Chapter 21 — Falsification: the ConLawDist programme

The governance thesis — *semantic regulation as metric stabilization* — is made
falsifiable here, not asserted.

### 21.1 The pre-registration

> **Pre-registration 21.1.** On one statutory domain (US Code Title 18), with the
> constructed `d_sem` (Ch. 13) and a frozen evaluation harness, the metric is *faithful*
> iff, on a held-out test split: triangle-violation `= 0` (structural); Spearman
> `ρ ≥ 0.70` vs expert pairwise judgments; drift detection `AUC ≥ 0.85` vs court-ruled
> drift cases; conformal coverage `≥ 0.90`. **Falsified if** every `α` reaching `ρ ≥ 0.70`
> destroys drift detection (or every `α` with `AUC ≥ 0.85` collapses `ρ < 0.4`) — then
> metric stabilization is the wrong model for this domain.

### 21.2 What is built and what is gated

> **Status.** The full harness — `d_sem` reference, the four metrics, the dataset schema +
> validator, and a synthetic self-test — is built and passing (`papers/conlawdist/`):
> triangle-violation `= 0` for all `α`; faithful synthetic data yields `ρ≈0.97`,
> `AUC≈1.0`; a null built from data unrelated to the labels collapses to `ρ≈0`,
> `AUC≈0.5` — the falsifier fires. `[CONSTRUCTED — harness]`
>
> The **real corpus + expert drift labels + pairwise judgments** are the remaining gate;
> they require human legal experts and cannot be synthesized. `[OPEN — data]`

This chapter carries the single highest-value obligation in the programme: running it on
real data is the only path that moves the semantic thesis from *no confirmation* to
*confirmed applied*.

---

## Chapter 22 — Open problems, standing, and honest scope

### 22.1 Where this monograph stands

On the ruler the scientific frontier is actually judged by (10 = the best work in the
history of science; `docs/audit/18`), the layers place as follows. A single number would
be a lie; the value is *bimodal*.

| Layer | Standing | ~score |
|---|---|---:|
| DDR substrate (Ch. 20) | young engineering, *machine-checked* | 5.4 |
| Semantic thesis (Ch. 13–17, 21) | nascent but now *constructed + falsifiable* | 3.1 |
| Operator/physics core (Ch. 2–11) | competent-but-standard; keystone refuted & repaired | 2.9 |
| (retired) cross-domain "everything" | excluded by Ch. 19 | — |

For calibration: confirmed leading theories (General Relativity 9.6, Standard Model /
quantum mechanics 9.3, Shannon 9.1) sit far above; *string theory* sits at 5.9 despite
world-class mathematics, held there by the absence of empirical confirmation — and CIIR
sits below it because it lacks the mathematics too (zero novel proven theorems, by both
audits). The DDR floor, by contrast, competes legitimately in young-engineering territory
*because it is checkable*.

### 22.2 Open obligations, each with an attack plan

- **O1 (highest value).** Run ConLawDist on real labeled data (Ch. 21). Moves the
  semantic thesis from *no confirmation* to *measured*; gated only on expert labels.
- **O2.** Derive `Π_C` from constraint geometry (Ch. 14). The deep theory gap;
  calibrated ~30% in 12 months.
- **O3.** Discharge the 14 TLAPS protocol leaves (Ch. 20). Takes the substrate toward the
  confirmed-engineering tier.
- **O4.** Establish `Φ_rec` modeling adequacy (Ch. 15) against labeled drift trajectories.
- **O5.** Publish Theorem K (Ch. 12) — a clean, mechanizable negative result that raises
  the programme's rigor standing immediately and establishes it as the careful party.

### 22.3 The single honest sentence

CIIR is not one theory but a stack: a *verified* engineering floor, a *constructed and
now-falsifiable* semantic agenda, a *correct but standard* physical core with one
refuted-and-repaired keystone, and a discarded universalist overreach — and its future
scientific standing depends almost entirely on **O1**, which is empirical, not
rhetorical.

---

# Appendix A — Notation and the resolved symbol collisions

| Symbol | Meaning | Dimension | Never equals |
|---|---|---|---|
| `κ_curv` | constraint-curvature field (Ch. 3) | `[length]⁻²` | `κ_contr` |
| `κ_contr` | Lipschitz contraction constant (Ch. 15) | dimensionless `∈[0,1)` | `κ_curv` |
| `Φ_iface` | CP/TP interface map (Ch. 4) | — | `Φ_rec` |
| `Φ_rec` | recursive stabilizer (Ch. 15) | — | `Φ_iface` |
| `Φ_t` | GKLS dynamical semigroup (Ch. 7) | — | `Φ_rec` |
| `Π_C` | observer closure / reflector (Ch. 14) | — | a curvature |
| `d_ℛ` | reality-space metric, primitive (Ch. 2) | — | `d_sem` |
| `d_sem` | constructed semantic metric (Ch. 13) | dimensionless | `d_ℛ` |
| `σ*` | unique semantic equilibrium (Ch. 16) | — | `ρ_ss` |
| `ρ_ss` | Lindblad steady state (Ch. 10) | — | `σ*` |

# Appendix B — Status ledger (all chapters)

`[PROVEN]`: 8.1, 9.1, 12 (Theorem K, all parts), 13.2, 13.3, 16.1*, 16.2, 17.1, 18.1,
18.3, 18.4, 19.1, 20.1, 20.2. `[DERIVED]`: 10.1, 15.2, 16.1, 17.2, 12.3. `[CONSTRUCTED]`:
9.2, 12.4, 13.1, 14.1 (toy), 15.1, 18.2, 18.4-repair, 19-restriction, 21 (harness).
`[STANDARD]`: 2.1, 2.2, 3.1, 4.1, 4.2, 4.3, 5.1, 5.2, 7.1, 7.2, 11.1. `[SKETCH]`: 6.1,
18.3-correction. `[CONDITIONAL]`: 15.2 (non-Hilbert / CAT(0) case). `[OPEN]`:
faithfulness (13.4/21), `Π_C` from geometry (14.3), modeling adequacy (15.3), 14 TLAPS
leaves (20.3), `F` in general (6.2), joint feasibility of multi-checks.
*(16.1 is `[DERIVED]`; the asterisk marks that the *theorem* is Banach, the *achievement*
is the constructed hypothesis.)* **Audit result: zero unlabeled assertions across all 22
chapters.**

# Appendix C — What in this monograph is genuinely new

Most of the mathematics is `[STANDARD]` by honest design, because most of CIIR's *correct*
content is standard (Polish spaces, GKLS dynamics, finite-dim C\*-algebra, Banach,
projection theorems). The genuinely *new* contributions, none in the original, are:

1. **Theorem K** (Ch. 12) — a no-go refuting the original's keystone, with machine-checked
   numerics. This is the strongest single result and is, notably, *negative*.
2. The **constructed** `d_sem` / `Π_C` / `Φ_rec` (Ch. 13–15), with proven
   metric / closure / contraction properties — turning the original's three central
   *assertions* into theorems (for a concrete model).
3. The **six error corrections** (Ch. 16–18): drift `δ/(1−κ)`, equivocation `2ε`, the
   non-functor + Kleisli repair, colimit ≠ limit, canonical (not unique) realizer,
   independence ⇏ joint satisfiability.
4. The **Scope/demarcation theorem** (Ch. 19), which converts the original's universalist
   ambition into a precise statement of what it can and cannot be.
5. The **machine-checked substrate** and the **falsification harness** (Ch. 20–21) — the
   programme's empirical spine.

The original's own novelty, by contrast, is `[STANDARD]` results re-skinned plus one
refuted keystone — which is exactly why this edition keeps the correct core, rebuilds the
load-bearing objects, and is honest, chapter by chapter, about which is which.

---

*End of monograph. Provenance, status tags, and the ledger (Appendix B) are integral to
the text: this is a corrected edition built on verified mathematics, and its honesty about
what is proven, constructed, standard, and open is the feature that most distinguishes it
from the original.*
