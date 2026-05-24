#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/22_nektulos_lavastorm_version_audit.sql",
    "database/recovery/migrations_pending/130_review_nektulos_lavastorm_version_and_zoneline_recovery.sql",
    "docs/recovery/RECOVERY_SLICE_V18_NEKTULOS_LAVASTORM_AUDIT.md",
    "recovery/verify_recovery_slice_v18.py",
]

REQUIRED_TEXT = {
    "database/recovery/audits/22_nektulos_lavastorm_version_audit.sql": [
        "22_nektulos_lavastorm_version",
        "nektulos",
        "lavastorm",
        "zone_points",
        "poknowledge",
        "spawn2_version_summary",
    ],
    "database/recovery/migrations_pending/130_review_nektulos_lavastorm_version_and_zoneline_recovery.sql": [
        "DO NOT APPLY YET",
        "Nektulos",
        "Lavastorm",
        "backup tables",
    ],
}

def fail(message: str) -> None:
    print(f"Recovery Slice v18 verification failed: {message}", file=sys.stderr)
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

print("Recovery Slice v18 verification passed.")
