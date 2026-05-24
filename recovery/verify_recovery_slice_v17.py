#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = {
    "database/recovery/migrations_safe/090_fix_blackburrow_jaggedpine_door_targets.sql": [
        "090_fix_blackburrow_jaggedpine_door_targets.sql",
        "msr_recovery_blackburrow_door_backup",
        "blackburrow",
        "jaggedpine",
        "dest_zone` = 'NONE'",
        "msr_recovery_migration_log",
    ],
    "database/recovery/audits/21_blackburrow_door_recovery_audit.sql": [
        "21_blackburrow_door_recovery",
        "blackburrow_doors_still_targeting_jaggedpine",
        "blackburrow_door_backup_summary",
        "blackburrow_door_migration_log",
    ],
    "database/recovery/migrations_pending/140_review_blackburrow_door_recovery.sql": [
        "Blackburrow",
        "Reversal",
        "msr_recovery_blackburrow_door_backup",
    ],
    "docs/recovery/RECOVERY_SLICE_V17_BLACKBURROW_DOOR_RECOVERY.md": [
        "Blackburrow Door Recovery",
        "blackburrow_doors_still_targeting_jaggedpine = 0",
    ],
}


def fail(message: str) -> None:
    print(f"Recovery Slice v17 verification failed: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    for rel, needles in REQUIRED.items():
        path = ROOT / rel
        if not path.exists():
            fail(f"missing required file: {rel}")
        text = path.read_text(encoding="utf-8", errors="replace")
        for needle in needles:
            if needle not in text:
                fail(f"{rel} missing required text: {needle}")

    print("Recovery Slice v17 verification passed.")


if __name__ == "__main__":
    main()
