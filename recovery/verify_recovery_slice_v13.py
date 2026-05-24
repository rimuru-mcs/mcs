#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

checks = [
    (ROOT / "common" / "ruletypes.h", [
        "RULE_BOOL(Custom, PermanentServerBuffsEnabled, false",
    ]),
    (ROOT / "zone" / "client.h", [
        "void ApplyPermanentServerBuffs();",
    ]),
    (ROOT / "zone" / "client_packet.cpp", [
        "kMSRPermanentServerBuffSpellIds[] = { 44000, 44001, 44003, 44007 }",
        "void Client::ApplyPermanentServerBuffs()",
        "RuleB(Custom, PermanentServerBuffsEnabled)",
        "ApplySpellBuff(spell_id, kMSRPermanentServerBuffDuration, GetLevel())",
        "ApplyPermanentServerBuffs();",
    ]),
    (ROOT / "database" / "recovery" / "audits" / "17_global_buff_runtime_implementation_audit.sql", [
        "global_buff_runtime_spell_preconditions",
        "runtime_activation_still_disabled",
    ]),
    (ROOT / "database" / "recovery" / "migrations_pending" / "120_review_enable_permanent_server_buffs.sql", [
        "44000 Echo of Experience",
        "44001 Echo of Power",
        "44003 Echo of Speed",
        "44007 Echo of Luck",
    ]),
    (ROOT / "docs" / "recovery" / "RECOVERY_SLICE_V13_GLOBAL_BUFF_RUNTIME_IMPLEMENTATION.md", [
        "Recovery Slice v13",
        "Custom:PermanentServerBuffsEnabled",
    ]),
]

missing = []
for path, required in checks:
    if not path.exists():
        missing.append(f"missing file: {path.relative_to(ROOT)}")
        continue
    text = path.read_text(errors="replace")
    for needle in required:
        if needle not in text:
            missing.append(f"{path.relative_to(ROOT)} missing required text: {needle}")

if missing:
    print("Recovery Slice v13 verification failed:")
    for item in missing:
        print(f"  - {item}")
    sys.exit(1)

print("Recovery Slice v13 verification passed.")
