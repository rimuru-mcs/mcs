#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/migrations_safe/020_apply_safe_rule_recovery_defaults.sql",
    "database/recovery/migrations_safe/030_apply_syncrosatchel_price_recovery.sql",
    "database/recovery/audits/08_safe_rule_and_syncrosatchel_recovery_audit.sql",
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql",
    "database/recovery/migrations_pending/050_review_syncrosatchel_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V4_SAFE_DB_FIXES.md",
]

REQUIRED_SNIPPETS = {
    "database/recovery/migrations_safe/020_apply_safe_rule_recovery_defaults.sql": [
        "World:EnableTutorialButton",
        "Spells:UseSpellImpliedTargeting",
        "Combat:MinRangedAttackDist",
        "020_apply_safe_rule_recovery_defaults.sql",
    ],
    "database/recovery/migrations_safe/030_apply_syncrosatchel_price_recovery.sql": [
        "Expanded %Syncrosatchel%",
        "5000000",
        "030_apply_syncrosatchel_price_recovery.sql",
    ],
    "database/recovery/audits/08_safe_rule_and_syncrosatchel_recovery_audit.sql": [
        "08_safe_rule_and_syncrosatchel_recovery",
        "expanded_syncrosatchel_count",
        "msr_recovery_migration_log",
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
    print("Recovery Slice v4 verification failed:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print("Recovery Slice v4 verification passed.")
