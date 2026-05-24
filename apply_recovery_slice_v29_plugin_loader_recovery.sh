#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/opt/msr/server}"

if [[ ! -d "$ROOT" ]]; then
  echo "Server root not found: $ROOT" >&2
  exit 1
fi

mkdir -p "$ROOT/plugins"
mkdir -p "$ROOT/recovery_backups"

if [[ -f "$ROOT/plugins/plugin.pl" ]]; then
  cp "$ROOT/plugins/plugin.pl" "$ROOT/recovery_backups/plugin.pl.before_v29_$(date +%Y%m%d_%H%M%S)"
fi

cp "$(dirname "$0")/plugins/plugin.pl" "$ROOT/plugins/plugin.pl"

echo "Installed MSR v29 plugin loader to $ROOT/plugins/plugin.pl"
echo "Next: restart zones/world before testing clickdoor or zoneline behavior."
