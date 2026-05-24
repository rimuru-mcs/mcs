#!/usr/bin/env python3
from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
audit = root / "database" / "recovery" / "audits" / "19_defiant_spawn_source_audit.sql"
doc = root / "docs" / "recovery" / "RECOVERY_SLICE_V15_1_DEFIANT_AUDIT_SCHEMA_FIX.md"

missing = [str(p) for p in [audit, doc] if not p.exists()]
if missing:
    print("Recovery Slice v15.1 verification failed. Missing:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

text = audit.read_text(encoding="utf-8")
for forbidden in ("lde.minlevel", "lde.maxlevel", "lde.multiplier"):
    if forbidden in text:
        print(f"Recovery Slice v15.1 verification failed: audit still references {forbidden}")
        sys.exit(1)

for required in ("lootdrop_entries_columns", "defiant_lootdrop_entry_count", "defiant_merchant_entry_count"):
    if required not in text:
        print(f"Recovery Slice v15.1 verification failed: audit missing required marker {required}")
        sys.exit(1)

print("Recovery Slice v15.1 verification passed.")
