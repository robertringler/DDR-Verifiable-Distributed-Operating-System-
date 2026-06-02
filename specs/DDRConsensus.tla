-------------------------- MODULE DDRConsensus --------------------------
(***************************************************************************)
(* TLA+ model of the DDR single-height BFT consensus with the Tendermint-  *)
(* style lock/unlock rule. This is the machine-checkable companion to the  *)
(* Rust `ddr-consensus` crate: the same round-synchronized model (active   *)
(* quorum per round = network partition, Byzantine nodes equivocate), so   *)
(* that TLC can *exhaustively* verify cross-round Agreement for a small     *)
(* configuration — discharging what the original DDR spec only asserted.   *)
(*                                                                          *)
(*   UseLock = TRUE  : Agreement holds (TLC: no violation).                 *)
(*   UseLock = FALSE : TLC finds a counterexample (lock is load-bearing).   *)
(***************************************************************************)
EXTENDS Integers, FiniteSets

CONSTANTS Validators, Faulty, Values, MaxRound, q, UseLock

ASSUME Faulty \subseteq Validators
ASSUME q \in Nat

Correct == Validators \ Faulty
Nil == "nil"            \* sentinel: a prevote/precommit for "nothing"

VARIABLES r, prevotes, precommits, locked, decided
vars == <<r, prevotes, precommits, locked, decided>>

\* Count distinct senders that voted `val` at round `rr` in vote-set `pset`.
Cnt(pset, rr, val) == Cardinality({ m \in pset : m.rnd = rr /\ m.val = val })
HasQuorum(pset, rr) == \E val \in Values : Cnt(pset, rr, val) >= q
\* Value with a quorum at round rr (at most one: honest vote once, < f+1 split).
QuorumVal(pset, rr) ==
  IF HasQuorum(pset, rr) THEN CHOOSE val \in Values : Cnt(pset, rr, val) >= q
  ELSE Nil

\* The safety-critical predicate: how an honest validator v prevotes given a
\* proposal `prop` = [val, vr] (vr = -1 means "no valid-round evidence").
PrevoteVal(v, prop) ==
  IF ~UseLock THEN prop.val                                  \* UNSAFE mode
  ELSE IF ~locked[v].has THEN prop.val                       \* not locked
  ELSE IF locked[v].value = prop.val THEN prop.val           \* matches our lock
  ELSE IF /\ prop.vr # -1                                    \* unlock evidence:
          /\ prop.vr >= locked[v].round                      \*   a polka for the
          /\ prop.vr < r                                     \*   proposed value at
          /\ Cnt(prevotes, prop.vr, prop.val) >= q           \*   round >= our lock
       THEN prop.val
  ELSE Nil                                                   \* else prevote nil

Init ==
  /\ r = 0
  /\ prevotes = {}
  /\ precommits = {}
  /\ locked  = [v \in Validators |-> [has |-> FALSE, round |-> 0,
                                      value |-> CHOOSE x \in Values : TRUE]]
  /\ decided = [v \in Validators |-> [has |-> FALSE,
                                      value |-> CHOOSE x \in Values : TRUE]]

(***************************************************************************)
(* One atomic round. The adversary chooses (nondeterministically) the      *)
(* active quorum (the partition that communicates this round), the leader,  *)
(* and — for a Byzantine or unlocked-honest leader — the proposed value.    *)
(* Faulty validators equivocate: they vote BOTH values, in and out of the   *)
(* active set. Honest active validators follow the protocol deterministically.*)
(***************************************************************************)
DoRound ==
  /\ r <= MaxRound
  /\ \E Active \in { S \in SUBSET Validators : Cardinality(S) = q } :
       \E leader \in Validators :
         \E propVal \in Values :
           \* avoid redundant states: a locked honest leader re-proposes its lock
           /\ (leader \in Faulty \/ ~locked[leader].has \/ propVal = locked[leader].value)
           /\ LET prop ==
                    IF leader \in Faulty THEN [val |-> propVal, vr |-> -1]
                    ELSE IF locked[leader].has
                         THEN [val |-> locked[leader].value, vr |-> locked[leader].round]
                         ELSE [val |-> propVal, vr |-> -1]
                  ActiveHonest == Active \ Faulty
                  honestPVraw == { [rnd |-> r, val |-> PrevoteVal(v, prop), src |-> v]
                                   : v \in ActiveHonest }
                  honestPV == { m \in honestPVraw : m.val \in Values }
                  faultyPV == { [rnd |-> r, val |-> x, src |-> v]
                                : v \in Faulty, x \in Values }
                  newPV == prevotes \cup honestPV \cup faultyPV
                  pv == QuorumVal(newPV, r)
                  honestPC == IF pv \in Values
                              THEN { [rnd |-> r, val |-> pv, src |-> v] : v \in ActiveHonest }
                              ELSE {}
                  faultyPC == { [rnd |-> r, val |-> x, src |-> v]
                                : v \in Faulty, x \in Values }
                  newPC == precommits \cup honestPC \cup faultyPC
                  cv == QuorumVal(newPC, r)
              IN /\ prevotes' = newPV
                 /\ precommits' = newPC
                 \* honest active validators LOCK on what they precommit
                 /\ locked' = [ v \in Validators |->
                                  IF v \in ActiveHonest /\ pv \in Values
                                  THEN [has |-> TRUE, round |-> r, value |-> pv]
                                  ELSE locked[v] ]
                 \* and DECIDE on a commit-quorum (once)
                 /\ decided' = [ v \in Validators |->
                                  IF v \in ActiveHonest /\ cv \in Values /\ ~decided[v].has
                                  THEN [has |-> TRUE, value |-> cv]
                                  ELSE decided[v] ]
                 /\ r' = r + 1

Done == r > MaxRound /\ UNCHANGED vars
Next == DoRound \/ Done
Spec == Init /\ [][Next]_vars

(***************************************************************************)
(* THE safety property: no two correct validators decide differently.      *)
(* This is the cross-round/cross-partition Agreement the original DDR Vol.I *)
(* Thm. 3.1 proof only established for a single round.                      *)
(***************************************************************************)
Agreement ==
  \A v, w \in Correct :
     (decided[v].has /\ decided[w].has) => (decided[v].value = decided[w].value)

\* Type sanity (cheap, helps catch modeling slips).
TypeOK ==
  /\ r \in 0..(MaxRound + 1)
  /\ \A v \in Validators : locked[v].has \in BOOLEAN
  /\ \A v \in Validators : decided[v].has \in BOOLEAN
=============================================================================
