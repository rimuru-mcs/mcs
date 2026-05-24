#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/14_global_buff_reconstruction_audit.sql",
    "database/recovery/migrations_pending/090_review_global_buff_reconstruction_candidates.sql",
    "recovery/extract_client_global_buff_rows.py",
    "docs/recovery/RECOVERY_SLICE_V10_GLOBAL_BUFF_RECONSTRUCTION_AUDIT.md",
]

def fail(message: str) -> None:
    print(f"Recovery Slice v10 verification failed: {message}", file=sys.stderr)
    sys.exit(1)

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing required file: {rel}")

audit_sql = (ROOT / REQUIRED_FILES[0]).read_text(encoding="utf-8")
for term in [
    "44000",
    "44007",
    "Echo of Power",
    "Custom:PermanentServerBuffsEnabled",
    "READ ONLY",
    "information_schema",
]:
    if term not in audit_sql:
        fail(f"audit SQL missing expected term: {term}")

extractor = (ROOT / REQUIRED_FILES[2]).read_text(encoding="utf-8")
for term in [
    "TARGET_IDS",
    "spells_us.txt",
    "global_buff_client_spell_rows.tsv",
    "zipfile",
]:
    if term not in extractor:
        fail(f"extractor missing expected term: {term}")

pending_sql = (ROOT / REQUIRED_FILES[1]).read_text(encoding="utf-8")
if "Do NOT enable" not in pending_sql:
    fail("pending note must explicitly warn not to enable server buffs yet")

print("Recovery Slice v10 verification passed.")
