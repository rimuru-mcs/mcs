#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "database/recovery/audits/18_permanent_server_buff_activation_test_audit.sql",
    "database/recovery/manual_tests/enable_permanent_server_buffs_dev_only.sql",
    "database/recovery/manual_tests/disable_permanent_server_buffs_dev_only.sql",
    "recovery/set_permanent_server_buffs.sh",
    "recovery/set_permanent_server_buffs.ps1",
    "docs/recovery/RECOVERY_SLICE_V14_PERMANENT_BUFF_ACTIVATION_TEST.md",
]

missing = [p for p in REQUIRED if not (ROOT / p).is_file()]
if missing:
    print("Recovery Slice v14 verification failed: missing files:")
    for p in missing:
        print(f"  - {p}")
    sys.exit(1)

checks = {
    "database/recovery/manual_tests/enable_permanent_server_buffs_dev_only.sql": [
        "Custom:PermanentServerBuffsEnabled",
        "true",
        "dev validation only",
    ],
    "database/recovery/manual_tests/disable_permanent_server_buffs_dev_only.sql": [
        "Custom:PermanentServerBuffsEnabled",
        "false",
    ],
    "recovery/set_permanent_server_buffs.sh": [
        "status|on|off",
        "MSR_ALLOW_ROOT_MIGRATIONS",
        "msr_migrate",
    ],
    "database/recovery/audits/18_permanent_server_buff_activation_test_audit.sql": [
        "runtime_spell_preconditions",
        "44000",
        "44001",
        "44003",
        "44007",
    ],
}

for rel, needles in checks.items():
    text = (ROOT / rel).read_text(encoding="utf-8", errors="replace")
    for needle in needles:
        if needle not in text:
            print(f"Recovery Slice v14 verification failed: {rel} missing required text: {needle}")
            sys.exit(1)

print("Recovery Slice v14 verification passed.")
