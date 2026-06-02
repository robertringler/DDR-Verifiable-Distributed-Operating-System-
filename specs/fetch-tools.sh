#!/usr/bin/env bash
# Fetch the TLA+ tools (TLC model checker). The jar is not committed.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p tools
if [ ! -f tools/tla2tools.jar ]; then
  curl -sSL -o tools/tla2tools.jar \
    https://github.com/tlaplus/tlaplus/releases/latest/download/tla2tools.jar
fi
echo "tools/tla2tools.jar ready ($(wc -c < tools/tla2tools.jar) bytes)"
