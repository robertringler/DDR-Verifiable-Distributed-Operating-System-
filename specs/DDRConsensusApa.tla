-------------------------- MODULE DDRConsensusApa --------------------------
(***************************************************************************)
(* Typed (Apalache) port of DDRConsensus for the INDUCTIVE-STEP discharge. *)
(* Same round-synchronized lock-rule model; UseLock is hard-wired TRUE     *)
(* (we only mechanize the safe variant). Goal: machine-check               *)
(*   (1) Init    => IndInv      (length 0 from Init)                        *)
(*   (2) IndInv /\ Next => IndInv'   (length 1 from CInit)                  *)
(*   (3) IndInv => Agreement    (length 0 from CInit)                       *)
(* (2) is the unbounded-rounds step that the paper proof does by hand.      *)
(***************************************************************************)
EXTENDS Integers, FiniteSets

\* @typeAlias: vote = { rnd: Int, val: Str, src: Str };
\* @typeAlias: lock = { has: Bool, round: Int, value: Str };
\* @typeAlias: dec  = { has: Bool, value: Str };
DDR_typedefs == TRUE

CONSTANTS
  \* @type: Set(Str);
  Validators,
  \* @type: Set(Str);
  Faulty,
  \* @type: Set(Str);
  Values,
  \* @type: Int;
  MaxRound,
  \* @type: Int;
  q

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

\* Constant initializer for Apalache (--cinit). n=4, f=1, q=3.
ConstInit ==
  /\ Validators = {"v1", "v2", "v3", "v4"}
  /\ Faulty = {"v4"}
  /\ Values = {"a", "b"}
  /\ MaxRound = 3
  /\ q = 3

ConstInit6 ==
  /\ Validators = {"v1", "v2", "v3", "v4"}
  /\ Faulty = {"v4"}
  /\ Values = {"a", "b"}
  /\ MaxRound = 6
  /\ q = 3

Correct == Validators \ Faulty
Nil == "nil"

\* @type: (Set($vote), Int, Str) => Int;
Cnt(S, rr, vv) == Cardinality({ m \in S : m.rnd = rr /\ m.val = vv })
PolkaT(S, rr, vv)  == Cnt(S, rr, vv) >= q
QuorumVal(S, rr) ==
  IF \E vv \in Values : Cnt(S, rr, vv) >= q
  THEN CHOOSE vv \in Values : Cnt(S, rr, vv) >= q
  ELSE Nil

\* @type: (Int, Str, Str) => $vote;
MkV(rr, vv, v) == [rnd |-> rr, val |-> vv, src |-> v]

\* Honest prevote rule (lock enforced).
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

Init ==
  /\ r = 0
  /\ prevotes = {}
  /\ precommits = {}
  /\ locked  = [v \in Validators |-> [has |-> FALSE, round |-> 0,
                                      value |-> CHOOSE x \in Values : TRUE]]
  /\ decided = [v \in Validators |-> [has |-> FALSE,
                                      value |-> CHOOSE x \in Values : TRUE]]

DoRound ==
  /\ r <= MaxRound
  /\ \E Active \in { S \in SUBSET Validators : Cardinality(S) = q } :
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

Done == r > MaxRound /\ UNCHANGED vars
Next == DoRound \/ Done

Agreement ==
  \A v, w \in Correct :
     (decided[v].has /\ decided[w].has) => (decided[v].value = decided[w].value)

PastVotes ==
  /\ \A m \in prevotes   : m.rnd < r
  /\ \A m \in precommits : m.rnd < r

UniqueVotes ==
  \A v \in Correct, rr \in 0..MaxRound :
    /\ Cardinality({ vv \in Values : MkV(rr, vv, v) \in prevotes })   <= 1
    /\ Cardinality({ vv \in Values : MkV(rr, vv, v) \in precommits }) <= 1

PrecommitJustified ==
  \A m \in precommits : m.src \in Correct => PolkaT(prevotes, m.rnd, m.val)

LockJustified ==
  \A v \in Correct :
    locked[v].has =>
      /\ MkV(locked[v].round, locked[v].value, v) \in precommits
      /\ \A m \in precommits : m.src = v => m.rnd <= locked[v].round

\* Converse: an honest validator that has ever precommitted is locked. (The CTI
\* showed IndInv otherwise admits unreachable states with a precommit but no
\* lock, letting a pinned value be re-voted.)
LockComplete ==
  \A v \in Correct : (\E m \in precommits : m.src = v) => locked[v].has

LockPin ==
  \A v \in Correct, r1 \in 0..MaxRound, V \in Values :
    (PolkaT(precommits, r1, V) /\ locked[v].has /\ locked[v].round >= r1)
      => locked[v].value = V

SafeInv ==
  \A r1 \in 0..MaxRound, V \in Values, r2 \in 0..MaxRound, W \in Values :
     (PolkaT(precommits, r1, V) /\ r2 >= r1 /\ PolkaT(prevotes, r2, W)) => (W = V)

\* An honest decision is backed by a commit-quorum (precommit polka).
DecidedJustified ==
  \A v \in Correct :
    decided[v].has => \E rr \in 0..MaxRound : PolkaT(precommits, rr, decided[v].value)

IndInv ==
  /\ PastVotes
  /\ UniqueVotes
  /\ PrecommitJustified
  /\ LockJustified
  /\ LockComplete
  /\ LockPin
  /\ SafeInv
  /\ DecidedJustified

\* Assigning version of IndInv, usable as an Apalache `--init` predicate.
AllVotes == { MkV(rr, vv, v) : rr \in 0..MaxRound, vv \in Values, v \in Validators }
AllLocks == [ has : BOOLEAN, round : 0..MaxRound, value : Values ]
AllDecs  == [ has : BOOLEAN, value : Values ]

CInit ==
  /\ r \in 0..(MaxRound + 1)
  /\ prevotes  \in SUBSET AllVotes
  /\ precommits \in SUBSET AllVotes
  /\ locked  \in [ Validators -> AllLocks ]
  /\ decided \in [ Validators -> AllDecs ]
  /\ IndInv
=============================================================================
