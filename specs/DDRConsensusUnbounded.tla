----------------------- MODULE DDRConsensusUnbounded -----------------------
(***************************************************************************)
(* UNBOUNDED-ROUNDS inductive-step discharge (Apalache, SMT).              *)
(*                                                                          *)
(* The MaxRound-bounded proof (DDRConsensusApa.tla) fixes a finite round    *)
(* horizon: vote rounds live in 0..MaxRound, so BOTH the magnitude of round *)
(* numbers AND the cardinality of the vote configuration are bounded        *)
(* together. This module DECOUPLES them. Here:                              *)
(*                                                                          *)
(*   * round numbers are FREE INTEGERS (`Int`), of arbitrary magnitude and  *)
(*     not required to be contiguous — there is no MaxRound anywhere;        *)
(*   * only the CARDINALITY of the vote configuration is bounded, via       *)
(*     Apalache's `Gen` (a symbolic generator of bounded-size structures).  *)
(*                                                                          *)
(* The inductive step `IndInv /\ Next => IndInv'` is then discharged from an *)
(* ARBITRARY IndInv-state whose round numbers are unconstrained integers.   *)
(* This is what "unbounded rounds" means operationally: the SMT solver is   *)
(* free to pick rounds 0, 1, 2, ... or 5, 1000, 7_000_000 — contiguous or   *)
(* not — and must still preserve every conjunct across one DoRound. Passing *)
(* establishes the step is independent of round MAGNITUDE.                  *)
(*                                                                          *)
(* The residual bound (vote-set cardinality, set by `Bound`) is discussed   *)
(* in docs/audit/15-unbounded-rounds-verification.md: the inductive step is *)
(* LOCAL — each conjunct references at most a constant number of polkas     *)
(* (q votes each), so a configuration large enough to hold the polkas the   *)
(* argument compares is sufficient. Round-homogeneity (also argued there)   *)
(* lifts this to genuinely unbounded behaviour.                             *)
(*                                                                          *)
(* The lock rule is hard-wired ON (we only mechanize the safe variant).     *)
(***************************************************************************)
EXTENDS Integers, FiniteSets, Apalache

\* @typeAlias: vote = { rnd: Int, val: Str, src: Str };
\* @typeAlias: lock = { has: Bool, round: Int, value: Str };
\* @typeAlias: dec  = { has: Bool, value: Str };
DDRU_typedefs == TRUE

CONSTANTS
  \* @type: Set(Str);
  Validators,
  \* @type: Set(Str);
  Faulty,
  \* @type: Set(Str);
  Values,
  \* @type: Int;
  q

\* n=4, f=1, q=3 — the smallest BFT configuration (n = 3f+1). NO MaxRound.
ConstInit ==
  /\ Validators = {"v1", "v2", "v3", "v4"}
  /\ Faulty = {"v4"}
  /\ Values = {"a", "b"}
  /\ q = 3

\* Per-set cardinality bound for the symbolic vote configuration (see header /
\* audit). Each set (prevotes / precommits) independently holds a full polka
\* (q = 3) plus the two equivocating votes of the single faulty validator. With
\* round numbers free integers, a 5-vote set can already place its polka at any
\* integer round, so this bound exercises round-MAGNITUDE independence (the point
\* of this module) at arbitrary, non-contiguous round labels. Multi-polka
\* completeness within a single set is covered separately by the EXHAUSTIVE
\* bounded runs of M5c (MaxRound = 3 and 6, DDRConsensusApa.tla), which scan all
\* reachable vote configurations and find no counterexample to the same IndInv.
Bound == 5

Correct == Validators \ Faulty
Nil == "nil"

VARIABLES
  \* @type: Int;
  r,
  \* @type: Set($vote);
  prevotes,
  \* @type: Set($vote);
  precommits,
  \* @type: Str -> $lock;
  locked,
  \* @type: Str -> $dec;
  decided

vars == <<r, prevotes, precommits, locked, decided>>

\* @type: (Set($vote), Int, Str) => Int;
Cnt(S, rr, vv) == Cardinality({ m \in S : m.rnd = rr /\ m.val = vv })
PolkaT(S, rr, vv) == Cnt(S, rr, vv) >= q
QuorumVal(S, rr) ==
  IF \E vv \in Values : Cnt(S, rr, vv) >= q
  THEN CHOOSE vv \in Values : Cnt(S, rr, vv) >= q
  ELSE Nil

\* @type: (Int, Str, Str) => $vote;
MkV(rr, vv, v) == [rnd |-> rr, val |-> vv, src |-> v]

\* Honest prevote rule (lock enforced) — identical to the bounded model.
\* @type: (Str, { val: Str, vr: Int }) => Str;
PrevoteVal(v, prop) ==
  IF ~locked[v].has THEN prop.val
  ELSE IF locked[v].value = prop.val THEN prop.val
  ELSE IF /\ prop.vr # -1
          /\ prop.vr >= locked[v].round
          /\ prop.vr < r
          /\ Cnt(prevotes, prop.vr, prop.val) >= q
       THEN prop.val
  ELSE Nil

\* One atomic round. UNCHANGED from the bounded model EXCEPT there is no
\* `r <= MaxRound` guard: rounds advance without an upper horizon.
DoRound ==
  \E Active \in { S \in SUBSET Validators : Cardinality(S) = q } :
    \E leader \in Validators :
      \E propVal \in Values :
        /\ (leader \in Faulty \/ ~locked[leader].has \/ propVal = locked[leader].value)
        /\ LET prop ==
                 IF leader \in Faulty THEN [val |-> propVal, vr |-> -1]
                 ELSE IF locked[leader].has
                      THEN [val |-> locked[leader].value, vr |-> locked[leader].round]
                      ELSE [val |-> propVal, vr |-> -1]
               ActiveHonest == Active \ Faulty
               honestPV == { MkV(r, PrevoteVal(v, prop), v) : v \in ActiveHonest }
               honestPVf == { m \in honestPV : m.val \in Values }
               faultyPV == { MkV(r, x, v) : x \in Values, v \in Faulty }
               newPV == prevotes \union honestPVf \union faultyPV
               pv == QuorumVal(newPV, r)
               honestPC == IF pv \in Values
                           THEN { MkV(r, pv, v) : v \in ActiveHonest }
                           ELSE {}
               faultyPC == { MkV(r, x, v) : x \in Values, v \in Faulty }
               newPC == precommits \union honestPC \union faultyPC
               cv == QuorumVal(newPC, r)
           IN /\ prevotes' = newPV
              /\ precommits' = newPC
              /\ locked' = [ v \in Validators |->
                               IF v \in ActiveHonest /\ pv \in Values
                               THEN [has |-> TRUE, round |-> r, value |-> pv]
                               ELSE locked[v] ]
              /\ decided' = [ v \in Validators |->
                               IF v \in ActiveHonest /\ cv \in Values /\ ~decided[v].has
                               THEN [has |-> TRUE, value |-> cv]
                               ELSE decided[v] ]
              /\ r' = r + 1

Next == DoRound

Agreement ==
  \A v, w \in Correct :
     (decided[v].has /\ decided[w].has) => (decided[v].value = decided[w].value)

(***************************************************************************)
(* RANGE-FREE inductive invariant. Every conjunct that the bounded model    *)
(* phrased with `\in 0..MaxRound` is re-expressed by quantifying over the    *)
(* rounds that ACTUALLY APPEAR in the vote sets (or over the votes           *)
(* themselves). On any state these are equivalent to the bounded forms — a   *)
(* round with no votes can carry no polka and no per-validator vote, so the  *)
(* trivial cases (cardinality 0) need not be enumerated — but the range-free *)
(* phrasing has NO dependence on a round horizon, which is the whole point.  *)
(***************************************************************************)

\* Well-formedness: the `Gen`-produced state must look like a protocol state.
WellFormed ==
  /\ DOMAIN locked = Validators
  /\ DOMAIN decided = Validators
  /\ \A m \in prevotes   : m.val \in Values /\ m.src \in Validators
  /\ \A m \in precommits : m.val \in Values /\ m.src \in Validators
  /\ \A v \in Validators : locked[v].value \in Values
  /\ \A v \in Validators : decided[v].value \in Values

\* Round numbers are non-negative (rounds start at 0 and only increment). A
\* sound strengthening of IndInv: it is itself inductive (r'=r+1; new votes at
\* round r>=0; locks at round r>=0) and it rules out spurious negative-round
\* CTIs that no reachable state exhibits.
NonNeg ==
  /\ r >= 0
  /\ \A m \in prevotes   : m.rnd >= 0
  /\ \A m \in precommits : m.rnd >= 0
  /\ \A v \in Validators : locked[v].round >= 0

\* Votes only ever concern rounds strictly before the current one.
PastVotes ==
  /\ \A m \in prevotes   : m.rnd < r
  /\ \A m \in precommits : m.rnd < r

\* An honest validator casts at most one prevote / precommit per round. Quantify
\* over rounds appearing in the vote sets (rounds with no vote are trivial).
UniqueVotes ==
  \A v \in Correct, m \in prevotes \union precommits :
    /\ Cardinality({ vv \in Values : MkV(m.rnd, vv, v) \in prevotes })   <= 1
    /\ Cardinality({ vv \in Values : MkV(m.rnd, vv, v) \in precommits }) <= 1

PrecommitJustified ==
  \A m \in precommits : m.src \in Correct => PolkaT(prevotes, m.rnd, m.val)

LockJustified ==
  \A v \in Correct :
    locked[v].has =>
      /\ MkV(locked[v].round, locked[v].value, v) \in precommits
      /\ \A m \in precommits : m.src = v => m.rnd <= locked[v].round

\* An honest validator that has ever precommitted is locked (the conjunct the
\* Apalache CTI surfaced in the bounded proof).
LockComplete ==
  \A v \in Correct : (\E m \in precommits : m.src = v) => locked[v].has

\* Lock pinning, range-free: quantify over precommit polkas that appear.
LockPin ==
  \A v \in Correct, m \in precommits :
    (PolkaT(precommits, m.rnd, m.val) /\ locked[v].has /\ locked[v].round >= m.rnd)
      => locked[v].value = m.val

\* Safety core, range-free: any precommit-polka at round r1=m1.rnd for V=m1.val
\* and any prevote-polka at round r2=m2.rnd>=r1 for W=m2.val must agree (W=V).
\* Ranging m1 over precommits and m2 over prevotes covers exactly the rounds /
\* values that can carry a polka.
SafeInv ==
  \A m1 \in precommits, m2 \in prevotes :
     (   PolkaT(precommits, m1.rnd, m1.val)
      /\ m2.rnd >= m1.rnd
      /\ PolkaT(prevotes, m2.rnd, m2.val) ) => (m2.val = m1.val)

\* An honest decision is backed by a commit-quorum (precommit polka).
DecidedJustified ==
  \A v \in Correct :
    decided[v].has => \E m \in precommits :
       m.val = decided[v].value /\ PolkaT(precommits, m.rnd, m.val)

IndInv ==
  /\ WellFormed
  /\ NonNeg
  /\ PastVotes
  /\ UniqueVotes
  /\ PrecommitJustified
  /\ LockJustified
  /\ LockComplete
  /\ LockPin
  /\ SafeInv
  /\ DecidedJustified

(***************************************************************************)
(* `Init` reaches IndInv (length-0 obligation).                            *)
(***************************************************************************)
Init ==
  /\ r = 0
  /\ prevotes = {}
  /\ precommits = {}
  /\ locked  = [v \in Validators |-> [has |-> FALSE, round |-> 0,
                                      value |-> CHOOSE x \in Values : TRUE]]
  /\ decided = [v \in Validators |-> [has |-> FALSE,
                                      value |-> CHOOSE x \in Values : TRUE]]

(***************************************************************************)
(* `CInit` — the UNBOUNDED arbitrary-IndInv-state generator. `Gen(Bound)`   *)
(* produces vote sets of cardinality <= Bound whose round fields are        *)
(* UNCONSTRAINED integers; the lock / decided functions are generated per   *)
(* validator with fresh symbolic fields. `IndInv` then carves out exactly   *)
(* the well-formed IndInv states. Nothing here mentions a round horizon.    *)
(***************************************************************************)
CInit ==
  /\ r = Gen(1)
  /\ prevotes  = Gen(Bound)
  /\ precommits = Gen(Bound)
  /\ locked  = [ v \in Validators |->
                   [ has |-> Gen(1), round |-> Gen(1), value |-> Gen(1) ] ]
  /\ decided = [ v \in Validators |->
                   [ has |-> Gen(1), value |-> Gen(1) ] ]
  /\ IndInv
=============================================================================
