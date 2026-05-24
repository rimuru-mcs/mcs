#!/usr/bin/env python3
from pathlib import Path
import sys

repo = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/opt/msr/repo/msr")
target = repo / "zone" / "tribute.cpp"

if not target.exists():
    raise SystemExit(f"Recovery Slice v28 verification failed: missing {target}")

text = target.read_text()

required = [
    "void Client::SendGuildTributes",
    "MSR recovery v28 guard: skip guild tribute packet during zone-entry crash recovery",
    "return;",
]

missing = [needle for needle in required if needle not in text]
if missing:
    raise SystemExit(
        "Recovery Slice v28 verification failed: zone/tribute.cpp missing required text: "
        + ", ".join(missing)
    )

fn_pos = text.find("void Client::SendGuildTributes")
guard_pos = text.find("MSR recovery v28 guard: skip guild tribute packet during zone-entry crash recovery")
if guard_pos < fn_pos:
    raise SystemExit("Recovery Slice v28 verification failed: guard appears before function")

print("Recovery Slice v28 guild tribute guard verification passed.")
