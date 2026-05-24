#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/10_progression_cap_storage_audit.sql",
    "database/recovery/migrations_pending/070_review_progression_cap_candidates.sql",
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V6_PROGRESSION_CAP_AUDIT.md",
]

REQUIRED_SNIPPETS = {
    "database/recovery/audits/10_progression_cap_storage_audit.sql": [
        "10_progression_cap_storage",
        "Character:PerCharacterBucketMaxLevel",
        "Character:PerCharacterQglobalMaxLevel",
        "data_buckets",
        "quest_globals",
        "CharMaxLevel",
    ],
    "database/recovery/migrations_pending/070_review_progression_cap_candidates.sql": [
        "DO NOT AUTO-RUN",
        "Candidate A",
        "Candidate B",
        "Do not set Character:MaxLevel here",
    ],
    "database/recovery/migrations_pending/020_review_rules_recovery_candidates.sql": [
        "Slice v6 adds a focused audit",
        "Do not enable both blindly",
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
    print("Recovery Slice v6 verification failed:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print("Recovery Slice v6 verification passed.")
