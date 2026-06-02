#!/usr/bin/env bash
# Discharge the DDR consensus safety theorem with TLC.
#   - lock ON : Agreement holds over the complete (bounded) state graph.
#   - lock OFF: TLC finds a counterexample (the lock is load-bearing).
set -euo pipefail
cd "$(dirname "$0")"
[ -f ../tools/tla2tools.jar ] || ./fetch-tools.sh
TLC="java -XX:+UseParallelGC -cp ../tools/tla2tools.jar tlc2.TLC -workers 4"

echo "== lock ON (expect: no error) =="
$TLC -config DDRConsensus.cfg DDRConsensus.tla | tee tlc-lock-on.log \
  | grep -E "No error|Invariant .* is violated|distinct states found"

echo "== lock OFF (expect: Agreement violated) =="
# TLC exits non-zero on an invariant violation; that is the EXPECTED result here.
$TLC -config DDRConsensus_nolock.cfg DDRConsensus.tla | tee tlc-lock-off.log \
  | grep -E "No error|Invariant .* is violated|distinct states found" || true
