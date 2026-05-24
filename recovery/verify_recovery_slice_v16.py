#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = {
    "database/recovery/migrations_safe/080_disable_defiant_lootdrop_spawn_sources.sql": [
        "080_disable_defiant_lootdrop_spawn_sources.sql",
        "disabled_chance",
        "chance` = 0",
        "msr_recovery_migration_log",
        "Defiant",
    ],
    "database/recovery/audits/20_defiant_spawn_cleanup_recovery_audit.sql": [
        "20_defiant_spawn_cleanup_recovery",
        "defiant_lootdrop_rows_still_active",
        "defiant_lootdrop_rows_disabled",
        "defiant_active_lootdrop_rows_after",
    ],
    "database/recovery/migrations_pending/130_review_defiant_spawn_cleanup.sql": [
        "Defiant lootdrop",
        "Reversal",
    ],
    "docs/recovery/RECOVERY_SLICE_V16_DEFIANT_LOOTDROP_RECOVERY.md": [
        "Defiant Lootdrop Spawn Recovery",
        "defiant_lootdrop_rows_still_active = 0",
    ],
}


def fail(message: str) -> None:
    print(f"Recovery Slice v16 verification failed: {message}", file=sys.stderr)
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

    print("Recovery Slice v16 verification passed.")


if __name__ == "__main__":
    main()
