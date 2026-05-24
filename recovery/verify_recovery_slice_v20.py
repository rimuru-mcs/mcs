#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

required = [
    "docs/recovery/RECOVERY_SLICE_V20_OLD_ZONE_ROUTE_TEST_SCAFFOLD.md",
    "database/recovery/audits/24_old_zone_route_fix_readiness_audit.sql",
    "database/recovery/migrations_pending/150_review_old_nektulos_lavastorm_route_fix_after_client_loc.sql",
]

missing = [p for p in required if not (ROOT / p).is_file()]
if missing:
    print("Recovery Slice v20 verification failed. Missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

audit = (ROOT / "database/recovery/audits/24_old_zone_route_fix_readiness_audit.sql").read_text(encoding="utf-8")
needles = [
    "zone_points_targeting_new_versions",
    "doors_targeting_new_versions",
    "poknowledge_target_doors",
    "manual_test_required",
]
missing_needles = [n for n in needles if n not in audit]
if missing_needles:
    print("Recovery Slice v20 verification failed. Audit missing required text:")
    for n in missing_needles:
        print(f"  - {n}")
    sys.exit(1)

print("Recovery Slice v20 verification passed.")
