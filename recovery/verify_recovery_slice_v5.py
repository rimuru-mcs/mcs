#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/migrations_safe/040_apply_corpse_run_and_ruleset_coverage_recovery.sql",
    "database/recovery/audits/09_corpse_and_ruleset_coverage_audit.sql",
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V5_CORPSE_RULESET_RECOVERY.md",
]

REQUIRED_SNIPPETS = {
    "database/recovery/migrations_safe/040_apply_corpse_run_and_ruleset_coverage_recovery.sql": [
        "Character:LeaveCorpses",
        "Character:LeaveNakedCorpses",
        "Character:DeathItemLossLevel",
        "Combat:MinRangedAttackDist",
        "040_apply_corpse_run_and_ruleset_coverage_recovery.sql",
    ],
    "database/recovery/audits/09_corpse_and_ruleset_coverage_audit.sql": [
        "09_corpse_and_ruleset_coverage",
        "leave_corpses",
        "min_ranged_attack_dist",
        "msr_recovery_migration_log",
    ],
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql": [
        "PROMOTED TO SAFE MIGRATION IN SLICE V5",
        "Progression max-level enforcement remains pending",
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
    print("Recovery Slice v5 verification failed:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print("Recovery Slice v5 verification passed.")
