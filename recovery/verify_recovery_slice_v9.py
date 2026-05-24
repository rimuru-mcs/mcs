#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/13_targeted_item_recovery_candidates_audit.sql",
    "database/recovery/migrations_pending/080_review_targeted_hero_ring_and_transcendent_bag_candidates.sql",
    "docs/recovery/RECOVERY_SLICE_V9_TARGETED_ITEM_AUDIT.md",
]

def fail(message: str) -> None:
    print(f"Recovery Slice v9 verification failed: {message}", file=sys.stderr)
    sys.exit(1)

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing required file: {rel}")

audit_sql = (ROOT / REQUIRED_FILES[0]).read_text(encoding="utf-8")
required_terms = [
    "Simple Ring of the Hero",
    "Sympathetic Strike I",
    "Transcendent Mage''s Syncrosatchel",
    "Bag Merchant Tunk",
    "READ ONLY",
]

for term in required_terms:
    if term not in audit_sql:
        fail(f"audit SQL missing expected term: {term}")

pending_sql = (ROOT / REQUIRED_FILES[1]).read_text(encoding="utf-8")
if "50,000,000 copper" not in pending_sql:
    fail("pending migration note must preserve copper-price reminder for 50,000 platinum")

print("Recovery Slice v9 verification passed.")
