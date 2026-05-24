#!/usr/bin/env python3
"""Verify MSR Recovery Slice v2 files are present and internally sane."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "docs/recovery/RECOVERY_SLICE_V2_DATABASE_BASELINE.md",
    "database/recovery/README.md",
    "database/recovery/RECOVERY_DB_FIX_MAP.md",
    "database/recovery/audits/00_schema_presence.sql",
    "database/recovery/audits/01_rules_and_server_defaults_audit.sql",
    "database/recovery/audits/02_global_buffs_audit.sql",
    "database/recovery/audits/03_syncrosatchel_audit.sql",
    "database/recovery/audits/04_sympathetic_items_audit.sql",
    "database/recovery/audits/05_zone_access_waypoints_audit.sql",
    "database/recovery/audits/06_defiant_and_missing_items_audit.sql",
    "database/recovery/migrations_safe/000_create_msr_recovery_ledger.sql",
    "database/recovery/migrations_safe/010_add_neutral_recovery_rule_placeholders.sql",
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql",
    "database/recovery/migrations_pending/030_review_global_buff_candidates.sql",
    "database/recovery/migrations_pending/040_review_zone_waypoint_candidates.sql",
    "database/recovery/migrations_pending/050_review_syncrosatchel_candidates.sql",
    "database/recovery/migrations_pending/060_review_sympathetic_item_candidates.sql",
    "recovery/run_db_audit.ps1",
    "recovery/run_db_audit.sh",
    "recovery/apply_db_migrations.ps1",
    "recovery/apply_db_migrations.sh",
]

FORBIDDEN_DIRS = [
    "build/vs2022",
    "build\\vs2022",
    "perl/x64",
    "vcpkg",
]

KEY_TERMS = {
    "database/recovery/audits/02_global_buffs_audit.sql": ["44000", "44007", "Echo of Power"],
    "database/recovery/audits/03_syncrosatchel_audit.sql": ["Syncrosatchel", "merchantlist"],
    "database/recovery/audits/04_sympathetic_items_audit.sql": ["Sympathetic", "Simple Ring of the Hero"],
    "database/recovery/migrations_safe/010_add_neutral_recovery_rule_placeholders.sql": ["Custom:PermanentServerBuffsEnabled", "false"],
    "database/recovery/RECOVERY_DB_FIX_MAP.md": ["corpse", "syncrosatchel", "Echo of Power", "Sympathetic"],
}


def fail(message: str) -> None:
    print(f"Recovery Slice v2 verification failed: {message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    for rel in REQUIRED_FILES:
        path = ROOT / rel
        if not path.is_file():
            fail(f"missing required file: {rel}")
        if path.stat().st_size == 0:
            fail(f"required file is empty: {rel}")

    for rel, terms in KEY_TERMS.items():
        text = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
        folded = text.lower()
        for term in terms:
            if term.lower() not in folded:
                fail(f"{rel} does not contain expected term: {term}")

    # Make sure safe migrations don't accidentally include broad UPDATEs for risky gameplay changes.
    safe_dir = ROOT / "database/recovery/migrations_safe"
    for sql_file in safe_dir.glob("*.sql"):
        text = sql_file.read_text(encoding="utf-8", errors="replace").lower()
        risky_tokens = [
            "update items",
            "update spells_new",
            "update doors",
            "update zone_points",
            "delete from",
            "drop table",
        ]
        for token in risky_tokens:
            if token in text:
                fail(f"safe migration contains risky token '{token}': {sql_file}")

    # This verifier is meant to run from a clean source checkout, not a generated build tree bundle.
    for rel in FORBIDDEN_DIRS:
        if (ROOT / rel).exists():
            fail(f"generated/dependency directory should not be part of this slice: {rel}")

    print("Recovery Slice v2 verification passed.")


if __name__ == "__main__":
    main()
