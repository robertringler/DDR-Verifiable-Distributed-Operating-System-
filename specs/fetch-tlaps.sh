#!/usr/bin/env bash
# One-time: fetch + install the TLA+ Proof System (TLAPS / tlapm).  Not committed.
# Installs to /opt/tlaps (the installer self-test compiles Isabelle/TLA+ theories).
set -euo pipefail
BIN=/opt/tlaps/bin/tlapm
if [ -x "$BIN" ]; then "$BIN" --version; exit 0; fi
INST=https://github.com/tlaplus/tlapm/releases/download/202210041448/tlaps-1.5.0-x86_64-linux-gnu-inst.bin
curl -sSL -o /tmp/tlaps-inst.bin "$INST"
chmod +x /tmp/tlaps-inst.bin
/tmp/tlaps-inst.bin -d /opt/tlaps
echo "Add /opt/tlaps/bin to PATH:  export PATH=/opt/tlaps/bin:\$PATH"
"$BIN" --version
