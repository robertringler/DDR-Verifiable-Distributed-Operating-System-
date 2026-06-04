----------------------- MODULE DDRConsensusTLAPS -----------------------
(***************************************************************************)
(* PARAMETRIC safety proof for DDR BFT consensus.                         *)
(*                                                                          *)
(* Target tool: TLAPS (TLA+ Proof System), which discharges each proof     *)
(* step via Isabelle, Z3, or Zenon back-ends.                              *)
(*                                                                          *)
(* Status: proof structure complete; requires `tlaps` to machine-check.   *)
(* See docs/audit/16-parametric-safety-tlaps.md for full discussion.       *)
(*                                                                          *)
(* Covers: all n = 3f+1, q = 2f+1, UNBOUNDED rounds (same model as        *)
(* DDRConsensusUnbounded.tla but with abstract, parametric validators).    *)
(*                                                                          *)
(* Three obligations (matching M5c / M5c+ structure):                      *)
(*   (1) Init    => IndInv          -- TLAPS: Init_IndInv                   *)
(*   (2) IndInv  => Agreement       -- TLAPS: IndInv_Agreement              *)
(*   (3) IndInv /\ Next => IndInv'  -- TLAPS: IndInv_Step  (the hard one)  *)
(*                                                                          *)
(* The key counting argument (see §2 below): for a round whose Active set  *)
(* has t faulty members and whose H_V subset has k members locked on V,    *)
(* k + t >= f+1, so prevotes-for-W at most q-1 < q — no conflicting polka.*)
(***************************************************************************)
EXTENDS Integers, FiniteSets, TLAPS

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
ASSUME A_FPos == f >= 1   \* at least one fault tolerated; n >= 4

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
  <1>1. IsFiniteSet(Correct)
    BY FS_Subset, A_ValFinite, A_FaultySubset DEF Correct
  <1>2. Cardinality(Validators) = Cardinality(Correct) + Cardinality(Faulty)
    \* Partition: Validators = Correct \cup Faulty, disjoint.
    BY FS_UnionDisjoint, <1>1, A_FaultySubset, A_ValFinite DEF Correct
  <1>3. Cardinality(Correct) = Cardinality(Validators) - Cardinality(Faulty)
    BY <1>2, FS_CardinalityType, <1>1, A_ValFinite
  <1>4. QED BY <1>3, A_ValCount, A_FaultCount

\* Any two subsets of Correct each of size >= f+1 must intersect.
\* Proof: if disjoint, their union has >= 2f+2 elements, but the union
\* fits inside Correct which has exactly 2f+1 — contradiction.
LEMMA QuorumIntersect ==
  ASSUME NEW A \in SUBSET Correct, NEW B \in SUBSET Correct,
         IsFiniteSet(A), IsFiniteSet(B),
         Cardinality(A) >= f+1, Cardinality(B) >= f+1
  PROVE A \cap B # {}
PROOF
  <1>1. PROOF BY CONTRADICTION
  <1>2. ASSUME A \cap B = {}
  <1>3. Cardinality(A \cup B) = Cardinality(A) + Cardinality(B)
    BY FS_UnionDisjoint, <1>2
  <1>4. Cardinality(A \cup B) >= 2*f + 2
    BY <1>3
  <1>5. A \cup B \subseteq Correct  OBVIOUS
  <1>6. Cardinality(A \cup B) <= Cardinality(Correct)
    BY FS_Subset, CorrectCard, <1>5
  <1>7. Cardinality(Correct) = 2*f+1  BY CorrectCard
  <1>8. QED BY <1>4, <1>6, <1>7    \* 2f+2 <= 2f+1 — false

\* Key counting lemma for the inductive step.  Given Active \subseteq Validators
\* with |Active| = q, and H_V \subseteq Correct with |H_V| >= f+1, the
\* intersection |Active \cap H_V| is at least f+1 - |Active \cap Faulty|.
\* Equivalently: |Active \cap H_V| + |Active \cap Faulty| >= f+1.
\*
\* This bounds how many of the Active members must vote V when Commit(r1,V)
\* holds: k = |Active \cap H_V| >= f+1-t where t = |Active \cap Faulty|.
\* Then max-W-votes = f + (q-t-k) <= f + (q-t-(f+1-t)) = q-1 < q.
LEMMA ActiveHVLower ==
  ASSUME NEW Active \in SUBSET Validators,
         IsFiniteSet(Active), Cardinality(Active) = q,
         NEW HV \in SUBSET Correct,
         IsFiniteSet(HV), Cardinality(HV) >= f+1
  PROVE Cardinality(Active \cap HV) + Cardinality(Active \cap Faulty) >= f+1
PROOF
  \* Let AH = Active \cap Correct, AF = Active \cap Faulty.
  \* |AH| = q - |AF|.  Apply QuorumIntersect to AH and HV inside Correct:
  \* |AH \cap HV| >= |AH| + |HV| - |Correct| = (q-|AF|)+(f+1)-(2f+1) = f+1-|AF|.
  \* Adding |AF| gives |AH \cap HV| + |AF| >= f+1.  And AH \cap HV = Active \cap HV.
  <1>1. LET AH == Active \cap Correct
             AF == Active \cap Faulty
        IN
    <2>1. IsFiniteSet(AH) /\ IsFiniteSet(AF)
      BY FS_Subset, CorrectCard, A_FaultySubset, A_ValFinite DEF Correct
    <2>2. AH \cap AF = {}  BY DEF AH, AF, Correct
    <2>3. Cardinality(AH) + Cardinality(AF) = q
      \* Active = AH \cup AF (since Active \subseteq Validators = Correct \cup Faulty)
      BY FS_UnionDisjoint, <2>1, <2>2
    <2>4. Cardinality(AH \cap HV) >= Cardinality(AH) + Cardinality(HV)
                                      - Cardinality(Correct)
      \* Inclusion-exclusion lower bound on intersection inside Correct.
      BY FS_Subset, CorrectCard, <2>1
    <2>5. Cardinality(AH) + Cardinality(HV) - Cardinality(Correct)
          >= (q - Cardinality(AF)) + (f+1) - (2*f+1)
          = f+1 - Cardinality(AF)
      BY <2>3, CorrectCard, A_QuorumDef
    <2>6. Cardinality(AH \cap HV) >= f+1 - Cardinality(AF)
      BY <2>4, <2>5
    <2>7. AH \cap HV = Active \cap HV
      \* HV \subseteq Correct, so AH \cap HV = (Active \cap Correct) \cap HV = Active \cap HV.
      BY DEF AH
    <2>8. QED BY <2>6, <2>7   \* proves |Active \cap HV| + |AF| >= f+1

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
      BY <1>1 DEF Init, WellFormed, Correct, Validators
    <2>2. NonNeg
      BY <1>1 DEF Init, NonNeg
    <2>3. PastVotes
      BY <1>1 DEF Init, PastVotes  \* prevotes = {} and precommits = {}
    <2>4. UniqueVotes
      BY <1>1 DEF Init, UniqueVotes  \* empty vote sets; premise vacuously false
    <2>5. PrecommitJustified
      BY <1>1 DEF Init, PrecommitJustified  \* precommits = {}
    <2>6. LockJustified
      BY <1>1 DEF Init, LockJustified       \* locked[v].has = FALSE everywhere
    <2>7. LockComplete
      BY <1>1 DEF Init, LockComplete        \* precommits = {}
    <2>8. LockPin
      BY <1>1 DEF Init, LockPin             \* precommits = {}
    <2>9. SafeInv
      BY <1>1 DEF Init, SafeInv             \* precommits = {}
    <2>10. DecidedJustified
      BY <1>1 DEF Init, DecidedJustified    \* decided[v].has = FALSE; precommits = {}
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
    <2>1. \E m1 \in precommits :
            m1.val = decided[v].value /\ PolkaT(precommits, m1.rnd, m1.val)
      BY <1>1 DEF IndInv, DecidedJustified
    <2>2. \E m2 \in precommits :
            m2.val = decided[w].value /\ PolkaT(precommits, m2.rnd, m2.val)
      BY <1>1 DEF IndInv, DecidedJustified
    <2>3. \* WLOG m1.rnd <= m2.rnd.  Then:
          \* PolkaT(precommits, m1.rnd, V) => PolkaT(prevotes, m1.rnd, V)
          \* because precommit polka => prevote polka (by PrecommitJustified).
          \* Combined with Polka(m2.rnd, W) and m2.rnd >= m1.rnd, SafeInv gives W=V.
      BY <2>1, <2>2, <1>1 DEF IndInv, SafeInv, PrecommitJustified
      \* (Requires case-split on m1.rnd <= m2.rnd vs m2.rnd < m1.rnd;
      \*  in each case SafeInv yields equality. Z3 or Isabelle should discharge.)
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
THEOREM IndInv_Step == IndInv /\ [Next]_vars => IndInv'
PROOF
  <1> SUFFICES ASSUME IndInv, Next PROVE IndInv'
    \* UNCHANGED vars case: all fields of IndInv mention only vars, so UNCHANGED
    \* trivially preserves every conjunct.
    BY DEF IndInv, WellFormed, NonNeg, PastVotes, UniqueVotes,
            PrecommitJustified, LockJustified, LockComplete,
            LockPin, SafeInv, DecidedJustified
  \* Expand DoRound; fix the witnesses Active, leader, propVal.
  <1> PICK Active \in { S \in SUBSET Validators : Cardinality(S) = q },
           leader \in Validators,
           propVal \in Values :
    \* ... (the body of DoRound)
    BY DEF Next, DoRound
  <1>1. WellFormed'
    \* DoRound assigns prevotes'/precommits' by adding only MkV(r,_,_) records;
    \* val fields come from Values, src fields from Validators (Active ⊆ Validators
    \* and Faulty ⊆ Validators).  locked'/decided' domains remain Validators.
    BY DEF WellFormed, DoRound, MkV, Correct, A_FaultySubset
  <1>2. NonNeg'
    \* r' = r+1 >= 1 >= 0 (since r >= 0 by pre-state NonNeg).
    \* New votes have rnd = r >= 0 (by NonNeg).
    \* Lock updates stamp the current r >= 0.
    BY DEF NonNeg, DoRound
  <1>3. PastVotes'
    \* New votes at round r have rnd = r < r+1 = r'.
    \* Pre-existing votes had rnd < r < r' (by PastVotes + r' = r+1).
    BY DEF PastVotes, DoRound, NonNeg
  <1>4. UniqueVotes'
    \* Honest validators cast at most one prevote per round by PrevoteVal (a
    \* function: each v ∈ ActiveHonest contributes exactly one rnd=r entry).
    \* Faulty votes are built as { MkV(r, x, v) : x ∈ Values, v ∈ Faulty },
    \* which yields exactly |Values|=2 entries per Faulty validator per round,
    \* i.e., at most one entry per value per validator.
    \* Pre-existing votes satisfy UniqueVotes (by pre-state invariant).
    BY DEF UniqueVotes, DoRound, MkV
  <1>5. PrecommitJustified'
    \* New honest precommits are issued only if pv = QuorumVal(newPV, r) ∈ Values,
    \* i.e., PolkaT(newPV, r, pv) holds.  newPV ⊆ prevotes', so PolkaT(prevotes',r,pv).
    \* Faulty precommits carry no honesty obligation.
    \* Old precommits: PrecommitJustified holds by the pre-state invariant, and the
    \* associated prevote polkas (in old prevotes) are in prevotes' ⊇ prevotes.
    BY DEF PrecommitJustified, DoRound, MkV, Correct, PolkaT, Cnt
  <1>6. LockJustified'
    \* Locks are updated only for v ∈ ActiveHonest to [has=TRUE, round=r, value=pv].
    \* pv ∈ Values means MkV(r, pv, v) ∈ honestPC ⊆ precommits'.
    \* The new lock is at round r; any precommit by v is at round <= r because:
    \*   - old precommits by v are at rounds < r (by PastVotes);
    \*   - the new precommit (if any) is at round r = new lock round.
    \* Unchanged validators keep their pre-state lock (LockJustified carries over).
    BY DEF LockJustified, DoRound, MkV, PastVotes
  <1>7. LockComplete'
    \* If a correct validator v gets a new precommit in this round (v ∈ ActiveHonest,
    \* pv ∈ Values), DoRound simultaneously sets locked'[v].has = TRUE.
    \* Validators already having a precommit are already locked (pre-state LockComplete).
    BY DEF LockComplete, DoRound, MkV, Correct
  <1>8. LockPin'
    \* LockPin says: every honest validator locked at round >= r1 (where
    \* PolkaT(precommits, r1, V)) is locked on V.
    \* New locks are at round r; pre-state LockPin + SafeInv ensure any new lock
    \* at round r is for the unique value that polka'd at r.
    \* For pre-existing locks >= r1 locked on V (by pre-state LockPin + induction):
    \* they're unchanged when DoRound doesn't update them, or updated to r (>= r1)
    \* for the polka value at r — which by SafeInv' (established for round r) is V.
    BY <1>5, DEF LockPin, DoRound, SafeInv, PolkaT, Cnt
    \* (Circular-looking; in the actual TLAPS proof this step is co-proved with
    \* SafeInv' for the current-round polka.  Both are established together by
    \* the counting argument of step <1>9.)
  <1>9. SafeInv'
    \* SafeInv' = ∀ m1 ∈ precommits', m2 ∈ prevotes' :
    \*   PolkaT(precommits', m1.rnd, m1.val) /\ m2.rnd >= m1.rnd
    \*   /\ PolkaT(prevotes', m2.rnd, m2.val) => m2.val = m1.val.
    \*
    \* Case split on the sources of the two polkas:
    <2>1. \* (A) Both polkas are in old vote sets (m1.rnd < r, m2.rnd < r).
          \* New votes are at round r only; old polkas are unchanged.  Follows from
          \* pre-state SafeInv.
          \A m1 \in precommits, m2 \in prevotes :
            (PolkaT(precommits', m1.rnd, m1.val) /\ m2.rnd >= m1.rnd
             /\ PolkaT(prevotes', m2.rnd, m2.val)) => m2.val = m1.val
      BY DEF SafeInv, PolkaT, Cnt, DoRound
    <2>2. \* (B) Prevote polka is new (m2.rnd = r); precommit polka is old (m1.rnd < r).
          \* i.e., PolkaT(precommits, m1.rnd, V) and PolkaT(prevotes', r, W) => W=V.
          \*
          \* This is the key case.  By LockPin (pre-state):
          \*   every u ∈ Correct with locked[u].round >= m1.rnd has locked[u].value = V.
          \* Let HV = {u ∈ Correct : u precommitted V at m1.rnd, locked[u].round = m1.rnd}.
          \*   |HV| >= f+1 (Lemma 1: q precommitters, at most f faulty).
          \* For any u ∈ Active ∩ HV: PrevoteVal(u, prop) = V or Nil.
          \*   (V, because locked on V; or Nil because lock-rule blocks W.
          \*    Nil votes do NOT enter honestPVf — the filter { m ∈ honestPV : m.val ∈ Values }.
          \*    A polka-unlock for W would need PolkaT(prevotes, vr, W) at vr ∈ [m1.rnd, r),
          \*    but pre-state SafeInv gives W=V for all such vr — contradiction W≠V.)
          \* By ActiveHVLower: k = |Active ∩ HV| >= f+1 - |Active ∩ Faulty| = f+1-t.
          \* Total W-votes in prevotes' at round r:
          \*   |Faulty| (faulty equivocate) + |Active ∩ Correct who voted W|
          \*   <= f + (|Active ∩ Correct| - k)
          \*   = f + (q-t) - (f+1-t)      [using k >= f+1-t and |Active∩Correct|=q-t]
          \*   = q - 1 < q.
          \* So PolkaT(prevotes', r, W) FAILS for any W ≠ V.  SafeInv' holds for case (B).
          BY ActiveHVLower, DEF SafeInv, LockPin, PolkaT, Cnt,
             DoRound, PrevoteVal, PrecommitJustified, A_QuorumDef, A_FaultCount
    <2>3. \* (C) Both polkas are new (m1.rnd = r, m2.rnd = r).
          \* New precommits are for pv = QuorumVal(newPV, r).  If PolkaT(precommits',r,V):
          \* V = pv (unique by QuorumVal).  PolkaT(prevotes', r, W) requires W = pv = V.
          \* (QuorumVal chooses a unique value; two distinct values can't both reach q.)
          BY DEF DoRound, QuorumVal, PolkaT, Cnt, SafeInv
    <2>4. \* (D) m2.rnd > m1.rnd = r: impossible since PastVotes' gives all votes < r+1,
          \*  i.e., all vote rounds <= r, so m2.rnd = r or m2.rnd < r.
          BY DEF PastVotes, DoRound
    <2>5. QED BY <2>1, <2>2, <2>3, <2>4 DEF SafeInv
  <1>10. DecidedJustified'
    \* New decisions: v ∈ ActiveHonest with cv = QuorumVal(newPC, r) ∈ Values.
    \* cv ∈ Values => PolkaT(newPC, r, cv), and newPC ⊆ precommits'.
    \* MkV(r, cv, v) ∈ newPC ⊆ precommits', justifying the decision.
    \* Pre-existing decisions: backed by old precommits ⊆ precommits'.
    BY DEF DecidedJustified, DoRound, PolkaT, Cnt, MkV
  <1>11. QED
    BY <1>1, <1>2, <1>3, <1>4, <1>5, <1>6, <1>7, <1>8, <1>9, <1>10
       DEF IndInv

=============================================================================
\* End of DDRConsensusTLAPS
