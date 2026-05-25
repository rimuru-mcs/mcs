#!/usr/bin/env python3
from pathlib import Path
import sys

repo = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/opt/msr/repo/msr")
aa_cpp = repo / "zone" / "aa.cpp"

if not aa_cpp.exists():
    print(f"ERROR: Missing {aa_cpp}")
    raise SystemExit(1)

text = aa_cpp.read_text()

checks = [
    "Custom handling for Bazaar and Back / Origin AA",
    "rank->id == aaOrigin || ability->id == aaOrigin || ability->id == 331",
    'current_zone == "bazaar"',
    'GetBucket("Return-Zone")',
    'GetBucket("Return-X")',
    'GetBucket("Return-Y")',
    'GetBucket("Return-Z")',
    'GetBucket("Return-H")',
    'GetBucket("Return-Instance")',
    "MovePC(return_zone_id, return_instance, return_x, return_y, return_z, return_h);",
    "MovePC(bazaar_id, 0, -151.44f, 168.93f, -16.25f, 0.0f);",
    "MovePC(bazaar_id, 0, -151.47f, -177.88f, -16.25f, 0.0f);",
]

missing = [c for c in checks if c not in text]

if missing:
    print("ERROR: v31b Bazaar and Back return verification failed. Missing:")
    for item in missing:
        print(f"  - {item}")
    raise SystemExit(1)

print("Recovery Slice v31b Bazaar and Back return verification passed.")
