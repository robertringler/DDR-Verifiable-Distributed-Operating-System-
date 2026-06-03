#!/usr/bin/env bash
# Discharge the inductive-invariant proof of consensus safety with Apalache.
set -euo pipefail
cd "$(dirname "$0")"
BIN=../tools/apalache/bin/apalache-mc
[ -x "$BIN" ] || ./fetch-apalache.sh
C="--cinit=ConstInit --next=Next"
echo "== (1) Init => IndInv =="
$BIN check $C --init=Init  --inv=IndInv     --length=0 DDRConsensusApa.tla | grep -E "no error|violated"
echo "== (2) IndInv => Agreement =="
$BIN check $C --init=CInit --inv=Agreement  --length=0 DDRConsensusApa.tla | grep -E "no error|violated"
echo "== (3) IndInv /\\ Next => IndInv'  (the inductive step) =="
$BIN check $C --init=CInit --inv=IndInv     --length=1 DDRConsensusApa.tla | grep -E "no error|violated"
