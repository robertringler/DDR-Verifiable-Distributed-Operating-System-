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

(***************************************************************************)
(* The inductive invariant behind the unbounded paper proof (M5b,          *)
(* docs/audit/13-unbounded-safety-proof.md): once a value V is committed at *)
(* round r1, every polka at any round >= r1 is for V. TLC confirms SafeInv  *)
(* holds on all reachable states of the bounded model; the paper proof      *)
(* shows it is inductive for all n, f<n/3 and unbounded rounds. SafeInv =>  *)
(* Agreement (a second commit needs a later polka for its value).          *)
(***************************************************************************)
PolkaT(rr, val)  == Cnt(prevotes, rr, val) >= q
CommitT(rr, val) == Cnt(precommits, rr, val) >= q

SafeInv ==
  \A r1 \in 0..r, V \in Values, r2 \in 0..r, W \in Values :
     (CommitT(r1, V) /\ r2 >= r1 /\ PolkaT(r2, W)) => (W = V)

(***************************************************************************)
(* The FULL inductive invariant behind the unbounded paper proof: SafeInv  *)
(* plus the support conjuncts the proof relies on. TLC confirms the whole   *)
(* conjunction holds on every reachable state (n=4 and n=7) — so every      *)
(* clause of the hand proof is a genuine invariant of the model, not just   *)
(* the headline SafeInv.                                                    *)
(***************************************************************************)
PV(rr, vv, v) == [rnd |-> rr, val |-> vv, src |-> v]

\* Votes only ever concern rounds strictly before the current one.
PastVotes ==
  /\ \A m \in prevotes   : m.rnd < r
  /\ \A m \in precommits : m.rnd < r

\* An honest validator casts at most one prevote / precommit per round.
UniqueVotes ==
  \A v \in Correct, rr \in 0..r :
    /\ Cardinality({ vv \in Values : PV(rr, vv, v) \in prevotes })   <= 1
    /\ Cardinality({ vv \in Values : PV(rr, vv, v) \in precommits }) <= 1

\* An honest precommit is backed by a polka at the same round.
PrecommitJustified ==
  \A m \in precommits : m.src \in Correct => PolkaT(m.rnd, m.val)

\* An honest lock equals that validator's highest-round precommit.
LockJustified ==
  \A v \in Correct :
    locked[v].has =>
      /\ PV(locked[v].round, locked[v].value, v) \in precommits
      /\ \A m \in precommits : m.src = v => m.rnd <= locked[v].round

\* Converse of LockJustified, discovered necessary by the Apalache inductive
\* check: an honest validator that has precommitted is locked.
LockComplete ==
  \A v \in Correct : (\E m \in precommits : m.src = v) => locked[v].has

\* Lock pinning: once V is committed at r1, every honest lock at a round >= r1
\* is on V. (This is the conjunct that makes SafeInv's induction close.)
LockPin ==
  \A v \in Correct, r1 \in 0..r, V \in Values :
    (CommitT(r1, V) /\ locked[v].has /\ locked[v].round >= r1) => locked[v].value = V

IndInv ==
  /\ PastVotes
  /\ UniqueVotes
  /\ PrecommitJustified
  /\ LockJustified
  /\ LockComplete
  /\ LockPin
  /\ SafeInv

\* Type sanity (cheap, helps catch modeling slips).
TypeOK ==
  /\ r \in 0..(MaxRound + 1)
  /\ \A v \in Validators : locked[v].has \in BOOLEAN
  /\ \A v \in Validators : decided[v].has \in BOOLEAN
=============================================================================
