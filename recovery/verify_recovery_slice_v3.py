#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

required = [
    "recovery/apply_db_migrations.sh",
    "recovery/apply_db_migrations.ps1",
    "database/recovery/audits/07_recovery_migration_log_audit.sql",
    "docs/recovery/RECOVERY_SLICE_V3_SAFE_DB_APPLY.md",
]

missing = [p for p in required if not (ROOT / p).exists()]
if missing:
    print("Recovery Slice v3 verification failed. Missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

sh = (ROOT / "recovery/apply_db_migrations.sh").read_text(encoding="utf-8")
ps = (ROOT / "recovery/apply_db_migrations.ps1").read_text(encoding="utf-8")
audit = (ROOT / "database/recovery/audits/07_recovery_migration_log_audit.sql").read_text(encoding="utf-8")

checks = [
    ("msr_migrate", sh, "Linux migration runner should default to msr_migrate"),
    ("msr_world_recovery", sh, "Linux migration runner should default to msr_world_recovery"),
    ("Refusing to run migrations as root", sh, "Linux migration runner should refuse root by default"),
    ("--dry-run", sh, "Linux migration runner should support dry run"),
    ("msr_migrate", ps, "PowerShell migration runner should default to msr_migrate"),
    ("msr_world_recovery", ps, "PowerShell migration runner should default to msr_world_recovery"),
    ("Refusing to run migrations as root", ps, "PowerShell migration runner should refuse root by default"),
    ("msr_recovery_migration_log", audit, "Audit 07 should inspect migration log"),
    ("Custom:PermanentServerBuffsEnabled", audit, "Audit 07 should inspect the neutral buff placeholder"),
]

failed = [message for needle, haystack, message in checks if needle not in haystack]
if failed:
    print("Recovery Slice v3 verification failed:")
    for message in failed:
        print(f"  - {message}")
    sys.exit(1)

print("Recovery Slice v3 verification passed.")
