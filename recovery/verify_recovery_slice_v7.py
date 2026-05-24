#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/migrations_safe/050_apply_bucket_progression_cap_recovery.sql",
    "database/recovery/audits/11_progression_cap_recovery_audit.sql",
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql",
    "database/recovery/migrations_pending/070_review_progression_cap_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V7_BUCKET_PROGRESSION_CAP.md",
]

REQUIRED_SNIPPETS = {
    "database/recovery/migrations_safe/050_apply_bucket_progression_cap_recovery.sql": [
        "050_apply_bucket_progression_cap_recovery.sql",
        "Character:PerCharacterBucketMaxLevel",
        "Character:PerCharacterQglobalMaxLevel",
        "FROM `rule_sets`",
        "data_buckets",
        "quest_globals",
    ],
    "database/recovery/audits/11_progression_cap_recovery_audit.sql": [
        "11_progression_cap_recovery",
        "rulesets_bucket_cap_enabled",
        "rulesets_qglobal_cap_disabled",
        "LEVEL_ABOVE_BUCKET_CAP",
        "050_apply_bucket_progression_cap_recovery.sql",
    ],
    "database/recovery/migrations_pending/070_review_progression_cap_candidates.sql": [
        "PROMOTED TO SAFE MIGRATION IN SLICE V7",
        "data_buckets",
        "quest_globals",
        "Candidate B remains rejected",
    ],
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql": [
        "PROMOTED TO SAFE MIGRATION IN SLICE V7",
        "bucket-backed progression max-level enforcement",
    ],
    "docs/recovery/RECOVERY_SLICE_V7_BUCKET_PROGRESSION_CAP.md": [
        "Bucket Progression Cap Recovery",
        "Character:PerCharacterBucketMaxLevel  = true",
        "Character:PerCharacterQglobalMaxLevel = false",
    ],
}

errors = []

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.exists():
        errors.append(f"Missing required file: {rel}")

for rel, snippets in REQUIRED_SNIPPETS.items():
    path = ROOT / rel
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8", errors="replace")
    for snippet in snippets:
        if snippet not in text:
            errors.append(f"Missing snippet in {rel}: {snippet}")

if errors:
    print("Recovery Slice v7 verification failed:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print("Recovery Slice v7 verification passed.")
