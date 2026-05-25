#!/usr/bin/env python3
from pathlib import Path
import sys

repo = Path(sys.argv[1] if len(sys.argv) > 1 else "/opt/msr/repo/msr")
aa_cpp = repo / "zone" / "aa.cpp"

if not aa_cpp.exists():
    raise SystemExit(f"ERROR: Missing {aa_cpp}")

text = aa_cpp.read_text()

required = [
    "Custom handling for Bazaar and Back / Origin AA",
    "rank->id == aaOrigin || ability->id == aaOrigin || ability->id == 331",
    'current_zone == "bazaar"',
    'GetBucket("Return-Zone")',
    'MovePC(return_zone_id, return_instance, return_x, return_y, return_z, return_h);',
    'MovePC(bazaar_id, 0, -151.44f, 168.93f, -16.25f, 0.0f);',
    'MovePC(bazaar_id, 0, -151.47f, -177.88f, -16.25f, 0.0f);',
]

missing = [item for item in required if item not in text]
if missing:
    print("ERROR: v31 Bazaar and Back return verification failed. Missing:")
    for item in missing:
        print(f"  - {item}")
    raise SystemExit(1)

bad = [
    'MovePC(bazaar_id, 0, 0.0f, 0.0f, 0.0f, 0.0f);',
    'if (ability->id == aaOrigin) {',
]
present_bad = [item for item in bad if item in text]
if present_bad:
    print("ERROR: stale v30/old Bazaar AA code still appears:")
    for item in present_bad:
        print(f"  - {item}")
    raise SystemExit(1)

print("Recovery Slice v31 Bazaar and Back return verification passed.")
