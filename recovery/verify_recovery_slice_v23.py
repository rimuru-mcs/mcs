#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
RULETYPES = ROOT / "common" / "ruletypes.h"
PATCHER = ROOT / "recovery" / "patch_ruletypes_linux_compat.py"
DOC = ROOT / "docs" / "recovery" / "RECOVERY_SLICE_V23_LINUX_RULETYPES_COMPAT.md"

REQUIRED = 'RULE_BOOL(Custom, IgnoreAALevelRequirements, false, "Ignore AA level requirements for custom multiclass recovery behavior.")'

def main() -> int:
    missing = [str(p.relative_to(ROOT)) for p in (PATCHER, DOC) if not p.exists()]
    if missing:
        print("Recovery Slice v23 verification failed: missing files: " + ", ".join(missing), file=sys.stderr)
        return 1

    if not RULETYPES.exists():
        print("Recovery Slice v23 verification failed: common/ruletypes.h not found.", file=sys.stderr)
        return 1

    text = RULETYPES.read_text(encoding="utf-8", errors="replace")
    if REQUIRED not in text:
        print("Recovery Slice v23 verification failed: common/ruletypes.h has not been patched yet.", file=sys.stderr)
        print("Run: python3 recovery/patch_ruletypes_linux_compat.py", file=sys.stderr)
        return 1

    print("Recovery Slice v23 verification passed.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
