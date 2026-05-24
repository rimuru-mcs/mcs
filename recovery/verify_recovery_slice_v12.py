#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/audits/16_global_buff_runtime_readiness_audit.sql",
    "database/recovery/migrations_pending/110_review_global_buff_runtime_code_path.sql",
    "docs/recovery/RECOVERY_SLICE_V12_GLOBAL_BUFF_RUNTIME_AUDIT.md",
    "recovery/audit_global_buff_runtime_code.py",
]


def fail(message: str) -> None:
    print(f"Recovery Slice v12 verification failed: {message}", file=sys.stderr)
    sys.exit(1)


for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing required file: {rel}")

audit_sql = (ROOT / REQUIRED_FILES[0]).read_text(encoding="utf-8")
pending = (ROOT / REQUIRED_FILES[1]).read_text(encoding="utf-8")
script = (ROOT / REQUIRED_FILES[3]).read_text(encoding="utf-8")

for needle in [
    "16_global_buff_runtime_readiness",
    "spell_row_preconditions",
    "activation_rule_safety",
    "Custom:PermanentServerBuffsEnabled",
    "44000",
    "44007",
]:
    if needle not in audit_sql:
        fail(f"DB audit missing required text: {needle}")

if "Do NOT promote" not in pending or "Custom:PermanentServerBuffsEnabled=true" not in pending:
    fail("pending runtime note must forbid enabling the buff rule yet")

for needle in [
    "Custom:PermanentServerBuffsEnabled",
    "PermanentServerBuffsEnabled",
    "4400[0-7]",
    "Echo of (Experience|Power|Statistics|Speed|Mana|Haste|Health|Luck)",
    "code_audit_output",
    "global_buff_runtime_code_audit.txt",
    "global_buff_runtime_code_audit.json",
]:
    if needle not in script:
        fail(f"runtime code audit script missing required text: {needle}")

print("Recovery Slice v12 verification passed.")
