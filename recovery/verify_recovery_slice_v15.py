#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/19_defiant_spawn_source_audit.sql",
    "database/recovery/migrations_pending/130_review_defiant_spawn_cleanup.sql",
    "docs/recovery/RECOVERY_SLICE_V15_DEFIANT_SPAWN_SOURCE_AUDIT.md",
]

REQUIRED_TEXT = {
    "database/recovery/audits/19_defiant_spawn_source_audit.sql": [
        "defiant_lootdrop_summary",
        "defiant_merchant_summary",
        "defiant_spawn_source_recovery_preconditions",
    ],
    "database/recovery/migrations_pending/130_review_defiant_spawn_cleanup.sql": [
        "DO NOT APPLY BLINDLY",
        "Fixed an issue that was allowing defiant gear to spawn in game",
    ],
}

def fail(message: str) -> None:
    print(f"Recovery Slice v15 verification failed: {message}")
    sys.exit(1)

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.exists():
        fail(f"missing required file: {rel}")

for rel, needles in REQUIRED_TEXT.items():
    text = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
    for needle in needles:
        if needle not in text:
            fail(f"{rel} missing required text: {needle}")

print("Recovery Slice v15 verification passed.")
