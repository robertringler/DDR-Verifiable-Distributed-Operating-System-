#!/usr/bin/env bash
# One-time: fetch the Apalache symbolic model checker (not committed).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p tools
if [ ! -x tools/apalache/bin/apalache-mc ]; then
  curl -sSL -o /tmp/apalache.tgz \
    https://github.com/apalache-mc/apalache/releases/latest/download/apalache.tgz
  tar xzf /tmp/apalache.tgz -C tools
fi
tools/apalache/bin/apalache-mc version
