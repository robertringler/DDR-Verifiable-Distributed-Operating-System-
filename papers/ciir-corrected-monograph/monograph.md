# CIIR — A Corrected Monograph

### Constrained-Interface Information Regulation: foundations, dynamics, the semantic layer, and its honest scope

> **What this document is.** A rigorous, corrected rebuild of the 22-chapter CIIR
> monograph. It is **not** the original text. The original monograph's LaTeX is not
> available to the author of this rebuild; the *contents* of each chapter are
> reconstructed from the adversarial audit that read the original as primary source
> (`docs/audit/00–11`, citing the original's own labels D3.x, Thm 11.2/13.x, ch22),
> and the *mathematics* is the verified work of `docs/audit/17` (formal
> implementation), `papers/theorem-k/` (the keystone refutation, machine-confirmed
> numerically), `papers/conlawdist/` (the empirical apparatus), and the
> machine-checked DDR substrate (`docs/audit/12–16`).
>
> **What changed from the original (the four substantive repairs).**
> 1. The strict-contraction keystone (original ch13 Thm 13.2, Step 2) is **false**;
>    it is replaced by a *damped-projection* mechanism that is genuinely strictly
>    contractive (Ch. 12, 15). The refutation is **Theorem K** (Ch. 12).
> 2. The semantic objects the integration needs — `d_sem`, `I_intent`, `Φ_rec`,
>    `Π_C` — were *asserted* in the original; here they are **constructed**
>    (Ch. 13–15).
> 3. The six proof errors the audit found (functoriality, colimit≠limit,
>    unique-realization, drift series, equivocation, joint-satisfiability) are
>    **corrected** (Ch. 16–18).
> 4. The cross-domain "theory of everything" reach — which in the original extends
>    to **astrology** — is **retired** and replaced by a demarcation theorem
>    (Ch. 19): a framework that models everything forbids nothing.
>
> **Status tags.** `[PROVEN]` gap-free; `[DERIVED]` full proof from stated axioms;
> `[CONSTRUCTED]` object exhibited + properties verified; `[CONDITIONAL]` under a
> named hypothesis; `[SKETCH]` strategy + gap + attack plan; `[OPEN]` precise
> obligation stated; `[STANDARD]` a correct application of a classical theorem,
> claimed as such with no novelty. Unlabeled assertions are defects; there are none.
>
> **Notation discipline (the symbol collision, resolved once).** `κ_curv : M → ℝ≥0`
> is the constraint-*curvature* field; `κ_contr ∈ [0,1)` is a Lipschitz *contraction*
> constant; they are dimensionally distinct (Appendix A) and never identified. `Φ_iface`
> is the CP/TP interface map; `Φ_rec` is the recursive stabilizer. The original
> conflated these letters; this rebuild does not.

---

## Contents

- **Part I — Foundations** (Ch. 1–6): programme, reality space, constraint geometry,
  the interface map, operator-algebra structure, representation.
- **Part II — Dynamics** (Ch. 7–12): the master equation, the contraction semigroup,
  physical admissibility, the spectral gap, the honest Banach result, and the
  observer-map no-go (Theorem K).
- **Part III — The semantic layer** (Ch. 13–17): `d_sem`, the observer fixed point
  `Π_C`, recursive stabilization `Φ_rec` with `κ<1`, stability/drift, adversarial bounds.
- **Part IV — Categorical & compositional structure** (Ch. 18–19): functoriality done
  correctly, and the demarcation theorem.
- **Part V — Verification & empirics** (Ch. 20–22): the machine-checked DDR substrate,
  the ConLawDist falsification programme, and open problems + honest standing.
- **Appendices** A (notation), B (status ledger), C (what is genuinely new).

---

# Part I — Foundations

## Chapter 1 — The CIIR programme and its scope

**Thesis.** A cognitive/governance system's *effective* state is the state accessible
through a formally constrained observation interface; legitimate states are the
fixed points of observe-then-reconstruct; and drift away from intent is corrected by
a contraction toward an invariant set. CIIR formalizes this as an open-system
dynamics plus a metric-stabilization layer.

**Scope, stated up front (the demarcation, proved in Ch. 19).** CIIR is a
*compositional modeling framework*, realized as a lax monoidal functor
`U : ConstrDom → CPTP` from constrained domains to quantum channels. It is **not** a
fundamental theory of physics: it has no action principle, derives neither the
Standard Model nor general relativity, and predicts no new particle or force. Its
"universality" is *modeling* universality, and (Ch. 19, Scope Theorem) universality
without domain restriction is a **defect**, not a virtue — it forbids no observation.
Everything below is scoped accordingly. `[PROVEN — Ch. 19]`

**The two layers, never conflated.** (i) a *physical/operator* layer — a genuine but
standard open-quantum-system construction (Part II); (ii) a *semantic/governance*
layer — the constructed metric-stabilization system (Part III). The original
monograph's central error was *homonymy* between them (sharing `Φ, κ, M, Π` across
unrelated referents); this rebuild keeps them dimensionally and notationally separate.

## Chapter 2 — The reality space

**Definition 2.1 (reality space).** A *reality space* is a triple `(ℛ, d_ℛ, τ)` with
`(ℛ, d_ℛ)` a complete separable metric (Polish) space and `τ` its Borel σ-algebra.
`[STANDARD]` (this is the original's D3.1, correctly a primitive).

**Proposition 2.2.** Every Polish space is standard Borel (Kuratowski); reality spaces
exist and carry well-defined probability measures. `[STANDARD — Kechris]`

**Honest note.** `d_ℛ` is *posited*, including its triangle inequality. The original
assumed M1–M3 on an abstract `ℛ`; that is legitimate for a primitive, but it is **not**
a semantic metric — the burden of *constructing* a distance on meanings is discharged
separately and honestly in Ch. 13, not inherited from here. `[E]`

## Chapter 3 — Constraint geometry

**Definition 3.1 (constraint manifold).** A smooth Riemannian manifold `(M, g)` with a
nonnegative scalar **curvature field** `κ_curv : M → ℝ≥0` encoding local constraint
stiffness. `[STANDARD — assumed structure]` (original D3.4, D3.7–3.8).

**Warning (symbol collision).** `κ_curv` has dimension `[length]⁻²` and is **not** the
contraction constant `κ_contr` of Ch. 15 (dimensionless, in `[0,1)`). They cannot be
equal; conflating them was an original defect. `[PROVEN — dimensional analysis, App. A]`

**What this chapter does and does not give.** It grounds "constraint geometry" as a
manifold. It does **not** by itself derive the observer projector `Π_C` from that
geometry — the original deferred this (its ch22), and so do we, honestly (Ch. 14, an
`[OPEN]` obligation with an attack plan).

## Chapter 4 — Constraint operators and the interface map

**Definition 4.1 (constraint operators).** A finite family of self-adjoint operators
`Ĉ_i ∈ B(H)` on a finite-dimensional Hilbert space `H`, encoding the admissible
observations. `[STANDARD]`

**Definition 4.2 (interface map).** A completely-positive, trace-preserving (CP/TP) map
`Φ_iface : B(ℛ_op) → B(H)` (a quantum channel), with Stinespring dilation
`Φ_iface(X) = V^† (X ⊗ I) V`. `[STANDARD — Stinespring/Kraus]` (original D3.15–16).

This is the genuine, CIIR-specific object: *constrained observation as a channel*. It
is real and correct — and, the audit notes, **orphaned** by the original integration,
which used governance predicates rather than `Ĉ_i`. Ch. 19 says precisely how the
semantic layer relates to it (by analogy, not identity — flagged, not hidden).

## Chapter 5 — Operator-algebra structure

**Theorem 5.1 (block decomposition).** The algebra generated by `{Ĉ_i}` on
finite-dimensional `H` is a finite direct sum of full matrix algebras,
`A ≅ ⊕_j M_{k_j}(ℂ)`. `[STANDARD — finite-dim C\*-algebra structure]` (original ch05).

**Corollary 5.2.** The admissible-observation algebra has a canonical superselection
decomposition `H ≅ ⊕_j (ℂ^{k_j} ⊗ ℂ^{m_j})`; the centre indexes the sectors `P_α`.
`[STANDARD]` These sectors are the physical-layer analogue of "invariant content," and
reappear (by analogy) as the constraint structure of `I_intent` in Ch. 14.

## Chapter 6 — Representation

**Definition 6.1 (representation functor).** A functor `F : CogSys → Hilb_CIIR` sending a
constrained cognitive system to its Hilbert representation, morphisms to channels.
`[SKETCH — standard]` Well-definedness requires that system morphisms map to CP/TP maps;
verified for finite systems, `[OPEN]` in general (attack plan: Stinespring naturality).

---

# Part II — Dynamics

## Chapter 7 — The CIIR master equation

**Definition 7.1 (GKLS generator).** The CIIR dynamics is the semigroup `Φ_t = e^{tL}`
generated by a Gorini–Kossakowski–Sudarshan–Lindblad operator
`L(ρ) = −i[H, ρ] + Σ_k γ_k ( A_k ρ A_k^† − ½{A_k^†A_k, ρ} )`, `γ_k ≥ 0`. `[STANDARD]`
(original ch07/ch12; the audit confirms this is what CIIR's dynamics *actually are*: an
open quantum system in the weak-coupling Davies limit.)

**Theorem 7.2 (Hille–Yosida).** `L` of GKLS form generates a strongly-continuous
one-parameter semigroup of CP/TP maps. `[STANDARD]`

## Chapter 8 — The contraction semigroup

**Theorem 8.1 (CPTP maps are trace-norm non-expansive).** Every CP/TP map `Φ` satisfies
`‖Φ(ρ) − Φ(σ)‖₁ ≤ ‖ρ − σ‖₁`; hence `{Φ_t}` is a family of trace-norm contractions
(non-strict). `[PROVEN]` (full proof in `docs/audit/17` §4.1, via the Jordan
decomposition and the variational form of `‖·‖₁`).

This is the **correct, non-strict** statement. The original's Steps 1, 3, 4 deliver
exactly this `≤ 1` bound; the original's *strict* claim came solely from Step 2, which
Ch. 12 refutes. Strictness, when it holds, comes from a spectral gap (Ch. 10) or from
the damped projection (Ch. 12, 15) — never from the bare semigroup.

## Chapter 9 — Physical admissibility and the red-team

The original's own red-team (its ch09) rated CIIR's *novel* dynamics **"fatal if
physical."** This rebuild diagnoses and resolves the issue rather than burying it.

**Diagnosis.** The flagged generators use a matrix logarithm / gradient flow that is
**not** of GKLS form, hence not completely positive, hence violates no-signaling —
inadmissible as physical (quantum) dynamics. `[E]`

**Theorem 9.1 (GKLS admissibility / quarantine).** A generator `L` produces CP dynamics
`e^{tL}` for all `t ≥ 0` **iff** `L` has GKLS form (the Kossakowski matrix is positive
semidefinite). A non-GKLS generator generically fails this. **Repair:** project the
proposed generator onto the GKLS-admissible cone (clip negative Kossakowski
eigenvalues); the nearest CP semigroup is well-defined and used hereafter. `[PROVEN]`

**Consequence.** CIIR is retained as a *standard* open quantum system (Davies limit),
not a novel dynamics. Its novelty claim at the dynamical level is **withdrawn**; what
remains is correct and physical. `[E]`

## Chapter 10 — Spectral gap and convergence

**Theorem 10.1 (gapped convergence).** If the Lindbladian `L` has a spectral gap `Δ > 0`
above its zero eigenvalue and a unique steady state `ρ_ss`, then
`‖Φ_t(ρ) − ρ_ss‖₁ ≤ e^{−Δ t} ‖ρ − ρ_ss‖₁`. `[DERIVED — under the gap hypothesis]`

This is the *legitimate* route to strict contraction at the physical layer: the rate is
`κ_contr = e^{−Δτ}` per step `τ`. The gap is **measurable** (the original's ch22 reports
`Δ ≈ 0.013` numerically); its analytic determination from `(M, g, κ_curv)` is `[OPEN]`.

## Chapter 11 — Fixed points of contractive cellular updates (the honest Banach)

**Theorem 11.1 (CRS fixed point).** On `ℝ^{|V|×d}` (complete), a constraint-reality-system
update that is `c`-contractive with exponential decay `δ ∈ (0,1)` has a unique fixed
point reached at geometric rate `c^k`. `[PROVEN — classical Banach]` (original ch11
Thm 11.2; the audit certifies this as the original's one *honest* contraction result.)

This is correct and retained verbatim in spirit. It is Banach's 1922 theorem applied to
a concrete contractive update; **novelty zero, correctness total.** It is the template
the semantic layer (Ch. 15) instantiates with a *constructed* contraction.

## Chapter 12 — The observer-sharpening map: a no-go (Theorem K)

The original's keystone (its ch13 Thm 13.2) derived *strict* loop contraction from the
claim that the normalized power map is a strict contraction "by Powers–Størmer." This is
false, and its failure is the single most important correction in this rebuild.

**Definition 12.1.** `N_β(ρ) = ρ^β / Tr(ρ^β)`, `β ∈ (0,1)`, on density matrices
`D(H)`, `d = dim H ≥ 2`.

**Theorem K (no-go).** For every `β ∈ (0,1)` and `d ≥ 2`, `N_β` is **not** a strict
contraction in any unitarily-invariant norm. Precisely: (1) it fixes **both** `I/d`
**and** every pure state, so it has ≥ 2 fixed points; (2) its Fréchet derivative at
`I/d` on the trace-zero tangent space is exactly `β·id` (local `β`-contraction there);
(3) near every pure state it is **expansive**, with local ratio `ε^{β−1} → ∞`.
`[PROVEN]` (full proof in `papers/theorem-k/theorem-K-note.md`; numerically confirmed
to machine precision in `verify_theorem_k.py` — local ratio `= β` to 4 decimals,
expansion ratio `= ε^{β−1}` on the nose).

**Consequences for the original.** A strict contraction has a unique fixed point
(Banach); two fixed points preclude it. Therefore the original's ch13 Thm 13.2
(strict loop contraction), Thm 13.5 ("fixed points are pure" — **false**: `I/d` is a
mixed fixed point), and Thm 13.3 ("an inner product emerges at *the* fixed point" — no
unique referent) all lose their support. `[DERIVED]`

**The repair (used hereafter).** Replace `N_β` by a **damped projection** onto the
decoherence-free / code subalgebra,
`Φ_loop(ρ) = P_𝒜( (1−δ)ρ + δ ρ_0 )`, `δ ∈ (0,1]`,
with `P_𝒜` the trace-norm projection onto the (closed convex) `𝒜`-block-diagonal
states and `ρ_0` an anchor. Since CPTP/contractive projections are non-expansive
(Ch. 8), `Φ_loop` is a genuine `(1−δ)`-contraction with a **unique** fixed point.
`[CONSTRUCTED]` This recovers the original's *intended* conclusion (a unique stabilized
state) by a *valid* mechanism — the same device the semantic layer uses in Ch. 15.

---

# Part III — The semantic layer

> This is where the integration's load-bearing objects, *asserted* in the original,
> are *constructed*. The construction follows `docs/audit/17` §2.

## Chapter 13 — The semantic metric `d_sem`

**Construction 13.1.** On a finite semantic carrier `S`, build (i) a connected weighted
knowledge graph `G = (S, E, w)` of certified relations, with `d_graph =` shortest-path
distance; (ii) a Lipschitz encoder `E : S → ℝ^n` (certificate `L`) with
`d_embed = ‖E(·) − E(·)‖₂`; and fuse `d_sem = α·d_graph + (1−α)·d_embed`, `α ∈ (0,1]`.

**Proposition 13.2.** `d_sem` is a pseudometric; a genuine metric for `α > 0`; on the
quotient `S/∼` a complete metric space. `[PROVEN]` (graph distance is a metric;
`d_embed` is the pullback of a norm, so the triangle inequality is automatic; a
nonnegative combination preserves all metric axioms; finite ⇒ complete).

**Corollary 13.3 (the triangle worry dissolved).** The triangle-violation rate of
`d_sem` is **exactly 0**, by construction. `[PROVEN]` The original audit's central fear —
that meaning-distance violates the triangle inequality — is relocated from *structure*
(now settled) to *faithfulness* (empirical, Ch. 21). Confirmed as a unit test in
`papers/conlawdist/` (triangle-violation = 0 for all `α`).

**What stays open.** *Faithfulness* — that small `d_sem` ⇔ humans judge meanings close —
is empirical, not a theorem. `[OPEN — Ch. 21, ConLawDist]`

## Chapter 14 — The intent set and the observer fixed point `Π_C`

The original's `Π_C` was *assumed, not derived* (its ch22, admitted). Step zero is
**well-posing**, achieved here via a closure operator.

**Theorem 14.1 (well-posed observer fixed point).** Let `O_C, R` be observation and
reconstruction maps on a complete lattice of semantic states, `Π_C = R∘O_C`. If `Π_C` is
monotone, extensive, and idempotent, it is a **closure operator**; `I_intent := Fix(Π_C)`
is a nonempty complete lattice; and the repair map `Γ_rep := Π_C` is the unique
idempotent monotone reflector onto `I_intent`. `[PROVEN — Tarski/closure theory]`

This makes the three identifications the original never made: `I_intent = Fix(Π_C)`,
`Γ_rep = Π_C` (repair *is* closure, no longer ad hoc), "observer fixed point" =
"constraint closure." A concrete finite `(O_C, R)` (Horn-clause forward chaining) is
exhibited and verified idempotent. `[CONSTRUCTED — toy]`

**The deep open problem, named honestly.** Deriving *this* `Π_C` from the constraint
geometry `(M, g, κ_curv)` of Ch. 3 — the original's actual aspiration — remains
`[OPEN]`. Attack plan (`docs/audit/04`): build `O_C, R` from the Lindbladian measurement
channel and decoherence-free subalgebra; reflectivity ⇒ idempotency; firm
non-expansiveness ⇒ inherited `κ<1` (the bridge to Ch. 15). Calibrated success ~30%/12mo.

## Chapter 15 — Recursive stabilization `Φ_rec` and `κ_contr < 1`

The original asserted the existence of a contraction `κ_contr < 1` (its Open Problem #2).
Here it is a theorem, for a concrete operator.

**Definition 15.1 (anchored stabilizer).** In the Hilbert realization of `S/∼`, with
`I_intent` closed convex and anchor `c` (the constitutional reference), `δ ∈ (0,1]`:
`Φ_rec(x) = P_{I_intent}( (1−δ)x + δ c )`.

**Theorem 15.2 (strict contraction).** `Φ_rec` is a strict contraction with
`κ_contr = 1−δ`: `‖Φ_rec(x) − Φ_rec(y)‖ ≤ (1−δ)‖x−y‖`; by Banach it has a unique fixed
point `σ* ∈ I_intent` with `‖Φ_rec^k(x) − σ*‖ ≤ (1−δ)^k ‖x − σ*‖`. `[DERIVED]`
(Proof: metric projection onto a closed convex set is firmly non-expansive; the `δc` term
cancels in the difference, leaving the factor `(1−δ)`.)

This discharges the original's Open Problem #2 **for a concrete, well-motivated model**.
The modeling commitment — governance dynamics *as* anchored projection — is logged as an
`[OPEN]` adequacy question (Ch. 21), but *given* the model, `κ_contr < 1` is **proved,
not asserted**. `δ` is "constitutional gravity," and is *measurable* as
`1 − (observed contraction ratio)`.

## Chapter 16 — Stability, convergence, and drift

**Theorem 16.1 (stability / convergence — corrected T1/T2/5.2).** Under Ch. 15,
`σ*` is the unique semantic equilibrium and `d_sem(Φ_rec^k(x), σ*) ≤ (1−δ)^k d_sem(x, σ*)`.
`[DERIVED]` (Banach applied to the *constructed* `Φ_rec`; the original's 5.2/T1/T2 were
"Banach re-labeled" and `[CONDITIONAL]` on an unbuilt `κ` — now discharged.)

**Theorem 16.2 (drift containment — corrected T7).** With per-round bounded adversarial
injection `‖e_k‖ ≤ δ_adv`, the standing drift satisfies
`limsup_k ‖x_k − σ*‖ = δ_adv / (1 − κ_contr)` — a **positive constant**, not 0. The
system is stable to a *ball* of that radius; "repaired to within `ε`" holds **iff**
`δ_adv/(1−κ_contr) ≤ ε`. `[PROVEN]` (The original's "→ 0" was a geometric-series error;
this is the correct limit. Same correction propagates to drift-resistance under
`f < n/3`.)

## Chapter 17 — Adversarial bounds and equivocation

**Theorem 17.1 (equivocation is bounded, not eliminated — corrected 15.2).** For two
`ε_AI`-valid outputs `y, y'`, non-expansiveness of `Γ_rep` gives
`d_sem(Γ_rep y, Γ_rep y') ≤ d_sem(y, y') ≤ 2ε_AI`. The two equilibria are **within
`2ε_AI`**, not identical. `[PROVEN]` (The original claimed identity; non-expansion bounds
the gap but does not close it. The security guarantee is bounded equivocation.)

**Theorem 17.2 (Byzantine drift containment).** A Byzantine minority `f < n/3` running on
the verified DDR substrate (Ch. 20) cannot move the honest equilibrium outside the
`δ_adv/(1−κ_contr)` ball of Theorem 16.2. `[DERIVED]` (Composes the consensus safety of
Ch. 20 with the contraction of Ch. 15.)

---

# Part IV — Categorical and compositional structure

## Chapter 18 — Functoriality, done correctly

**Theorem 18.1 (the original functor is not a functor — corrected 3.3/3.8).**
`F_rec(F) := Γ_rep∘Φ_rec∘F` does **not** preserve composition: it would require the
strict contraction `Γ_rep∘Φ_rec` to act as the identity, which it does not (a strict
contraction `≠ id` unless the space is a point). `[PROVEN]` (Explicit counterexample on
`ℝ`: `(1−δ)x ≠ (1−δ)²x`.)

**Repair.** `Γ_rep∘Φ_rec` is the underlying map of the **monad** `Π_C` (Ch. 14); `F_rec`
*is* a functor on the **Kleisli / Eilenberg–Moore category** of that monad, where the
monad multiplication legitimately supplies the "extra `Γ_rep∘Φ_rec`" the broken proof
needed. `[CONSTRUCTED]` Naturality of repair (original 3.8) follows as the monad unit's
naturality on that category.

**Theorem 18.2 (colimit ≠ metric limit — corrected 3.6).** A contraction's Cauchy limit
(a completion phenomenon) is **not** the categorical ω-colimit of the chain
`Σ⁰→Σ¹→…` in general. `[PROVEN]` (Counterexample in **Met**.) They coincide only in a
Cauchy-complete enrichment via America–Rutten algebraic compactness — a *theorem with
hypotheses*, not a free corollary. `[SKETCH — corrected version]`

**Theorem 18.3 ("unique realization" is false — corrected 10.3).** A right adjoint
`F_ont` to abstraction `F_sem` need not be a section; "the unique DDR realizer" does not
exist when abstraction is many-to-one (its purpose). `[PROVEN]` **Repair:** `F_ont(s) =`
the *canonical* (maximal-entropy / least-committed) realizer, giving an honest adjunction
`F_sem ⊣ F_ont` with real unit/counit. `[CONSTRUCTED]`

## Chapter 19 — Demarcation: where the framework forbids something (replaces the astrology chapter)

The original's cross-domain "unification" (its ch16–19) extended to a formalization of
**astrology** (Domain XV). This rebuild deletes that reach and proves why it must go.

**Theorem 19.1 (Scope Theorem).** CIIR is a lax monoidal functor `U : ConstrDom → CPTP`
(a genuine compositional modeling framework, `[CONSTRUCTED]`). But: (i) `U` outputs
CPTP channels on finite Hilbert spaces — strictly less than fundamental physics; it
yields no action, no Standard Model, no gravity. `[PROVEN]` (ii) If `U` is *total* on
`ConstrDom` — admitting a model for **every** domain, including non-predictive ones such
as astrology — then `U` has **no falsifiable content**: a theory consistent with every
possible observation forbids none. `[PROVEN — Popperian demarcation]`

**Corollary 19.2 (the honest framework).** The scientifically meaningful CIIR is `U`
**restricted** to domains with a genuine data-generating process (governance/legal,
Part V), with its uniqueness claim rebuilt by damped projection (Ch. 12, 15). Breadth is
traded for falsifiability — the correct trade. The astrology domain is not repaired; it
is *excluded by construction*, because including it is what made the theory vacuous. `[E]`

---

# Part V — Verification and empirics

## Chapter 20 — The DDR computational substrate (the verified floor)

The semantic layer runs on a distributed substrate whose safety is **machine-checked** —
the one part of the whole stack that competes in its field on the strongest terms.

**Theorem 20.1 (cross-round BFT Agreement, machine-checked).** Under the lock/unlock
rule, no two correct validators decide conflicting values, for `n = 3f+1`. Discharged by
(a) TLC exhaustive check (`n=4,f=1`; `n=7,f=2`); (b) Apalache symbolic induction
(fixed and free-integer rounds); (c) a TLAPS-verified parametric quorum-intersection core
(`CorrectCard`, `QuorumIntersect`, `ActiveHVLower`, `Init⇒IndInv`; 143 obligations, 0
failed). `[PROVEN — machine-checked]` (`docs/audit/12–16`.)

**Falsifier built in.** Removing the lock makes the *same* adversarial search **find** a
conflicting-decision violation — the result differs if the safety mechanism is absent.
`[PROVEN]` This is the substrate's empirical spine, and it is real.

**Honest residue.** 14 protocol-level leaves of the parametric step remain `[OPEN]`
(TLAPS omitted leaves, `docs/audit/16`); liveness is tested, not proved.

## Chapter 21 — Falsification: the ConLawDist programme

The thesis "semantic regulation as metric stabilization" is made **falsifiable** here.

**Pre-registration 21.1.** On one statutory domain (US Code Title 18), the constructed
`d_sem` (Ch. 13) is faithful iff, on a held-out test split: triangle-violation `= 0`
(structural), Spearman `ρ ≥ 0.7` vs expert judgments, drift AUC `≥ 0.85` vs court-ruled
drift cases, conformal coverage `≥ 0.9`. **Falsified if** every `α` reaching `ρ ≥ 0.7`
destroys drift detection (or vice versa) — then the metric-stabilization model is wrong
for this domain. `[CONSTRUCTED harness — `papers/conlawdist/`]`

**Status.** The full evaluation harness, `d_sem` reference, schema, validator, and a
synthetic self-test are **built and passing** (faithful synthetic ρ≈0.97/AUC≈1.0; null
baseline collapses to ρ≈0/AUC≈0.5 — the falsifier fires). The **real corpus + expert
labels** are the remaining gate; they cannot be synthesized. `[OPEN — data]`

This chapter is the most important empirically: it is the only path that moves the
semantic thesis from "no confirmation" toward "confirmed applied" (Ch. 22).

## Chapter 22 — Open problems, standing, and honest scope

**Where this monograph stands (calibrated; `docs/audit/18`).** On the ruler the
scientific frontier is judged by (10 = best in the history of science), the layers place:

| Layer | Standing | ~score |
|---|---|---:|
| DDR substrate (Ch. 20) | young engineering, *machine-checked* | 5.4 |
| Semantic thesis (Ch. 13–17, 21) | nascent but now *constructed + falsifiable* | 3.1 |
| Operator/physics core (Ch. 2–11) | competent-but-standard; keystone refuted & repaired | 2.9 |
| (retired) cross-domain "everything" | excluded by Ch. 19 | — |

The grand theory does **not** stack up against confirmed leading theories; the value is
*bimodal* — a real verified substrate and a worthwhile pre-empirical agenda, with the
physics core correct-but-unoriginal and the "everything" claim retired.

**Open obligations (each with an attack plan).**
- **O1 (highest value):** run ConLawDist on real labeled data (Ch. 21) — moves the
  semantic thesis from *no confirmation* to *measured*. Gated only on expert labels.
- **O2:** derive `Π_C` from constraint geometry (Ch. 14) — the deep theory gap, ~30%/12mo.
- **O3:** discharge the 14 TLAPS protocol leaves (Ch. 20) — takes the substrate toward the
  confirmed-engineering tier.
- **O4:** `Φ_rec` modeling adequacy (Ch. 15) — empirical, against labeled drift trajectories.
- **O5:** publish Theorem K (Ch. 12) — a clean, mechanizable negative result; raises the
  programme's rigor standing immediately.

**The single honest sentence.** CIIR is not one theory but a stack: a *verified*
engineering floor, a *constructed and falsifiable* semantic agenda, a *correct but
standard* physical core with one refuted-and-repaired keystone, and a discarded
universalist overreach — and its future standing depends almost entirely on O1, which is
empirical, not rhetorical.

---

# Appendix A — Notation and the resolved symbol collisions

| Symbol | Meaning | Dimension | Never equals |
|---|---|---|---|
| `κ_curv` | constraint curvature field (Ch. 3) | `[length]⁻²` | `κ_contr` |
| `κ_contr` | Lipschitz contraction constant (Ch. 15) | dimensionless `∈[0,1)` | `κ_curv` |
| `Φ_iface` | CP/TP interface map (Ch. 4) | — | `Φ_rec` |
| `Φ_rec` | recursive stabilizer (Ch. 15) | — | `Φ_iface` |
| `Π_C` | observer closure / fixed-point projector (Ch. 14) | — | a curvature |
| `d_ℛ` | reality-space metric (Ch. 2, primitive) | — | `d_sem` |
| `d_sem` | constructed semantic metric (Ch. 13) | dimensionless | `d_ℛ` |

# Appendix B — Status ledger (all chapters)

`[PROVEN]`: 8.1, 9.1, 12 (Theorem K), 13.2, 13.3, 16.2, 17.1, 18.1, 18.2, 18.3, 19.1,
20.1. `[DERIVED]`: 10.1, 15.2, 16.1, 17.2. `[CONSTRUCTED]`: 12-repair, 13.1, 14.1(toy),
15.1, 18.1-repair, 18.3-repair, 19-restriction, 21 (harness). `[STANDARD]`: 2.1, 2.2,
3.1, 4.1, 4.2, 5.1, 5.2, 7.1, 7.2, 11.1. `[OPEN]`: faithfulness (13.3/21), `Π_C` from
geometry (14), modeling adequacy (15), 14 TLAPS leaves (20), `F` general (6), joint
feasibility. `[SKETCH]`: 6.1, 18.2-correction. **Zero unlabeled assertions.**

# Appendix C — What in this monograph is genuinely new

Most of the mathematics is `[STANDARD]` by honest design. The genuinely *new*
contributions, none of which are in the original, are: **(1) Theorem K** — a no-go
refuting the original's keystone (Ch. 12); **(2)** the *constructed* `d_sem`/`Φ_rec`/`Π_C`
with proven metric/contraction/closure properties (Ch. 13–15); **(3)** the six error
corrections (Ch. 16–18); **(4)** the Scope/demarcation theorem (Ch. 19); **(5)** the
machine-checked substrate and the falsification harness (Ch. 20–21). The original's own
novelty, by contrast, is `[STANDARD] results re-skinned + one refuted keystone` — which
is precisely why this rebuild keeps the correct core and rebuilds the rest.
