#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/23_old_nektulos_lavastorm_route_reference_audit.sql",
    "database/recovery/migrations_pending/140_review_old_nektulos_lavastorm_route_recovery.sql",
    "docs/recovery/RECOVERY_SLICE_V19_OLD_NEKTULOS_LAVASTORM_ROUTE_REFERENCE_AUDIT.md",
    "recovery/verify_recovery_slice_v19.py",
]

REQUIRED_TEXT = {
    "database/recovery/audits/23_old_nektulos_lavastorm_route_reference_audit.sql": [
        "23_old_nektulos_lavastorm_route_reference",
        "old_zone_policy",
        "candidate_zone_points_routing_to_new_instances",
        "candidate_doors_routing_to_new_instances",
        "teleport_spell_candidates",
        "spawn2_version_summary",
    ],
    "database/recovery/migrations_pending/140_review_old_nektulos_lavastorm_route_recovery.sql": [
        "DO NOT APPLY YET",
        "older/classic versions",
        "wizard/druid port",
        "backup tables",
    ],
}

def fail(message: str) -> None:
    print(f"Recovery Slice v19 verification failed: {message}", file=sys.stderr)
    sys.exit(1)

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.is_file():
        fail(f"required file missing: {rel}")

for rel, needles in REQUIRED_TEXT.items():
    text = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
    for needle in needles:
        if needle not in text:
            fail(f"{rel} missing required text: {needle}")

print("Recovery Slice v19 verification passed.")
