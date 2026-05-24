#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-/opt/msr/repo/msr}"
TARGET="$REPO_ROOT/zone/tribute.cpp"

if [[ ! -f "$TARGET" ]]; then
  echo "Missing target file: $TARGET" >&2
  exit 1
fi

python3 - "$TARGET" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()

guard = '/* MSR recovery v28 guard: skip guild tribute packet during zone-entry crash recovery. */\n    return;\n'

if 'MSR recovery v28 guard: skip guild tribute packet during zone-entry crash recovery' in text:
    print(f"{path}: v28 guild tribute guard already present")
    raise SystemExit(0)

patterns = [
    re.compile(r'(void\s+Client::SendGuildTributes\s*\(\s*\)\s*\{\s*)', re.MULTILINE),
]

for pat in patterns:
    match = pat.search(text)
    if match:
        insert_at = match.end()
        text = text[:insert_at] + guard + text[insert_at:]
        path.write_text(text)
        print(f"{path}: inserted v28 guild tribute guard")
        raise SystemExit(0)

raise SystemExit("Could not find function opening for Client::SendGuildTributes()")
PY

echo
echo "Verify with:"
echo "  python3 recovery/verify_recovery_slice_v28_guild_tribute_guard.py"
echo
echo "Then rebuild/copy zone:"
echo "  cmake --build \"$REPO_ROOT/build/linux-release\" --target zone -j\"\$(nproc)\""
echo "  pkill -f 'eqlaunch' || true"
echo "  pkill -f '/zone' || true"
echo "  cp \"$REPO_ROOT/build/linux-release/bin/zone\" /opt/msr/server/bin/zone.new"
echo "  chmod +x /opt/msr/server/bin/zone.new"
echo "  mv -f /opt/msr/server/bin/zone.new /opt/msr/server/bin/zone"
