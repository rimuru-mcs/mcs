#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
RULETYPES = ROOT / "common" / "ruletypes.h"

OLD = "RULE_BOOL(Custom, IgnoreAALevelRequirements, false)"
NEW = 'RULE_BOOL(Custom, IgnoreAALevelRequirements, false, "Ignore AA level requirements for custom multiclass recovery behavior.")'

def main() -> int:
    if not RULETYPES.exists():
        print(f"Missing file: {RULETYPES}", file=sys.stderr)
        return 1

    text = RULETYPES.read_text(encoding="utf-8", errors="replace")

    if NEW in text:
        print("ruletypes.h already contains the Linux-compatible IgnoreAALevelRequirements rule.")
        return 0

    if OLD not in text:
        print("Could not find the expected 3-argument IgnoreAALevelRequirements rule.", file=sys.stderr)
        print("Please inspect common/ruletypes.h around the Custom rule block.", file=sys.stderr)
        return 1

    text = text.replace(OLD, NEW, 1)
    RULETYPES.write_text(text, encoding="utf-8", newline="\n")
    print("Patched common/ruletypes.h: added required rule notes argument for IgnoreAALevelRequirements.")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
