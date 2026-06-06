#!/usr/bin/env bash
# Parametric safety proof (all n=3f+1) for DDR consensus — TLAPS (tlapm).
# Discharges, machine-checked, the parametric quorum-intersection counting core
# plus Init => IndInv; the protocol-level inductive step is structured with
# OMITTED leaves (see docs/audit/16-parametric-safety-tlaps.md).
#
# Machine-checked (143 obligations, 0 failed):
#   LEMMA CorrectCard      -- |Correct| = 2f+1                      (parametric f)
#   LEMMA QuorumIntersect  -- two (f+1)-subsets of Correct intersect (FS_MajoritiesIntersect)
#   LEMMA ActiveHVLower    -- |Active cap HV| + |Active cap Faulty| >= f+1  (the counting core)
#   THEOREM Init_IndInv    -- Init => IndInv
#   THEOREM IndInv_Agreement / IndInv_Step -- proof structure; 14 OMITTED protocol leaves
set -uo pipefail
cd "$(dirname "$0")"
M=DDRConsensusTLAPS.tla

TLAPM="$(command -v tlapm || true)"
[ -z "$TLAPM" ] && [ -x /opt/tlaps/bin/tlapm ] && TLAPM=/opt/tlaps/bin/tlapm
if [ -z "$TLAPM" ]; then
  echo "tlapm not found. Install with: ./fetch-tlaps.sh   (then add /opt/tlaps/bin to PATH)"
  exit 1
fi

echo "== TLAPS version =="; "$TLAPM" --version
echo "== proof summary (obligations + omitted leaves) =="
"$TLAPM" --summary $M 2>&1 | grep -A4 'summary of module "DDRConsensusTLAPS"' | grep -vE "PATH=|not found"
echo "== verify (all non-omitted obligations) =="
"$TLAPM" --toolbox 0 0 --cleanfp $M 2>&1 | grep -E "All [0-9]+ obligations proved|obligations failed" | tail -1
