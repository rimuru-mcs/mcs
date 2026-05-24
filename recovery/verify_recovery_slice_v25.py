#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
required = [
    ROOT / "recovery" / "patch_embperl_strings_include.py",
    ROOT / "docs" / "recovery" / "RECOVERY_SLICE_V25_LINUX_EMBPERL_STRINGS_INCLUDE.md",
]
missing = [str(p.relative_to(ROOT)) for p in required if not p.exists()]
if missing:
    raise SystemExit("Recovery Slice v25 verification failed; missing: " + ", ".join(missing))

embperl = ROOT / "zone" / "embperl.cpp"
if embperl.exists():
    text = embperl.read_text(encoding="utf-8", errors="replace")
    if 'Strings::Trim' in text and '#include "../common/strings.h"' not in text:
        raise SystemExit("Recovery Slice v25 verification failed: embperl.cpp uses Strings but does not include common/strings.h")

print("Recovery Slice v25 verification passed.")
