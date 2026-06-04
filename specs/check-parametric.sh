#!/usr/bin/env bash
# Parametric safety proof (all n=3f+1) for DDR consensus — TLAPS proof structure.
# Run with the TLA+ Proof System (tlaps).
#
# Status: proof structure complete; requires the `tlaps` tool to machine-check.
# See docs/audit/16-parametric-safety-tlaps.md.
#
# Install TLAPS:
#   https://tla.msr-inria.inria.fr/tlaps/content/Download/Binaries.html
#   (ships with the TLA+ Toolbox; standalone Linux binary also available)
#
# Usage (once tlaps is installed):
#   cd specs
#   ./check-parametric.sh       # type-check + attempt proof
set -euo pipefail
cd "$(dirname "$0")"
M=DDRConsensusTLAPS.tla

if ! command -v tlaps &>/dev/null; then
  echo "TLAPS not found. Install from:"
  echo "  https://tla.msr-inria.inria.fr/tlaps/content/Download/Binaries.html"
  echo ""
  echo "Proof structure summary (from $M):"
  echo "  THEOREM Init_IndInv      -- Init => IndInv         (trivial; all vars = empty/FALSE)"
  echo "  THEOREM IndInv_Agreement -- IndInv => Agreement    (SafeInv + DecidedJustified)"
  echo "  THEOREM IndInv_Step      -- IndInv /\ Next => IndInv'  (key: case <1>9 SafeInv')"
  echo ""
  echo "The counting argument for SafeInv' (case B, the hard case):"
  echo "  k + t >= f+1  (ActiveHVLower lemma)"
  echo "  max W-votes = f + (q-t-k) <= f + (q-t-(f+1-t)) = q-1 < q"
  echo "  => no conflicting prevote polka"
  exit 1
fi

echo "== TLAPS typecheck =="
tlaps --toolbox DDRConsensusTLAPS.tla

echo "== Obligation (1): Init => IndInv =="
tlaps --toolbox --theorem Init_IndInv DDRConsensusTLAPS.tla

echo "== Obligation (2): IndInv => Agreement =="
tlaps --toolbox --theorem IndInv_Agreement DDRConsensusTLAPS.tla

echo "== Obligation (3): IndInv /\ Next => IndInv' (parametric n) =="
tlaps --toolbox --theorem IndInv_Step DDRConsensusTLAPS.tla
