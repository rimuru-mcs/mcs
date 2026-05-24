#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

required = [
    "docs/recovery/RECOVERY_SLICE_V22_OLD_ZONE_ROUTE_RECOVERY.md",
    "database/recovery/migrations_safe/100_fix_old_lavastorm_nektulos_najena_routes.sql",
    "database/recovery/audits/25_old_zone_route_recovery_audit.sql",
    "database/recovery/migrations_pending/170_review_remaining_old_zone_progression_routes.sql",
]

missing = [p for p in required if not (ROOT / p).is_file()]
if missing:
    print("Recovery Slice v22 verification failed. Missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

migration = (ROOT / "database/recovery/migrations_safe/100_fix_old_lavastorm_nektulos_najena_routes.sql").read_text(encoding="utf-8")
needles = [
    "msr_recovery_old_zone_route_backup",
    "WHERE `id` = 2394",
    "WHERE `id` IN (889, 4502)",
    "WHERE `id` = 2398",
    "WHERE `id` IN (1446, 2302)",
    "WHERE `id` = 2057",
    "preserved version-1 routes",
]
missing_needles = [n for n in needles if n not in migration]
if missing_needles:
    print("Recovery Slice v22 verification failed. Migration missing required text:")
    for n in missing_needles:
        print(f"  - {n}")
    sys.exit(1)

audit = (ROOT / "database/recovery/audits/25_old_zone_route_recovery_audit.sql").read_text(encoding="utf-8")
for n in ["v22_expected_flags", "v22_pok_new_instance_doors_remaining", "v22_version_one_rows_preserved"]:
    if n not in audit:
        print(f"Recovery Slice v22 verification failed. Audit missing {n}")
        sys.exit(1)

print("Recovery Slice v22 verification passed.")
