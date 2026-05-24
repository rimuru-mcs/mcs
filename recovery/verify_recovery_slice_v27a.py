#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/27_crescent_start_and_zone_entry_audit.sql",
    "database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql",
    "database/recovery/migrations_pending/181_review_crescent_start_reenable_and_zone_crash.sql",
    "docs/recovery/RECOVERY_SLICE_V27A_CRESCENT_START_HOLD.md",
]

REQUIRED_TEXT = {
    "database/recovery/audits/27_crescent_start_and_zone_entry_audit.sql": [
        "crescent_start_gate_summary",
        "msr_crescent_start_unlocked",
        "characters_currently_in_crescent",
        "intentionally avoids selecting or ordering by start_zones.id",
    ],
    "database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql": [
        "msr_recovery_start_zones_crescent_backup_v27a",
        "msr_crescent_start_unlocked",
        "zone_id = 394",
        "start_zone = 394",
        "natural-key backup matching",
    ],
    "database/recovery/migrations_pending/181_review_crescent_start_reenable_and_zone_crash.sql": [
        "Do NOT apply blindly",
        "msr_crescent_start_unlocked",
    ],
    "docs/recovery/RECOVERY_SLICE_V27A_CRESCENT_START_HOLD.md": [
        "Crescent Reach",
        "SendAlternateAdvancementTable",
        "recovery hold",
    ],
}

FORBIDDEN_TEXT = {
    "database/recovery/audits/27_crescent_start_and_zone_entry_audit.sql": [
        "\n  id,",
        "ORDER BY player_race, player_class, player_deity, id",
    ],
    "database/recovery/migrations_safe/111_gate_crescent_start_zones_for_recovery.sql": [
        "b.id",
        "ON b.id = sz.id",
    ],
}


def main() -> int:
    missing = []
    for rel in REQUIRED_FILES:
        path = ROOT / rel
        if not path.exists():
            missing.append(rel)
            continue

        content = path.read_text(encoding="utf-8", errors="replace")
        for needle in REQUIRED_TEXT.get(rel, []):
            if needle not in content:
                raise SystemExit(f"Recovery Slice v27a verification failed: {rel} missing required text: {needle}")
        for needle in FORBIDDEN_TEXT.get(rel, []):
            if needle in content:
                raise SystemExit(f"Recovery Slice v27a verification failed: {rel} still contains forbidden text: {needle}")

    if missing:
        raise SystemExit("Recovery Slice v27a verification failed: missing files: " + ", ".join(missing))

    print("Recovery Slice v27a verification passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
