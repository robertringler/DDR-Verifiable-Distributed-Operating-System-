----------------------- MODULE DDRConsensusTLAPS -----------------------
(***************************************************************************)
(* PARAMETRIC safety proof for DDR BFT consensus.                         *)
(*                                                                          *)
(* Target tool: TLAPS (TLA+ Proof System), which discharges each proof     *)
(* step via Isabelle, Z3, or Zenon back-ends.                              *)
(*                                                                          *)
(* Status (machine-checked with tlapm 1.5.0, Z3 4.8.9; 143 obligations,    *)
(* 0 failed; reproduce with ../specs/check-parametric.sh):                 *)
(*   * MACHINE-CHECKED, parametric in f:                                    *)
(*       LEMMA CorrectCard       (|Correct| = 2f+1)                         *)
(*       LEMMA QuorumIntersect   (two (f+1)-subsets of Correct intersect)  *)
(*       LEMMA ActiveHVLower     (the counting core; see below)            *)
(*       THEOREM Init_IndInv     (Init => IndInv)                          *)
(*   * STRUCTURED with OMITTED protocol leaves (14 total):                  *)
(*       THEOREM IndInv_Agreement  (1 omitted leaf)                        *)
(*       THEOREM IndInv_Step       (13 omitted leaves; the SafeInv' case    *)
(*                                  analysis + per-conjunct preservation)   *)
(* See docs/audit/16-parametric-safety-tlaps.md for full discussion.       *)
(*                                                                          *)
(* Covers: all n = 3f+1, q = 2f+1, UNBOUNDED rounds (same model as        *)
(* DDRConsensusUnbounded.tla but with abstract, parametric validators).    *)
(*                                                                          *)
(* The key counting argument (LEMMA ActiveHVLower, machine-checked): for a *)
(* round whose Active set has t faulty members and whose H_V subset has k  *)
(* members locked on V, k + t >= f+1, so prevotes-for-W are at most        *)
(* q-1 < q — no conflicting polka can form.                                *)
(***************************************************************************)
EXTENDS Integers, FiniteSets, FiniteSetTheorems, TLAPS

(***************************************************************************)
(* §0. Constants and parametric assumptions                                *)
(***************************************************************************)
CONSTANTS
  Validators,   \* finite set of all validators
  Faulty,       \* the f Byzantine validators
  Values,       \* possible decision values (|Values| >= 2)
  f,            \* fault-tolerance parameter
  q             \* quorum = 2f+1

\* Exact tight-BFT configuration: n = 3f+1, |Faulty| = f, q = 2f+1.
\* (For n > 3f+1 with the same q, the quorum intersection can fail;
\*  the n=3f+1 family is the canonical DDR configuration.)
ASSUME A_ValFinite == IsFiniteSet(Validators)
ASSUME A_FaultySubset == Faulty \subseteq Validators /\ IsFiniteSet(Faulty)
ASSUME A_ValCount == Cardinality(Validators) = 3*f + 1
ASSUME A_FaultCount == Cardinality(Faulty) = f
ASSUME A_QuorumDef == q = 2*f + 1
ASSUME A_ValuesFinite == IsFiniteSet(Values) /\ Cardinality(Values) >= 2
ASSUME A_fNat == f \in Nat   \* f is a natural number (count of faulty validators)
ASSUME A_FPos == f >= 1      \* at least one fault tolerated; n >= 4

Correct == Validators \ Faulty
Nil == "nil"

(***************************************************************************)
(* §1. Structural lemmas about Correct and quorum cardinalities            *)
(***************************************************************************)

\* |Correct| = n - f = (3f+1) - f = 2f+1 = q.  The correct-set has
\* exactly q members — this equality underpins every quorum argument.
LEMMA CorrectCard ==
  IsFiniteSet(Correct) /\ Cardinality(Correct) = 2*f + 1
PROOF
  <1>1. Validators \cap Faulty = Faulty
    BY A_FaultySubset
  <1>2. /\ IsFiniteSet(Correct)
        /\ Cardinality(Correct) = Cardinality(Validators) - Cardinality(Validators \cap Faulty)
    BY FS_Difference, A_ValFinite DEF Correct
  <1>3. Cardinality(Correct) = Cardinality(Validators) - Cardinality(Faulty)
    BY <1>1, <1>2
  <1>4. QED
    BY <1>2, <1>3, A_ValCount, A_FaultCount, A_fNat

\* Any two subsets of Correct each of size >= f+1 must intersect.
\* Proof: if disjoint, their union has >= 2f+2 elements, but the union
\* fits inside Correct which has exactly 2f+1 — contradiction.
LEMMA QuorumIntersect ==
  ASSUME NEW A \in SUBSET Correct, NEW B \in SUBSET Correct,
         IsFiniteSet(A), IsFiniteSet(B),
         Cardinality(A) >= f+1, Cardinality(B) >= f+1
  PROVE A \cap B # {}
PROOF
  <1>0. Cardinality(A) \in Nat /\ Cardinality(B) \in Nat
    BY FS_CardinalityType
  <1>1. Cardinality(A) + Cardinality(B) > Cardinality(Correct)
    BY <1>0, CorrectCard, A_FPos, A_fNat
  <1>2. QED
    BY <1>1, CorrectCard, FS_MajoritiesIntersect

\* Key counting lemma for the inductive step.  Given Active \subseteq Validators
\* with |Active| = q, and H_V \subseteq Correct with |H_V| >= f+1, the
\* intersection |Active \cap H_V| is at least f+1 - |Active \cap Faulty|.
\* Equivalently: |Active \cap H_V| + |Active \cap Faulty| >= f+1.
\*
\* This bounds how many of the Active members must vote V when Commit(r1,V)
\* holds: k = |Active \cap H_V| >= f+1-t where t = |Active \cap Faulty|.
\* Then max-W-votes = f + (q-t-k) <= f + (q-t-(f+1-t)) = q-1 < q.
LEMMA ActiveHVLower ==
  ASSUME NEW Active, Active \in SUBSET Validators,
         IsFiniteSet(Active), Cardinality(Active) = q,
         NEW HV, HV \in SUBSET Correct,
         IsFiniteSet(HV), Cardinality(HV) >= f+1
  PROVE Cardinality(Active \cap HV) + Cardinality(Active \cap Faulty) >= f+1
PROOF
  \* AH = Active \cap Correct, AF = Active \cap Faulty.  |AH| + |AF| = |Active| = q.
  \* AH, HV \subseteq Correct, so by inclusion-exclusion inside Correct:
  \*   |AH \cap HV| >= |AH| + |HV| - |Correct| = (q-|AF|)+(f+1)-(2f+1) = f+1-|AF|.
  \* AH \cap HV = Active \cap HV (HV \subseteq Correct), giving the bound.
  <1> DEFINE AH == Active \cap Correct
  <1> DEFINE AF == Active \cap Faulty
  <1>0. /\ IsFiniteSet(AH) /\ AH \in SUBSET Correct
        /\ IsFiniteSet(AF)
        /\ IsFiniteSet(Correct)
        /\ IsFiniteSet(AH \cap HV)
        /\ IsFiniteSet(AH \cup HV)
    BY FS_Intersection, FS_Union, CorrectCard DEF AH, AF
  <1>5. /\ Cardinality(AH \cap HV) \in Nat /\ Cardinality(AH) \in Nat
        /\ Cardinality(HV) \in Nat /\ Cardinality(AF) \in Nat
        /\ Cardinality(Active) \in Nat /\ Cardinality(Correct) \in Nat
    BY FS_CardinalityType, CorrectCard, <1>0
  <1>1. AH \cup AF = Active /\ AH \cap AF = {}
    \* Active \subseteq Validators = Correct \cup Faulty, Correct \cap Faulty = {}.
    BY A_FaultySubset DEF AH, AF, Correct
  <1>2. Cardinality(AH) + Cardinality(AF) = q
    <2>1. Cardinality(AH \cup AF) = Cardinality(AH) + Cardinality(AF) - Cardinality(AH \cap AF)
      BY FS_Union, <1>0
    <2>2. Cardinality(AH \cap AF) = 0
      BY <1>1, FS_EmptySet
    <2>3. Cardinality(Active) = Cardinality(AH) + Cardinality(AF)
      BY <2>1, <2>2, <1>1, <1>5
    <2>4. QED BY <2>3, <1>5
  <1>3. (AH \cup HV) \in SUBSET Correct /\ Cardinality(AH \cup HV) <= Cardinality(Correct)
    BY <1>0, FS_Subset, CorrectCard
  <1>4. Cardinality(AH \cup HV) = Cardinality(AH) + Cardinality(HV) - Cardinality(AH \cap HV)
    BY FS_Union, <1>0
  <1>6. Cardinality(AH \cap HV) >= Cardinality(AH) + Cardinality(HV) - Cardinality(Correct)
    BY <1>3, <1>4, <1>5
  <1>7. AH \cap HV = Active \cap HV
    \* HV \subseteq Correct, so (Active \cap Correct) \cap HV = Active \cap HV.
    BY DEF AH
  <1>8a. Cardinality(Active \cap HV) = Cardinality(AH \cap HV)
    BY <1>7
  <1>8b. Cardinality(AH) = q - Cardinality(AF)
    BY <1>2, <1>5
  <1>8c. Cardinality(HV) >= f+1 /\ Cardinality(Correct) = 2*f+1 /\ q = 2*f+1
    BY CorrectCard, A_QuorumDef
  <1>8. Cardinality(Active \cap HV) >= f+1 - Cardinality(AF)
    \* |Active cap HV| = |AH cap HV| >= |AH|+|HV|-|Correct|
    \*               = (q-|AF|) + (f+1) - (2f+1) = f+1-|AF|.
    BY <1>6, <1>8a, <1>8b, <1>8c, A_fNat, <1>5
  <1>8d. Cardinality(Active \cap Faulty) = Cardinality(AF)
    BY DEF AF
  <1>9. QED
    \* From <1>8: |Active cap HV| >= f+1 - |AF|; add |AF| (a Nat) to both sides.
    \* <1>8a gives |Active cap HV| = |AH cap HV| (a Nat by <1>5), so the sum is over Ints.
    BY <1>8, <1>8a, <1>8d, <1>5, A_fNat

(***************************************************************************)
(* §2. Protocol state, operators, and transition                           *)
(* (Same semantics as DDRConsensusUnbounded.tla; no Apalache dependencies) *)
(***************************************************************************)
VARIABLES
  r,          \* current round (non-negative integer, advances without bound)
  prevotes,   \* accumulated prevote messages
  precommits, \* accumulated precommit messages
  locked,     \* per-validator lock: [has, round, value]
  decided     \* per-validator decision: [has, value]

vars == <<r, prevotes, precommits, locked, decided>>

Cnt(S, rr, vv)    == Cardinality({ m \in S : m.rnd = rr /\ m.val = vv })
PolkaT(S, rr, vv) == Cnt(S, rr, vv) >= q
QuorumVal(S, rr)  ==
  IF \E vv \in Values : Cnt(S, rr, vv) >= q
  THEN CHOOSE vv \in Values : Cnt(S, rr, vv) >= q
  ELSE Nil

MkV(rr, vv, v) == [rnd |-> rr, val |-> vv, src |-> v]

\* Honest prevote rule: vote the proposal unless the lock rule blocks it.
PrevoteVal(v, prop) ==
  IF ~locked[v].has THEN prop.val
  ELSE IF locked[v].value = prop.val THEN prop.val
  ELSE IF /\ prop.vr # -1
          /\ prop.vr >= locked[v].round
          /\ prop.vr < r
          /\ Cnt(prevotes, prop.vr, prop.val) >= q
       THEN prop.val
  ELSE Nil

\* One atomic round.  No MaxRound guard; rounds advance indefinitely.
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
               honestPV  == { MkV(r, PrevoteVal(v, prop), v) : v \in ActiveHonest }
               honestPVf == { m \in honestPV : m.val \in Values }
               faultyPV  == { MkV(r, x, v) : x \in Values, v \in Faulty }
               newPV     == prevotes \union honestPVf \union faultyPV
               pv        == QuorumVal(newPV, r)
               honestPC  == IF pv \in Values
                            THEN { MkV(r, pv, v) : v \in ActiveHonest }
                            ELSE {}
               faultyPC  == { MkV(r, x, v) : x \in Values, v \in Faulty }
               newPC     == precommits \union honestPC \union faultyPC
               cv        == QuorumVal(newPC, r)
           IN /\ prevotes'   = newPV
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

(***************************************************************************)
(* §3. Full inductive invariant (same conjuncts as DDRConsensusUnbounded) *)
(***************************************************************************)

WellFormed ==
  /\ DOMAIN locked  = Validators
  /\ DOMAIN decided = Validators
  /\ \A m \in prevotes   : m.val \in Values /\ m.src \in Validators
  /\ \A m \in precommits : m.val \in Values /\ m.src \in Validators
  /\ \A v \in Validators : locked[v].value \in Values
  /\ \A v \in Validators : decided[v].value \in Values

NonNeg ==
  /\ r >= 0
  /\ \A m \in prevotes   : m.rnd >= 0
  /\ \A m \in precommits : m.rnd >= 0
  /\ \A v \in Validators : locked[v].round >= 0

PastVotes ==
  /\ \A m \in prevotes   : m.rnd < r
  /\ \A m \in precommits : m.rnd < r

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

LockComplete ==
  \A v \in Correct : (\E m \in precommits : m.src = v) => locked[v].has

LockPin ==
  \A v \in Correct, m \in precommits :
    (PolkaT(precommits, m.rnd, m.val) /\ locked[v].has /\ locked[v].round >= m.rnd)
      => locked[v].value = m.val

SafeInv ==
  \A m1 \in precommits, m2 \in prevotes :
     (   PolkaT(precommits, m1.rnd, m1.val)
      /\ m2.rnd >= m1.rnd
      /\ PolkaT(prevotes, m2.rnd, m2.val) ) => (m2.val = m1.val)

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

Agreement ==
  \A v, w \in Correct :
     (decided[v].has /\ decided[w].has) => (decided[v].value = decided[w].value)

(***************************************************************************)
(* §4. Initial state                                                       *)
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
(* §5. Proof obligation (1): Init => IndInv                               *)
(* The initial state satisfies every conjunct trivially.                   *)
(***************************************************************************)
THEOREM Init_IndInv == Init => IndInv
PROOF
  <1>1. ASSUME Init PROVE IndInv
    <2>1. WellFormed
      \* DOMAIN locked = DOMAIN decided = Validators by Init; vote sets empty;
      \* locked[v].value = decided[v].value = (CHOOSE x \in Values : TRUE) \in Values
      \* because Values is non-empty (Cardinality(Values) >= 2).
      <3>1. Values # {}
        BY A_ValuesFinite, FS_EmptySet
      <3>2. (CHOOSE x \in Values : TRUE) \in Values
        BY <3>1
      <3>3. QED
        BY <1>1, <3>2 DEF Init, WellFormed, Correct
    <2>2. NonNeg
      BY <1>1 DEF Init, NonNeg
    <2>3. PastVotes
      BY <1>1 DEF Init, PastVotes  \* prevotes = {} and precommits = {}
    <2>4. UniqueVotes
      BY <1>1 DEF Init, UniqueVotes  \* empty vote sets; premise vacuously false
    <2>5. PrecommitJustified
      BY <1>1 DEF Init, PrecommitJustified  \* precommits = {}
    <2>6. LockJustified
      \* v \in Correct \subseteq Validators, so locked[v].has = FALSE (vacuous premise).
      BY <1>1 DEF Init, LockJustified, Correct
    <2>7. LockComplete
      BY <1>1 DEF Init, LockComplete        \* precommits = {}
    <2>8. LockPin
      BY <1>1 DEF Init, LockPin             \* precommits = {}
    <2>9. SafeInv
      BY <1>1 DEF Init, SafeInv             \* precommits = {}
    <2>10. DecidedJustified
      \* v \in Correct \subseteq Validators, so decided[v].has = FALSE (vacuous premise).
      BY <1>1 DEF Init, DecidedJustified, Correct
    <2>11. QED BY <2>1, <2>2, <2>3, <2>4, <2>5, <2>6, <2>7,
                  <2>8, <2>9, <2>10 DEF IndInv
  <1>2. QED BY <1>1

(***************************************************************************)
(* §6. Proof obligation (2): IndInv => Agreement                          *)
(*                                                                          *)
(* If IndInv holds and two correct validators decided V and W (WLOG via    *)
(* commits at r1 <= r2), then Commit(r1,V) /\ Polka(r2,W) and r2 >= r1,   *)
(* so SafeInv gives W = V.                                                 *)
(***************************************************************************)
THEOREM IndInv_Agreement == IndInv => Agreement
PROOF
  <1>1. ASSUME IndInv,
               NEW v \in Correct, NEW w \in Correct,
               decided[v].has, decided[w].has
        PROVE decided[v].value = decided[w].value
    \* By DecidedJustified each decision is backed by a precommit-polka:
    <2>1. \E m1 \in precommits :
            m1.val = decided[v].value /\ PolkaT(precommits, m1.rnd, m1.val)
      BY <1>1 DEF IndInv, DecidedJustified
    <2>2. \E m2 \in precommits :
            m2.val = decided[w].value /\ PolkaT(precommits, m2.rnd, m2.val)
      BY <1>1 DEF IndInv, DecidedJustified
    \* WLOG m1.rnd <= m2.rnd.  A precommit-polka implies a same-round prevote-polka
    \* (PrecommitJustified + Lemma 1: >= f+1 correct precommitters, each justified by
    \* a prevote-polka).  Then Commit(m1.rnd,V) /\ Polka(m2.rnd,W) /\ m2.rnd>=m1.rnd
    \* yields W=V by SafeInv (symmetric in the other case).
    \* [Leaf admitted: requires PrecommitPolkaImpliesPrevotePolka, a protocol-level
    \*  counting lemma built on the same q->f+1-correct argument as Lemma 1.]
    <2>3. decided[v].value = decided[w].value
      OMITTED
    <2>4. QED BY <2>3
  <1>2. QED BY <1>1 DEF Agreement

(***************************************************************************)
(* §7. Proof obligation (3): IndInv /\ Next => IndInv'                    *)
(*                                                                          *)
(* The inductive step: one DoRound preserves every conjunct of IndInv.     *)
(*                                                                          *)
(* The substantive cases are SafeInv' and LockPin'.  All other conjuncts   *)
(* are preserved by routine case analysis on which fields DoRound updates. *)
(*                                                                          *)
(* SafeInv' argument (see §ActiveHVLower and §2 in the header):            *)
(*   New precommit polkas: if a new polka forms at round r in precommits',  *)
(*   it's for the unique value pv = QuorumVal(newPV, r), which implies     *)
(*   PolkaT(prevotes', r, pv).  LockPin (pre-state) + the counting lemma  *)
(*   show no conflicting prevote polka can form at the same round.          *)
(*   For rounds < r: pre-state SafeInv handles them (old polkas unchanged). *)
(*   For round r prevote polka vs old commit polka at r1 < r:              *)
(*     the counting argument (ActiveHVLower) shows the W-votes at round r  *)
(*     total <= q-1 < q, so PolkaT(prevotes', r, W) fails for W != pv.    *)
(***************************************************************************)
\* Stated over the action Next (matching the Apalache obligation discharged in
\* M5c / M5c+, which checks IndInv /\ Next => IndInv').  Stuttering ([Next]_vars
\* with vars unchanged) preserves any state predicate trivially and is omitted.
THEOREM IndInv_Step == IndInv /\ Next => IndInv'
PROOF
  <1> SUFFICES ASSUME IndInv, Next PROVE IndInv'
    OBVIOUS
  \* Each conjunct below is preserved by one DoRound.  The leaf proofs marked
  \* OMITTED are protocol-level obligations that require unfolding the (large)
  \* DoRound action plus per-conjunct supporting lemmas; their mathematical
  \* arguments are the comments.  The KEY case (SafeInv', <2>2) is where the
  \* machine-checked counting lemma ActiveHVLower (above) is the load-bearing fact.
  <1>1. WellFormed'
    \* DoRound adds only MkV(r,_,_) records; val fields from Values, src from
    \* Validators (Active, Faulty subseteq Validators).  Domains stay Validators.
    OMITTED
  <1>2. NonNeg'
    \* r' = r+1 >= 1 (r >= 0 by NonNeg); new votes/locks stamped at round r >= 0.
    OMITTED
  <1>3. PastVotes'
    \* New votes have rnd = r < r+1 = r'; old votes had rnd < r < r'.
    OMITTED
  <1>4. UniqueVotes'
    \* Each honest v in ActiveHonest contributes exactly one rnd=r prevote
    \* (PrevoteVal is a function); faulty validators contribute one vote per value.
    OMITTED
  <1>5. PrecommitJustified'
    \* New honest precommits issue only when pv = QuorumVal(newPV,r) in Values, i.e.
    \* PolkaT(newPV,r,pv); newPV subseteq prevotes'.  Old precommits keep their polkas.
    OMITTED
  <1>6. LockJustified'
    \* Locks update only for ActiveHonest to [has,round=r,value=pv] with
    \* MkV(r,pv,v) in precommits'; any precommit by v is at round <= r (PastVotes).
    OMITTED
  <1>7. LockComplete'
    \* A correct v getting a new precommit (pv in Values) is simultaneously locked.
    OMITTED
  <1>8. LockPin'
    \* New locks at round r; co-proved with SafeInv' (<1>9): a new lock at r takes
    \* the unique polka value at r, which SafeInv' pins to the committed value.
    OMITTED
  <1>9. SafeInv'
    \* The substantive conjunct.  SUFFICES: take an arbitrary post-state precommit
    \* polka (m1) and prevote polka (m2) with m2.rnd >= m1.rnd; prove m2.val=m1.val.
    <2> SUFFICES ASSUME NEW m1 \in precommits', NEW m2 \in prevotes',
                        PolkaT(precommits', m1.rnd, m1.val),
                        m2.rnd >= m1.rnd,
                        PolkaT(prevotes', m2.rnd, m2.val)
                 PROVE m2.val = m1.val
      BY DEF SafeInv
    <2>1. CASE m1.rnd < r /\ m2.rnd < r
      \* (A) Both polkas predate this round; votes at round r don't affect them.
      \* Follows from pre-state SafeInv (the old polkas are unchanged).
      OMITTED
    <2>2. CASE m1.rnd < r /\ m2.rnd = r
      \* (B) KEY CASE.  Commit(m1.rnd,V) is old; a prevote polka for W might form at
      \* the new round r.  Let HV = honest precommitters of V at m1.rnd, |HV| >= f+1.
      \* By LockPin (pre-state), every u in HV is locked on V; the lock rule then
      \* forces PrevoteVal(u,_) in {V, Nil} for u in Active cap HV (a W-unlock would
      \* need a polka for W at vr in [m1.rnd, r), excluded by pre-state SafeInv).
      \* By the machine-checked lemma ActiveHVLower:
      \*     k = |Active cap HV| >= f+1 - t   where t = |Active cap Faulty|.
      \* Max prevotes for W at round r = f (faulty) + (|Active cap Correct| - k)
      \*     <= f + (q - t) - (f+1 - t) = q - 1  <  q.
      \* So PolkaT(prevotes', r, W) is impossible for W # V; hence m2.val = V = m1.val.
      OMITTED
    <2>3. CASE m1.rnd = r /\ m2.rnd = r
      \* (C) Both new.  New precommits are all for pv = QuorumVal(newPV,r); a polka
      \* needs >= q votes for one value, and QuorumVal picks the unique such value,
      \* so both m1.val and m2.val equal pv.
      OMITTED
    <2>4. QED
      \* PastVotes' gives every vote round <= r, so m1.rnd, m2.rnd in {<r} \cup {r}.
      \* With m2.rnd >= m1.rnd, the case m1.rnd=r /\ m2.rnd<r is impossible, leaving
      \* exactly the three cases (A),(B),(C) above.
      OMITTED
  <1>10. DecidedJustified'
    \* New decisions take cv = QuorumVal(newPC,r) in Values, with MkV(r,cv,v) in
    \* newPC subseteq precommits'; old decisions keep their backing precommits.
    OMITTED
  <1>11. QED
    BY <1>1, <1>2, <1>3, <1>4, <1>5, <1>6, <1>7, <1>8, <1>9, <1>10
       DEF IndInv

=============================================================================
\* End of DDRConsensusTLAPS
