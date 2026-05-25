#!/usr/bin/env python3
from pathlib import Path
import sys

repo = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/opt/msr/repo/msr")
aa_cpp = repo / "zone" / "aa.cpp"

if not aa_cpp.exists():
    raise SystemExit(f"Recovery Slice v30 verification failed: missing {aa_cpp}")

s = aa_cpp.read_text()

if "MSR recovery guard: skipping AA table send to isolate zone-entry crash" in s:
    raise SystemExit("Recovery Slice v30 verification failed: temporary AA table guard text is still present")

bad_patterns = [
    "return;\n\tfor(auto &aa : zone->aa_abilities)",
    "return;\n        for(auto &aa : zone->aa_abilities)",
    "return;\n    for(auto &aa : zone->aa_abilities)",
]
if any(p in s for p in bad_patterns):
    raise SystemExit("Recovery Slice v30 verification failed: SendAlternateAdvancementTable still returns before AA loop")

if "rank->id == aaOrigin || ability->id == aaOrigin" not in s:
    raise SystemExit("Recovery Slice v30 verification failed: Origin/Bazaar AA condition was not patched to include rank->id")

if 'Custom "Bazaar and Back" Origin AA behavior' not in s:
    raise SystemExit("Recovery Slice v30 verification failed: custom Bazaar-and-Back Origin block missing")

print("Recovery Slice v30 verification passed.")
