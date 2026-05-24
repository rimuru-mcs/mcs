#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "zone" / "embperl.cpp"
INCLUDE = '#include "../common/strings.h"'
ANCHOR = '#include "../common/file.h"'

if not TARGET.exists():
    raise SystemExit(f"Missing target file: {TARGET}")

text = TARGET.read_text(encoding="utf-8", errors="replace")
if INCLUDE in text:
    print("embperl.cpp already includes strings.h")
    raise SystemExit(0)

if ANCHOR not in text:
    raise SystemExit(f"Could not find include anchor in {TARGET}: {ANCHOR}")

text = text.replace(ANCHOR, f"{ANCHOR}\n{INCLUDE}", 1)
TARGET.write_text(text, encoding="utf-8", newline="")
print("Patched zone/embperl.cpp with common/strings.h include")
