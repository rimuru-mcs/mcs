#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/migrations_safe/060_apply_sympathetic_level_gate_recovery.sql",
    "database/recovery/audits/12_sympathetic_level_gate_recovery_audit.sql",
    "database/recovery/migrations_pending/060_review_sympathetic_item_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V8_SYMPATHETIC_LEVEL_GATE.md",
]

REQUIRED_SNIPPETS = {
    "database/recovery/migrations_safe/060_apply_sympathetic_level_gate_recovery.sql": [
        "060_apply_sympathetic_level_gate_recovery.sql",
        "msr_recovery_sympathetic_spell_ids",
        "LIKE '%Sympathetic%'",
        "proclevel",
        "wornlevel",
        "focuslevel",
        "Required/recommended levels and Simple Ring of the Hero were intentionally not changed",
    ],
    "database/recovery/audits/12_sympathetic_level_gate_recovery_audit.sql": [
        "12_sympathetic_level_gate_recovery",
        "sympathetic_items_with_level_gates_after",
        "Simple Ring of the Hero",
        "060_apply_sympathetic_level_gate_recovery.sql",
    ],
    "database/recovery/migrations_pending/060_review_sympathetic_item_candidates.sql": [
        "PROMOTED TO SAFE MIGRATION IN SLICE V8",
        "Simple Ring of the Hero needs a separate targeted audit/migration",
    ],
    "docs/recovery/RECOVERY_SLICE_V8_SYMPATHETIC_LEVEL_GATE.md": [
        "Sympathetic Item Level Gate Recovery",
        "reqlevel",
        "Simple Ring of the Hero",
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
    print("Recovery Slice v8 verification failed:")
    for error in errors:
        print(f"  - {error}")
    sys.exit(1)

print("Recovery Slice v8 verification passed.")
