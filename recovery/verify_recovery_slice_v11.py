#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = [
    "database/recovery/migrations_safe/070_apply_global_buff_spell_row_reconstruction.sql",
    "database/recovery/audits/15_global_buff_spell_row_recovery_audit.sql",
    "database/recovery/migrations_pending/100_review_global_buff_runtime_activation.sql",
    "docs/recovery/RECOVERY_SLICE_V11_GLOBAL_BUFF_SPELL_ROWS.md",
]

def fail(message: str) -> None:
    print(f"Recovery Slice v11 verification failed: {message}", file=sys.stderr)
    sys.exit(1)

for rel in REQUIRED_FILES:
    path = ROOT / rel
    if not path.is_file():
        fail(f"missing required file: {rel}")

migration = (ROOT / REQUIRED_FILES[0]).read_text(encoding="utf-8")
audit = (ROOT / REQUIRED_FILES[1]).read_text(encoding="utf-8")
pending = (ROOT / REQUIRED_FILES[2]).read_text(encoding="utf-8")

for spell_id in range(44000, 44008):
    if str(spell_id) not in migration:
        fail(f"migration missing spell ID {spell_id}")

for name in [
    "Echo of Experience",
    "Echo of Power",
    "Echo of Statistics",
    "Echo of Speed",
    "Echo of Mana",
    "Echo of Haste",
    "Echo of Health",
    "Echo of Luck",
]:
    if name not in migration:
        fail(f"migration missing recovered spell name: {name}")

if "Custom:PermanentServerBuffsEnabled" not in migration:
    fail("migration must keep permanent server buff rule explicit")

if "`rule_value` = 'false'" not in migration and "'false'" not in migration:
    fail("migration must keep permanent server buffs disabled")

if "CREATE TEMPORARY TABLE `msr_recovery_global_buff_spell_rows`" not in migration:
    fail("migration must use a temporary recovery table")

if "WHERE NOT EXISTS" not in migration:
    fail("migration must insert missing rows without overwriting existing rows")

if "070_apply_global_buff_spell_row_reconstruction.sql" not in migration:
    fail("migration ledger name missing")

if "global_buff_rows_present" not in audit:
    fail("audit must summarize recovered global buff rows")

if "Do NOT set Custom:PermanentServerBuffsEnabled=true" not in pending:
    fail("pending activation note must explicitly forbid enabling runtime buffs yet")

# Check that the recovered INSERT row width matches the known spells_new schema width.
# Count the value row opening parens in VALUES and ensure at least 8 spell rows exist.
values_section = migration.split("VALUES", 1)[1].split("SET @msr_global_buff_rows_before", 1)[0]
row_count = len(re.findall(r"\n  \(", values_section))
if row_count != 8:
    fail(f"expected 8 recovered spell rows, found {row_count}")

print("Recovery Slice v11 verification passed.")
