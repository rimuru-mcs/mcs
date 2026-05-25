#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-/opt/msr/repo/msr}"
AA_CPP="$REPO/zone/aa.cpp"

if [[ ! -f "$AA_CPP" ]]; then
  echo "ERROR: zone/aa.cpp not found at: $AA_CPP" >&2
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
cp "$AA_CPP" "$AA_CPP.v30_bazaar_origin_aa.bak_$STAMP"

python3 - "$AA_CPP" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
s = path.read_text()
original = s

# Remove the temporary AA table guard that was added during zone-entry crash isolation.
# Keep the function and the real for(auto &aa : zone->aa_abilities) loop intact.
s = re.sub(
    r'\n[ \t]*LogDebug\("MSR recovery guard: skipping AA table send to isolate zone-entry crash"\);\s*\n[ \t]*return;\s*',
    "\n",
    s,
    count=1,
)

# Fix Bazaar-and-Back custom Origin behavior.
# In this schema, aaOrigin is rank id 1000, while the Origin ability id is 331.
custom_comment = '// --- Custom handling for Origin AA ---'
idx = s.find(custom_comment)
if idx == -1:
    raise SystemExit("ERROR: Could not find custom Origin AA block marker in zone/aa.cpp")

before = s[:idx]
after = s[idx:]

old_condition = 'if (ability->id == aaOrigin) {'
new_condition = 'if (rank->id == aaOrigin || ability->id == aaOrigin) {'

if new_condition not in after:
    if old_condition not in after:
        raise SystemExit("ERROR: Could not find Origin AA condition to patch after custom block marker")
    after = after.replace(old_condition, new_condition, 1)

s = before + after

if s == original:
    print("No changes made; file already appears patched.")
else:
    path.write_text(s)
    print(f"Patched {path}")
PY

echo
echo "Patch summary:"
grep -n -A12 "void Client::SendAlternateAdvancementTable" "$AA_CPP" | sed -n '1,24p'
echo
grep -n -A28 "Custom \"Bazaar and Back\" Origin AA behavior" "$AA_CPP" | sed -n '1,42p'
