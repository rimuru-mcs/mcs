#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

required = [
    "docs/recovery/RECOVERY_SLICE_V21_OLD_ZONE_CLIENT_LOC_VALIDATION.md",
    "database/recovery/manual_tests/old_zone_client_file_checklist.md",
    "database/recovery/manual_tests/old_nektulos_lavastorm_route_validation.tsv",
    "database/recovery/migrations_pending/160_review_old_zone_route_fix_after_validation_report.sql",
]

missing = [p for p in required if not (ROOT / p).is_file()]
if missing:
    print("Recovery Slice v21 verification failed. Missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

tsv = (ROOT / "database/recovery/manual_tests/old_nektulos_lavastorm_route_validation.tsv").read_text(encoding="utf-8")
needles = [
    "NEK-POK-DOOR-NEW",
    "NEK-ECOMMONS-ZP-CLASSIC",
    "LAVA-NEK-ZP-CLASSIC",
    "LAVA-SOLTEMPLE-ZP-OLD-A",
    "CORATHUS-NEK-DOOR-NEW",
]
missing_needles = [n for n in needles if n not in tsv]
if missing_needles:
    print("Recovery Slice v21 verification failed. Validation TSV missing required test rows:")
    for n in missing_needles:
        print(f"  - {n}")
    sys.exit(1)

print("Recovery Slice v21 verification passed.")
