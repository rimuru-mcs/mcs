#!/usr/bin/env python3
from pathlib import Path

root = Path(__file__).resolve().parents[1]
client_cpp = root / "zone" / "client.cpp"

def fail(message: str) -> None:
    raise SystemExit(f"Recovery Slice v24 verification failed: {message}")

if not client_cpp.exists():
    fail("zone/client.cpp missing")

text = client_cpp.read_text(errors="replace")

required = [
    "int CountEnabledClassBits(uint32 classes_bits)",
    "classes_bits &= (classes_bits - 1);",
    "int class_count = CountEnabledClassBits(classes_bits);",
]

for needle in required:
    if needle not in text:
        fail(f"zone/client.cpp missing required text: {needle}")

if "__popcnt(classes_bits)" in text:
    fail("zone/client.cpp still uses MSVC-only __popcnt(classes_bits)")

print("Recovery Slice v24 verification passed.")
