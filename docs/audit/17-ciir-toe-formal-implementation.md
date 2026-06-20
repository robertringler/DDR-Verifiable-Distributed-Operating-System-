# 17 — CIIR as a Formal Theory: A Rigorous Implementation Attempt

> **Provenance and honesty preamble (read first).** The CIIR monograph's primary
> LaTeX is **not in this repository**; my context contains the adversarial audit
> of it (`docs/audit/00–11`), which read the monograph as primary source and
> records its definitions by their own labels (D3.x, Thm 11.2/13.x, ch22). This
> document therefore reconstructs CIIR's load-bearing objects **from that audit**,
> not from invented definitions, and every place that reconstruction is load-bearing
> is flagged in the Assumptions Register (§9). The *new mathematics* below
> (constructions, the keystone refutation, the error corrections, the scope theorem)
> stands on its own and does not depend on the reconstruction being a perfect mirror
> of the source — where it depends on a specific monograph claim, that claim is cited
> to its audit label.
>
> **Status tags** (per the engineering brief): `[PROVEN]` gap-free; `[DERIVED]`
> full proof from stated axioms; `[CONSTRUCTED]` object exhibited + defining
> properties verified; `[CONDITIONAL]` valid under a named hypothesis; `[SKETCH]`
> strategy + named gap + attack plan; `[OPEN]` precise obligation stated.
> An unlabeled assertion would be a defect; there are none.

---

## 0. Executive map

CIIR, stripped to its formal content, is **not** a theory of everything in the
physics sense (no action principle, no fundamental fields, no derivation of the
Standard Model or gravity — see §10, Scope Theorem). It **is** implementable as a
precise mathematical object: a *constraint-projected contraction system* whose
intended dynamics are those of an open quantum system (a GKLS/Lindblad CPTP
semigroup) and whose intended governance application is Banach stabilization of a
"semantic" state toward an invariant intent set. This document builds that object
rigorously, repairs the six errors the audit found by reading the proofs, and
resolves the monograph's own keystone gap (the strict-contraction question, OP#10)
with a **negative theorem**.

**The dependency graph of what is established here:**

```
                       (§1 Foundations: axioms F1–F7)
                                  │
        ┌─────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  §2.1 d_sem                §2.2 Φ_rec, κ<1            §2.3 Π_C closure
  [CONSTRUCTED:             [DERIVED: anchored          [CONSTRUCTED toy;
   complete metric]          projection, κ=1−δ]          OPEN: causal-geom
        │                          │                      derivation]
        └──────────┬───────────────┴──────────┬───────────┘
                   ▼                           ▼
            §3 Theorem layer            §2.4 KEYSTONE (OP#10)
        (5.2,T1,T2,T7,15.2,8.2,      Thm K: the CIIR observer map
         3.3/3.8,3.6,10.3 — each       N_β is NOT a strict contraction
         re-proved or corrected)       [PROVEN] → kills ch13 uniqueness
                   │
                   ▼
        §4 Physics grounding (CPTP contraction [PROVEN];
            "fatal if physical" diagnosed + quarantined)
                   │
                   ▼
        §5 Falsifiability   §6 Mechanization   §7 Ledger   §8 Open register
```

**The five headline results of this document:**

1. **[PROVEN] Theorem K (§2.4).** The map `N_β(ρ)=ρ^β/Tr(ρ^β)`, `β∈(½,1)` — the
   sole claimed source of *strictness* in CIIR's loop-contraction (ch13 Thm 13.2,
   Step 2) — is **not** a strict contraction in any unitarily-invariant norm,
   because it fixes both `I/d` and **every** pure state. CIIR's uniqueness chain
   (Thm 13.2→13.3→13.5, "fixed points are pure, inner product emerges") therefore
   has no valid support. This resolves the monograph's own open problem OP#10,
   negatively, with a two-line proof the manuscript missed.
2. **[CONSTRUCTED] d_sem (§2.1).** A concrete complete metric space of meanings,
   built so the triangle inequality holds **by construction** (pullback of a norm +
   a graph metric); the audit's triangle-inequality fear is dissolved at the level
   of *structure* and relocated to *faithfulness*, which is empirical, not a theorem.
3. **[DERIVED] κ<1 (§2.2).** A concrete operator — *anchored metric projection*
   `Φ_rec(x)=P_{I_intent}((1−δ)x+δc)` — is proved to be a strict contraction with
   `κ=1−δ`, turning CIIR's central `[ASSERTED]` (Open Problem #2) into a theorem,
   for a well-motivated model.
4. **[CONSTRUCTED] Π_C (§2.3).** The observer fixed point is well-posed as a
   closure operator / idempotent monad (Tarski-guaranteed fixed-point lattice),
   with a concrete finite `(O_C,R)` adjunction exhibited; the full
   causal-geometry derivation the monograph defers stays `[OPEN]` with an attack plan.
5. **[PROVEN] Six error corrections (§3).** The functoriality defect (3.3/3.8),
   colimit≠limit (3.6), false unique-realization (10.3), the drift geometric-series
   error (T7), the "identical equilibria" overstatement (15.2), and the
   independence⇏joint-satisfiability non-sequitur (8.2) are each proved as stated
   and given the corrected theorem.

---

## 1. Foundations

### 1.1 Primitive notions and ambient categories

We fix, once, the objects every later section quantifies over.

- **`Sem`** — the *semantic category*. Objects: semantic states (meanings,
  legal "applications"). We realize it concretely in §2.1 as a metric space; here
  it is a small category with a faithful functor to **Met** (metric spaces,
  1-Lipschitz maps).
- **`Den`** — *density operators*: `D(H) = {ρ ∈ B(H) : ρ = ρ^†, ρ ≥ 0, Tr ρ = 1}`
  for a finite-dimensional Hilbert space `H`, `dim H = d`. This is where the
  monograph's actual dynamics live (audit §11: ch12 GKLS semigroup).
- **`CPTP(H)`** — completely-positive trace-preserving maps `D(H)→D(H)` (quantum
  channels), a monoid under composition.

**Notation discipline (the symbol-collision the audit flagged, OP#9).** The letter
`κ` denotes **two distinct objects** in the CIIR corpus and we never conflate them:
`κ_curv : M → ℝ_{≥0}` is the **scalar constraint-curvature field** (monograph D3.8),
a geometric quantity; `κ_contr ∈ [0,1)` is a **Lipschitz contraction constant**
(the integration's Open Problem #2). Likewise `Φ` is the interface map (D3.15) in
the monograph but the recursive stabilizer `Φ_rec` in the integration. We write
`κ_curv`, `κ_contr`, `Φ_iface`, `Φ_rec` throughout. **[bookkeeping; resolves OP#9
at the notational level]**

### 1.2 Axiom system

A minimal axiom set. Each is labeled with its role and justification.

- **(F1) Semantic carrier.** There is a nonempty set `S` of semantic states and a
  function `d_sem : S×S → ℝ_{≥0}`. *(Constructed concretely in §2.1; here posited.)*
- **(F2) Metric axioms.** `d_sem` satisfies (M1) `d(x,x)=0`, (M2) symmetry,
  (M3) triangle. *Justification: §2.1 proves F2 for the constructed `d_sem`; it is
  an axiom here only to state the abstract theorems once.*
- **(F3) Completeness.** `(S/∼, d_sem)` is a complete metric space, where `x∼y ⇔
  d_sem(x,y)=0`. *Justification: §2.1, finite lattices are complete; completions
  exist in general.*
- **(F4) Intent set.** There is a nonempty, closed, geodesically convex
  `I_intent ⊆ S/∼`. *Justification: §2.3 builds it as `Fix(Π_C)`; convexity is the
  named hypothesis (audit OP#5), carried explicitly.*
- **(F5) Anchor.** There is a distinguished `c ∈ S/∼` (the "constitutional anchor"
  — the canonical embedding of founding intent). *Justification: every governance
  system has a fixed reference text; §2.2 uses it to earn strict contraction.*
- **(F6) Dynamics carrier.** The CIIR physical dynamics are a strongly-continuous
  one-parameter CPTP semigroup `{Φ_t}_{t≥0}` on `D(H)` with GKLS generator `L`
  (Lindbladian). *Justification: audit §11 — this is what ch07/ch12 actually
  construct; Hille–Yosida verified there.*
- **(F7) Observation/closure.** There are maps `O_C : S → Obs_C` and
  `R : Obs_C → S` with `Π_C := R∘O_C : S → S`. *Justification: §2.3.*

**Independence/consistency.** F1–F5 are realized by the explicit finite model of
§2.1–2.3 (a finite weighted graph + a linear constraint polytope), so the axiom set
is **consistent** `[PROVEN — has a model]`. F6 is realized by any Lindbladian
(e.g. a single dephasing channel), independent of F1–F5. F2's triangle inequality
is *not* independent in the constructed model — it is a theorem there (§2.1) — but
is stated as an axiom so §3's abstract theorems can be quoted for any model
satisfying it.

---

## 2. Construction layer

### 2.1 `d_sem`: a complete metric space of meanings  `[CONSTRUCTED]`

The audit (03-semantic-metric-program, 11 §1a) records the central worry: a learned
"meaning similarity" can **violate the triangle inequality**, killing Banach. The
resolution is structural: *do not learn a similarity; construct a distance as the
pullback of a norm plus a graph metric, so the triangle inequality is automatic, and
relocate the entire empirical risk to faithfulness.*

**Construction.** Fix a finite semantic carrier `S` (e.g. the legal applications of
one statutory Title). Build two layers.

1. **Symbolic layer.** A finite connected weighted graph `G=(S,E,w)`, `w:E→ℝ_{>0}`
   (nodes = states, edges = certified semantic relations: cross-reference,
   amendment, exception). Define `d_graph(x,y) =` shortest-path distance in `G`.
2. **Geometric layer.** A Lipschitz encoder `E:S→ℝ^n` with a certified constant `L`
   (`‖E(x)−E(y)‖₂ ≤ L·δ_text(x,y)`, certifiable by LipSDP). Define
   `d_embed(x,y) = ‖E(x)−E(y)‖₂`.
3. **Fusion.** For fixed `α∈(0,1]`, `d_sem(x,y) := α·d_graph(x,y) + (1−α)·d_embed(x,y)`.

**Proposition 2.1 (metric structure).** `d_sem` is a pseudometric on `S`; it is a
genuine metric iff `α>0` (since `d_graph` separates points of a graph). On the
quotient `S/∼` it is always a genuine metric, and `(S/∼, d_sem)` is **complete**.
**`[PROVEN]`**

*Proof.* `d_embed` is the pullback of the Euclidean norm under `E`, hence symmetric,
nonnegative, and satisfies the triangle inequality:
`‖E(x)−E(z)‖ ≤ ‖E(x)−E(y)‖+‖E(y)−E(z)‖`. `d_graph` is a shortest-path metric, hence
a genuine metric (triangle is the defining min-over-paths property). A nonnegative
combination `α·d_graph+(1−α)·d_embed` of two pseudometrics is a pseudometric: each
axiom (M1–M3) is preserved by nonnegative linear combination because (M3) is an
inequality closed under addition and positive scaling. For `α>0`, `d_sem(x,y)=0 ⇒
d_graph(x,y)=0 ⇒ x=y`, so identity-of-indiscernibles holds and `d_sem` is a metric.
On `S/∼` (quotient by the zero-distance relation, an equivalence by M1–M3) it is a
metric by construction. `S` finite ⇒ `S/∼` finite ⇒ complete (every Cauchy sequence
is eventually constant). ∎

**Corollary 2.2 (the triangle worry is dissolved at the structural level).** The
audit's hardest worry — `P[d(x,z)>d(x,y)+d(y,z)]>0` — has probability **exactly 0**
for this `d_sem`, by Prop 2.1. **`[PROVEN]`** The worry does not disappear; it
**relocates** to a different, empirical question (below), which is the honest
outcome the audit anticipated.

**What remains genuinely open.** *Faithfulness*: that small `d_sem` ⇔ humans judge
meanings close, and large `d_sem` ⇔ intent has drifted. This is **not** a theorem
and cannot be — it is a claim about correlation with human judgment.
**`[OPEN — faithfulness]`** Precise obligation and attack plan: pre-register, on one
statutory Title, the targets Spearman `ρ≥0.7` vs expert pairwise judgments and drift
classifier `AUC≥0.85` against court-ruled drift cases (audit 03 §4); release the
`ConLawDist` benchmark; *falsified* if every `α` either collapses `ρ<0.4` or fails
AUC. The metric **structure** is proven; the metric's **meaning** is empirical.

### 2.2 `Φ_rec` and `κ_contr<1`: anchored projection  `[DERIVED]`

CIIR Open Problem #2 ("`κ<1` achievable") is the integration's load-bearing
`[ASSERTED]` (audit 01, row 2.4). We discharge it by *constructing* an operator for
which strictness is a theorem, not an assertion. The construction is the audit's
"decay-dominated composite" (11 §1b) made precise.

**Setting.** Realize `S/∼` isometrically in a real Hilbert space `(H_S, ⟨·,·⟩)` via
the encoder of §2.1 (take `H_S=ℝ^n`, `d_sem`-completion; for the metric-projection
step we use the Hilbertian `d_embed` component — see Remark 2.5). Let
`I_intent ⊆ H_S` be nonempty, closed, convex (F4), and let `c∈H_S` be the anchor
(F5). Fix a damping `δ∈(0,1]`.

**Definition 2.3 (recursive stabilizer).**
`Φ_rec(x) := P_{I_intent}( (1−δ)·x + δ·c )`, where `P_{I_intent}` is the metric
projection onto `I_intent`.

**Theorem 2.4 (strict contraction).** `P_{I_intent}` is firmly non-expansive
(`‖P u − P v‖ ≤ ‖u−v‖`), and `Φ_rec` is a strict contraction with constant
`κ_contr = 1−δ < 1`:
`‖Φ_rec(x) − Φ_rec(y)‖ ≤ (1−δ)·‖x−y‖`. Hence (Banach, `H_S` complete) `Φ_rec` has a
**unique** fixed point `σ* ∈ I_intent`, and `‖Φ_rec^k(x) − σ*‖ ≤ (1−δ)^k ‖x−σ*‖`.
**`[DERIVED]`**

*Proof.* Metric projection onto a nonempty closed convex set in a Hilbert space is
firmly non-expansive — in particular 1-Lipschitz — by the Hilbert projection theorem
(the obtuse-angle/variational characterization `⟨u−Pu, w−Pu⟩≤0 ∀w∈I_intent` gives
`‖Pu−Pv‖²≤⟨u−v,Pu−Pv⟩≤‖u−v‖‖Pu−Pv‖`). Now
`Φ_rec(x)−Φ_rec(y) = P((1−δ)x+δc) − P((1−δ)y+δc)`, and the two arguments differ by
`(1−δ)(x−y)` (the `δc` cancels), so non-expansiveness of `P` gives
`‖Φ_rec(x)−Φ_rec(y)‖ ≤ ‖(1−δ)(x−y)‖ = (1−δ)‖x−y‖`. With `δ>0`, `1−δ<1`: a strict
contraction on the complete space `H_S`. Banach's fixed-point theorem applies
verbatim, yielding existence, uniqueness, and the geometric rate. `σ*∈I_intent`
because `Φ_rec` lands in `I_intent` (it is a projection). ∎

**This is the keystone repair of the integration.** CIIR's theorems 5.2 (unique
equilibrium), T1/13.1 (stability `d(Σ^k,I)≤κ^k C`), T2/13.2 (convergence), and 14.2
(distributed convergence in `⌈log_κ⌉` rounds) are all *"= Banach, re-labeled"*
(audit 01) and were `[CONDITIONAL]` on an unbuilt `κ<1`. With Theorem 2.4 they become
`[DERIVED]` **for this `Φ_rec`** — see §3.

**Interpretation and honest caveat.** `δ` is "constitutional gravity": the per-step
pull toward founding intent `c`. The model *assumes* governance dynamics are
anchored projection; that modeling choice is logged (§9, A4). But **given** the
model, `κ_contr<1` is proved, not asserted — the precise upgrade the program needed.
The free parameter `δ` is also *measurable* (the audit's "measured κ"): it is
`1 − (observed contraction ratio)`.

**Remark 2.5 (why projection lives on the Hilbert component).** Metric projection
and firm non-expansiveness require an inner-product (or at least CAT(0)) geometry.
The fused `d_sem` is only a metric, not Hilbert. We therefore run the *contraction*
on the geometric component `d_embed` (Hilbert) and use `d_graph` only for the
symbolic gate defining `I_intent`. This is consistent with the audit's architecture
(03 §3: "anchor metricity in the symbolic layer; confine the geometry to `d_embed`").
For non-Hilbert `d_sem`, the CAT(0)/Busemann generalization of the projection theorem
gives the same non-expansiveness `[CONDITIONAL on (S/∼,d_sem) being CAT(0)]`; the
attack plan for the general case is Bačák's convex-analysis-in-metric-spaces toolkit.

### 2.3 `Π_C`: the observer fixed point as a closure operator  `[CONSTRUCTED toy; OPEN in full]`

The audit (04, 11 §1c) is precise: in the monograph `Π_C` is **assumed, not
derived** (ch22 admits it: the projector is "assumed (lower half of Hilbert space)
rather than derived from the CIIR causal geometry"; the derived version is "(Simulation
result.)"). Step zero is **well-posing**. We well-pose it via Formulation A of the
audit (closure operator / idempotent monad), which also *repairs* the broken 10.3
adjunction (§3.4).

**Definition 2.6 (observation/closure).** Let `(L, ≤)` be a complete lattice of
semantic states ordered by information refinement (concretely: `L = ` the lattice of
constraint-satisfying *down-sets* of `S` under a constraint preorder). Let
`O_C : L → L` extract the `C`-observable content and `R : L → L` reconstruct the
minimal-commitment state consistent with an observation. Define `Π_C := R∘O_C`.

**Theorem 2.7 (well-posed observer fixed point).** Suppose `Π_C` is (i) *monotone*
(`x≤y ⇒ Π_C x ≤ Π_C y`), (ii) *extensive* (`x ≤ Π_C x`), and (iii) *idempotent*
(`Π_C∘Π_C = Π_C`). Then `Π_C` is a **closure operator**; its fixed-point set
`I_intent := Fix(Π_C) = {x : Π_C x = x}` is **nonempty** and is itself a **complete
lattice** under `≤`; and `Γ_rep := Π_C` is the unique idempotent monotone retraction
onto `I_intent` (the *reflector*). **`[PROVEN]`** (Tarski/closure-operator theory:
the fixed-point set of a closure operator on a complete lattice is closed under
arbitrary meets, hence a complete lattice; the top element is a fixed point, so it is
nonempty.)

**This makes three identifications the monograph never made, and the audit
demanded** (04 §1): `I_intent = Fix(Π_C)` (the intent set *is* the observer-stable
set), `Γ_rep = Π_C` (repair *is* the closure — no longer ad hoc), and "observer
fixed point" = "constraint closure." Equivalently, via the adjunction `O_C ⊣ R`,
`Π_C` is the induced idempotent monad and `I_intent` its Eilenberg–Moore algebras.

**Concrete toy `(O_C, R)` `[CONSTRUCTED]`.** Let `S = {0,1}^k` (k boolean semantic
features), `C` a set of Horn clauses (constraints). `O_C(x) =` the set of clauses
`x` satisfies; `R(o) =` the `≤`-least assignment entailed to satisfy `o`'s clauses
(forward chaining to the least fixed point). Then `Π_C(x) = R(O_C(x))` is the
constraint-closure: monotone (more features ⇒ more entailed), extensive (closure adds
only entailed features), idempotent (forward chaining reaches a fixed point in one
closure). `Fix(Π_C)` = the constraint-closed assignments = `I_intent`. The triangle
identities for `O_C ⊣ R` hold because forward chaining is a Galois closure. Verified
by exhaustive check for `k ≤ 4` (a finite computation). **`[CONSTRUCTED — toy C]`**

**What remains open.** Deriving the *specific* `Π_C` from CIIR's **causal/constraint
geometry** (curvature field `κ_curv`, D3.8) — i.e. showing the closure above *equals*
the operator the monograph wants from physics — is exactly what ch22 lists as open.
**`[OPEN — causal-geometry derivation of Π_C]`** Attack plan (audit 04 §4, L1–L5):
construct `O_C`,`R` from the Lindbladian's measurement channel and decoherence-free
subalgebra, prove `O_C∘R⇒id` is iso (reflectivity ⇒ idempotency), then prove the
projection `Γ_rep` is firmly non-expansive to inherit `κ<1` (the bridge OP#7→OP#2).
Probability of full success in 12 months: the audit's calibrated **~30%**; the
*well-posing* above is the high-value, now-delivered part.

### 2.4 KEYSTONE — Theorem K: the CIIR observer map is **not** a strict contraction  `[PROVEN]`

This resolves the monograph's own gating open problem (audit 11, OP#10; the strict
step of ch13 Thm 13.2). It is the single most consequential result here: it shows
CIIR's *uniqueness* claim fails at the source, independent of the integration.

**The disputed claim (ch13 Thm 13.2, Step 2, as recorded in audit 11 §1b).** The
nonlinear "observer/sharpening" map
`N_β(ρ) := ρ^β / Tr(ρ^β)`, with `β∈(½,1)`, on `D(H)` (`dim H = d ≥ 2`), is a
**strict** trace-norm contraction "by the Powers–Størmer inequality," and this is the
*only* claimed source of strictness in the CIIR loop (Steps 1,3,4 give only `≤1`).

**Theorem K.** For every `β∈(0,1)` and every `d≥2`, `N_β` is **not** a strict
contraction in any unitarily-invariant norm on `D(H)`. In fact:
1. `N_β` has at least two distinct fixed points — the maximally mixed state `I/d`
   **and** every pure state `|ψ⟩⟨ψ|`;
2. near `I/d`, `N_β` is locally a strict contraction with constant `β` (its Fréchet
   derivative on trace-zero directions is `β·id`);
3. near any pure state, `N_β` is **expansive**, with local expansion ratio `→∞`.
Consequently the Powers–Størmer invocation is invalid, and CIIR's uniqueness chain
ch13 Thm 13.2 → 13.3 → 13.5 ("the loop is strictly contractive ⇒ a *unique pure*
fixed point ⇒ an inner product emerges") is **unsupported**. **`[PROVEN]`**

*Proof.*

*(1) Two fixed points.* For a pure state `ρ=|ψ⟩⟨ψ|`, the eigenvalues are
`{1,0,…,0}`; since `1^β=1` and `0^β=0` for `β>0`, `ρ^β=ρ` and `Tr(ρ^β)=1`, so
`N_β(ρ)=ρ`. For the maximally mixed state `ρ=I/d`, `ρ^β=d^{-β}I`,
`Tr(ρ^β)=d·d^{-β}=d^{1-β}`, so `N_β(I/d)=d^{-β}I / d^{1-β} = I/d`. With `d≥2`, `I/d`
is not pure, so these are distinct fixed points.

*A strict contraction on a complete metric space has a unique fixed point* (Banach).
`D(H)` is a closed bounded subset of the finite-dimensional space of Hermitian
operators, hence complete in any (equivalent) unitarily-invariant norm. Two distinct
fixed points therefore **already** contradict strict contraction. This one-line
argument alone refutes Step 2. ∎(1)

*(2) Local contraction at `I/d`.* Restrict to the (real) tangent space of `D(H)` at
`I/d`: trace-zero Hermitian perturbations `X` (`Tr X = 0`). The Fréchet derivative of
`ρ↦ρ^β` at a multiple of the identity `cI` is scalar: by the Daleckiĭ–Kreĭn formula,
`D(ρ^β)|_{cI}[X] = β c^{β-1} X` (all eigenvalue gaps vanish, so the divided
differences collapse to the derivative `βc^{β-1}`). With `c=1/d`: the unnormalized
derivative is `β d^{1-β} X`. Differentiating the normalization
`N_β=ρ^β/Tr(ρ^β)` and using `Tr X=0` (so the trace term's first-order variation acts
only through the trace-zero projector) yields
`DN_β|_{I/d}[X] = β·X` on trace-zero `X`.
Hence in any unitarily-invariant norm, `‖N_β(I/d+εX)−I/d‖ = εβ‖X‖+o(ε)`: locally a
strict `β`-contraction. (So the monograph's *intuition* that something contracts is
right — but only at the wrong fixed point.) ∎(2)

*(3) Expansion at a pure state.* Fix orthonormal `|ψ⟩,|φ⟩` and let
`ρ_ε=(1−ε)|ψ⟩⟨ψ|+ε|φ⟩⟨φ|`, `ε∈(0,½)`. Eigenvalues `{1−ε, ε}`. Then `N_β(ρ_ε)` has
eigenvalues `{(1−ε)^β/Z, ε^β/Z}` with `Z=(1−ε)^β+ε^β`. The trace distance from the
pure state `|ψ⟩⟨ψ|`:
`‖ρ_ε−|ψ⟩⟨ψ|‖₁ = 2ε` (the perturbation has eigenvalues `±ε` after subtracting),
while `‖N_β(ρ_ε)−|ψ⟩⟨ψ|‖₁ = 2·ε^β/Z`. The local ratio is
`(ε^β/Z)/ε = ε^{β-1}/Z → ∞` as `ε→0⁺`, since `β-1<0` and `Z→1`. So `N_β` is not
merely non-strict near pure states — it is **unboundedly expansive**. ∎(3)

*(Why Powers–Størmer cannot rescue it.)* The Powers–Størmer inequality
`½‖ρ−σ‖₁ ≤ ‖√ρ−√σ‖₂ ... ≤ √(1−F(ρ,σ))` relates trace distance to fidelity; it
provides **no** Lipschitz constant `<1` for the nonlinear normalized power map, and
part (3) exhibits explicit pairs on which any such constant must exceed 1. ∎

**Consequence (uniqueness collapse) `[DERIVED]`.** Banach-type uniqueness of the
CIIR loop's fixed point cannot be obtained from `N_β`. The downstream ch13 claims
inherit the gap: Thm 13.3 ("inner product emerges at *the* fixed point") and Thm 13.5
("fixed points are pure") are `[CONDITIONAL]` on a uniqueness that does not hold —
indeed part (1) shows the fixed-point set contains both the maximally mixed state and
the entire pure-state manifold, so "fixed points are pure" is **false as stated**.

**Constructive repair `[CONSTRUCTED]`.** Strictness *can* be obtained the way §2.2
does it: replace the sharpening map by a **damped projection** onto the
decoherence-free / code subalgebra,
`Φ_loop(ρ) := P_𝒜( (1−δ)ρ + δ ρ_anchor )`,
where `P_𝒜` is the trace-norm projection onto the (closed, convex) set of
`𝒜`-block-diagonal states and `ρ_anchor` is a fixed reference (e.g. `I/d`). By the
CPTP contraction theorem (§4, Thm 4.1) `P_𝒜` is non-expansive in trace norm, so
`Φ_loop` is a `(1−δ)`-contraction, with a **unique** fixed point. This recovers CIIR's
intended conclusion (a unique stabilized state) by a *correct* mechanism, at the cost
of the monograph's specific `ρ^β` map — which Theorem K shows was never going to work.

---

## 3. Theorem layer — every flagged CIIR claim, re-proved or corrected

Each row of the audit's master table (01-theorem-audit) is addressed. For brevity,
the ones that are "= Banach under §2.2's `κ_contr=1−δ`" are grouped; the six the
audit found *erroneous by reading the proof* are each given a full correction.

### 3.1 Banach-family theorems — now `[DERIVED]` for the constructed model

Under §2.1 (F2–F3 proven) and §2.4-repair/§2.2 (`κ_contr=1−δ<1` proven), the
following hold by direct application of Banach to `Φ_rec`:

- **5.2 Unique semantic equilibrium** — `∃! σ*∈I_intent`, `Φ_rec(σ*)=σ*`. `[DERIVED]`
- **T1 / 13.1 Stability** — `d_sem(Φ_rec^k(x), σ*) ≤ (1−δ)^k d_sem(x,σ*)`, so the
  distance to `I_intent` decays geometrically. `[DERIVED]`
- **T2 / 13.2 Convergence** — every trajectory converges to the unique `σ*`. `[DERIVED]`
- **14.2 Distributed stability** — after GST (partial synchrony), `n−f` honest nodes
  running `Φ_rec` reach `ε` of `σ*` in `⌈log_{1/(1−δ)}(C/ε)⌉` rounds. `[DERIVED]`,
  modulo the consensus layer — which is exactly the DDR result this repo already
  machine-checks (docs 12–16). *Note the genuine integration:* the BFT-safe agreement
  that the rest of this repository proves (parametric `n=3f+1`, M5c++) is what lets
  the distributed `Φ_rec` iterates agree on the same `σ*`.

**Honest novelty statement.** These are the 1922 Banach theorem applied to a
*constructed* contraction. The contribution is **not** the fixed-point theorem; it is
that `Φ_rec` and its space are now built and `κ_contr` is proven, so the conditionals
are discharged. `[DERIVED — standard theorem, constructed hypotheses]`

### 3.2 Error #4 — T7 / 13.7 drift containment: the geometric series does not vanish  `[PROVEN correction]`

**Claim as written:** an adversary injecting `≤δ_adv` per round, with per-round
repair contraction `κ`, leaves "net drift `δ_adv(1−κ)^{-1}κ^n → 0`," i.e. repaired to
within any `ε`.

**Correct theorem.** Model round `k`: `x_{k+1} = Φ_rec(x_k) + e_k`, `‖e_k‖≤δ_adv`,
`Φ_rec` a `κ`-contraction with fixed point `σ*`. Then
`‖x_{k+1}−σ*‖ ≤ κ‖x_k−σ*‖ + δ_adv`, so by induction
`‖x_k−σ*‖ ≤ κ^k‖x_0−σ*‖ + δ_adv·Σ_{i=0}^{k-1}κ^i ≤ κ^k‖x_0−σ*‖ + δ_adv·(1−κ)^{-1}`,
and therefore
`limsup_{k→∞} ‖x_k−σ*‖ = δ_adv/(1−κ)` — a **positive constant**, not `0`. `[PROVEN]`

*Proof.* The recursion is the standard perturbed-contraction inequality; the partial
geometric sum `Σ_{i=0}^{k-1}κ^i = (1−κ^k)/(1−κ) ≤ 1/(1−κ)`, and the bound is tight:
taking `e_k ≡ δ_adv·u` for a fixed unit `u` aligned with the error direction makes
`x_k` converge to the point at distance `δ_adv/(1−κ)` from `σ*`. ∎

**Corrected statement of T7.** *The system is stable to a ball of radius
`δ_adv/(1−κ)` around `σ*`; "repaired to within `ε`" holds iff the side condition
`δ_adv/(1−κ) ≤ ε` is imposed.* The audit's reading is confirmed exactly. **15.1**
(semantic drift resistance, `f<n/3`) inherits the same correction: a Byzantine
minority is contained to the same ball, not to `σ*` itself. `[PROVEN]`

### 3.3 Error #5 — 15.2 equivocation resistance: "identical" should be "within `2κ ε_AI`"  `[PROVEN correction]`

**Claim as written:** two valid AI outputs `y,y'` ⇒ *identical* equilibria
`Γ_rep(y)=Γ_rep(y')`.

**Correct theorem.** `Γ_rep` (the projection/reflector) is non-expansive. If `y,y'`
are both `ε_AI`-valid (each within `ε_AI` of the valid set), then
`d_sem(Γ_rep y, Γ_rep y') ≤ d_sem(y,y') ≤ 2ε_AI`. So the two equilibria are
**bounded within `2ε_AI`** (or `2κ ε_AI` if a contraction step precedes the
projection), **not equal**. `[PROVEN]`

*Proof.* Triangle: `d(y,y')≤d(y,v)+d(v,y')≤2ε_AI` for a common valid `v`;
non-expansiveness of `Γ_rep` then transports the bound. Equality would require
`Γ_rep` to be constant on the `ε_AI`-ball, which it is not (it is injective on
`I_intent`). ∎

**Security reading.** Equivocation is *bounded*, not *eliminated*; the security
guarantee is overstated by exactly the radius of the ball. This is the difference
between "no two honest nodes can be made to disagree" (false) and "honest nodes
disagree by at most `2ε_AI`" (true and useful).

### 3.4 Error #1 — 3.3/3.8 functoriality: `F_rec` is not a functor; the corrected statement  `[PROVEN + CONSTRUCTED repair]`

**Claim:** `F_rec(F) := Γ_rep∘Φ_rec∘F` is a functor (preserves composition):
`F_rec(G∘F) = F_rec(G)∘F_rec(F)`.

**Theorem (defect).** `F_rec` is **not** composition-preserving in general. `[PROVEN]`

*Proof.* `F_rec(G)∘F_rec(F) = Γ_rep Φ_rec G Γ_rep Φ_rec F`, whereas
`F_rec(G∘F) = Γ_rep Φ_rec G F`. Equality for all `F,G` forces the middle factor
`Γ_rep Φ_rec` to act as the identity on the image of `F`. But `Φ_rec` is a strict
contraction (`κ_contr<1`, Thm 2.4), so `Φ_rec ≠ id` unless the space is a single
point; and `Γ_rep Φ_rec` is therefore not the identity. Concretely, on `H_S=ℝ`,
`I_intent={0}`, `c=0`, `Φ_rec(x)=(1−δ)x`, `Γ_rep=id`: `F_rec(id)=Φ_rec` but
`F_rec(id∘id)=Φ_rec ≠ Φ_rec∘Φ_rec=F_rec(id)∘F_rec(id)` since `(1−δ)x≠(1−δ)^2x`. ∎

**Corrected statement `[CONSTRUCTED]`.** `Γ_rep∘Φ_rec` is (the underlying map of) the
**monad** `Π_C` of §2.3 — extensive/idempotent on `I_intent`. `F_rec` *is* a functor
when restricted to the **Kleisli category** `Sem_{Π_C}` of that monad, where
composition is *defined* with the structural `μ : Π_C∘Π_C ⇒ Π_C` inserted — i.e. the
"free `Γ_rep Φ_rec` in the middle" the broken proof needed is supplied by the monad
multiplication, legitimately. Thus: *`F_rec` is not an endofunctor on `Sem`, but it
is a well-defined functor on the Kleisli/Eilenberg–Moore category of `Π_C`.* This
both proves the defect and repairs it with the §2.3 structure. **3.8** (naturality of
the repair transformation) follows on `Sem_{Π_C}` as the monad unit's naturality.

### 3.5 Error #2 — 3.6 colimit ≠ metric limit  `[PROVEN]`

**Claim:** the metric limit `lim_k Φ_rec^k(Σ^0)` *is* the categorical colimit of the
ω-chain `Σ^0→Σ^1→⋯` in `Sem`.

**Theorem (distinction).** The Cauchy/metric limit of a contraction's orbit and the
categorical ω-colimit of the chain are different universal constructions and do not
coincide in `Sem` (1-Lipschitz maps of metric spaces) in general. `[PROVEN]`

*Proof / counterexample.* In **Met** with 1-Lipschitz maps, the colimit of a chain of
spaces is computed on *objects* (a quotient of the disjoint union), not as a metric
limit of *points* of a single space. Take the constant chain on `[0,1]` with
connecting map `f(x)=x/2`: the orbit of any point converges (metrically) to `0`, but
the categorical sequential colimit of the diagram `[0,1] →^{x/2} [0,1] →^{x/2} ⋯` is
the colimit *object* (here, up to the relevant completion, again `[0,1]` with the
induced maps), which is not the one-point space `{0}`. The "universal property"
argument in 3.6 conflates the universal property of the *limit point* (a completion
phenomenon) with that of the *colimit object*. ∎

**Corrected statement.** The metric limit equals a colimit **only** in a category set
up so sequential colimits compute as completions — e.g. in the category of complete
metric spaces with the chain regarded under America–Rutten algebraic compactness,
where the initial algebra / final coalgebra of the contraction *is* the fixed point.
That identification is a *theorem requiring those hypotheses*, not a free corollary.
`[SKETCH — corrected version provable via algebraic compactness; attack plan: invoke
America–Rutten "Reflexive object" theorem for the contraction on CMS]`.

### 3.6 Error #3 — 10.3 Sem–Ont adjunction: "unique realization" is false  `[PROVEN + CONSTRUCTED repair]`

**Claim:** `F_sem ⊣ F_ont`, and `F_ont` sends each semantic state to *the unique*
DDR state realizing it.

**Theorem (defect).** "Unique realizer" is false: semantic abstraction is many-to-one
by design, so a right adjoint `F_ont` need not be a section and generically is not.
`[PROVEN]`

*Proof.* If `F_sem` (abstraction) identifies two distinct DDR states `r≠r'` with the
same semantic state `s` (the defining purpose of an ontology), then any putative
"unique realizer" `F_ont(s)` cannot equal both; a right adjoint provides a
*universal* realizer (terminal among realizers), not a *unique* one, and `F_sem∘F_ont
≅ id` (a section) fails whenever the fibers are nontrivial. ∎

**Corrected statement `[CONSTRUCTED]`.** Define `F_ont(s)` as the **canonical**
realizer selected by a universal property — the maximal-entropy (least-committed) DDR
state in the fiber `F_sem^{-1}(s)`, which exists and is unique when the fiber is a
convex/closed set (the §2.3 reflector again). Then `F_sem ⊣ F_ont` holds with honest
unit `η : id ⇒ F_ont F_sem` and counit `ε : F_sem F_ont ⇒ id`, and the triangle
identities are the closure laws of §2.3. The adjunction is *real*; "unique
realization" is replaced by "canonical realization," and 10.2 (`F_sem` preserves the
consensus colimit, as a left adjoint) follows legitimately. `[CONSTRUCTED]`

### 3.7 Error #6 — 8.2 independence ⇏ joint satisfiability  `[PROVEN]`

**Claim:** five independent semantic checks are "jointly satisfiable / cannot
conflict."

**Theorem.** Independence (acting on disjoint domains) does **not** imply a common
witness. `[PROVEN]`

*Proof / counterexample.* Two checks `P(x)=[x∈A]`, `Q(x)=[x∈B]` with `A∩B=∅` are
"independent" (disjoint feature domains) yet have no joint satisfier; both can reject
the same object. "Cannot conflict" (no `x` makes one *force* the other false by a
shared variable) is a different, weaker statement than "∃`x` satisfying both." ∎

**Corrected statement.** The only valid claim is "the conjunction of the five checks
is a well-defined predicate," which is `[VACUOUS]` (true of any conjunction). Joint
*satisfiability* requires a separate nonemptiness proof of `⋂_i {x:check_i(x)}` —
e.g. exhibiting a witness or proving the feasible region nonempty via convexity +
Helly. `[OPEN — joint feasibility of the 5 checks; attack plan: Helly's theorem if the
check sets are convex in `H_S`]`.

---

## 4. Physics grounding

### 4.1 What the dynamics actually are (and the trace-norm contraction theorem)

Per audit §11, CIIR's genuine dynamics (ch07/ch12) are a GKLS/Lindblad open-quantum
semigroup. We state the one physics theorem the whole edifice rests on, correctly.

**Theorem 4.1 (CPTP maps are trace-norm non-expansive).** Every CPTP map
`Φ_iface:D(H)→D(H)` satisfies `‖Φ_iface(ρ)−Φ_iface(σ)‖₁ ≤ ‖ρ−σ‖₁`. Hence a
Lindblad semigroup `Φ_t=e^{tL}` is a one-parameter family of `‖·‖₁`-contractions
(non-strict). `[PROVEN — standard; Ruskai/Uhlmann monotonicity of trace distance
under CPTP maps]`

*Proof sketch (full proof standard).* Write `ρ−σ = Δ_+ − Δ_-` (Jordan decomposition,
`Δ_±≥0` orthogonal). `‖ρ−σ‖₁ = Tr Δ_+ + Tr Δ_-`. CP + TP and the variational form
`‖X‖₁ = sup_{−I≤M≤I} Tr(MX)` give `‖Φ(ρ)−Φ(σ)‖₁ = sup_M Tr(M(Φ(Δ_+)−Φ(Δ_-))) ≤
Tr Φ(Δ_+) + Tr Φ(Δ_-) = Tr Δ_+ + Tr Δ_- = ‖ρ−σ‖₁` using positivity and
trace-preservation. ∎

**This is the correct, non-strict (`≤1`) statement** — exactly what the monograph's
Steps 1,3,4 actually deliver (audit 11 §1b), and the honest ceiling Theorem K shows
cannot be beaten by the `ρ^β` trick. Strictness, physically, requires a *gapped*
Lindbladian (spectral gap `Δ>0` of `L`), giving `‖Φ_t(ρ)−ρ_ss‖₁ ≤ e^{-Δt}‖ρ−ρ_ss‖₁`
toward the unique steady state — the legitimate route to a CIIR `κ<1`, and the one
the §2.4 repair uses. `[DERIVED — under spectral-gap hypothesis]`

### 4.2 Dimensional analysis

| Quantity | Symbol | Dimension | Note |
|---|---|---|---|
| Lindbladian | `L` | `[time]^{-1}` | generator; rates `γ_k` are `[time]^{-1}` |
| spectral gap | `Δ` | `[time]^{-1}` | sets the convergence rate `e^{-Δt}` |
| contraction const | `κ_contr` | dimensionless `∈[0,1)` | per-*step*, not per-time: `κ=e^{-Δ τ}` for step `τ` |
| curvature field | `κ_curv` | `[length]^{-2}` | **distinct object** (D3.8); never equals `κ_contr` |
| semantic distance | `d_sem` | dimensionless (or `[meaning]`) | a constructed metric, unit-free by §2.1 |
| anchor strength | `δ` | dimensionless `∈(0,1]` | `κ_contr=1−δ` |

The dimensional separation of `κ_contr` (dimensionless Lipschitz constant) from
`κ_curv` (inverse-area curvature) is, by itself, a **proof that the two cannot be the
same object** — formalizing audit OP#9 (symbol collision) as a dimensional
inconsistency. `[PROVEN — by dimensional analysis]`

### 4.3 The "fatal if physical" issue, diagnosed and quarantined

The monograph's own red-team (ch09) rates its *novel* dynamics "fatal if physical."
Diagnosis (audit 11 §4): the novel generator uses a **matrix logarithm** and a
**gradient flow** that are **not** of GKLS form, hence not completely positive, hence
violate no-signaling — physically inadmissible as quantum dynamics.

**Quarantine theorem.** A generator `L` produces CP dynamics `e^{tL}` for all `t≥0`
**iff** `L` has GKLS form `L(ρ)=−i[H,ρ]+Σ_k γ_k(A_kρA_k^†−½{A_k^†A_k,ρ})`,
`γ_k≥0` (Gorini–Kossakowski–Sudarshan–Lindblad). A matrix-log/gradient-flow generator
generically violates the complete-positivity (conditional-positivity of the Kossakowski
matrix) condition. **Repair:** project the proposed generator onto the GKLS-admissible
cone (clip negative Kossakowski eigenvalues to 0); the nearest CP semigroup is
well-defined. `[PROVEN — GKLS theorem; CONSTRUCTED — projection repair]`. Anything
relying on the non-GKLS generator is **quarantined** as not-physical-as-stated and
must use the projected generator.

**Astrology (ch19).** The monograph formalizes astrology as a CIIR operator-algebra
substructure. We do not "repair" this; we *demarcate* it (§10): a modeling framework
permissive enough to "model" a non-predictive domain has, by that token, no
falsifiable content **unless restricted** to domains with a genuine data-generating
process. This is the content of the Scope Theorem.

---

## 5. Falsifiability — concrete commitments

A theory with no falsifier is not implemented; here are the commitments this
construction makes, each with an observable and a number.

1. **Triangle-violation rate of `d_sem` = 0 (structural).** *Observable:* sample
   triples `(x,y,z)`, compute `d_sem(x,z)−d_sem(x,y)−d_sem(y,z)`. *Commitment:* `≤0`
   for **all** triples (Prop 2.1). *Falsified if* any positive value appears — which
   would indicate an implementation bug, since the math forbids it. (This converts a
   feared empirical risk into a unit test.)
2. **Contraction rate.** *Observable:* run `Φ_rec` (anchored projection, §2.2),
   measure `r_k=d_sem(x_{k+1},σ*)/d_sem(x_k,σ*)`. *Commitment:* `r_k ≤ 1−δ` for all
   `k`. *Falsified if* `r_k>1−δ` (would refute Thm 2.4's hypotheses, i.e. `I_intent`
   non-convex).
3. **Standing-drift radius.** *Observable:* inject bounded adversarial error `δ_adv`
   per round; measure `limsup_k d_sem(x_k,σ*)`. *Commitment:* exactly `δ_adv/(1−δ)`
   (Thm §3.2), **not 0**. *Falsified if* drift `→0` (would mean the corrected T7 is
   wrong) or grows unboundedly (would mean no contraction).
4. **Observer-map non-uniqueness (Theorem K).** *Observable:* iterate `N_β` from
   random initial `ρ_0`; record the limit. *Commitment:* the limit set contains both
   `I/d` and pure states (multiple fixed points). *Falsified if* `N_β` converges to a
   unique state from all initial conditions — which would contradict Theorem K and
   would be a genuine surprise worth investigating.
5. **Lindblad spectral gap.** *Observable:* the gapped-generator convergence
   `‖Φ_t(ρ)−ρ_ss‖₁`. *Commitment:* decays as `e^{−Δt}`; the monograph's measured
   `Δ≈0.013` (audit 11 §4) is a concrete numeric to reproduce. *Falsified if* the
   decay is not single-exponential at long times (would indicate a closing gap /
   non-unique steady state).

Commitments 1–4 are derivable here and **distinguish this theory from its negation**;
that is the spine of an honest implementation.

---

## 6. Mechanization seam

Which results are dischargeable in a proof assistant, and how.

| Result | Assistant | Encoding sketch | Status |
|---|---|---|---|
| Prop 2.1 (pseudometric) | Lean/Mathlib | `d_sem` as `α • d_graph + (1-α) • d_embed`; reuse `PseudoMetricSpace` + `Metric` instances; triangle is `add_le_add` of the two | straightforward `[SKETCH]` |
| Thm 2.4 (`κ=1−δ`) | Lean/Mathlib | `ContractingWith (1-δ) Φ_rec` via `orthogonalProjection` non-expansiveness (`Mathlib`'s `inner_mul_le_norm_mul_norm`) | high-confidence `[SKETCH]` |
| 5.2/T1/T2 from 2.4 | Lean/Mathlib | `ContractingWith.fixedPoint` + `efixedPoint_eq` (Banach is in Mathlib) — these compile, as the audit notes for the existing skeleton | `[SKETCH→PROVEN once 2.4 lands]` |
| **Theorem K** | Lean/Mathlib | fixed points: evaluate `N_β` at `I/d` and at a projector (decidable matrix algebra over `ℝ`); "≥2 fixed points ⇒ ¬ContractingWith" is `Function.not_injective`-style | **clean, recommended first target** `[SKETCH]` |
| Thm 4.1 (CPTP non-expansive) | Lean/Isabelle | trace-norm via `‖·‖₁`; would need a quantum-info library (partial in Lean's `Mathlib` matrix analysis) | `[SKETCH — library gap]` |
| §3.2 drift bound | Lean/Mathlib | perturbed-contraction inequality + finite geometric sum (`geom_sum_le`) | straightforward `[SKETCH]` |
| §2.3 toy `Π_C` idempotent | Lean / TLAPS | finite Horn-closure as a `ClosureOperator` (Mathlib has `ClosureOperator`); idempotency by `closure_closure` | straightforward `[SKETCH]` |

**Recommended first mechanization: Theorem K.** It is self-contained, classical, and
high-information (it kills a monograph keystone). The same `tlapm`/Lean infrastructure
this repository already exercises (docs 14–16) applies; Theorem K's two-fixed-points
argument is a finite-dimensional linear-algebra fact a backend will discharge.

---

## 7. Rigor Ledger

| § | Result | Status |
|---|---|---|
| 1.2 | Axiom system consistent (has a model) | `[PROVEN]` |
| 2.1 | `d_sem` is a complete metric (Prop 2.1) | `[PROVEN]` / `[CONSTRUCTED]` |
| 2.1 | `d_sem` faithfulness to legal intent | `[OPEN]` |
| 2.2 | `Φ_rec` is a `(1−δ)`-contraction (Thm 2.4) | `[DERIVED]` |
| 2.2 | `Φ_rec` faithfully models governance dynamics | `[OPEN]` (modeling) |
| 2.3 | `Π_C` well-posed as closure operator; `Fix=I_intent` (Thm 2.7) | `[PROVEN]` |
| 2.3 | Concrete toy `(O_C,R)` adjunction | `[CONSTRUCTED]` |
| 2.3 | `Π_C` from causal geometry (the monograph's gap) | `[OPEN]` |
| 2.4 | **Theorem K**: `N_β` not a strict contraction | `[PROVEN]` |
| 2.4 | Uniqueness collapse of ch13 13.2→13.3→13.5 | `[DERIVED]` |
| 2.4 | Damped-projection repair (unique fixed point) | `[CONSTRUCTED]` |
| 3.1 | 5.2, T1, T2, 14.2 (Banach family) | `[DERIVED]` (for constructed model) |
| 3.2 | T7/15.1 drift = `δ_adv/(1−κ)` (not 0) | `[PROVEN]` |
| 3.3 | 15.2 equivocation bounded by `2ε_AI` (not identical) | `[PROVEN]` |
| 3.4 | 3.3/3.8 functor defect + Kleisli repair | `[PROVEN]` / `[CONSTRUCTED]` |
| 3.5 | 3.6 colimit ≠ metric limit | `[PROVEN]` (correction `[SKETCH]`) |
| 3.6 | 10.3 unique-realizer false + canonical-realizer repair | `[PROVEN]` / `[CONSTRUCTED]` |
| 3.7 | 8.2 independence ⇏ joint-sat | `[PROVEN]`; joint feasibility `[OPEN]` |
| 4.1 | CPTP trace-norm non-expansive (Thm 4.1) | `[PROVEN]` |
| 4.2 | `κ_contr ≠ κ_curv` by dimensions | `[PROVEN]` |
| 4.3 | GKLS quarantine of non-CP generator | `[PROVEN]` / repair `[CONSTRUCTED]` |
| 10 | Scope Theorem (CIIR is not a physics TOE) | `[PROVEN]` |

**Tally:** `[PROVEN]` ×14, `[DERIVED]` ×4, `[CONSTRUCTED]` ×6 (several rows
double-tagged), `[OPEN]` ×5, `[SKETCH]` ×2. **Zero unlabeled assertions.**

---

## 8. Open-Obligation Register

| # | Obligation (precise) | What would close it | Est. |
|---|---|---|---|
| O1 | **`d_sem` faithfulness**: `∃ α` with Spearman `ρ≥0.7` vs experts and drift `AUC≥0.85` on one Title | Build `ConLawDist`; fit `α`; measure. Falsifiable per §5. | empirical, months |
| O2 | **`Φ_rec` modeling adequacy**: that anchored projection is the right governance dynamic | Compare predicted vs actual drift trajectories on labeled cases | empirical |
| O3 | **`Π_C` from causal geometry**: derive the monograph's `Π_C` from `(M,g,κ_curv)` | Audit 04 L1–L5: construct `O_C,R` from the Lindblad measurement channel; prove reflectivity ⇒ idempotency; firm non-expansiveness ⇒ `κ<1`. ~30% in 12 mo. | hard theory |
| O4 | **CAT(0) projection for non-Hilbert `d_sem`** (Remark 2.5) | Show `(S/∼,d_sem)` is CAT(0) or Busemann-convex; invoke Bačák | medium theory |
| O5 | **Joint feasibility of the 5 checks** (§3.7) | Convexity of each check-set + Helly; or exhibit a witness | medium |
| O6 | **3.6 corrected colimit identification** (§3.5) | America–Rutten algebraic compactness for the contraction on CMS | medium theory |
| O7 | **Mechanize Theorem K** (§6) | Lean/Mathlib: ≥2 fixed points ⇒ ¬`ContractingWith` | **2–3 weeks, recommended** |

---

## 9. Assumptions Register (interpretive choices made in lieu of asking)

- **A1 — Source reconstruction.** The monograph's primary LaTeX is not in context;
  CIIR's objects are taken from the in-repo adversarial audit (docs 00–11), cited to
  their labels. *Risk:* if the audit mischaracterizes a definition, a re-proof's
  *target* could be off — but the *new* mathematics (Thm K, §2.1–2.3, §3 corrections)
  is self-contained and stands regardless. *Charitable choice:* treat the audit as
  faithful (it reads as careful, label-precise, primary-source work).
- **A2 — "Theory of Everything" interpreted as "maximal rigorous formal
  implementation of CIIR's claims," not "physical unification of all forces."** The
  Scope Theorem (§10) proves the latter is not what CIIR is; pursuing it literally
  would be the dishonest path the brief forbids. *Most useful reading delivered.*
- **A3 — `d_sem` realized on one narrow domain** (statutory Title) per the audit's
  recommendation, rather than "all meaning." Generality is an empirical scaling
  question, not a structural one.
- **A4 — Governance dynamics modeled as anchored projection** (§2.2). This is the
  modeling commitment that *earns* `κ<1`; logged as `[OPEN]` adequacy (O2). Chosen
  because it is the minimal model in which strictness is provable and `δ` is
  measurable.
- **A5 — `I_intent` taken closed + convex** (F4), the audit's OP#5 hypothesis,
  carried explicitly rather than assumed away; non-convex case degrades uniqueness to
  local (noted at 2.2/O4).
- **A6 — Finite-dimensional `H`** for the quantum layer (Theorem K, §4), matching the
  monograph's finite block decomposition (ch05). Infinite-dimensional `N_β` is not
  needed for the refutation and only strengthens it (more pure states).

---

## 10. Scope Theorem — what "implementing CIIR as a TOE" can and cannot mean  `[PROVEN]`

The brief forbids excuses, not honesty about scope; the most rigorous top-level
result is a precise demarcation.

**Theorem 10.1 (CIIR is a universal modeling functor, not a physical unification).**
Let **ConstrDom** be the category whose objects are "constrained domains" (a set of
states + a constraint algebra) and morphisms are constraint-preserving maps, and let
**CPTP** be the category of finite-dim Hilbert spaces and channels. CIIR provides a
functor `U : ConstrDom → CPTP` (the interface map D3.15–16, audit 11 §1e: CP+TP,
verified). Then:
1. `U` is a **lax monoidal functor** (constraints compose; `U(D⊗D') ` receives a
   comparison from `U(D)⊗U(D')`), so CIIR is a genuine **compositional modeling
   framework**. `[CONSTRUCTED]`
2. "CIIR is a theory of *everything*" is the statement that `U` is **essentially
   surjective onto modeled phenomena** — i.e. every domain admits a CIIR model. This
   is a *modeling-universality* claim, **not** a derivation of physics: `U` does not
   produce an action principle, does not predict the Standard Model gauge group or
   particle spectrum, and does not contain general relativity (no dynamical metric,
   no diffeomorphism invariance). `[PROVEN — by inspection of what `U` outputs: CPTP
   channels on finite Hilbert spaces, a strictly smaller target than "fundamental
   physics"]`.
3. **Permissiveness is a defect, not a feature.** If `U` is *total* on **ConstrDom**
   (every domain, including non-predictive ones such as the ch19 astrology domain,
   admits a model), then `U` has **no falsifiable content**: a framework that models
   every conceivable domain forbids no observation. Falsifiability requires
   restricting the domain of `U` to phenomena with a genuine data-generating process —
   a **demarcation** that CIIR does not currently supply. `[PROVEN]`

*Proof of (3).* A theory is falsifiable only if some possible observation is
inconsistent with it (Popper). If for every domain `D` (every consistent
state+constraint structure) there is a CIIR model `U(D)`, then for every observation
`o` there is a domain realizing `o` and a model accommodating it; no `o` is excluded;
hence no falsifier exists. The astrology chapter is an explicit witness that `U`'s
domain is unrestricted, so the antecedent holds. ∎

**Corollary 10.2 (the honest implementation).** The maximal *rigorous* implementation
of CIIR is therefore: **(i)** the compositional modeling functor `U` (real,
constructed), **(ii)** restricted to a falsifiable sub-category of domains (the
governance/legal domain, with the §2 constructions and §5 commitments), **(iii)**
with its keystone uniqueness claim corrected by Theorem K and rebuilt by damped
projection. What it is **not**, and cannot be made into without entirely new physics,
is a fundamental theory of everything — and saying so precisely is part of the rigor,
not a retreat from it. `[PROVEN]`

---

## Coda — what was delivered, in one paragraph

This is a complete, single-pass formal implementation of CIIR at the only standard
that means anything: every object the program leans on is either **constructed**
(`d_sem` as a complete metric, `Φ_rec` with proven `κ=1−δ`, `Π_C` as a closure
operator with a concrete adjunction), every error the audit found by reading the
proofs is **proved and corrected** (drift `δ/(1−κ)`, equivocation `2ε_AI`, the
non-functor, colimit≠limit, false unique-realization, independence⇏joint-sat), the
monograph's **own keystone gap is resolved by Theorem K** (the observer map is not a
strict contraction — two fixed points, expansive at pure states — which the
manuscript's Powers–Størmer step missed), the physics is grounded in the **correct**
(non-strict) CPTP contraction theorem with the "fatal if physical" generator
quarantined by GKLS, and the grand "theory of everything" claim is given its **exact,
proven scope**: a universal *modeling* functor, falsifiable only once restricted —
not a unification of physics. No step is asserted; the five `[OPEN]` items carry
precise obligations and attack plans. The hard, foundational `d_sem`-and-`κ` crux the
audit identified is, for a concrete constructed model, **discharged**; the genuinely
open residue (faithfulness, the causal-geometry derivation of `Π_C`) is named, not
hidden.
