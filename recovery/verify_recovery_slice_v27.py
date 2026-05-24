#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

required = [
    "docs/recovery/RECOVERY_SLICE_V27_START_ZONE_RECOVERY.md",
    "database/recovery/audits/26_start_zone_progression_alignment_audit.sql",
    "database/recovery/migrations_safe/110_gate_revamped_freeport_start_zones.sql",
    "database/recovery/migrations_pending/180_review_expansion_race_start_envelopes.sql",
]

missing = [p for p in required if not (ROOT / p).is_file()]
if missing:
    print("Recovery Slice v27 verification failed. Missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

migration = (ROOT / "database/recovery/migrations_safe/110_gate_revamped_freeport_start_zones.sql").read_text(encoding="utf-8")
for needle in [
    "msr_recovery_start_zone_v27_backup",
    "msr_revamped_freeport_unlocked",
    "freeportwest",
    "freeporteast",
    "383, 384, 385, 386, 387, 388, 389, 390, 391",
    "Do not block expansion-native races/classes",
]:
    if needle not in migration:
        print(f"Recovery Slice v27 verification failed. Migration missing required text: {needle}")
        sys.exit(1)

audit = (ROOT / "database/recovery/audits/26_start_zone_progression_alignment_audit.sql").read_text(encoding="utf-8")
for needle in [
    "v27_revamped_freeport_start_rows",
    "v27_old_freeport_default_start_rows",
    "v27_crescent_reach_start_rows",
    "v27_expansion_race_sanctuary_candidate_rows",
    "v27_characters_in_revamped_freeport",
    "v27_post_migration_active_revamped_freeport_check",
]:
    if needle not in audit:
        print(f"Recovery Slice v27 verification failed. Audit missing required section: {needle}")
        sys.exit(1)

pending = (ROOT / "database/recovery/migrations_pending/180_review_expansion_race_start_envelopes.sql").read_text(encoding="utf-8")
for needle in ["Iksar", "Froglok", "Rathe Mountains", "Field of Bone", "Lake of Ill Omen"]:
    if needle not in pending:
        print(f"Recovery Slice v27 verification failed. Pending review missing doctrine text: {needle}")
        sys.exit(1)

doc = (ROOT / "docs/recovery/RECOVERY_SLICE_V27_START_ZONE_RECOVERY.md").read_text(encoding="utf-8")
for needle in ["default racial cities or Crescent Reach", "msr_revamped_freeport_unlocked", "Does not globally disable expansion-origin races/classes"]:
    if needle not in doc:
        print(f"Recovery Slice v27 verification failed. Doc missing required text: {needle}")
        sys.exit(1)

print("Recovery Slice v27 verification passed.")
